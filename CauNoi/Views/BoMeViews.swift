import SwiftUI

// ═══════════════════════════════════════════════════════
//  Bố-Mẹ-Modus: Deutsch lernen (UI Vietnamesisch)
// ═══════════════════════════════════════════════════════

/// Beispielsatz mit Vorlese-Knopf — kräftig umrandet für den Eltern-Modus.
struct ExampleRow: View {
    let ex: (de: String, vi: String)
    var body: some View {
        Button {
            Speech.shared.speak(ex.de, lang: "de")
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "speaker.wave.2.circle.fill")
                    .font(.title3).foregroundStyle(Color.indigo)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.de)
                        .font(.system(.body, design: .serif).weight(.semibold))
                        .foregroundStyle(Color.ink)
                    Text(ex.vi)
                        .font(.subheadline).foregroundStyle(Color.ink2)
                }
                Spacer()
            }
            .padding(12)
            .background(Color.surface2.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.indigo.opacity(0.4), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .multilineTextAlignment(.leading)
    }
}

struct BoMeRoot: View {
    @State private var tab = UserDefaults.standard.integer(forKey: "tab")
    var body: some View {
        TabView(selection: $tab) {
            ListenQuizView()
                .tabItem { Label("Nghe", systemImage: "ear") }.tag(0)
            ArticleQuizView()
                .tabItem { Label("der · die · das", systemImage: "textformat.abc") }.tag(1)
            PhrasesView()
                .tabItem { Label("Mẫu câu", systemImage: "text.bubble") }.tag(2)
            GermanSoundsView()
                .tabItem { Label("Phát âm", systemImage: "waveform") }.tag(3)
            BoMeMoreView()
                .tabItem { Label("Thêm", systemImage: "ellipsis.circle") }.tag(4)
        }
        // Eltern-Seite: eine Stufe größer voreingestellt.
        .dynamicTypeSize(.xLarge ... .accessibility3)
    }
}

// ── Nghe & chọn (Hörquiz) ───────────────────────────────
struct ListenQuizView: View {
    @ObservedObject private var progress = Progress.shared
    @State private var word = GermanData.words[0]
    @State private var options: [String] = []
    @State private var chosen: String? = nil
    @State private var seen = 0
    @State private var showDict = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Nghe từ tiếng Đức rồi chọn nghĩa đúng. Bấm loa để nghe lại — nghe chậm cũng được.")
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

                        if chosen == nil {
                            Image(systemName: "ear")
                                .font(.system(size: 44))
                                .foregroundStyle(Color.indigo)
                                .padding(.top, 6)
                        } else {
                            VStack(spacing: 2) {
                                Text(word.full)
                                    .font(.system(size: 36, design: .serif).weight(.medium))
                                    .foregroundStyle(word.art.map { Color.article($0) } ?? Color.ink)
                                if let pl = word.pl {
                                    Text("số nhiều: die \(pl)")
                                        .font(.footnote).foregroundStyle(Color.ink3)
                                }
                                if !word.note.isEmpty {
                                    Text(word.note).font(.caption).foregroundStyle(Color.ink3)
                                        .multilineTextAlignment(.center)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            Button {
                                Speech.shared.speak(word.full, lang: "de")
                            } label: {
                                Label("nghe", systemImage: "speaker.wave.2").font(.footnote)
                            }
                            .buttonStyle(.borderedProminent).buttonBorderShape(.capsule)
                            Button {
                                Speech.shared.speak(word.full, lang: "de", slow: true)
                            } label: {
                                Label("chậm", systemImage: "tortoise").font(.footnote)
                            }
                            .buttonStyle(.bordered).buttonBorderShape(.capsule)
                        }

                        VStack(spacing: 8) {
                            ForEach(options, id: \.self) { opt in
                                Button { answer(opt) } label: {
                                    HStack(spacing: 6) {
                                        if chosen != nil && opt == word.vi {
                                            Image(systemName: "checkmark.circle.fill")
                                        } else if opt == chosen && opt != word.vi {
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                        Text(opt)
                                    }
                                    .font(.body.weight(chosen != nil && opt == word.vi ? .bold : .regular))
                                    .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(optBg(opt))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(optBorder(opt), lineWidth: chosen != nil && (opt == word.vi || opt == chosen) ? 2 : 1))
                                }
                                .buttonStyle(.plain)
                                .foregroundStyle(optFg(opt))
                                .allowsHitTesting(chosen == nil)
                            }
                        }

                        if let c = chosen {
                            if let e = Pictos.emoji(de: word.de, cat: word.cat) {
                                Text(e).font(.system(size: 56))
                            }
                            FeedbackBox(
                                ok: c == word.vi,
                                title: c == word.vi ? "Đúng rồi!" : "Chưa đúng.",
                                body_: Text("\(word.full) = \(word.vi)"),
                                bold: true
                            )
                            if let ex = GermanData.examples[word.de] ?? MyWords.shared.example(de: word.de) {
                                ExampleRow(ex: ex)
                            }
                            FlagButton(entry: "\(word.full) = \(word.vi)", ui: "vi")
                            Button { next() } label: {
                                Text("Tiếp →").font(.body.weight(.semibold)).frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }

                        ProgressLine(done: progress.mastered(prefix: "g:", of: (GermanData.words + MyWords.shared.asGWords).map(\.de)),
                                     total: GermanData.words.count + MyWords.shared.items.count,
                                     label: "từ đã thuộc", sep: "trên")
                    }
                    .card()
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle("Nghe & chọn")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showDict = true } label: {
                        Label("Tra từ", systemImage: "character.book.closed")
                    }
                }
            }
            .sheet(isPresented: $showDict) { DictionaryView(ui: "vi") }
            .onAppear {
                if seen == 0 { next() }
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "showdict") { showDict = true }
                if UserDefaults.standard.bool(forKey: "autoanswer"), chosen == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { answer(word.vi) }
                }
                #endif
            }
        }
    }

    private func optBg(_ o: String) -> Color {
        guard chosen != nil else { return .surface }
        if o == word.vi { return .celadon }
        if o == chosen { return .vermilion }
        return .surface
    }
    private func optFg(_ o: String) -> Color {
        guard chosen != nil else { return .ink }
        if o == word.vi || o == chosen { return .paper }
        return .ink
    }
    private func optBorder(_ o: String) -> Color {
        guard chosen != nil else { return .lineC }
        if o == word.vi { return .celadon }
        if o == chosen { return .vermilion }
        return .lineC
    }
    private func answer(_ o: String) {
        guard chosen == nil else { return }
        chosen = o
        progress.record("g:" + word.de, right: o == word.vi)
        Speech.shared.speak(word.full, lang: "de")
    }
    private func next() {
        word = progress.pick(GermanData.words + MyWords.shared.asGWords, key: { "g:" + $0.de }, avoid: "g:" + word.de)
        var opts = [word.vi]
        var others = (GermanData.words + MyWords.shared.asGWords).map(\.vi).filter { $0 != word.vi }.shuffled()
        while opts.count < 4, let o = others.popLast() {
            if !opts.contains(o) { opts.append(o) }
        }
        options = opts.shuffled()
        chosen = nil
        seen += 1
        Speech.shared.speak(word.full, lang: "de")
    }
}

// ── der · die · das ─────────────────────────────────────
struct ArticleQuizView: View {
    @ObservedObject private var progress = Progress.shared
    @State private var word = GermanData.nouns[0]
    @State private var chosen: String? = nil
    @State private var seen = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Mỗi danh từ tiếng Đức có một trong ba „giống“: der, die, das. Không có quy tắc chắc chắn — phải học thuộc từng từ. Màu sắc giúp nhớ: der xanh dương, die đỏ, das xanh lá.")
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
                        if let e = Pictos.emoji(de: word.de, cat: word.cat) {
                            Text(e).font(.system(size: 46))
                        }
                        Text("__ \(word.de)")
                            .font(.system(size: 38, design: .serif).weight(.medium))
                            .foregroundStyle(Color.ink)
                            .minimumScaleFactor(0.5).lineLimit(1)
                        Text(word.vi)
                            .font(.body).foregroundStyle(Color.ink2)
                        Button {
                            // Vor der Antwort ohne Artikel — der Klang würde die Lösung verraten.
                            Speech.shared.speak(chosen == nil ? word.de : word.full, lang: "de")
                        } label: {
                            Label("nghe", systemImage: "speaker.wave.2").font(.footnote)
                        }
                        .buttonStyle(.borderedProminent).buttonBorderShape(.capsule)

                        HStack(spacing: 8) {
                            ForEach(["der", "die", "das"], id: \.self) { a in
                                Button { answer(a) } label: {
                                    HStack(spacing: 6) {
                                        if chosen != nil && a == word.art {
                                            Image(systemName: "checkmark.circle.fill")
                                        } else if a == chosen && a != word.art {
                                            Image(systemName: "xmark.circle.fill")
                                        }
                                        Text(a)
                                    }
                                    .font(.system(.title2, design: .serif).weight(.bold))
                                    .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(artBg(a))
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(artStroke(a), lineWidth: 2))
                                        .foregroundStyle(artFg(a))
                                        .opacity(chosen != nil && a != word.art && a != chosen ? 0.35 : 1)
                                }
                                .buttonStyle(.plain)
                                .allowsHitTesting(chosen == nil)
                            }
                        }

                        if let c = chosen {
                            FeedbackBox(
                                ok: c == word.art,
                                title: c == word.art ? "Đúng rồi!" : "Chưa đúng — là \(word.art!).",
                                body_: Text("\(word.full)")
                                    .font(.body.weight(.semibold))
                                    + Text(word.pl.map { " · số nhiều: die \($0) (số nhiều luôn là die)" } ?? "")
                                    + Text(GermanData.articleHint(de: word.de, art: word.art!).map { "\n\($0)" } ?? "")
                                    + Text(word.note.isEmpty ? "" : "\n\(word.note)"),
                                bold: true
                            )
                            if let ex = GermanData.examples[word.de] ?? MyWords.shared.example(de: word.de) {
                                ExampleRow(ex: ex)
                            }
                            FlagButton(entry: "\(word.full) = \(word.vi)", ui: "vi")
                            Button { next() } label: {
                                Text("Tiếp →").font(.body.weight(.semibold)).frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                        }

                        ProgressLine(done: progress.mastered(prefix: "a:", of: (GermanData.nouns + MyWords.shared.asGNouns).map(\.de)),
                                     total: GermanData.nouns.count + MyWords.shared.asGNouns.count,
                                     label: "danh từ đã thuộc", sep: "trên")
                    }
                    .card()
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle("der · die · das")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if seen == 0 { next() }
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "autoanswer"), chosen == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        answer(word.art == "die" ? "das" : "die")
                    }
                }
                #endif
            }
        }
    }

    private func artBg(_ a: String) -> Color {
        guard chosen != nil else { return Color.article(a) }
        if a == word.art { return .celadon }
        if a == chosen { return .vermilion }
        return .surface
    }
    private func artFg(_ a: String) -> Color {
        guard chosen != nil else { return .paper }
        if a == word.art || a == chosen { return .paper }
        return Color.article(a)
    }
    private func artStroke(_ a: String) -> Color {
        guard chosen != nil else { return Color.article(a) }
        if a == word.art { return .celadon }
        if a == chosen { return .vermilion }
        return .lineC
    }
    private func answer(_ a: String) {
        guard chosen == nil else { return }
        chosen = a
        progress.record("a:" + word.de, right: a == word.art)
        Speech.shared.speak(word.full, lang: "de")
    }
    private func next() {
        word = progress.pick(GermanData.nouns + MyWords.shared.asGNouns, key: { "a:" + $0.de }, avoid: "a:" + word.de)
        chosen = nil
        seen += 1
    }
}

// ── Mẫu câu ─────────────────────────────────────────────
struct PhrasesView: View {
    @State private var showDict = false
    @State private var showBuilder = false
    @ObservedObject private var my = MyWords.shared
    private var mySentences: [(de: String, vi: String)] {
        my.items.compactMap { w in
            guard let d = w.exDe, let v = w.exVi else { return nil }
            return (d, v)
        }
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Bấm vào câu để nghe. Bấm con rùa để nghe chậm. Tập nói theo từng câu một.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .listRowBackground(Color.paper)
                }
                Section {
                    Button { showBuilder = true } label: {
                        HStack(spacing: 12) {
                            Text("🧩").font(.system(size: 34))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Ghép câu — luyện tập")
                                    .font(.system(.body, design: .serif).weight(.bold))
                                    .foregroundStyle(Color.paper)
                                Text("Xếp ô chữ thành câu tiếng Đức")
                                    .font(.subheadline).foregroundStyle(Color.paper.opacity(0.85))
                            }
                            Spacer()
                            Image(systemName: "chevron.right").foregroundStyle(Color.paper)
                        }
                        .padding(.vertical, 6)
                    }
                    .listRowBackground(Color.indigo)
                }
                if !mySentences.isEmpty {
                    Section("Câu của tôi — từ những từ đã tra") {
                        ForEach(mySentences, id: \.de) { p in
                            Button {
                                Speech.shared.speak(p.de, lang: "de")
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(p.de)
                                        .font(.system(.body, design: .serif).weight(.semibold))
                                        .foregroundStyle(Color.ink)
                                    Text(p.vi)
                                        .font(.subheadline).foregroundStyle(Color.ink2)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .listRowBackground(Color.surface)
                        }
                    }
                }
                ForEach(GermanData.phraseCats, id: \.self) { cat in
                    Section(cat) {
                        ForEach(GermanData.phrases.filter { $0.cat == cat }) { p in
                            HStack(alignment: .firstTextBaseline, spacing: 10) {
                                Button {
                                    Speech.shared.speak(p.de, lang: "de")
                                } label: {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(p.de)
                                            .font(.system(.body, design: .serif).weight(.semibold))
                                            .foregroundStyle(Color.ink)
                                        Text(p.vi)
                                            .font(.subheadline).foregroundStyle(Color.ink2)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .buttonStyle(.plain)
                                Button {
                                    Speech.shared.speak(p.de, lang: "de", slow: true)
                                } label: {
                                    Image(systemName: "tortoise")
                                        .font(.footnote)
                                        .foregroundStyle(Color.indigo)
                                }
                                .buttonStyle(.borderless)
                            }
                            .listRowBackground(Color.surface)
                        }
                    }
                }
                Section("Số đếm — cẩn thận: đọc ngược!") {
                    Text(GermanData.numberNote)
                        .font(.footnote).foregroundStyle(Color.vermilion)
                        .listRowBackground(Color.surface)
                    FlowLayout(spacing: 6) {
                        ForEach(GermanData.numbers, id: \.0) { de, num in
                            Button {
                                Speech.shared.speak(de, lang: "de")
                            } label: {
                                (Text(de).font(.subheadline.weight(.semibold))
                                 + Text(" \(num)").font(.caption).foregroundStyle(Color.ink3))
                                    .padding(.horizontal, 10).padding(.vertical, 5)
                                    .background(Color.surface2.opacity(0.5))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(Color.ink)
                        }
                    }
                    .listRowBackground(Color.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Mẫu câu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showDict = true } label: {
                        Label("Tra từ", systemImage: "character.book.closed")
                    }
                }
            }
            .sheet(isPresented: $showDict) { DictionaryView(ui: "vi") }
            .sheet(isPresented: $showBuilder) { TileQuizView() }
            .onAppear {
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "showbuild") { showBuilder = true }
                #endif
            }
        }
    }
}

// ── Phát âm ─────────────────────────────────────────────
struct GermanSoundsView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Chữ Đức không khó — chỉ có mấy chữ cái đọc khác. Bấm vào ví dụ để nghe.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .listRowBackground(Color.paper)
                }
                Section("Những chữ đọc khác tiếng Việt") {
                    ForEach(GermanData.sounds) { SoundRow(card: $0, lang: "de") }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Phát âm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// ── Thêm ────────────────────────────────────────────────
struct BoMeMoreView: View {
    @ObservedObject private var progress = Progress.shared
    @AppStorage("profile") private var profile = ""
    @State private var confirmReset = false
    @State private var showVoices = false
    @ObservedObject private var my = MyWords.shared
    @ObservedObject private var flags = Flags.shared

    var body: some View {
        NavigationStack {
            List {
                Section("Tiến độ") {
                    let gDone = progress.mastered(prefix: "g:", of: (GermanData.words + MyWords.shared.asGWords).map(\.de))
                    let aDone = progress.mastered(prefix: "a:", of: (GermanData.nouns + MyWords.shared.asGNouns).map(\.de))
                    Text("Nghe & chọn: \(gDone)/\(GermanData.words.count + MyWords.shared.items.count) · der die das: \(aDone)/\(GermanData.nouns.count + MyWords.shared.asGNouns.count) · hôm nay: \(progress.today) thẻ · chuỗi ngày: \(progress.streak)")
                        .font(.footnote).foregroundStyle(Color.ink2)
                        .listRowBackground(Color.surface)
                    Text("Một từ được tính là „đã thuộc“ khi trả lời đúng ba lần. Từ đã thuộc vẫn thỉnh thoảng quay lại.")
                        .font(.caption).foregroundStyle(Color.ink3)
                        .listRowBackground(Color.surface)
                    Button("Xóa hết tiến độ", role: .destructive) { confirmReset = true }
                        .listRowBackground(Color.surface)
                }
                if !Flags.shared.items.isEmpty {
                    Section("Đã ghi lại — nghe lạ (\(flags.items.count))") {
                        ForEach(flags.items, id: \.self) { f in
                            Text(f).font(.subheadline).foregroundStyle(Color.ink2)
                                .listRowBackground(Color.surface)
                        }
                        .onDelete { idx in idx.map { flags.items[$0] }.forEach { flags.remove($0) } }
                        Text("Đưa danh sách này cho con xem để sửa lại lời dịch.")
                            .font(.caption).foregroundStyle(Color.ink3)
                            .listRowBackground(Color.paper)
                    }
                }
                if !my.items.isEmpty {
                    Section("Từ của tôi (\(my.items.count)) — vuốt sang trái để xóa") {
                        ForEach(my.items) { w in
                            HStack {
                                Text(w.art.map { "\($0) " } ?? "")
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(w.art.map { Color.article($0) } ?? Color.ink) +
                                Text(w.de).font(.body.weight(.semibold)).foregroundStyle(Color.ink)
                                Spacer()
                                Text(w.vi).font(.subheadline).foregroundStyle(Color.ink2)
                            }
                            .listRowBackground(Color.surface)
                        }
                        .onDelete { idx in
                            idx.map { my.items[$0] }.forEach { my.remove($0) }
                        }
                    }
                }
                Section("Giọng đọc") {
                    Button {
                        showVoices = true
                    } label: {
                        Label("Nghe thử & chọn giọng đọc", systemImage: "waveform.circle")
                    }
                    .listRowBackground(Color.surface)
                }
                Section("Chữ to hơn") {
                    Text("Muốn chữ to hơn nữa: Cài đặt (Einstellungen) → Màn hình & Độ sáng → Cỡ chữ.")
                        .font(.footnote).foregroundStyle(Color.ink2)
                        .listRowBackground(Color.surface)
                }
                Section {
                    Button {
                        profile = ""
                    } label: {
                        Label("Đổi người học · Profil wechseln", systemImage: "person.2")
                    }
                    .listRowBackground(Color.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle("Thêm")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("Xóa hết tiến độ học?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Xóa", role: .destructive) { progress.reset() }
            }
            .sheet(isPresented: $showVoices) { VoicePickerView(ui: "vi") }
            .onAppear {
                #if DEBUG
                if UserDefaults.standard.bool(forKey: "showvoices") { showVoices = true }
                #endif
            }
        }
    }
}
