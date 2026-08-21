import Foundation
import Combine

/// Vom Nutzer im Wörterbuch gespeicherte Wörter — der Wachstums-Kreislauf der App:
/// Einmal online nachschlagen → dauerhaft eigene Lernkarte in allen Quiz-Modi.
struct MyWord: Codable, Identifiable, Equatable {
    let de: String
    let vi: String
    var art: String?      // der/die/das (von Wiktionary)
    var plural: String?
    var exDe: String?     // Beispielsatz (von Tatoeba)
    var exVi: String?
    let added: Date
    var id: String { de.lowercased() + "|" + vi.lowercased() }
}

@MainActor
final class MyWords: ObservableObject {
    static let shared = MyWords()
    private static let key = "caunoi.mywords.v1"

    @Published private(set) var items: [MyWord] = []

    private init() {
        if let d = UserDefaults.standard.data(forKey: Self.key),
           let list = try? JSONDecoder().decode([MyWord].self, from: d) {
            items = list
        }
        #if DEBUG
        if UserDefaults.standard.bool(forKey: "seedmyword"), items.isEmpty {
            items = [MyWord(de: "Bäckerei", vi: "tiệm bánh mì", art: "die", plural: "Bäckereien",
                            exDe: "Die Bäckerei öffnet um sechs Uhr.",
                            exVi: "Tiệm bánh mì mở cửa lúc sáu giờ.", added: Date())]
        }
        #endif
    }

    /// Aus einem Wörterbuch-Treffer übernehmen. false = war schon da.
    @discardableResult
    func add(from e: DictEntry) -> Bool {
        let de = (e.from == "de" ? e.q : e.main).trimmingCharacters(in: .whitespaces)
        let vi = (e.from == "de" ? e.main : e.q).trimmingCharacters(in: .whitespaces)
        guard !de.isEmpty, !vi.isEmpty else { return false }
        let w = MyWord(de: de, vi: vi, art: e.art, plural: e.plural,
                       exDe: e.exDe, exVi: e.exVi, added: Date())
        guard !items.contains(where: { $0.id == w.id }),
              !GermanData.words.contains(where: { $0.de.lowercased() == de.lowercased() })
        else { return false }
        items.insert(w, at: 0)
        save()
        return true
    }

    func contains(_ e: DictEntry) -> Bool {
        let de = (e.from == "de" ? e.q : e.main).lowercased()
        let vi = (e.from == "de" ? e.main : e.q).lowercased()
        return items.contains { $0.id == de + "|" + vi }
            || GermanData.words.contains { $0.de.lowercased() == de }
    }

    func remove(_ w: MyWord) {
        items.removeAll { $0.id == w.id }
        save()
    }

    private func save() {
        if let d = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(d, forKey: Self.key)
        }
    }

    // ── Brücken in die Quiz-Pools ──
    static let catVi = "Từ của tôi"
    static let catDe = "Meine Wörter"

    var asGWords: [GWord] {
        items.map { GWord(de: $0.de, art: $0.art, pl: $0.plural, vi: $0.vi, cat: Self.catVi, note: "") }
    }
    var asGNouns: [GWord] { asGWords.filter { $0.art != nil } }
    var asVWords: [VWord] {
        items.map { VWord(v: $0.vi, de: $0.de, cat: Self.catDe, note: "") }
    }
    var asVTone: [VWord] { asVWords.filter { !$0.v.contains(" ") } }

    func example(de: String) -> (de: String, vi: String)? {
        guard let w = items.first(where: { $0.de == de }),
              let d = w.exDe, let v = w.exVi else { return nil }
        return (d, v)
    }
}
