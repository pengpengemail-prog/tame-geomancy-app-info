import SwiftUI
import Combine

enum AppAppearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system:
            return TAMEL10n.text("跟随系统", "Follow System")
        case .light:
            return TAMEL10n.text("浅色", "Light")
        case .dark:
            return TAMEL10n.text("深色", "Dark")
        }
    }

    var summary: String {
        switch self {
        case .system:
            return TAMEL10n.text("当前版本统一采用白底品牌界面；即使跟随系统，也保持浅色可读性。", "This release keeps the branded white interface even when system appearance changes.")
        case .light:
            return TAMEL10n.text("使用白底、深蓝黑文字与星砂金强调的品牌标准界面。", "Uses the standard white-background brand interface with deep ink text and soft gold accents.")
        case .dark:
            return TAMEL10n.text("为保证罗盘与分析页可读性，当前版本夜间也保持白底品牌界面。", "To preserve compass and analysis readability, the current release also keeps a white branded interface at night.")
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system, .light, .dark:
            return .light
        }
    }
}

enum TAMETheme {
    static let deepSpaceBlack = Color(red: 5 / 255, green: 5 / 255, blue: 5 / 255)
    static let moonWhite = Color(red: 253 / 255, green: 252 / 255, blue: 251 / 255)
    static let stardustGold = Color(red: 189 / 255, green: 160 / 255, blue: 106 / 255)
    static let techGray = Color(red: 138 / 255, green: 143 / 255, blue: 152 / 255)
    static let deepBlueBlack = Color(red: 13 / 255, green: 17 / 255, blue: 23 / 255)
    static let ghostInk = deepBlueBlack.opacity(0.04)

    static let pageBackground = moonWhite
    static let cardBackground = Color.white
    static let emphasizedCardBackground = Color(red: 252 / 255, green: 251 / 255, blue: 248 / 255)
    static let fieldBackground = Color(red: 250 / 255, green: 249 / 255, blue: 246 / 255)
    static let chromeBackground = Color.white
    static let shadow = Color.black.opacity(0.03)

    static let brandTextPrimary = deepBlueBlack.opacity(0.96)
    static let brandTextSecondary = deepBlueBlack.opacity(0.68)
    static let brandTextMuted = techGray.opacity(0.96)
    static let brandHairline = deepBlueBlack.opacity(0.08)
    static let brandStroke = stardustGold.opacity(0.16)
    static let brandGlow = stardustGold.opacity(0.05)
    static let brandShadow = Color.black.opacity(0.035)
    static let brandAlert = Color(red: 190 / 255, green: 108 / 255, blue: 86 / 255)
    static let brandChipFill = Color.white.opacity(0.92)
    static let brandChipStrongFill = stardustGold.opacity(0.14)

    static let brandBadgeTop = Color.white
    static let brandBadgeBottom = Color(red: 249 / 255, green: 247 / 255, blue: 243 / 255)
    static let brandBadgeCore = stardustGold
    static let brandBadgeHighlight = Color.white
    static let brandPanelTint = Color(red: 251 / 255, green: 250 / 255, blue: 247 / 255)
    static let bottomContentInset: CGFloat = 164

    static var brandPageBackground: LinearGradient {
        LinearGradient(
            colors: [
                moonWhite,
                Color.white
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func brandCardFill(emphasized: Bool = false) -> Color {
        emphasized ? emphasizedCardBackground : cardBackground
    }

    static var brandGlassOverlay: Color {
        .clear
    }

    static var brandStrokeGradient: LinearGradient {
        LinearGradient(
            colors: [
                deepBlueBlack.opacity(0.08),
                stardustGold.opacity(0.12)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func tamePageBackground() -> some View {
        background(TAMETheme.brandPageBackground.ignoresSafeArea())
    }

    func tameCardStyle(emphasized: Bool = false, shadow: Bool = true) -> some View {
        background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TAMETheme.brandCardFill(emphasized: emphasized))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(TAMETheme.brandGlassOverlay)
                .blendMode(.screen)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(TAMETheme.brandStrokeGradient, lineWidth: 1)
        }
        .shadow(color: shadow ? TAMETheme.brandShadow.opacity(0.9) : .clear, radius: 18, y: 8)
    }

    func tameBrandPageBackground() -> some View {
        background(TAMETheme.brandPageBackground.ignoresSafeArea())
    }

    func tameBrandPanel(cornerRadius: CGFloat = 24, emphasized: Bool = false, shadow: Bool = true) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(TAMETheme.brandCardFill(emphasized: emphasized))
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(TAMETheme.brandStrokeGradient, lineWidth: 1)
        }
        .shadow(color: shadow ? TAMETheme.brandShadow.opacity(0.55) : .clear, radius: 14, y: 8)
    }

    func tameInstrumentCard(cornerRadius: CGFloat = 18, emphasized: Bool = false, shadow: Bool = true) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(TAMETheme.brandCardFill(emphasized: emphasized))
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(TAMETheme.brandHairline, lineWidth: 0.9)
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.9), lineWidth: 0.6)
                .blur(radius: 0.2)
                .padding(0.4)
        }
        .shadow(color: shadow ? TAMETheme.brandShadow.opacity(0.85) : .clear, radius: 18, y: 10)
    }

    func tameFieldStyle(cornerRadius: CGFloat = 14) -> some View {
        background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color.white.opacity(0.96))
        )
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(TAMETheme.brandHairline, lineWidth: 1)
        }
    }

    @ViewBuilder
    func tameOnChangeCompat<Value: Equatable>(of value: Value, perform action: @escaping () -> Void) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: value) {
                action()
            }
        } else {
            self.modifier(TAMELegacyOnChangeModifier(value: value, action: action))
        }
    }
}

private struct TAMELegacyOnChangeModifier<Value: Equatable>: ViewModifier {
    let value: Value
    let action: () -> Void
    @State private var previousValue: Value?

    func body(content: Content) -> some View {
        content.onReceive(Just(value)) { newValue in
            if let previousValue, previousValue != newValue {
                action()
            }
            previousValue = newValue
        }
    }
}

struct TAMEFeatureBadge: View {
    let icon: String
    let accentIcon: String?
    let tint: Color
    var size: CGFloat = 58

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .stroke(TAMETheme.brandHairline, lineWidth: 0.9)
                }

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(0.82), lineWidth: size * 0.024)
                .frame(width: size * 0.56, height: size * 0.56)

            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .trim(from: 0.01, to: 0.06)
                    .stroke(TAMETheme.stardustGold, style: StrokeStyle(lineWidth: size * 0.028, lineCap: .round))
                    .frame(width: size * 0.59, height: size * 0.59)
                    .rotationEffect(.degrees(Double(index) * 72 - 90))
            }

            Image(systemName: icon)
                .font(.system(size: size * 0.22, weight: .medium))
                .foregroundColor(TAMETheme.deepBlueBlack)

            if let accentIcon {
                Image(systemName: accentIcon)
                    .font(.system(size: size * 0.12, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
                    .offset(x: size * 0.12, y: -size * 0.14)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: TAMETheme.brandShadow.opacity(0.8), radius: 12, y: 8)
    }
}

struct TAMEWordmark: View {
    var color: Color = TAMETheme.brandTextPrimary
    var height: CGFloat = 34

    private var estimatedWidth: CGFloat {
        max(height * 3.05, 92)
    }

    var body: some View {
        Text("TAME")
            .font(.system(size: height * 0.9, weight: .light, design: .rounded))
            .tracking(height * 0.11)
            .foregroundColor(color)
            .frame(width: estimatedWidth, height: height, alignment: .leading)
            .accessibilityLabel("TAME")
    }
}

struct TAMEBrandLockup: View {
    var wordmarkColor: Color = .black
    var primaryColor: Color = .black
    var secondaryColor: Color = TAMETheme.brandTextSecondary
    var wordmarkHeight: CGFloat = 30
    var spacing: CGFloat = 6
    var alignLeading: Bool = true

    var body: some View {
        VStack(alignment: alignLeading ? .leading : .center, spacing: spacing) {
            HStack(alignment: .lastTextBaseline, spacing: max(8, wordmarkHeight * 0.18)) {
                TAMEWordmark(color: wordmarkColor, height: wordmarkHeight)

                Text(TAMEL10n.text("· 空间罗盘", "· Space Compass"))
                    .font(.system(size: max(12, wordmarkHeight * 0.42), weight: .semibold, design: .rounded))
                    .tracking(0.4)
                    .foregroundColor(primaryColor)
                    .padding(.bottom, max(1, wordmarkHeight * 0.08))
            }

            if !TAMEL10n.isEnglish {
                Text(TAMEL10n.text("探觅·空间罗盘", "TAME Space Compass"))
                    .font(.system(size: max(10, wordmarkHeight * 0.24), weight: .medium, design: .rounded))
                    .tracking(0.2)
                    .foregroundColor(secondaryColor)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(TAMEL10n.text("TAME Space Compass，探觅·空间罗盘", "TAME Space Compass"))
    }
}

enum TAMEDashboardBadgeStyle {
    case compass
    case analysis
    case records
    case settings
    case naqi
    case period
    case stars
    case annual
    case yangGong
    case layout
    case bazhai
    case reference

    var topColor: Color {
        TAMETheme.brandBadgeTop
    }

    var bottomColor: Color {
        TAMETheme.brandBadgeBottom
    }

    var coreColor: Color {
        TAMETheme.brandBadgeCore
    }

    var highlightColor: Color {
        TAMETheme.brandBadgeHighlight
    }

    var primarySymbol: String {
        switch self {
        case .compass:
            return "location.north.line.fill"
        case .analysis:
            return "circle.grid.cross.fill"
        case .records:
            return "bookmark.fill"
        case .settings:
            return "checkmark.shield.fill"
        case .naqi:
            return "door.left.hand.open"
        case .period:
            return "clock.fill"
        case .stars:
            return "sparkles"
        case .annual:
            return "calendar"
        case .yangGong:
            return "scope"
        case .layout:
            return "square.grid.3x3.fill"
        case .bazhai:
            return "house.fill"
        case .reference:
            return "book.closed.fill"
        }
    }

    var secondarySymbol: String {
        switch self {
        case .compass:
            return "scope"
        case .analysis:
            return "waveform.path.ecg"
        case .records:
            return "square.and.pencil"
        case .settings:
            return "gearshape.fill"
        case .naqi:
            return "wind"
        case .period:
            return "seal.fill"
        case .stars:
            return "square.grid.3x3"
        case .annual:
            return "arrow.clockwise"
        case .yangGong:
            return "point.3.connected.trianglepath.dotted"
        case .layout:
            return "viewfinder"
        case .bazhai:
            return "seal.fill"
        case .reference:
            return "exclamationmark.triangle.fill"
        }
    }

    var orbitSymbol: String {
        switch self {
        case .compass:
            return "scope"
        case .analysis:
            return "circle.grid.cross"
        case .records:
            return "bookmark.fill"
        case .settings:
            return "checkmark.shield.fill"
        case .naqi:
            return "wind"
        case .period:
            return "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .stars:
            return "sparkles"
        case .annual:
            return "calendar"
        case .yangGong:
            return "scope"
        case .layout:
            return "square.grid.3x3.fill"
        case .bazhai:
            return "house.fill"
        case .reference:
            return "book.closed.fill"
        }
    }

    var minimalSymbol: String {
        switch self {
        case .compass:
            return "location.north.line"
        case .analysis:
            return "circle.grid.cross"
        case .records:
            return "bookmark"
        case .settings:
            return "gearshape"
        case .naqi:
            return "door.left.hand.open"
        case .period:
            return "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .stars:
            return "sparkles"
        case .annual:
            return "calendar"
        case .yangGong:
            return "scope"
        case .layout:
            return "square.grid.3x3"
        case .bazhai:
            return "house"
        case .reference:
            return "book.closed"
        }
    }

    var symbolScale: CGFloat {
        switch self {
        case .period:
            return 0.28
        case .yangGong:
            return 0.3
        case .layout:
            return 0.3
        case .reference:
            return 0.28
        default:
            return 0.34
        }
    }
}

struct TAMEDashboardBadge: View {
    let style: TAMEDashboardBadgeStyle
    var size: CGFloat = 66

    var body: some View {
        TAMEInstrumentBadge(symbol: style.minimalSymbol, size: size, symbolScale: style.symbolScale)
    }
}

enum TAMEWorkflowBadgeStyle {
    case compass
    case floorPlan
    case report
    case support

    var primarySymbol: String {
        switch self {
        case .compass:
            return "location.north.line.fill"
        case .floorPlan:
            return "square.grid.3x3.fill"
        case .report:
            return "doc.text.fill"
        case .support:
            return "lock.shield.fill"
        }
    }

    var detailSymbol: String {
        switch self {
        case .compass:
            return "scope"
        case .floorPlan:
            return "house.fill"
        case .report:
            return "square.and.arrow.up.fill"
        case .support:
            return "gearshape.fill"
        }
    }

    var watermarkSymbol: String {
        switch self {
        case .compass:
            return "circle.dashed"
        case .floorPlan:
            return "square.split.2x2"
        case .report:
            return "chart.line.uptrend.xyaxis"
        case .support:
            return "checkmark.shield"
        }
    }

    var topColor: Color {
        TAMETheme.brandBadgeTop
    }

    var bottomColor: Color {
        TAMETheme.brandBadgeBottom
    }

    var coreColor: Color {
        TAMETheme.brandBadgeCore
    }

    var highlightColor: Color {
        TAMETheme.brandBadgeHighlight
    }

    var cardTopColor: Color {
        Color(red: 22 / 255, green: 30 / 255, blue: 42 / 255)
    }

    var cardBottomColor: Color {
        Color(red: 9 / 255, green: 12 / 255, blue: 18 / 255)
    }

    var marketingLabel: String {
        switch self {
        case .compass:
            return "双盘罗盘"
        case .floorPlan:
            return "九宫热力"
        case .report:
            return "记录导出"
        case .support:
            return "使用支持"
        }
    }

    var minimalSymbol: String {
        switch self {
        case .compass:
            return "location.north.line"
        case .floorPlan:
            return "square.grid.3x3"
        case .report:
            return "doc.text"
        case .support:
            return "gearshape"
        }
    }
}

struct TAMEWorkflowBadge: View {
    let style: TAMEWorkflowBadgeStyle
    var size: CGFloat = 66

    var body: some View {
        TAMEInstrumentBadge(symbol: style.minimalSymbol, size: size, symbolScale: 0.3)
    }
}

struct TAMEStatusBanner: View {
    let message: String
    var systemImage: String = "checkmark.circle.fill"
    var tint: Color = TAMETheme.stardustGold

    var body: some View {
        Label(message, systemImage: systemImage)
            .font(.system(size: 12.5, weight: .medium, design: .rounded))
            .foregroundColor(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .tameInstrumentCard(cornerRadius: 14, shadow: false)
    }
}

struct TAMEGlyphMetricCard: View {
    let title: String
    let value: String
    let symbol: String
    var note: String? = nil
    var tint: Color = TAMETheme.stardustGold

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(tint.opacity(0.11))

                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(tint)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextMuted)
                        .lineLimit(1)

                    if let note {
                        Text(note)
                            .font(.system(size: 11, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextMuted)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 0)
            }

            Text(value)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Capsule()
                .fill(tint.opacity(0.18))
                .frame(width: 28, height: 3)
        }
        .frame(maxWidth: .infinity, minHeight: 94, alignment: .leading)
        .padding(14)
        .tameInstrumentCard(cornerRadius: 18, shadow: false)
    }
}

struct TAMEPrimaryActionButtonStyle: ButtonStyle {
    var tint: Color = TAMETheme.stardustGold

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(TAMETheme.deepBlueBlack)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(tint.opacity(configuration.isPressed ? 0.18 : 0.14))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(tint.opacity(0.24), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct TAMESecondaryActionButtonStyle: ButtonStyle {
    var tint: Color = TAMETheme.stardustGold

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundColor(TAMETheme.brandTextPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.white.opacity(configuration.isPressed ? 0.96 : 1))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(TAMETheme.brandHairline, lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

private struct TAMEInstrumentBadge: View {
    let symbol: String
    let size: CGFloat
    let symbolScale: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .shadow(color: TAMETheme.brandShadow.opacity(0.82), radius: 12, y: 7)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(0.82), lineWidth: max(0.8, size * 0.016))
                .padding(size * 0.14)

            Circle()
                .stroke(TAMETheme.ghostInk, lineWidth: max(0.6, size * 0.012))
                .padding(size * 0.25)

            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .trim(from: 0.01, to: 0.055)
                    .stroke(TAMETheme.stardustGold, style: StrokeStyle(lineWidth: max(1, size * 0.022), lineCap: .round))
                    .padding(size * 0.132)
                    .rotationEffect(.degrees(Double(index) * 72 - 90))
            }

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(0.95), lineWidth: max(0.8, size * 0.012))
                .frame(width: size * 0.12, height: size * 0.12)

            Circle()
                .fill(TAMETheme.deepBlueBlack)
                .frame(width: size * 0.056, height: size * 0.056)

            Image(systemName: symbol)
                .font(.system(size: size * symbolScale, weight: .medium))
                .foregroundColor(TAMETheme.deepBlueBlack)
        }
        .frame(width: size, height: size)
    }
}
