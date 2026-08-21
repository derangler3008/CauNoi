import Foundation

// ═══════════════════════════════════════════════════════════
//  Inhalts-Engine — das „Backend" der App, komplett auf dem Gerät.
//  Quellen-Registry: welche APIs liefern was (Doku für Erweiterungen):
//    MyMemory   → Übersetzung DE↔VI        (Dict.swift)
//    Wiktionary → Genus, Plural            (Dict.swift)
//    Tatoeba    → echte Satzpaare          (Dict.swift)
//    Satzfabrik → generierte Sätze         (hier, regelbasiert)
// ═══════════════════════════════════════════════════════════

/// Ein lernbares Satzpaar, egal aus welcher Quelle.
struct SentencePair: Identifiable, Equatable {
    let de: String
    let vi: String
    let source: String     // "Mẫu câu" | "Tự tạo" | "Tatoeba"
    var id: String { de }
    /// Kacheln für die Ghép-câu-Übung (ohne Endzeichen).
    var tiles: [String] {
        de.replacingOccurrences(of: ".", with: "")
          .replacingOccurrences(of: "!", with: "")
          .replacingOccurrences(of: "?", with: "")
          .split(separator: " ").map(String.init)
    }
}

enum SentenceFactory {

    /// der→den im Akkusativ; die/das bleiben gleich.
    static func akkusativ(_ art: String) -> String { art == "der" ? "den" : art }

    /// Satz-Schablonen: (de-Muster mit {art}/{akk}/{de}, vi-Muster mit {vi})
    private static let templates: [(de: String, vi: String)] = [
        ("Wo ist {art} {de}?",        "{vi} ở đâu?"),
        ("Das ist {art} {de}.",       "Đây là {vi}."),
        ("Ich brauche {akk} {de}.",   "Tôi cần {vi}."),
        ("Ich suche {akk} {de}.",     "Tôi đang tìm {vi}."),
        ("Hier ist {art} {de}.",      "{vi} ở đây.")
    ]

    /// Baut aus einem Nomen grammatisch korrekte Übungssätze.
    static func sentences(for w: GWord) -> [SentencePair] {
        guard let art = w.art else { return [] }
        return templates.map { t in
            SentencePair(
                de: t.de
                    .replacingOccurrences(of: "{art}", with: art)
                    .replacingOccurrences(of: "{akk}", with: akkusativ(art))
                    .replacingOccurrences(of: "{de}", with: w.de),
                vi: t.vi.replacingOccurrences(of: "{vi}", with: w.vi),
                source: "Tự tạo")
        }
    }

    /// Gesamter Übungs-Pool für Ghép câu: kuratierte Sätze + generierte
    /// Sätze aus Nomen (inkl. eigener Wörter) + Tatoeba-Sätze eigener Wörter.
    /// maxTiles hält die Kacheln für Anfänger überschaubar.
    @MainActor
    static func pool(maxTiles: Int = 8) -> [SentencePair] {
        var out: [SentencePair] = GermanData.phrases.map {
            SentencePair(de: $0.de, vi: $0.vi, source: "Mẫu câu")
        }
        let nouns = GermanData.nouns + MyWords.shared.asGNouns
        for n in nouns { out += sentences(for: n) }
        for w in MyWords.shared.items {
            if let d = w.exDe, let v = w.exVi {
                out.append(SentencePair(de: d, vi: v, source: "Tatoeba"))
            }
        }
        var seen = Set<String>()
        return out.filter { p in
            let n = p.tiles.count
            return n >= 3 && n <= maxTiles && seen.insert(p.de).inserted
        }
    }
}

/// Kleine Bilder zu den Wörtern — Emoji: offline, skalierbar, freundlich.
enum Pictos {
    private static let byWord: [String: String] = [
        // Sức khỏe / Gesundheit
        "Arzt": "🧑‍⚕️", "Krankenhaus": "🏥", "Apotheke": "💊", "Rezept": "📋",
        "Krankenkasse": "🏷️", "Schmerz": "🤕", "Tablette": "💊", "Fieber": "🤒",
        "Erkältung": "🤧", "Termin": "📅", "Zahn": "🦷", "Auge": "👁️",
        // Giấy tờ / Papiere
        "Ausweis": "🪪", "Reisepass": "🛂", "Formular": "📝", "Unterschrift": "✍️",
        "Amt": "🏛️", "Antrag": "📄", "Frist": "⏳", "Brief": "✉️",
        "Rechnung": "🧾", "Vertrag": "📑", "Steuer": "💶",
        // Nhà cửa / Wohnen
        "Wohnung": "🏠", "Miete": "🔑", "Schlüssel": "🗝️", "Nachbar": "🧑‍🤝‍🧑",
        "Vermieter": "🧑‍💼", "Heizung": "🌡️", "Fenster": "🪟", "Tür": "🚪",
        "Küche": "🍳", "Keller": "🕳️", "Müll": "🗑️",
        // Đi lại / Unterwegs
        "Zug": "🚆", "Bus": "🚌", "Haltestelle": "🚏", "Fahrkarte": "🎫",
        "Bahnhof": "🚉", "Flughafen": "✈️", "Auto": "🚗", "Fahrrad": "🚲",
        "Straße": "🛣️", "Ampel": "🚦",
        // Mua sắm & Ăn uống
        "Geld": "💶", "Kasse": "🛒", "Brot": "🍞", "Bäckerei": "🥐",
        "Supermarkt": "🛒", "Milch": "🥛", "Wasser": "💧", "Reis": "🍚",
        "Gemüse": "🥬", "Obst": "🍎", "Zucker": "🍬", "Salz": "🧂",
        "Fleisch": "🥩", "Fisch": "🐟", "Ei": "🥚", "Tüte": "🛍️",
        // Gia đình & Menschen
        "Familie": "👨‍👩‍👧‍👦", "Kind": "🧒", "Tochter": "👧", "Sohn": "👦",
        "Eltern": "👫", "Enkelkind": "👶", "Freund": "🤝", "Kollege": "🧑‍💼",
        // Công việc & Thời gian
        "Arbeit": "🔧", "Urlaub": "🏖️", "Pause": "☕", "Feierabend": "🌇",
        "Chef": "🧑‍💼", "Uhr": "🕐", "Woche": "🗓️", "Monat": "📆",
        "Jahr": "🎆", "Morgen": "🌅", "Abend": "🌆", "Nacht": "🌙",
        // Sonstiges
        "Hilfe": "🆘", "Frage": "❓", "Sprache": "🗣️", "Wort": "🔤",
        "Schule": "🏫", "Handy": "📱", "Wetter": "⛅", "Regen": "🌧️"
    ]
    private static let byCat: [String: String] = [
        "Sức khỏe": "🩺", "Giấy tờ": "📄", "Nhà cửa": "🏠", "Đi lại": "🚌",
        "Mua sắm": "🛒", "Gia đình": "👨‍👩‍👧", "Công việc": "💼",
        "Thời gian": "🕐", "Động từ": "🏃", "Chào hỏi": "👋",
        "Khi chưa hiểu": "🤔", "Ở phòng khám": "🩺", "Ở cơ quan": "🏛️",
        "Hàng xóm": "🏘️", "Từ của tôi": "⭐",
        "Ăn uống": "🍽️", "Cơ thể": "💪", "Quần áo": "👕", "Thời tiết": "⛅",
        "Trường học": "🏫", "Cảm xúc": "💛", "Tính từ & trạng từ": "🎨",
        "Giao tiếp": "💬", "Ở nhà hàng": "🍜", "Hỏi đường": "🧭", "Gọi điện": "📞",
        "Thời tiết & chuyện phiếm": "☕", "Gia đình & cảm xúc": "🏡"
    ]
    static func emoji(de: String, cat: String) -> String? {
        byWord[de] ?? byCat[cat]
    }
}
