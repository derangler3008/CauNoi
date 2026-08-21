import Foundation
import Combine

/// Zentrale, abgesicherte Netzschicht — die EINZIGE Stelle der App, die ins
/// Internet darf. Nur ausgehende HTTPS-GETs an bekannte Hosts; die App
/// öffnet selbst niemals einen Port und nimmt keine Verbindungen an.
enum Net {
    /// Erlaubte Quellen — neue Quellen bewusst hier eintragen, nirgendwo sonst.
    static let allowedHosts: Set<String> = [
        "api.mymemory.translated.net",  // Übersetzung
        "de.wiktionary.org",            // Artikel & Plural
        "api.tatoeba.org"               // Beispielsätze
    ]
    static let maxResponseBytes = 512 * 1024

    enum NetError: Error { case forbiddenHost, badStatus, tooLarge }

    private static let session: URLSession = {
        let c = URLSessionConfiguration.ephemeral   // keine Cookies, kein Tracking-Speicher
        c.timeoutIntervalForRequest = 12
        c.timeoutIntervalForResource = 25
        return URLSession(configuration: c)
    }()

    /// Nur HTTPS, nur Allowlist-Hosts, nur 2xx, begrenzte Antwortgröße.
    static func fetch(_ url: URL) async throws -> Data {
        guard url.scheme == "https", let host = url.host, allowedHosts.contains(host) else {
            throw NetError.forbiddenHost
        }
        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NetError.badStatus
        }
        guard data.count <= maxResponseBytes else { throw NetError.tooLarge }
        return data
    }

    /// Suchbegriff säubern: Steuerzeichen raus, Länge begrenzen.
    static func cleanQuery(_ s: String) -> String {
        String(s.trimmingCharacters(in: .whitespacesAndNewlines)
            .filter { !$0.isNewline && !$0.unicodeScalars.contains { $0.properties.generalCategory == .control } }
            .prefix(60))
    }

    /// Fremdtext fürs Anzeigen säubern: HTML-Tags und Wiki-Reste raus,
    /// Whitespace normalisieren, Länge begrenzen. SwiftUI-Text führt ohnehin
    /// nichts aus — das hier verhindert zusätzlich Anzeige-Müll.
    static func cleanDisplay(_ s: String, max: Int = 160) -> String {
        var t = s.replacingOccurrences(of: "<[^>]*>", with: " ", options: .regularExpression)
        t = t.replacingOccurrences(of: "[{}\\[\\]|]", with: " ", options: .regularExpression)
        t = t.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        return String(t.trimmingCharacters(in: .whitespaces).prefix(max))
    }
}

/// Online-Wörterbuch (MyMemory, kostenlos, ohne Schlüssel) mit lokalem Cache.
/// Jede erfolgreiche Suche wird gespeichert und ist danach offline verfügbar —
/// so wächst die App mit, sobald jemand im Internet ist.
struct DictEntry: Codable, Identifiable, Equatable {
    let q: String          // Suchwort
    let from: String       // "de" | "vi"
    let to: String
    let main: String       // beste Übersetzung
    let alts: [String]     // weitere Treffer
    let date: Date
    // Anreicherung — Wiktionary (Grammatik) und Tatoeba (Beispielsatz):
    var art: String?       // der/die/das des deutschen Worts
    var plural: String?    // Nominativ Plural
    var exDe: String?      // Beispielsatz Deutsch
    var exVi: String?      // Übersetzung Vietnamesisch
    var id: String { "\(from)>\(to):\(q.lowercased())" }

    /// Das deutsche Wort des Eintrags (Suchwort oder Ergebnis).
    var deWord: String { from == "de" ? q : main }
}

@MainActor
final class Dict: ObservableObject {
    static let shared = Dict()
    private static let cacheKey = "caunoi.dict.cache.v1"
    private static let cacheLimit = 200

    @Published private(set) var history: [DictEntry] = []

    private init() {
        if let d = UserDefaults.standard.data(forKey: Self.cacheKey),
           let h = try? JSONDecoder().decode([DictEntry].self, from: d) {
            history = h
        }
    }

    enum DictError: Error { case offline, badResponse, empty }

    func cached(_ q: String, from: String, to: String) -> DictEntry? {
        let key = "\(from)>\(to):\(q.lowercased().trimmingCharacters(in: .whitespaces))"
        return history.first { $0.id == key }
    }

    func lookup(_ rawQ: String, from: String, to: String) async throws -> DictEntry {
        let q = Net.cleanQuery(rawQ)
        guard !q.isEmpty else { throw DictError.empty }
        if let hit = cached(q, from: from, to: to) { return hit }

        var comps = URLComponents(string: "https://api.mymemory.translated.net/get")!
        comps.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "langpair", value: "\(from)|\(to)")
        ]
        let data: Data
        do {
            data = try await Net.fetch(comps.url!)
        } catch {
            throw DictError.offline
        }

        struct MM: Decodable {
            struct RD: Decodable { let translatedText: String }
            struct Match: Decodable { let translation: String? }
            let responseData: RD
            let matches: [Match]?
        }
        guard let mm = try? JSONDecoder().decode(MM.self, from: data) else {
            throw DictError.badResponse
        }
        let main = Net.cleanDisplay(mm.responseData.translatedText, max: 120)
        guard !main.isEmpty else { throw DictError.empty }

        var seen = Set([main.lowercased(), q.lowercased()])
        var alts: [String] = []
        for m in mm.matches ?? [] {
            guard let t = m.translation.map({ Net.cleanDisplay($0, max: 120) }), !t.isEmpty else { continue }
            if seen.insert(t.lowercased()).inserted { alts.append(t) }
            if alts.count == 3 { break }
        }

        var entry = DictEntry(q: q, from: from, to: to, main: main, alts: alts, date: Date())

        // Anreicherung: nur für einzelne deutsche Wörter, Fehler werden still toleriert.
        let deWord = entry.deWord.trimmingCharacters(in: .whitespaces)
        if !deWord.isEmpty, !deWord.contains(" ") {
            async let grammar = try? Self.fetchGrammar(deWord)
            async let example = try? Self.fetchExample(deWord)
            if let g = await grammar { entry.art = g.art; entry.plural = g.plural }
            if let e = await example { entry.exDe = e.de; entry.exVi = e.vi }
        }

        history.removeAll { $0.id == entry.id }
        history.insert(entry, at: 0)
        if history.count > Self.cacheLimit { history = Array(history.prefix(Self.cacheLimit)) }
        save()
        return entry
    }

    /// de.wiktionary: Genus + Plural aus der Substantiv-Übersicht.
    private static func fetchGrammar(_ word: String) async throws -> (art: String?, plural: String?) {
        var c = URLComponents(string: "https://de.wiktionary.org/w/api.php")!
        c.queryItems = [
            URLQueryItem(name: "action", value: "query"),
            URLQueryItem(name: "titles", value: word),
            URLQueryItem(name: "prop", value: "revisions"),
            URLQueryItem(name: "rvprop", value: "content"),
            URLQueryItem(name: "rvslots", value: "main"),
            URLQueryItem(name: "redirects", value: "1"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "formatversion", value: "2")
        ]
        let data = try await Net.fetch(c.url!)
        struct W: Decodable {
            struct Q: Decodable { let pages: [P] }
            struct P: Decodable { let revisions: [R]? }
            struct R: Decodable { let slots: [String: S] }
            struct S: Decodable { let content: String }
            let query: Q
        }
        guard let text = (try? JSONDecoder().decode(W.self, from: data))?
            .query.pages.first?.revisions?.first?.slots["main"]?.content else { return (nil, nil) }
        // Nur der deutsche Abschnitt (die Seite kann weitere Sprachen enthalten).
        let sect = text.components(separatedBy: "({{Sprache|").count > 1
            ? "({{Sprache|" + text.components(separatedBy: "({{Sprache|")[1] : text
        var art: String? = nil
        if let m = sect.range(of: #"Genus(?: \d)?=([mfn])"#, options: .regularExpression) {
            switch sect[sect.index(before: m.upperBound)] {
            case "m": art = "der"
            case "f": art = "die"
            default:  art = "das"
            }
        }
        var plural: String? = nil
        if let m = sect.range(of: #"Nominativ Plural(?: \d)?=([^\n|}]+)"#, options: .regularExpression) {
            let raw = String(sect[m.lowerBound..<m.upperBound])
            let v = raw.components(separatedBy: "=").dropFirst().joined(separator: "=")
                .trimmingCharacters(in: .whitespaces)
            let strict = String(v.filter { $0.isLetter || $0 == "-" || $0 == " " }.prefix(40))
                .trimmingCharacters(in: .whitespaces)
            if let first = strict.first, first.isLetter { plural = strict }
        }
        return (art, plural)
    }

    /// Tatoeba: kürzestes deutsches Beispiel mit vietnamesischer Übersetzung.
    private static func fetchExample(_ word: String) async throws -> (de: String, vi: String)? {
        var c = URLComponents(string: "https://api.tatoeba.org/unstable/sentences")!
        c.queryItems = [
            URLQueryItem(name: "lang", value: "deu"),
            URLQueryItem(name: "q", value: word),
            URLQueryItem(name: "trans:lang", value: "vie"),
            URLQueryItem(name: "sort", value: "relevance"),
            URLQueryItem(name: "limit", value: "10")
        ]
        let data = try await Net.fetch(c.url!)
        struct T: Decodable { let data: [Sent] }
        struct Sent: Decodable { let text: String; let translations: [Flex] }
        struct Tr: Decodable { let lang: String?; let text: String? }
        enum Flex: Decodable {
            case one(Tr), many([Tr])
            var all: [Tr] {
                switch self { case .one(let t): return [t]; case .many(let a): return a }
            }
            init(from d: Decoder) throws {
                if let a = try? [Tr](from: d) { self = .many(a) }
                else { self = .one(try Tr(from: d)) }
            }
        }
        guard let resp = try? JSONDecoder().decode(T.self, from: data) else { return nil }
        let pairs: [(de: String, vi: String)] = resp.data.compactMap { s in
            let vi = s.translations.flatMap(\.all).first { $0.lang == "vie" && !($0.text ?? "").isEmpty }
            guard let v = vi?.text, s.text.count < 90 else { return nil }
            return (Net.cleanDisplay(s.text, max: 140), Net.cleanDisplay(v, max: 140))
        }
        return pairs.min { $0.de.count < $1.de.count }
    }

    private func save() {
        if let d = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(d, forKey: Self.cacheKey)
        }
    }
}
