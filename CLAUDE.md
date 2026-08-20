# Cầu Nối — Arbeitsweise

Zweisprachige Lern-App (SwiftUI, iOS 17+): Profil „con" = Vietnamesisch lernen (UI Deutsch),
Profil „bome" = Deutsch lernen für die Eltern (UI Vietnamesisch, große Schrift, kräftige Farben).

## Iterativer Workflow (Dauerauftrag des Users)
Entwickeln → prüfen → korrigieren → erneut prüfen. Nach jedem Entwicklungsschritt die
10-Punkte-Review durchlaufen und kompakt berichten:

1. Anforderungen nachvollziehen (verlangt ↔ gebaut)
2. Selbstreview des Diffs
3. Statische Analyse: 0 Warnungen
4. Unit-Tests grün — Engine-Suite:
   `swiftc -O CauNoi/Model/Engine.swift CauNoi/Model/VietnameseData.swift CauNoi/Model/GermanData.swift Tests/EngineTestMain.swift -o /tmp/cntest && /tmp/cntest`
5. Build grün: `xcodebuild -project CauNoi.xcodeproj -scheme CauNoi -destination 'platform=iOS Simulator,id=…' -derivedDataPath build build`
6. Funktionaler Smoke-Test per Simulator-Screenshots (Launch-Args: `-profile con|bome -tab 0..4`, DEBUG-Hooks: `-autoanswer 1`, `-showdict 1 -dictq Wort`)
7. Fehlerpfade & Offline-Verhalten (Wörterbuch muss offline sauber degradieren)
8. Sicherheit & Datenschutz: keine Secrets, nur HTTPS, keine Nutzerdaten an APIs (nie die E-Mail des Users mitsenden)
9. Barrierefreiheit: Dynamic Type, Kontrast (Eltern-Modus!)
10. Version + CHANGELOG.md pflegen

## Ablage & Backup
- Web-App-Quelle: `web/hoc-dau.html` (Artifact: claude.ai/code/artifact/15e899f6-af90-46e2-ae0e-0a2db964ab94)
- Backup: `git push icloud` → Bare-Repo in iCloud Drive (`Backups/CauNoi.git`)

## Technische Notizen
- Tonlogik/Telex: `Model/Engine.swift` — bei Änderungen IMMER Suite aus Punkt 4 laufen lassen
- Wörterbuch: MyMemory-API (kostenlos, ohne Schlüssel), `Model/Dict.swift`, Cache lokal, Quelle in der UI nennen
- Eltern-Modus: kräftige, gefüllte Farbflächen im Light Mode; Dark Mode bewusst schlicht lassen
- Artikel immer mitsprechen (word.full), AUSSER vor der Antwort im Artikel-Quiz (würde die Lösung verraten)
- Simulator-Runtime-Mapping aktiv: `xcrun simctl runtime match set iphoneos26.5 23E244`
