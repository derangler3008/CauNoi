# Changelog

## 1.5 (2026-08-20)
- Inhalts-Engine (ContentEngine.swift): Satzfabrik baut aus jedem Nomen —
  auch selbst gespeicherten — grammatisch korrekte Übungssätze
  (Nominativ/Akkusativ, der→den) mit vietnamesischer Übersetzung
- Neue Übung „Ghép câu": Sätze aus Wortkacheln zusammensetzen
  (Duolingo-Mechanik) — kuratierte + generierte + Tatoeba-Sätze,
  Einstieg über große Karte in Mẫu câu
- Bilder: ~80 Wort-Emoji + Kategorie-Symbole auf den Quiz-Karten
  (im Hörquiz erst nach der Antwort — vorher wäre es ein Tipp)

## 1.4 (2026-08-20)
- Die App wächst jetzt wirklich: Im Wörterbuch nachgeschlagene Wörter lassen sich
  per „Zum Üben speichern / Thêm vào bài học" als eigene Lernkarten übernehmen —
  sie erscheinen in Hörquiz, der·die·das (mit Wiktionary-Artikel), Ton-Quiz und
  Schreibtrainer, ihre Tatoeba-Beispielsätze zusätzlich unter „Mẫu câu"
- Verwaltung unter Mehr/Thêm: „Meine Wörter / Từ của tôi", Wischen zum Löschen
- Fortschrittszählung berücksichtigt eigene Wörter

## 1.3 (2026-08-20)
- Wörterbuch um zwei Quellen erweitert: de.wiktionary.org liefert Artikel +
  Plural (farbig, autoritativ), Tatoeba echte Beispielsatz-Paare DE↔VI —
  beides offline-gecacht wie die Übersetzung
- Datenqualität: alle 81 Nomen gegen Wiktionary validiert — 0 Artikelfehler;
  3 fehlende Plurale ergänzt (Arbeiten, Hilfen, Feierabende)

## 1.2 (2026-08-20)
- Stimmen-Auswahl in beiden Profilen (Mehr/Thêm → Stimmen): alle installierten
  Stimmen anhören und wählen, beste Qualität zuerst, Auswahl bleibt gespeichert
- Anleitung in der App, wie man Apples Premium-Stimmen nachlädt
  (Bedienungshilfen → Gesprochene Inhalte → Stimmen)

## 1.1 (2026-08-20)
- Wörterbuch (Tra từ) in beiden Profilen: Deutsch↔Vietnamesisch über MyMemory-API,
  jede Suche wird lokal gespeichert und ist danach offline nutzbar
- Artikel wird beim Vorsprechen mitgesprochen („die Apotheke" statt „Apotheke");
  im Artikel-Quiz vor der Antwort bewusst ohne Artikel (würde die Lösung verraten)
- der·die·das: Faustregeln (-ung → die, -chen → das, …) mit Ausnahme-Erkennung
  und 43 Alltags-Beispielsätze mit Vorlesefunktion
- Eltern-Modus prägnanter: gefüllte farbige Artikel-Knöpfe, kräftige
  Richtig/Falsch-Flächen, größere Weiter-Knöpfe; Dark Mode bleibt bewusst schlicht
- Debug-Hooks für automatisierte UI-Tests (-autoanswer, -showdict, -dictq)

## 1.0 (2026-08-20)
- Erstversion: zwei Profile (Vietnamesisch lernen / Deutsch lernen),
  Ton-Quiz, Telex-Schreibtrainer, Lesetexte, Lautlehre, Hörquiz,
  Artikel-Quiz, Alltagssätze, deutsche Phonetik auf Vietnamesisch
