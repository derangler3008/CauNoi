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

    /// Schablonen für ORTBARES (Dinge/Orte): sehen, zeigen, suchen.
    private static let locateTemplates: [(de: String, vi: String)] = [
        ("Wo ist {art} {de}?",        "{vi} ở đâu?"),
        ("Das ist {art} {de}.",       "Đây là {vi}."),
        ("Ich suche {akk} {de}.",     "Tôi đang tìm {vi}."),
        ("Hier ist {art} {de}.",      "{vi} ở đây.")
    ]
    /// Schablone für BESCHAFFBARES: brauchen.
    private static let needTemplates: [(de: String, vi: String)] = [
        ("Ich brauche {akk} {de}.",   "Tôi cần {vi}.")
    ]

    /// Kategorien, deren Wörter greifbar/ortbar sind.
    private static let locateCats: Set<String> = [
        "Ăn uống", "Nhà cửa", "Quần áo", "Mua sắm", "Giấy tờ",
        "Đi lại", "Trường học", "Sức khỏe", "Từ của tôi"
    ]
    /// Teilmenge: Dinge, die man sinnvoll „braucht".
    private static let needCats: Set<String> = [
        "Ăn uống", "Quần áo", "Giấy tờ", "Trường học", "Từ của tôi"
    ]
    private static let needExtra: Set<String> = [
        "Pflaster", "Verband", "Salbe", "Rezept", "Termin", "Tablette",
        "Schlüssel", "Quittung", "Tüte", "Speisekarte"
    ]
    /// Abstrakta & Vorgänge, für die KEINE Sätze generiert werden —
    /// „Wo ist der Husten?" ist grammatisch, aber Unsinn.
    private static let noGen: Set<String> = [
        "Husten", "Schnupfen", "Grippe", "Impfung", "Blutdruck",
        "Untersuchung", "Allergie", "Schwindel", "Krankmeldung",
        "Sprechstunde", "Überweisung", "Anmeldung", "Größe", "Unfall",
        "Verspätung", "Richtung", "Feiertag", "Staatsangehörigkeit",
        "Gebühr", "Frist", "Miete", "Steuererklärung", "Rente"
    ]

    /// Nur die erste Übersetzungsvariante, ohne Klammern — sonst
    /// kleben Kommas und Erläuterungen mitten im generierten Satz.
    static func viShort(_ vi: String) -> String {
        var v = vi.replacingOccurrences(of: "\\s*\\([^)]*\\)", with: "", options: .regularExpression)
        if let cut = v.firstIndex(where: { $0 == "," || $0 == ";" }) { v = String(v[..<cut]) }
        return v.trimmingCharacters(in: .whitespaces)
    }

    /// Baut aus einem Nomen nur dann Sätze, wenn sie natürlich klingen.
    static func sentences(for w: GWord) -> [SentencePair] {
        guard let art = w.art, !noGen.contains(w.de), locateCats.contains(w.cat) else { return [] }
        let vi = viShort(w.vi)
        guard !vi.isEmpty else { return [] }
        var ts = locateTemplates
        if needCats.contains(w.cat) || needExtra.contains(w.de) { ts += needTemplates }
        return ts.map { t in
            SentencePair(
                de: t.de
                    .replacingOccurrences(of: "{art}", with: art)
                    .replacingOccurrences(of: "{akk}", with: akkusativ(art))
                    .replacingOccurrences(of: "{de}", with: w.de),
                vi: t.vi.replacingOccurrences(of: "{vi}", with: vi),
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
