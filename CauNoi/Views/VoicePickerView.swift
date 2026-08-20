import SwiftUI
import AVFoundation

/// Stimmen anhören, auswählen, und erklären, wo es bessere gibt.
struct VoicePickerView: View {
    let ui: String   // "de" (Con) | "vi" (Bố Mẹ)
    @AppStorage("voice.vi") private var viVoice = ""
    @AppStorage("voice.de") private var deVoice = ""
    @Environment(\.dismiss) private var dismiss

    private func t(_ de: String, _ vi: String) -> String { ui == "de" ? de : vi }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(t("Antippen = anhören und auswählen. Die Reihenfolge: beste Qualität zuerst.",
                           "Bấm vào giọng để nghe thử và chọn. Giọng tốt nhất xếp trên cùng."))
                        .font(.subheadline).foregroundStyle(Color.ink2)
                        .listRowBackground(Color.paper)
                }
                voiceSection(lang: "vi",
                             title: t("Vietnamesische Stimme", "Giọng tiếng Việt"),
                             sample: "Cả nhà mình ăn cơm nhé.",
                             selection: $viVoice)
                voiceSection(lang: "de",
                             title: t("Deutsche Stimme", "Giọng tiếng Đức"),
                             sample: "Guten Morgen! Wie geht es Ihnen?",
                             selection: $deVoice)
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(t("So bekommst du natürlichere Stimmen",
                               "Cách tải giọng hay hơn, tự nhiên hơn"))
                            .font(.footnote.weight(.semibold)).foregroundStyle(Color.goldC)
                        Text(t("iPhone-Einstellungen → Bedienungshilfen → Gesprochene Inhalte → Stimmen → Sprache wählen → eine Stimme mit „Premium“ oder „Verbessert“ laden. Danach hier zurückkommen und auswählen. Premium-Stimmen (z. B. Linh für Vietnamesisch, Anna oder Petra für Deutsch) klingen deutlich angenehmer.",
                               "Vào Cài đặt → Trợ năng → Nội dung được đọc → Giọng đọc → chọn ngôn ngữ → tải giọng có chữ „Premium“ hoặc „Nâng cao“. Tải xong quay lại đây chọn. Giọng Premium nghe tự nhiên và dễ chịu hơn hẳn."))
                            .font(.caption).foregroundStyle(Color.ink2)
                    }
                    .listRowBackground(Color.surface)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.paper)
            .navigationTitle(t("Stimmen", "Giọng đọc"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(t("Fertig", "Xong")) { dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func voiceSection(lang: String, title: String, sample: String, selection: Binding<String>) -> some View {
        let voices = Speech.shared.voices(for: lang)
        Section(title) {
            if voices.isEmpty {
                Text(t("Keine Stimme installiert — siehe Anleitung unten.",
                       "Chưa có giọng nào — xem hướng dẫn ở dưới."))
                    .font(.subheadline).foregroundStyle(Color.vermilion)
                    .listRowBackground(Color.surface)
            }
            ForEach(voices, id: \.identifier) { v in
                Button {
                    selection.wrappedValue = v.identifier
                    Speech.shared.speak(sample, lang: lang)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(v.name).font(.body.weight(.medium)).foregroundStyle(Color.ink)
                            Text("\(Speech.qualityLabel(v, ui: ui)) · \(v.language)")
                                .font(.caption).foregroundStyle(v.quality == .default ? Color.ink3 : Color.celadon)
                        }
                        Spacer()
                        if isSelected(v, lang: lang, selection: selection.wrappedValue) {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(Color.indigo)
                        } else {
                            Image(systemName: "speaker.wave.2").foregroundStyle(Color.ink3)
                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.surface)
            }
        }
    }

    private func isSelected(_ v: AVSpeechSynthesisVoice, lang: String, selection: String) -> Bool {
        if selection.isEmpty {
            return v.identifier == Speech.shared.currentVoice(lang)?.identifier
        }
        return v.identifier == selection
    }
}
