import Foundation
import Combine

/// Lernfortschritt — lokal in UserDefaults, ein Eintrag pro Karte.
/// Ein Wort „sitzt“ ab Stufe 3 (dreimal öfter richtig als falsch).
final class Progress: ObservableObject {
    static let shared = Progress()
    private static let key = "caunoi.progress.v1"

    struct Item: Codable { var s: Int; var t: Date }
    private struct Blob: Codable {
        var items: [String: Item]
        var day: String
        var today: Int
        var streak: Int
    }

    @Published private(set) var items: [String: Item] = [:]
    @Published private(set) var today = 0
    @Published private(set) var streak = 0
    private var day = ""

    private init() {
        if let d = UserDefaults.standard.data(forKey: Self.key),
           let b = try? JSONDecoder().decode(Blob.self, from: d) {
            items = b.items; day = b.day; today = b.today; streak = b.streak
        }
        tickDay()
    }

    private func save() {
        let b = Blob(items: items, day: day, today: today, streak: streak)
        if let d = try? JSONEncoder().encode(b) {
            UserDefaults.standard.set(d, forKey: Self.key)
        }
    }

    private static func dayString(_ date: Date = Date()) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func tickDay() {
        let t = Self.dayString()
        guard day != t else { return }
        let yesterday = Self.dayString(Date(timeIntervalSinceNow: -86400))
        streak = (day == yesterday) ? streak + 1 : 1
        day = t; today = 0
        save()
    }

    func score(_ k: String) -> Int { items[k]?.s ?? 0 }

    func record(_ k: String, right: Bool) {
        var it = items[k] ?? Item(s: 0, t: .distantPast)
        it.s = right ? min(5, it.s + 1) : max(0, it.s - 1)
        it.t = Date()
        items[k] = it
        tickDay()
        today += 1
        save()
    }

    /// Gewichtete Auswahl: schwache und lange nicht gesehene Karten zuerst.
    func pick<T>(_ pool: [T], key: (T) -> String, avoid: String? = nil) -> T {
        let now = Date()
        var best: T? = nil
        var bestW = -Double.infinity
        for it in pool {
            let k = key(it)
            if k == avoid && pool.count > 1 { continue }
            let rec = items[k]
            let s = Double(rec?.s ?? 0)
            let ageMin = rec.map { now.timeIntervalSince($0.t) / 60 } ?? 9999
            let w = (6 - s) * (0.4 + min(3, ageMin / 4)) * Double.random(in: 0.6...1.5)
            if w > bestW { bestW = w; best = it }
        }
        return best ?? pool[0]
    }

    func mastered(prefix: String, of pool: [String]) -> Int {
        pool.filter { score(prefix + $0) >= 3 }.count
    }

    func reset() {
        items = [:]; today = 0; streak = 0; day = ""
        tickDay()
        save()
    }
}
