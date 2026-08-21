# HANDOFF — Cầu Nối
> **Für einen frischen Chat:** Nur diese Datei lesen genügt, um weiterzuarbeiten.
> Aktualisiert bei jedem Big Step (Versionssprung, neues Feature, Infrastruktur).

**Stand:** 2026-08-20 · **Version 1.5 (Build 6)** · läuft auf iPhone 15 des Users
**Repo:** `~/Developer/CauNoi` · Remotes: `icloud` (Bare-Repo iCloud Drive/Backups) + `github` (derangler3008/CauNoi, privat) — nach jedem Commit auf BEIDE pushen.

## Projekt in 3 Sätzen
Zweisprachige SwiftUI-Lern-App (iOS 17+): Profil **con** = User lernt Vietnamesisch
lesen/schreiben (UI Deutsch, kann nur sprechen/verstehen); Profil **bome** = seine Eltern
lernen Deutsch (UI Vietnamesisch, große Schrift, kräftige Farben). Design „Sơn mài":
Indigo/Zinnober/Seladon auf Eierschale, Serif-Display, Dark Mode bewusst gedämpft.

## Was verifiziert läuft
- Ton-Quiz, Telex-Schreibtrainer, Lesen, Laute (con) · Hörquiz, der·die·das mit
  Faustregeln+43 Beispielsätzen, Mẫu câu, Phát âm (bome)
- Wörterbuch „Tra từ" in beiden Profilen: MyMemory (Übersetzung) + de.wiktionary
  (Artikel/Plural, farbig) + Tatoeba (DE↔VI-Satzpaare) — alles offline-gecacht
- Wachstums-Kreislauf: Lookup → „Zum Üben speichern" → `Model/MyWords.swift` → Wort
  erscheint in ALLEN Quiz-Pools (+ Beispielsatz in Mẫu câu); Verwaltung in Mehr/Thêm
- `Model/ContentEngine.swift`: Quellen-Registry-Doku, SentenceFactory (Template-Sätze
  mit Akkusativ-Regel der→den) und Pictos (Emoji-Bilder je Wort/Kategorie)
- Ghép-câu-Kachelübung: `Views/TileQuizView.swift`, Einstieg in Mẫu câu, Hook `-showbuild 1`
- Stimmen-Auswahl mit Hörprobe (Mehr/Thêm), bevorzugt Premium > Enhanced > Standard
- Artikel wird mitgesprochen (word.full) — AUSSER vor Antwort im Artikel-Quiz (Spoiler)
- QA: 81 Nomen gegen Wiktionary validiert (0 Artikelfehler); Engine-Testsuite grün

## Dateien
- `CauNoi/Model/Engine.swift` — Ton-/Telex-Logik. Nach JEDER Änderung: Testsuite!
- `CauNoi/Model/{VietnameseData,GermanData}.swift` — kuratierte Inhalte
- `CauNoi/Model/Dict.swift` — 3-Quellen-Wörterbuch mit Cache (UserDefaults)
- `CauNoi/Model/MyWords.swift` — vom User gespeicherte Wörter, Brücken in alle Pools
- `CauNoi/Model/{Speech,Progress}.swift` — TTS (Stimmwahl via UserDefaults voice.vi/de),
  Lernstand (Karte „sitzt" ab Stufe 3)
- `CauNoi/Views/…` — Theme (Farb-Tokens, ToneCurve, FlowLayout), ConViews, BoMeViews,
  DictionaryView, VoicePickerView
- `web/README.md` → Web-App „Học Dấu" lebt als Artifact:
  claude.ai/code/artifact/15e899f6-af90-46e2-ae0e-0a2db964ab94 (Quelle bei Bedarf neu erzeugen)

## Befehle
```bash
# Simulator-Build + Tests
xcodebuild -project CauNoi.xcodeproj -scheme CauNoi -configuration Debug \
  -destination 'platform=iOS Simulator,id=08C50EDF-E1E0-4EA1-B71C-EC3408C0BBE9' \
  -derivedDataPath build build
swiftc -O CauNoi/Model/Engine.swift CauNoi/Model/VietnameseData.swift \
  CauNoi/Model/GermanData.swift Tests/main.swift -o /tmp/cntest && /tmp/cntest
# iPhone-Deploy (Team HLRMF3W3M9, Gerät „iPhone 15 vhvu")
xcodebuild … -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath build-device -allowProvisioningUpdates DEVELOPMENT_TEAM=HLRMF3W3M9 build
xcrun devicectl device install app --device 4CF1BE53-2A23-51AF-828E-0BF5BD79C7EB \
  build-device/Build/Products/Release-iphoneos/CauNoi.app
```
Smoke-Test-Hooks (Debug): `-profile con|bome -tab 0..4 -autoanswer 1 -showdict 1
-dictq Wort -showvoices 1 -seedmyword 1` · Screenshots: `xcrun simctl io <sim> screenshot x.png`

## Stolperfallen (bereits gelöst — nicht erneut hineinlaufen)
- Xcode-26.6-SDK vs. Runtime 26.4: `xcrun simctl runtime match set iphoneos26.5 23E244` ist GESETZT
- MCP-Simulator-Panel geht erst nach `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` (User, offen)
- `.disabled()` dimmt gefüllte Buttons aus → `allowsHitTesting` verwenden
- swiftc: Top-Level-Testcode nur in `main.swift`
- Tatoeba-API braucht `sort=relevance` und `trans:lang=vie` (unstable-Endpoint)
- Wiktionary-vi-Übersetzungen meist leer → nur für Grammatik nutzen
- Platzhalter ◌ rendert nicht → echte Buchstaben (à á ả ã ạ) verwenden
- iCloud-Sync des Lernstands bräuchte bezahlten Dev-Account (Free = keine iCloud-Entitlements)
- Signatur (kostenlose Apple-ID) läuft nach 7 Tagen ab → neu deployen
- Debug-Launch-Args wirken NUR im jeweiligen Prozessstart (arguments domain, nicht
  persistent) — Seeds bei jedem Testlauf erneut mitgeben
- SIMULATOR-QUIRK: Color-Emoji rendern in der 26.6↔26.4-Match-Konstellation als
  Tofu/leer — Datenebene per Isolationstest verifiziert (U+1F6D2 korrekt), Font im
  Runtime vorhanden. Emoji-Optik NUR auf dem echten Gerät beurteilen

## Arbeitsregeln des Users (verbindlich, Details in CLAUDE.md + Memory)
1. Iterativ: entwickeln → prüfen → korrigieren → erneut prüfen; 10-Punkte-Review je Schritt
2. Lösch-Protokoll: ersatzlose Löschungen/destruktive git-Ops NUR nach Vorab-Bericht
   (Was+Zeile · Warum · Auswirkungen · eigene Bewertung) und Freigabe
3. Bei jedem Big Step: Version bumpen, CHANGELOG + diese HANDOFF.md aktualisieren,
   Commit auf icloud UND github pushen
4. Nichts an Dritt-APIs senden außer dem Suchwort; nie die E-Mail des Users

## Offen / Ideen
- [ ] User: `sudo xcode-select …` (Live-Panel) · Premium-Stimmen laden · Eltern-iPhones anschließen
- [ ] Ideen: Cloud-TTS (ElevenLabs o. ä.), Leipzig-Beispielsätze, Lernstand-Sync (paid account)
