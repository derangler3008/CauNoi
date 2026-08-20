import Foundation

/// Vietnamesische Schrift-Werkzeuge: Töne lesen, setzen, entfernen + Telex-Eingabe.
/// Töne: 0 ngang · 1 huyền · 2 sắc · 3 hỏi · 4 ngã · 5 nặng
enum VN {

    // 12 Vokalfamilien × 6 Töne (Index = Ton)
    static let families: [[Character]] = [
        ["a","à","á","ả","ã","ạ"], ["ă","ằ","ắ","ẳ","ẵ","ặ"], ["â","ầ","ấ","ẩ","ẫ","ậ"],
        ["e","è","é","ẻ","ẽ","ẹ"], ["ê","ề","ế","ể","ễ","ệ"], ["i","ì","í","ỉ","ĩ","ị"],
        ["o","ò","ó","ỏ","õ","ọ"], ["ô","ồ","ố","ổ","ỗ","ộ"], ["ơ","ờ","ớ","ở","ỡ","ợ"],
        ["u","ù","ú","ủ","ũ","ụ"], ["ư","ừ","ứ","ử","ữ","ự"], ["y","ỳ","ý","ỷ","ỹ","ỵ"]
    ]

    static let toBase: [Character: Character] = {
        var m: [Character: Character] = [:]
        for fam in families {
            let base = fam[0]
            let upperBase = Character(String(base).uppercased())
            for ch in fam {
                m[ch] = base
                m[Character(String(ch).uppercased())] = upperBase
            }
        }
        return m
    }()

    static let toneOf: [Character: Int] = {
        var m: [Character: Int] = [:]
        for fam in families {
            for (t, ch) in fam.enumerated() {
                m[ch] = t
                m[Character(String(ch).uppercased())] = t
            }
        }
        return m
    }()

    /// (Basisvokal, Ton) → Zeichen
    static let compose: [String: Character] = {
        var m: [String: Character] = [:]
        for fam in families {
            for (t, ch) in fam.enumerated() {
                m["\(fam[0])\(t)"] = ch
                m["\(Character(String(fam[0]).uppercased()))\(t)"] = Character(String(ch).uppercased())
            }
        }
        return m
    }()

    static func isVowel(_ c: Character) -> Bool { toBase[c] != nil }

    /// Entfernt nur die Tonzeichen — Vokalzeichen (ă â ê ô ơ ư đ) bleiben.
    static func stripTone(_ s: String) -> String {
        String(s.map { toBase[$0] ?? $0 })
    }

    /// Ton einer Silbe (erster tontragender Vokal).
    static func tone(of s: String) -> Int {
        for c in s where (toneOf[c] ?? 0) > 0 { return toneOf[c]! }
        return 0
    }

    /// Index des Vokals, der das Tonzeichen tragen muss (Eingabe: tonlose Silbe).
    static func toneTargetIndex(_ chars: [Character]) -> Int? {
        let lw = chars.map { Character(String($0).lowercased()) }
        var idx = lw.indices.filter { isVowel(lw[$0]) }
        guard !idx.isEmpty else { return nil }
        let s = String(lw)
        // In "qu…" und "gi…" gehört u bzw. i zum Konsonanten.
        if (s.hasPrefix("qu") || s.hasPrefix("gi")), idx.first == 1, idx.count > 1 { idx.removeFirst() }
        // ơ und ê ziehen das Zeichen immer an sich.
        for i in idx where lw[i] == "ơ" || lw[i] == "ê" { return i }
        if idx.count == 1 { return idx[0] }
        let hasFinal = idx.last! < lw.count - 1
        if hasFinal { return idx.last! }
        if idx.count == 3 { return idx[1] }
        return idx[0]
    }

    /// Setzt einen Ton auf eine Silbe (ersetzt einen vorhandenen).
    static func applyTone(_ word: String, _ t: Int) -> String {
        var chars = Array(stripTone(word))
        guard t != 0, let i = toneTargetIndex(chars),
              let c = compose["\(chars[i])\(t)"] else { return String(chars) }
        chars[i] = c
        return String(chars)
    }

    // ── Telex ─────────────────────────────────────────
    static let toneKey: [Character: Int] = ["s": 2, "f": 1, "r": 3, "x": 4, "j": 5]

    private static func keepCase(_ orig: Character, _ repl: Character) -> Character {
        let s = String(orig)
        if s == s.uppercased() && s != s.lowercased() {
            return Character(String(repl).uppercased())
        }
        return repl
    }

    static func telexWord(_ raw: String) -> String {
        var out: [Character] = []
        var tone = 0
        for c in raw {
            let lc = Character(String(c).lowercased())
            let last = out.last
            let llc: Character? = last.map { Character(String($0).lowercased()) }
            let prev2 = out.count >= 2 ? String(out.suffix(2)).lowercased() : ""

            if let t = toneKey[lc], out.contains(where: { isVowel($0) }) {
                if tone == t { tone = 0; out.append(c) } else { tone = t }
                continue
            }
            func swapLast(_ r: Character) { out[out.count - 1] = keepCase(last!, r) }

            if lc == "a", llc == "a" { swapLast("â"); continue }
            if lc == "a", llc == "â" { swapLast("a"); out.append(c); continue }
            if lc == "e", llc == "e" { swapLast("ê"); continue }
            if lc == "e", llc == "ê" { swapLast("e"); out.append(c); continue }
            if lc == "o", llc == "o" { swapLast("ô"); continue }
            if lc == "o", llc == "ô" { swapLast("o"); out.append(c); continue }
            if lc == "d", llc == "d" { swapLast("đ"); continue }
            if lc == "d", llc == "đ" { swapLast("d"); out.append(c); continue }
            if lc == "w" {
                if prev2 == "uo" || prev2 == "ưo" || prev2 == "uơ" {
                    out[out.count - 2] = keepCase(out[out.count - 2], "ư")
                    out[out.count - 1] = keepCase(out[out.count - 1], "ơ")
                    continue
                }
                if prev2 == "ươ" {
                    out[out.count - 2] = keepCase(out[out.count - 2], "u")
                    out[out.count - 1] = keepCase(out[out.count - 1], "o")
                    out.append(c); continue
                }
                if llc == "a" { swapLast("ă"); continue }
                if llc == "o" { swapLast("ơ"); continue }
                if llc == "u" { swapLast("ư"); continue }
                if llc == "ă" || llc == "ơ" || llc == "ư" {
                    let back: [Character: Character] = ["ă": "a", "ơ": "o", "ư": "u"]
                    swapLast(back[llc!]!); out.append(c); continue
                }
                out.append(keepCase(c, "ư")); continue
            }
            out.append(c)
        }
        var w = String(out)
        if tone != 0 { w = applyTone(w, tone) }
        return w
    }

    static func telex(_ raw: String) -> String {
        raw.split(separator: " ", omittingEmptySubsequences: false)
            .map { telexWord(String($0)) }
            .joined(separator: " ")
    }
}

/// Metadaten der sechs Töne.
struct ToneInfo {
    let id: Int
    let name: String
    let de: String        // Beschreibung für den Con-Modus
    let vi: String        // Beschreibung für den Bố-Mẹ-Modus (ungenutzt dort, Töne sind ihr Alltag)
    let markDE: String
    let sample: String
}

let TONES: [ToneInfo] = [
    ToneInfo(id: 0, name: "ngang", de: "gleichbleibend, mittlere Höhe",      vi: "không dấu",  markDE: "kein Zeichen", sample: "ma"),
    ToneInfo(id: 1, name: "huyền", de: "tief fallend, weich",                vi: "dấu huyền",  markDE: "à-Strich",     sample: "mà"),
    ToneInfo(id: 2, name: "sắc",   de: "hoch steigend, scharf",              vi: "dấu sắc",    markDE: "á-Strich",     sample: "má"),
    ToneInfo(id: 3, name: "hỏi",   de: "absinkend, dann wieder hoch",        vi: "dấu hỏi",    markDE: "ả-Haken",      sample: "mả"),
    ToneInfo(id: 4, name: "ngã",   de: "steigend mit Knacklaut in der Mitte",vi: "dấu ngã",    markDE: "ã-Tilde",      sample: "mã"),
    ToneInfo(id: 5, name: "nặng",  de: "tief, kurz, abgehackt",              vi: "dấu nặng",   markDE: "ạ-Punkt",      sample: "mạ")
]
