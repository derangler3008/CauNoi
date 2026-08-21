import SwiftUI

/// Ghép câu — Satz aus Wortkacheln zusammensetzen (Duolingo-Mechanik).
struct TileQuizView: View {
    @ObservedObject private var progress = Progress.shared
    @Environment(\.dismiss) private var dismiss
    @State private var pair = SentencePair(de: "Guten Morgen!", vi: "Chào buổi sáng!", source: "Mẫu câu")
    @State private var bank: [String] = []      // verfügbare Kacheln
    @State private var answer: [String] = []    // gelegte Kacheln
    @State private var checked: Bool? = nil     // nil = offen, true/false = Ergebnis
    @State private var seen = 0

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    Text("Đọc câu tiếng Việt, rồi xếp các ô chữ thành câu tiếng Đức đúng.")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(Color.ink2)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(spacing: 12) {
                        HStack {
                            Text(pair.source)
                                .font(.caption2.weight(.semibold)).textCase(.uppercase)
                                .foregroundStyle(Color.ink3)
                            Spacer()
                            Text("#\(seen)").font(.caption2).foregroundStyle(Color.ink3)
                        }
                        Text(pair.vi)
                            .font(.system(.title3, design: .serif).weight(.semibold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)

                        // Antwortzeile
                        FlowLayout(spacing: 8) {
                            ForEach(Array(answer.enumerated()), id: \.offset) { i, w in
                                Button {
                                    guard checked == nil else { return }
                                    bank.append(answer.remove(at: i))
                                } label: { Tile(text: w, filled: true) }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                        .padding(10)
                        .background(Color.paper)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: checked == nil ? 1 : 2))

                        // Kachel-Bank
                        FlowLayout(spacing: 8) {
                            ForEach(Array(bank.enumerated()), id: \.offset) { i, w in
                                Button {
                                    guard checked == nil else { return }
                                    answer.append(bank.remove(at: i))
                                } label: { Tile(text: w, filled: false) }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if let ok = checked {
                            FeedbackBox(
                                ok: ok,
                                title: ok ? "Đúng rồi!" : "Chưa đúng.",
                                body_: Text(pair.de).font(.body.weight(.semibold))
                                    + Text("\n\(pair.vi)"),
                                bold: true
                            )
                        }

                        HStack(spacing: 8) {
                            if checked == nil {
                                Button {
                                    let ok = answer == pair.tiles
                                    checked = ok
                                    progress.record("b:" + pair.de, right: ok)
                                    Speech.shared.speak(pair.de, lang: "de")
                                } label: {
                                    Text("Kiểm tra").font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .disabled(answer.isEmpty)
                            } else {
                                Button {
                                    Speech.shared.speak(pair.de, lang: "de")
                                } label: { Label("nghe", systemImage: "speaker.wave.2") }
                                .buttonStyle(.bordered)
                                Button { next() } label: {
                                    Text("Tiếp →").font(.body.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                            }
                        }
                    }
                    .card()
                }
                .padding()
            }
            .background(Color.paper)
            .navigationTitle("Ghép câu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) { Button("Xong") { dismiss() } }
            }
            .onAppear { if seen == 0 { next() } }
        }
    }

    private var borderColor: Color {
        switch checked {
        case .some(true): return .celadon
        case .some(false): return .vermilion
        case nil: return .lineC
        }
    }

    private func next() {
        let pool = SentenceFactory.pool()
        pair = progress.pick(pool, key: { "b:" + $0.de }, avoid: "b:" + pair.de)
        bank = pair.tiles.shuffled()
        // Nie in schon gelöster Reihenfolge zeigen
        if bank == pair.tiles && bank.count > 1 { bank.reverse() }
        answer = []
        checked = nil
        seen += 1
    }
}

private struct Tile: View {
    let text: String
    let filled: Bool
    var body: some View {
        Text(text)
            .font(.system(.body, design: .serif).weight(.semibold))
            .padding(.horizontal, 12).padding(.vertical, 8)
            .background(filled ? Color.indigo : Color.surface)
            .foregroundStyle(filled ? Color.paper : Color.ink)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.lineC, lineWidth: filled ? 0 : 1))
    }
}
