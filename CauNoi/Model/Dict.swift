import Foundation
import Combine

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
    var id: String { "\(from)>\(to):\(q.lowercased())" }
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
        let q = rawQ.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { throw DictError.empty }
        if let hit = cached(q, from: from, to: to) { return hit }

        var comps = URLComponents(string: "https://api.mymemory.translated.net/get")!
        comps.queryItems = [
            URLQueryItem(name: "q", value: q),
            URLQueryItem(name: "langpair", value: "\(from)|\(to)")
        ]
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 12
        let session = URLSession(configuration: cfg)

        let data: Data
        do {
            (data, _) = try await session.data(from: comps.url!)
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
        let main = mm.responseData.translatedText.trimmingCharacters(in: .whitespaces)
        guard !main.isEmpty else { throw DictError.empty }

        var seen = Set([main.lowercased(), q.lowercased()])
        var alts: [String] = []
        for m in mm.matches ?? [] {
            guard let t = m.translation?.trimmingCharacters(in: .whitespaces), !t.isEmpty else { continue }
            if seen.insert(t.lowercased()).inserted { alts.append(t) }
            if alts.count == 3 { break }
        }

        let entry = DictEntry(q: q, from: from, to: to, main: main, alts: alts, date: Date())
        history.removeAll { $0.id == entry.id }
        history.insert(entry, at: 0)
        if history.count > Self.cacheLimit { history = Array(history.prefix(Self.cacheLimit)) }
        save()
        return entry
    }

    private func save() {
        if let d = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(d, forKey: Self.cacheKey)
        }
    }
}
