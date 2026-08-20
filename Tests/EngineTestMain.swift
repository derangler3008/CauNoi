import Foundation

var fails = 0

// 1) Roundtrip Tonplatzierung über gesamten Wortschatz
var n = 0, ok = 0
for w in VietnameseData.words {
    for syl in w.v.split(separator: " ") {
        n += 1
        let s = String(syl)
        let rt = VN.applyTone(VN.stripTone(s), VN.tone(of: s))
        if rt == s { ok += 1 } else { print("  TON  \(s) -> \(rt)"); fails += 1 }
    }
}
print("Tonplatzierung Wortschatz: \(ok)/\(n)")

// 2) Sätze
n = 0; ok = 0
for s in VietnameseData.sentences {
    for tok in s.vi.split(separator: " ") {
        let w = String(tok).filter { !".,!?;:".contains($0) }
        if w.isEmpty { continue }
        n += 1
        let rt = VN.applyTone(VN.stripTone(w), VN.tone(of: w))
        if rt == w { ok += 1 } else { print("  SATZ \(w) -> \(rt)"); fails += 1 }
    }
}
print("Tonplatzierung Sätze:      \(ok)/\(n)")

// 3) Telex-Roundtrip: Tastenfolge aus Zielwort erzeugen, Rückweg prüfen
let qual: [Character: String] = ["â":"aa","ă":"aw","ê":"ee","ô":"oo","ơ":"ow","ư":"uw","đ":"dd"]
let tk = [1:"f",2:"s",3:"r",4:"x",5:"j"]
func toKeys(_ word: String) -> String {
    word.split(separator: " ").map { syl -> String in
        let s = String(syl)
        let t = VN.tone(of: s)
        var out = ""
        for ch in VN.stripTone(s) {
            let lc = Character(String(ch).lowercased())
            if let q = qual[lc] {
                let isUpper = String(ch) == String(ch).uppercased() && String(ch) != String(ch).lowercased()
                out += isUpper ? q.prefix(1).uppercased() + q.dropFirst() : q
            } else { out.append(ch) }
        }
        return out + (t > 0 ? tk[t]! : "")
    }.joined(separator: " ")
}
n = 0; ok = 0
for w in VietnameseData.words {
    n += 1
    let keys = toKeys(w.v)
    let got = VN.telex(keys)
    if got == w.v { ok += 1 } else { print("  TELEX \(w.v) <- \"\(keys)\" ergab \"\(got)\""); fails += 1 }
}
print("Telex Wortschatz:          \(ok)/\(n)")

// 4) Die Lehr-Tabelle aus der App selbst
n = 0; ok = 0
for (keys, _, ex) in VietnameseData.telexRows {
    _ = keys
    let parts = ex.components(separatedBy: " → ")
    guard parts.count == 2 else { continue }
    n += 1
    let got = VN.telex(parts[0])
    if got == parts[1] { ok += 1 } else { print("  TABELLE \(parts[0]) → \(got), behauptet \(parts[1])"); fails += 1 }
}
print("Telex-Lehrtabelle:         \(ok)/\(n)")

// 5) Ton-Referenz ma-Reihe
for t in TONES {
    if VN.tone(of: t.sample) != t.id { print("  REF \(t.sample) ist nicht \(t.name)"); fails += 1 }
}
print("Ton-Referenz:              ok")

// 6) Handproben
let manual = [("mej","mẹ"),("ddwowngf","đường"),("nuowcs","nước"),("tieengs Vieejt","tiếng Việt"),
              ("hocj","học"),("khoong","không"),("quar","quả"),("nguwowfi","người"),("giowf","giờ"),("yeeu","yêu")]
n = 0; ok = 0
for (k, e) in manual {
    n += 1
    let g = VN.telex(k)
    if g == e { ok += 1 } else { print("  MANUELL \"\(k)\" → \"\(g)\", erwartet \"\(e)\""); fails += 1 }
}
print("Telex Handproben:          \(ok)/\(n)")

// 7) Deutsche Daten: Artikel gültig, Duplikate
let arts = Set(GermanData.nouns.map { $0.art! })
if !arts.isSubset(of: ["der","die","das"]) { print("  ARTIKEL ungültig: \(arts)"); fails += 1 }
let dedup = Set(GermanData.words.map { $0.de })
if dedup.count != GermanData.words.count { print("  DUPLIKATE in GermanData"); fails += 1 }
let vdup = Set(VietnameseData.words.map { $0.v })
if vdup.count != VietnameseData.words.count { print("  DUPLIKATE in VietnameseData"); fails += 1 }
print("Datenintegrität:           ok (\(GermanData.nouns.count) Nomen, \(GermanData.words.count) DE-Wörter, \(VietnameseData.words.count) VN-Wörter)")

print(fails == 0 ? "\nALLE TESTS BESTANDEN" : "\n\(fails) FEHLER")
exit(fails == 0 ? 0 : 1)
