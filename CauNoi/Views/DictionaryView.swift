import SwiftUI

/// Wörterbuch-Sheet — beide Profile, Texte je nach UI-Sprache.
struct DictionaryView: View {
    /// "de" = deutsche Oberfläche (Con), "vi" = vietnamesische (Bố Mẹ)
    let ui: String
    @State private var query = ""
    @State private var deToVi: Bool
    @State private var result: DictEntry? = nil
    @State private var errorText: String? = nil
    @State private var loading = false
    @ObservedObject private var dict = Dict.shared
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused: Bool

    init(ui: String) {
        self.ui = ui
        // Con sucht meist VN→DE, die Eltern DE→VN
        _deToVi = State(initialValue: ui == "vi")
    }

    private func t(_ de: String, _ vi: String) -> String { ui == "de" ? de : vi }
    private var fromLang: String { deToVi ? "de" : "vi" }
    private var toLang: String { deToVi ? "vi" : "de" }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    Picker("", selection: $deToVi) {
                        Text("Deutsch → Việt").tag(true)
                        Text("Việt → Deutsch").tag(false)
                    }
                    .pickerStyle(.segmented)

                    HStack(spacing: 8) {
                        TextField(t("Wort eingeben …", "Nhập từ …"), text: $query)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($focused)
                            .onSubmit { run() }
                        Button { run() } label: {
                            if loading { ProgressView() } else { Image(systemName: "magnifyingglass") }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(loading || query.trimmingCharacters(in: .whitespaces).isEmpty)
                    }

                    if let e = errorText {
                        Text(e)
                            .font(.subheadline)
                            .foregroundStyle(Color.vermilion)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
                            .background(Color.vermBg)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    if let r = result {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(r.q)
                                    .font(.system(.title3, design: .serif).weight(.semibold))
                                Spacer()
                                Button {
                                    Speech.shared.speak(r.q, lang: r.from)
                                } label: { Image(systemName: "speaker.wave.2") }
                                    .buttonStyle(.bordered).buttonBorderShape(.circle)
                            }
                            Divider()
                            HStack {
                                Text(r.main)
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.indigo)
                                Spacer()
                                Button {
                                    Speech.shared.speak(r.main, lang: r.to)
                                } label: { Image(systemName: "speaker.wave.2") }
                                    .buttonStyle(.bordered).buttonBorderShape(.circle)
                            }
                            if !r.alts.isEmpty {
                                Text(t("Weitere Treffer:", "Kết quả khác:"))
                                    .font(.caption).foregroundStyle(Color.ink3)
                                ForEach(r.alts, id: \.self) { a in
                                    Button {
                                        Speech.shared.speak(a, lang: r.to)
                                    } label: {
                                        Label(a, systemImage: "speaker.wave.1")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.ink2)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            Text(t("Automatische Übersetzung — bei wichtigen Sachen (Amt, Arzt) lieber doppelt prüfen.",
                                   "Bản dịch tự động — chuyện quan trọng (cơ quan, bác sĩ) nên kiểm tra lại."))
                                .font(.caption2).foregroundStyle(Color.ink3)
                        }
                        .card()
                    }

                    if !dict.history.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(t("Zuletzt gesucht — auch offline verfügbar", "Đã tra — dùng được cả khi không có mạng"))
                                .font(.caption.weight(.semibold)).foregroundStyle(Color.ink3)
                            ForEach(dict.history.prefix(12)) { h in
                                Button {
                                    query = h.q
                                    deToVi = h.from == "de"
                                    result = h
                                    errorText = nil
                                } label: {
                                    HStack {
                                        Text(h.q).font(.subheadline.weight(.medium)).foregroundStyle(Color.ink)
                                        Text("→ \(h.main)").font(.subheadline).foregroundStyle(Color.ink2)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.vertical, 3)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .card()
                    }

                    Text(t("Quelle: MyMemory (mymemory.translated.net) — kostenlos, keine Anmeldung.",
                           "Nguồn: MyMemory (mymemory.translated.net) — miễn phí."))
                        .font(.caption2).foregroundStyle(Color.ink3)
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle(t("Wörterbuch", "Tra từ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(t("Fertig", "Xong")) { dismiss() }
                }
            }
            .onAppear {
                #if DEBUG
                if let q = UserDefaults.standard.string(forKey: "dictq"), !q.isEmpty {
                    query = q
                    run()
                    return
                }
                #endif
                focused = true
            }
        }
    }

    private func run() {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return }
        loading = true
        errorText = nil
        Task {
            defer { loading = false }
            do {
                result = try await Dict.shared.lookup(q, from: fromLang, to: toLang)
            } catch {
                result = Dict.shared.cached(q, from: fromLang, to: toLang)
                errorText = t("Gerade kein Internet — gespeicherte Suchen unten funktionieren trotzdem.",
                              "Không có mạng — những từ đã tra ở dưới vẫn dùng được.")
            }
        }
    }
}
