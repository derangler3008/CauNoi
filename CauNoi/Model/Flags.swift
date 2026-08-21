import Foundation
import Combine
import SwiftUI

/// Meldeliste: „Das klingt komisch" — sammelt Stellen, an denen das
/// Sprachgefühl des Nutzers protestiert, damit sie gezielt korrigiert
/// werden können. Bleibt lokal auf dem Gerät.
@MainActor
final class Flags: ObservableObject {
    static let shared = Flags()
    private static let key = "caunoi.flags.v1"
    @Published private(set) var items: [String] = []

    private init() {
        items = UserDefaults.standard.stringArray(forKey: Self.key) ?? []
    }
    func contains(_ s: String) -> Bool { items.contains(s) }
    func toggle(_ s: String) {
        if let i = items.firstIndex(of: s) { items.remove(at: i) }
        else { items.insert(s, at: 0) }
        UserDefaults.standard.set(items, forKey: Self.key)
    }
    func remove(_ s: String) {
        items.removeAll { $0 == s }
        UserDefaults.standard.set(items, forKey: Self.key)
    }
}

/// Kleiner Melde-Knopf unter Quiz-Feedback.
struct FlagButton: View {
    let entry: String          // z. B. "die Tasse = tách, cốc"
    let ui: String             // "de" | "vi"
    @ObservedObject private var flags = Flags.shared
    var body: some View {
        Button {
            flags.toggle(entry)
        } label: {
            Label(flags.contains(entry)
                    ? (ui == "de" ? "Gemeldet — danke!" : "Đã ghi lại — cảm ơn!")
                    : (ui == "de" ? "Klingt komisch? Melden" : "Nghe lạ? Ghi lại"),
                  systemImage: flags.contains(entry) ? "flag.fill" : "flag")
                .font(.caption)
                .foregroundStyle(flags.contains(entry) ? Color.vermilion : Color.ink3)
        }
        .buttonStyle(.plain)
    }
}
