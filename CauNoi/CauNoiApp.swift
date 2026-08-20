import SwiftUI

@main
struct CauNoiApp: App {
    @AppStorage("profile") private var profile = ""

    var body: some Scene {
        WindowGroup {
            Group {
                switch profile {
                case "con":  ConRoot()
                case "bome": BoMeRoot()
                default:     ProfilePicker()
                }
            }
            .tint(.indigo)
        }
    }
}

/// Erste Frage beim Start: Wer lernt?
struct ProfilePicker: View {
    @AppStorage("profile") private var profile = ""

    var body: some View {
        ZStack {
            Color.paper.ignoresSafeArea()
            VStack(spacing: 28) {
                Spacer()
                VStack(spacing: 6) {
                    Text("Cầu Nối")
                        .font(.system(size: 44, design: .serif).weight(.semibold))
                        .foregroundStyle(Color.ink)
                    Text("die Brücke · cây cầu nối hai ngôn ngữ")
                        .font(.footnote)
                        .foregroundStyle(Color.ink3)
                }
                Spacer().frame(height: 8)

                Button { profile = "con" } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ich lerne Vietnamesisch")
                            .font(.system(.title3, design: .serif).weight(.semibold))
                        Text("Lesen & Schreiben — für alle, die es nur sprechen. App auf Deutsch.")
                            .font(.subheadline).foregroundStyle(Color.ink2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain).card()

                Button { profile = "bome" } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tôi học tiếng Đức")
                            .font(.system(.title3, design: .serif).weight(.semibold))
                        Text("Từ vựng, mẫu câu và phát âm cho cuộc sống ở Đức. Ứng dụng bằng tiếng Việt.")
                            .font(.subheadline).foregroundStyle(Color.ink2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain).card()

                Spacer()
                Text("Mỗi người một hồ sơ — đổi được bất cứ lúc nào.\nJederzeit umschaltbar.")
                    .font(.caption2).multilineTextAlignment(.center)
                    .foregroundStyle(Color.ink3)
            }
            .padding(24)
            .foregroundStyle(Color.ink)
        }
    }
}
