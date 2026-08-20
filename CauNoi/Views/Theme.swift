import SwiftUI

/// Farbwelt Sơn mài — identisch zur Web-App, hell/dunkel adaptiv.
extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { tc in
            let h = tc.userInterfaceStyle == .dark ? dark : light
            return UIColor(
                red: CGFloat((h >> 16) & 0xFF) / 255,
                green: CGFloat((h >> 8) & 0xFF) / 255,
                blue: CGFloat(h & 0xFF) / 255, alpha: 1)
        })
    }
    static let paper      = Color(light: 0xE9E8E1, dark: 0x10181F)
    static let surface    = Color(light: 0xF7F6F1, dark: 0x17222B)
    static let surface2   = Color(light: 0xDFDED5, dark: 0x1E2C37)
    static let lineC      = Color(light: 0xC9C8BC, dark: 0x2C3D4A)
    static let ink        = Color(light: 0x15202B, dark: 0xE3E7E4)
    static let ink2       = Color(light: 0x43535F, dark: 0xA6B4BC)
    static let ink3       = Color(light: 0x6E7C86, dark: 0x7C8B95)
    static let indigo     = Color(light: 0x23405D, dark: 0x8FB4D8)
    static let celadon    = Color(light: 0x45775E, dark: 0x7FBE97)
    static let celadonBg  = Color(light: 0xCFE2D6, dark: 0x1B2E26)
    static let vermilion  = Color(light: 0xB03A24, dark: 0xE5765D)
    static let vermBg     = Color(light: 0xF2D6CB, dark: 0x331C17)
    static let goldC      = Color(light: 0x9C7526, dark: 0xD2A85C)

    /// der / die / das
    static func article(_ a: String) -> Color {
        switch a {
        case "der": return .indigo
        case "die": return .vermilion
        default:    return .celadon
        }
    }
}

/// Tonhöhen-Kurve eines Tons — die Bildsprache der App.
struct ToneCurve: Shape {
    let tone: Int
    func path(in r: CGRect) -> Path {
        var p = Path()
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: r.minX + x * r.width, y: r.minY + y * r.height)
        }
        switch tone {
        case 0: p.move(to: pt(0.10, 0.50)); p.addLine(to: pt(0.90, 0.50))
        case 1: p.move(to: pt(0.10, 0.32)); p.addLine(to: pt(0.90, 0.75))
        case 2: p.move(to: pt(0.10, 0.75)); p.addLine(to: pt(0.90, 0.25))
        case 3: p.move(to: pt(0.10, 0.36))
                p.addCurve(to: pt(0.90, 0.43), control1: pt(0.28, 0.92), control2: pt(0.62, 0.92))
        case 4: p.move(to: pt(0.10, 0.68))
                p.addCurve(to: pt(0.42, 0.44), control1: pt(0.20, 0.38), control2: pt(0.33, 0.66))
                p.move(to: pt(0.57, 0.46)); p.addLine(to: pt(0.90, 0.16))
        default: p.move(to: pt(0.30, 0.28)); p.addLine(to: pt(0.60, 0.66))
        }
        return p
    }
}

struct ToneGlyph: View {
    let tone: Int
    var color: Color = .indigo
    var body: some View {
        ZStack {
            ToneCurve(tone: tone)
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
            if tone == 5 {
                GeometryReader { g in
                    Circle().fill(color)
                        .frame(width: 5, height: 5)
                        .position(x: g.size.width * 0.68, y: g.size.height * 0.78)
                }
            }
        }
    }
}

/// Zeilenumbruch-Layout für antippbare Wörter.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxW = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > maxW, x > 0 { x = 0; y += rowH + spacing; rowH = 0 }
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
        return CGSize(width: maxW == .infinity ? x : maxW, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for v in subviews {
            let s = v.sizeThatFits(.unspecified)
            if x + s.width > bounds.maxX, x > bounds.minX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            v.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(s))
            x += s.width + spacing
            rowH = max(rowH, s.height)
        }
    }
}

/// Karten-Hintergrund.
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.lineC, lineWidth: 1))
    }
}
extension View {
    func card() -> some View { modifier(CardStyle()) }
}

/// Rückmeldebalken unter einer Antwort.
struct FeedbackBox: View {
    let ok: Bool
    let title: String
    let body_: Text
    /// Eltern-Modus: gefüllte, kräftige Fläche statt dünner Linie.
    var bold = false
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(bold ? .title3 : .body, design: .serif).weight(.semibold))
                .foregroundStyle(ok ? Color.celadon : Color.vermilion)
            body_
                .font(bold ? .body : .subheadline)
                .foregroundStyle(Color.ink2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 12)
        .padding(bold ? 12 : 0)
        .background(bold ? (ok ? Color.celadonBg : Color.vermBg) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: bold ? 6 : 0))
        .overlay(alignment: .leading) {
            Rectangle().fill(ok ? Color.celadon : Color.vermilion).frame(width: bold ? 4 : 2)
        }
    }
}
