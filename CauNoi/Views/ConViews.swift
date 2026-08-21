import SwiftUI

// ═══════════════════════════════════════════════════════
//  Con-Modus: Vietnamesisch lesen & schreiben (UI Deutsch)
// ═══════════════════════════════════════════════════════

struct ConRoot: View {
    @State private var tab = UserDefaults.standard.integer(forKey: "tab")
    var body: some View {
        TabView(selection: $tab) {
            ToneQuizView()
                .tabItem { Label("Töne", systemImage: "waveform.path") }.tag(0)
            WriteView()
                .tabItem { Label("Schreiben", systemImage: "keyboard") }.tag(1)
            ReadView()
                .tabItem { Label("Lesen", systemImage: "text.book.closed") }.tag(2)
            ConSoundsView()
                .tabItem { Label("Laute", systemImage: "ear") }.tag(3)
            ConMoreView()
                .tabItem { Label("Mehr", systemImage: "ellipsis.circle") }.tag(4)
        }
    }
}

/// Warnbanner, wenn keine vietnamesische Stimme installiert ist.
struct VoiceWarning: View {
    var body: some View {
        if !Speech.shared.hasVietnamese {
            VStack(alignment: .leading, spacing: 4) {
                Text("Noch keine vietnamesische Stimme")
                    .font(.footnote.weight(.semibold)).foregroundStyle(Color.goldC)
                Text("Einstellungen → Bedienungshilfen → Gesprochene Inhalte → Stimmen → Vietnamesisch laden. Bis dahin klingen die Wörter falsch.")
                    .font(.caption2).foregroundStyle(Color.ink2)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.goldC, lineWidth: 1))
        }
    }
}

// ── Töne ────────────────────────────────────────────────
struct ToneQuizView: View {
    @ObservedObject private var progress = Progress.shared
    @State private var word = VietnameseData.tonePool[0]
    @State private var chosen: Int? = nil
    @State private var seen = 0

    private var correct: Int { VN.tone(of: word.v) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VoiceWarning()
                    Text("Du hörst die Töne längst richtig — du hast sie nur nie gesehen. Sprich das Wort, wie du es kennst, und setz das Zeichen.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 14) {
                        HStack {
                            Text(word.cat.uppercased())
                                .font(.caption2.weight(.semibold)).kerning(1.2)
                                .foregroundStyle(Color.ink3)
                            Spacer()
                            Text("#\(seen + 1)").font(.caption2.monospaced()).foregroundStyle(Color.ink3)
                        }
                        Text(VN.stripTone(word.v))
                            .font(.system(size: 58, design: .serif).weight(.medium))
                            .foregroundStyle(Color.ink)
                        Text(word.de)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.ink2)
                        Button {
                            Speech.shared.speak(word.v, lang: "vi")
                        } label: {
                            Label("anhören", systemImage: "speaker.wave.2")
                                .font(.footnote)
                        }
                        .buttonStyle(.bordered).buttonBorderShape(.capsule)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(TONES, id: \.id) { t in
                                Button { answer(t.id) } label: {
                                    VStack(spacing: 5) {
                                        ToneGlyph(tone: t.id, color: glyphColor(t.id))
                                            .frame(width: 40, height: 26)
                                        Text(t.name)
                                            .font(.system(.subheadline, design: .serif).weight(.semibold))
                                            .foregroundStyle(Color.ink)
                                        Text(t.markDE)
                                            .font(.caption2).foregroundStyle(Color.ink3)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(bg(t.id))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(border(t.id), lineWidth: 1))
                                    .opacity(chosen != nil && t.id != correct && t.id != chosen ? 0.4 : 1)
                                }
                                .buttonStyle(.plain)
                                .disabled(chosen != nil)
                            }
                        }

                        if let c = chosen {
                            let t = TONES[correct]
                            FeedbackBox(
                                ok: c == correct,
                                title: c == correct ? "Đúng rồi — richtig." : "Noch nicht.",
                                body_: Text("\(word.v)").font(.system(.title3, design: .serif).weight(.semibold))
                                    + Text("  ·  \(t.name), \(t.de)."
                                        + (word.note.isEmpty ? "" : "\n\(word.note)"))
                            )
                            Button { next() } label: {
                                Text("Weiter →").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        ProgressLine(done: progress.mastered(prefix: "t:", of: (VietnameseData.tonePool + MyWords.shared.asVTone).map(\.v)),
                                     total: VietnameseData.tonePool.count + MyWords.shared.asVTone.count,
                                     label: "Wörtern sitzen")
                    }
                    .card()
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle("Töne")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { if seen == 0 { next() } }
        }
    }

    private func glyphColor(_ id: Int) -> Color {
        guard chosen != nil else { return .indigo }
        if id == correct { return .celadon }
        if id == chosen { return .vermilion }
        return .indigo
    }
    private func bg(_ id: Int) -> Color {
        guard chosen != nil else { return .surface }
        if id == correct { return .celadonBg }
        if id == chosen { return .vermBg }
        return .surface
    }
    private func border(_ id: Int) -> Color {
        guard chosen != nil else { return .lineC }
        if id == correct { return .celadon }
        if id == chosen { return .vermilion }
        return .lineC
    }
    private func answer(_ id: Int) {
        guard chosen == nil else { return }
        chosen = id
        progress.record("t:" + word.v, right: id == correct)
        Speech.shared.speak(word.v, lang: "vi")
    }
    private func next() {
        word = progress.pick(VietnameseData.tonePool + MyWords.shared.asVTone, key: { "t:" + $0.v }, avoid: "t:" + word.v)
        chosen = nil
        seen += 1
        Speech.shared.speak(word.v, lang: "vi")
    }
}

struct ProgressLine: View {
    let done: Int; let total: Int; let label: String
    var sep = "von"
    var body: some View {
        VStack(spacing: 5) {
            GeometryReader { g in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.surface2)
                    Capsule().fill(Color.goldC)
                        .frame(width: g.size.width * CGFloat(done) / CGFloat(max(1, total)))
                }
            }
            .frame(height: 3)
            Text("\(done) \(sep) \(total) \(label)")
                .font(.caption2.monospacedDigit())
                .foregroundStyle(Color.ink3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 6)
    }
}

// ── Schreiben ───────────────────────────────────────────
struct WriteView: View {
    @ObservedObject private var progress = Progress.shared
    @State private var word = VietnameseData.words[0]
    @State private var raw = ""
    @State private var shown = ""
    @State private var rendered = ""
    @State private var telexOn = true
    @State private var result: Bool? = nil
    @State private var revealed = false
    @State private var seen = 0
    @State private var showDict = false
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Telex ist eingebaut: aa → â, ow → ơ, dd → đ, und s f r x j für die Töne. Tipp einfach los.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 14) {
                        HStack {
                            Text(word.cat.uppercased())
                                .font(.caption2.weight(.semibold)).kerning(1.2)
                                .foregroundStyle(Color.ink3)
                            Spacer()
                            Text("#\(seen + 1)").font(.caption2.monospaced()).foregroundStyle(Color.ink3)
                        }
                        Text(word.de)
                            .font(.system(.title, design: .serif).weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.ink)
                        if !word.note.isEmpty {
                            Text(word.note).font(.caption).foregroundStyle(Color.ink3)
                        }
                        Button {
                            Speech.shared.speak(word.v, lang: "vi")
                        } label: {
                            Label("anhören", systemImage: "speaker.wave.2").font(.footnote)
                        }
                        .buttonStyle(.bordered).buttonBorderShape(.capsule)

                        TextField("tippen …", text: $shown)
                            .font(.system(.title, design: .serif))
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .keyboardType(.asciiCapable)
                            .focused($focused)
                            .padding(12)
                            .background(fieldBg)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(fieldBorder, lineWidth: 1))
                            .onChange(of: shown) { _, new in reconcile(new) }
                            .onSubmit { check() }

                        // Schnelltasten: Telex-Sequenzen
                        FlowLayout(spacing: 6) {
                            ForEach([("â","aa"),("ă","aw"),("ê","ee"),("ô","oo"),("ơ","ow"),("ư","w"),("đ","dd"),
                                     ("à","f"),("á","s"),("ả","r"),("ã","x"),("ạ","j")], id: \.0) { glyph, keys in
                                Button {
                                    raw += keys
                                    rendered = VN.telex(raw)
                                    shown = rendered
                                } label: {
                                    VStack(spacing: 0) {
                                        Text(glyph).font(.system(.body, design: .serif))
                                        Text(keys).font(.system(size: 8).monospaced()).foregroundStyle(Color.ink3)
                                    }
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color.surface2.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if let r = result {
                            FeedbackBox(
                                ok: r,
                                title: r ? "Chính xác — genau so." : "Noch nicht.",
                                body_: r
                                    ? Text("\(word.v)").font(.system(.title3, design: .serif).weight(.semibold)) + Text("  ·  \(word.de)")
                                    : Text(hint())
                            )
                        }
                        if revealed {
                            FeedbackBox(ok: true, title: word.v,
                                body_: Text("Tipp es einmal selbst nach — das prägt sich besser ein als Lesen."))
                        }

                        HStack(spacing: 8) {
                            Button { result == true ? next() : check() } label: {
                                Text(result == true ? "Weiter →" : "Prüfen").frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            Button("Zeigen") { reveal() }
                                .buttonStyle(.bordered)
                            Button("Neu") { next() }
                                .buttonStyle(.bordered)
                        }

                        ProgressLine(done: progress.mastered(prefix: "w:", of: (VietnameseData.words + MyWords.shared.asVWords).map(\.v)),
                                     total: VietnameseData.words.count + MyWords.shared.asVWords.count,
                                     label: "Wörtern sitzen")
                    }
                    .card()
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle("Schreiben")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showDict = true } label: {
                        Label("Wörterbuch", systemImage: "character.book.closed")
                    }
                }
            }
            .sheet(isPresented: $showDict) { DictionaryView(ui: "de") }
            .onAppear { if seen == 0 { next() } }
        }
    }

    private var fieldBg: Color {
        switch result {
        case .some(true): return .celadonBg
        case .some(false): return .vermBg
        default: return .paper
        }
    }
    private var fieldBorder: Color {
        switch result {
        case .some(true): return .celadon
        case .some(false): return .vermilion
        default: return .lineC
        }
    }

    private func reconcile(_ new: String) {
        guard telexOn else { raw = new; rendered = new; return }
        if new == rendered { return }
        if new.count > rendered.count, new.hasPrefix(rendered) {
            raw += String(new.dropFirst(rendered.count))
        } else if new.count < rendered.count, rendered.hasPrefix(new) {
            raw = String(raw.dropLast(rendered.count - new.count))
        } else {
            raw = new
        }
        rendered = VN.telex(raw)
        shown = rendered
        if result != nil { result = nil }
    }

    private func norm(_ s: String) -> String {
        s.lowercased().trimmingCharacters(in: .whitespaces)
            .filter { !".,!?;:".contains($0) }
    }
    private func check() {
        guard result != true else { return }
        let ok = norm(shown) == norm(word.v)
        result = ok
        progress.record("w:" + word.v, right: ok)
        Speech.shared.speak(word.v, lang: "vi")
    }
    private func hint() -> String {
        let g = norm(shown), t = norm(word.v)
        if g.isEmpty { return "Nichts eingegeben. Sprich das Wort vietnamesisch aus und tipp Silbe für Silbe." }
        if VN.stripTone(g) == VN.stripTone(t) { return "Die Buchstaben stimmen — nur die Töne noch nicht." }
        return "Hör dir das Wort noch einmal an — oder tipp auf „Zeigen“."
    }
    private func reveal() {
        revealed = true
        result = nil
        raw = word.v; rendered = word.v; shown = word.v
        progress.record("w:" + word.v, right: false)
        Speech.shared.speak(word.v, lang: "vi")
    }
    private func next() {
        word = progress.pick(VietnameseData.words + MyWords.shared.asVWords, key: { "w:" + $0.v }, avoid: "w:" + word.v)
        raw = ""; shown = ""; rendered = ""
        result = nil; revealed = false
        seen += 1
        focused = true
    }
}

// ── Lesen ───────────────────────────────────────────────
struct ReadView: View {
    @State private var idx = 0
    @State private var pickedWord: String? = nil
    @State private var showTranslation = false
    @State private var showDict = false

    private var sentence: VSentence { VietnameseData.sentences[idx] }
    private static let lookup: [String: VWord] = {
        var m: [String: VWord] = [:]
        for w in VietnameseData.words { m[w.v.lowercased()] = m[w.v.lowercased()] ?? w }
        for w in MyWords.shared.asVWords { m[w.v.lowercased()] = m[w.v.lowercased()] ?? w }
        return m
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Lies laut vor — das ist die eigentliche Übung. Tipp ein Wort an, wenn du hängen bleibst.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("SATZ").font(.caption2.weight(.semibold)).kerning(1.2).foregroundStyle(Color.ink3)
                            Spacer()
                            Text("\(idx + 1) / \(VietnameseData.sentences.count)")
                                .font(.caption2.monospaced()).foregroundStyle(Color.ink3)
                        }
                        FlowLayout(spacing: 8) {
                            ForEach(Array(sentence.vi.split(separator: " ").enumerated()), id: \.offset) { _, tok in
                                let clean = String(tok).filter { !".,!?;:".contains($0) }
                                Button {
                                    pickedWord = clean
                                    Speech.shared.speak(clean, lang: "vi")
                                } label: {
                                    Text(String(tok))
                                        .font(.system(.title2, design: .serif))
                                        .foregroundStyle(pickedWord == clean ? Color.vermilion : Color.ink)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        if let w = pickedWord {
                            let entry = Self.lookup[w.lowercased()]
                            let t = TONES[VN.tone(of: w)]
                            (Text(w).font(.system(.body, design: .serif).weight(.semibold))
                             + Text(entry.map { " — \($0.de)" } ?? "")
                             + Text("  ·  ohne Ton ").foregroundStyle(Color.ink3)
                             + Text(VN.stripTone(w)).font(.system(.body, design: .serif))
                             + Text(", Ton ").foregroundStyle(Color.ink3)
                             + Text(t.name).foregroundStyle(Color.indigo).font(.body.weight(.semibold)))
                                .font(.subheadline)
                                .foregroundStyle(Color.ink2)
                        } else {
                            Text("Tipp ein Wort an →").font(.subheadline).foregroundStyle(Color.ink3)
                        }
                        Button {
                            Speech.shared.speak(sentence.vi, lang: "vi")
                        } label: {
                            Label("vorlesen lassen", systemImage: "speaker.wave.2").font(.footnote)
                        }
                        .buttonStyle(.bordered).buttonBorderShape(.capsule)
                        .frame(maxWidth: .infinity)

                        Divider()
                        Text(sentence.de)
                            .font(.system(.body, design: .serif))
                            .foregroundStyle(Color.ink2)
                            .blur(radius: showTranslation ? 0 : 6)
                            .onTapGesture { showTranslation.toggle() }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if !showTranslation {
                            Text("Übersetzung antippen zum Aufdecken").font(.caption2).foregroundStyle(Color.ink3)
                        }

                        HStack(spacing: 8) {
                            Button { step(1) } label: { Text("Nächster Satz →").frame(maxWidth: .infinity) }
                                .buttonStyle(.borderedProminent)
                            Button("← Zurück") { step(-1) }
                                .buttonStyle(.bordered)
                        }
                    }
                    .card()
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle("Lesen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showDict = true } label: {
                        Label("Wörterbuch", systemImage: "character.book.closed")
                    }
                }
            }
            .sheet(isPresented: $showDict) { DictionaryView(ui: "de") }
        }
    }
    private func step(_ d: Int) {
        idx = (idx + d + VietnameseData.sentences.count) % VietnameseData.sentences.count
        pickedWord = nil
        showTranslation = false
    }
}

// ── Laute ───────────────────────────────────────────────
struct ConSoundsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Die Fallen sind nicht die Töne, sondern die Buchstaben, die anders klingen als im Deutschen. Tipp ein Beispiel an, um es zu hören.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .listRowBackground(Color.paper)
                }
                Section("Konsonanten, die täuschen") {
                    ForEach(VietnameseData.consonants) { SoundRow(card: $0, lang: "vi") }
                }
                Section("Die sieben eigenen Vokale — Vokalzeichen, keine Töne") {
                    ForEach(VietnameseData.vowels) { SoundRow(card: $0, lang: "vi") }
                }
                Section {
                    Text("Nord und Süd: Deine Eltern sprechen eine bestimmte Variante — beide sind richtig. Geschrieben wird überall gleich; genau deshalb lohnt sich die Schrift.")
                        .font(.caption).foregroundStyle(Color.ink3)
                        .listRowBackground(Color.paper)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Laute")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SoundRow: View {
    let card: SoundCard
    let lang: String
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(card.head)
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(Color.indigo)
            Text(card.desc).font(.subheadline).foregroundStyle(Color.ink2)
            if !card.warn.isEmpty {
                Text(card.warn).font(.caption).foregroundStyle(Color.vermilion)
            }
            FlowLayout(spacing: 6) {
                ForEach(card.examples, id: \.0) { ex, gloss in
                    Button {
                        Speech.shared.speak(ex, lang: lang)
                    } label: {
                        (Text(ex).font(.system(.subheadline, design: .serif).weight(.semibold))
                         + Text(" \(gloss)").font(.caption).foregroundStyle(Color.ink3))
                            .padding(.horizontal, 10).padding(.vertical, 4)
                            .background(Color.surface2.opacity(0.5))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(Color.surface)
    }
}

// ── Mehr ────────────────────────────────────────────────
struct ConMoreView: View {
    @ObservedObject private var progress = Progress.shared
    @AppStorage("profile") private var profile = ""
    @State private var confirmReset = false
    @State private var showVoices = false

    var body: some View {
        NavigationStack {
            List {
                Section("Die sechs Töne") {
                    ForEach(TONES, id: \.id) { t in
                        Button {
                            Speech.shared.speak(t.sample, lang: "vi")
                        } label: {
                            HStack(spacing: 14) {
                                ToneGlyph(tone: t.id).frame(width: 44, height: 26)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(t.name).font(.system(.body, design: .serif).weight(.semibold)).foregroundStyle(Color.ink)
                                    Text("\(t.de) · \(t.markDE)").font(.caption).foregroundStyle(Color.ink3)
                                }
                                Spacer()
                                Text(t.sample).font(.system(.title3, design: .serif)).foregroundStyle(Color.ink)
                            }
                        }
                        .buttonStyle(.plain)
                        .listRowBackground(Color.surface)
                    }
                }
                Section("Telex-Tastatur — so auch am iPhone: Einstellungen → Tastatur → Vietnamesisch (Telex)") {
                    ForEach(VietnameseData.telexRows, id: \.0) { keys, out, ex in
                        HStack {
                            Text(keys).font(.footnote.monospaced())
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Color.surface2).clipShape(RoundedRectangle(cornerRadius: 4))
                            Text(out).font(.system(.body, design: .serif).weight(.semibold)).foregroundStyle(Color.ink)
                            Spacer()
                            Text(ex).font(.caption.monospaced()).foregroundStyle(Color.ink3)
                        }
                        .listRowBackground(Color.surface)
                    }
                }
                Section("Alphabet — 29 Buchstaben, grün = gibt es im Deutschen nicht") {
                    FlowLayout(spacing: 6) {
                        ForEach(VietnameseData.alphabet, id: \.self) { l in
                            Button {
                                Speech.shared.speak(l, lang: "vi")
                            } label: {
                                Text("\(l.uppercased()) \(l)")
                                    .font(.system(.subheadline, design: .serif).weight(.semibold))
                                    .foregroundStyle(Color.ink)
                                    .padding(.horizontal, 8).padding(.vertical, 5)
                                    .background(VietnameseData.newLetters.contains(l) ? Color.celadonBg : Color.surface2.opacity(0.5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listRowBackground(Color.surface)
                }
                Section("Stimme") {
                    Button {
                        showVoices = true
                    } label: {
                        Label("Stimmen anhören & wählen", systemImage: "waveform.circle")
                    }
                    .listRowBackground(Color.surface)
                }
                Section("Fortschritt") {
                    let tDone = progress.mastered(prefix: "t:", of: VietnameseData.tonePool.map(\.v))
                    let wDone = progress.mastered(prefix: "w:", of: VietnameseData.words.map(\.v))
                    Text("Töne: \(tDone)/\(VietnameseData.tonePool.count) · Schreiben: \(wDone)/\(VietnameseData.words.count) · heute: \(progress.today) Karten · Serie: \(progress.streak) Tag\(progress.streak == 1 ? "" : "e")")
                        .font(.footnote).foregroundStyle(Color.ink2)
                        .listRowBackground(Color.surface)
                    Button("Fortschritt zurücksetzen", role: .destructive) { confirmReset = true }
                        .listRowBackground(Color.surface)
                }
                Section {
                    Button {
                        profile = ""
                    } label: {
                        Label("Profil wechseln · Đổi người học", systemImage: "person.2")
                    }
                    .listRowBackground(Color.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Mehr")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Wirklich den ganzen Fortschritt löschen?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Löschen", role: .destructive) { progress.reset() }
            }
            .sheet(isPresented: $showVoices) { VoicePickerView(ui: "de") }
            .onAppear {
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "showvoices") { showVoices = true }
                #endif
            }
        }
    }
}
