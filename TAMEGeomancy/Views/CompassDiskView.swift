import SwiftUI

struct CompassDiskView: View {
    enum DiskType {
        case earth
        case naqi
    }

    enum VisualStyle: String, CaseIterable, Identifiable {
        case classic
        case modern
        case minimal

        var id: String { rawValue }

        var title: String {
            switch self {
            case .classic:
                return TAMEL10n.text("复古", "Classic")
            case .modern:
                return TAMEL10n.text("现代", "Modern")
            case .minimal:
                return TAMEL10n.text("简洁", "Minimal")
            }
        }

        var summary: String {
            switch self {
            case .classic:
                return TAMEL10n.text("暖金与墨色层次更强，更接近传统罗盘质感。", "Warm gold and ink layers feel closest to a traditional luopan.")
            case .modern:
                return TAMEL10n.text("冷色高对比更利落，适合实时测向与快速辨识。", "Sharper contrast makes live orientation checks easier.")
            case .minimal:
                return TAMEL10n.text("降低装饰层，信息更干净，适合长时间连续查看。", "Reduced ornament keeps long reading sessions cleaner.")
            }
        }
    }

    let heading: Double
    let diskType: DiskType
    let visualStyle: VisualStyle
    let magneticInterference: Double
    let isLocked: Bool
    let levelOffset: (pitch: Double, roll: Double)
    let period: SanyuanJiuyun
    let externalReadout: AnyView?

    @Environment(\.colorScheme) private var colorScheme

    init(
        heading: Double,
        diskType: DiskType = .earth,
        visualStyle: VisualStyle = .classic,
        magneticInterference: Double = 0,
        isLocked: Bool = false,
        levelOffset: (pitch: Double, roll: Double) = (0, 0),
        period: SanyuanJiuyun = .current,
        externalReadout: AnyView? = nil
    ) {
        self.heading = heading
        self.diskType = diskType
        self.visualStyle = visualStyle
        self.magneticInterference = magneticInterference
        self.isLocked = isLocked
        self.levelOffset = levelOffset
        self.period = period
        self.externalReadout = externalReadout
    }

    var body: some View {
        ZStack {
            if diskType == .earth {
                instrumentBezel
            }

            if magneticInterference > 100 && diskType == .earth {
                interferenceRipples
            }

            rotatingDial

            if diskType == .earth {
                instrumentGlass
                centerDisk
                compassNeedle
                northPointer

                if let externalReadout {
                    pointerBoundReadout(externalReadout)
                }
            }

            if diskType == .earth {
                levelIndicator
                    .offset(y: 204)
            }

            if magneticInterference > 100 && diskType == .earth {
                magneticIndicator
                    .offset(y: -182)
            }
        }
        .frame(width: 340, height: 340)
        .shadow(color: shadowColor, radius: 26, y: 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    @ViewBuilder
    private var instrumentBezel: some View {
        if visualStyle == .minimal {
            originalMinimalBezel
        } else {
            metalInstrumentBezel
        }
    }

    private var originalMinimalBezel: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.96))
                .frame(width: 338, height: 338)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.34 : 0.18), lineWidth: 2.4)
                .frame(width: 334, height: 334)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.20 : 0.12), lineWidth: 1.4)
                .frame(width: 322, height: 322)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.16 : 0.08), lineWidth: 1)
                .frame(width: 300, height: 300)
        }
    }

    private var metalInstrumentBezel: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.06 : 0.98),
                            TAMETheme.fieldBackground.opacity(colorScheme == .dark ? 0.08 : 0.92),
                            TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.42 : 0.08)
                        ],
                        center: .center,
                        startRadius: 54,
                        endRadius: 178
                    )
                )
                .frame(width: 338, height: 338)

            Circle()
                .fill(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.10 : 0.82),
                            TAMETheme.techGray.opacity(colorScheme == .dark ? 0.56 : 0.34),
                            TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.48 : 0.16),
                            TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.62 : 0.38),
                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.66),
                            TAMETheme.techGray.opacity(colorScheme == .dark ? 0.46 : 0.28),
                            TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.52 : 0.18),
                            Color.white.opacity(colorScheme == .dark ? 0.10 : 0.82)
                        ],
                        center: .center
                    )
                )
                .frame(width: 334, height: 334)

            Circle()
                .fill(TAMETheme.fieldBackground.opacity(colorScheme == .dark ? 0.08 : 0.92))
                .frame(width: 298, height: 298)

            ForEach(0..<144, id: \.self) { index in
                let major = index.isMultiple(of: 12)
                Capsule(style: .continuous)
                    .fill(
                        major
                        ? Color.white.opacity(colorScheme == .dark ? 0.12 : 0.42)
                        : TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.12 : 0.10)
                    )
                    .frame(width: major ? 0.9 : 0.55, height: major ? 21 : 15)
                    .offset(y: -158)
                    .rotationEffect(.degrees(Double(index) * 2.5))
            }

            ForEach(0..<72, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.18))
                    .frame(width: 0.5, height: 9)
                    .offset(y: -146)
                    .rotationEffect(.degrees(Double(index) * 5 + 1.4))
            }

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.24 : 0.96),
                            TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.72 : 0.58),
                            TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.52 : 0.30),
                            TAMETheme.techGray.opacity(colorScheme == .dark ? 0.62 : 0.48),
                            Color.white.opacity(colorScheme == .dark ? 0.16 : 0.88),
                            TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.70 : 0.54),
                            Color.white.opacity(colorScheme == .dark ? 0.24 : 0.96)
                        ],
                        center: .center
                    ),
                    lineWidth: 7
                )
                .frame(width: 326, height: 326)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.44 : 0.24), lineWidth: 2.2)
                .frame(width: 334, height: 334)

            Circle()
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.13 : 0.86), lineWidth: 1.4)
                .frame(width: 318, height: 318)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.42 : 0.18), lineWidth: 2)
                .frame(width: 300, height: 300)

            Circle()
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.68), lineWidth: 1)
                .frame(width: 292, height: 292)

            ForEach(0..<8, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.18 : 0.90),
                                    TAMETheme.techGray.opacity(colorScheme == .dark ? 0.34 : 0.38),
                                    TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.48 : 0.20)
                                ],
                                center: .topLeading,
                                startRadius: 1,
                                endRadius: 8
                            )
                        )
                        .frame(width: 8, height: 8)

                    Capsule(style: .continuous)
                        .fill(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.36 : 0.28))
                        .frame(width: 5.6, height: 0.8)
                        .rotationEffect(.degrees(Double(index) * 22.5))
                }
                .offset(y: -159)
                .rotationEffect(.degrees(Double(index) * 45 + 22.5))
            }

            Circle()
                .trim(from: 0.58, to: 0.76)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.11 : 0.58), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .frame(width: 318, height: 318)
                .rotationEffect(.degrees(-14))
        }
    }

    @ViewBuilder
    private var instrumentGlass: some View {
        if visualStyle == .minimal {
            originalMinimalGlass
        } else {
            metalInstrumentGlass
        }
    }

    private var originalMinimalGlass: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.48), lineWidth: 1)
                .frame(width: 296, height: 296)

            Circle()
                .trim(from: 0.16, to: 0.34)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.06 : 0.36), style: StrokeStyle(lineWidth: 22, lineCap: .round))
                .frame(width: 300, height: 300)
                .rotationEffect(.degrees(168))
        }
        .allowsHitTesting(false)
    }

    private var metalInstrumentGlass: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.62), lineWidth: 1)
                .frame(width: 296, height: 296)

            Circle()
                .trim(from: 0.57, to: 0.80)
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.08 : 0.42), style: StrokeStyle(lineWidth: 30, lineCap: .round))
                .frame(width: 268, height: 268)
                .rotationEffect(.degrees(-20))

            Circle()
                .trim(from: 0.08, to: 0.20)
                .stroke(TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.12 : 0.16), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 252, height: 252)
                .rotationEffect(.degrees(8))
        }
        .allowsHitTesting(false)
    }

    private var rotatingDial: some View {
        ZStack {
            if diskType == .naqi {
                naqiGuideDial
            } else {
                outerRing
                mainDisk
                degreeMarkers
                mountainMarkers
                earthlyBranchMarkers
                baguaMarkers
            }
        }
        .rotationEffect(.degrees(-normalizedHeading))
        .animation(.easeOut(duration: 0.16), value: normalizedHeading)
    }

    private var naqiGuideDial: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                SectorBandShape(
                    startAngle: .degrees(Double(index) * 45 - 90),
                    endAngle: .degrees(Double(index + 1) * 45 - 90),
                    innerRadius: 116,
                    outerRadius: 142
                )
                .fill(naqiOuterZoneFill(for: index))

                SectorBandShape(
                    startAngle: .degrees(Double(index) * 45 - 90),
                    endAngle: .degrees(Double(index + 1) * 45 - 90),
                    innerRadius: 90,
                    outerRadius: 116
                )
                .fill(naqiInnerZoneFill(for: index))

                SectorBandShape(
                    startAngle: .degrees(Double(index) * 45 - 90 + 7),
                    endAngle: .degrees(Double(index + 1) * 45 - 90 - 7),
                    innerRadius: 82,
                    outerRadius: 108
                )
                .fill(naqiNumberFill(for: index))

                VStack(spacing: 3) {
                    Text(naqiDirectionLabel(for: index))
                        .font(.system(size: TAMEL10n.isEnglish ? 10 : 14, weight: .medium, design: TAMEL10n.isEnglish ? .rounded : .serif))
                        .foregroundColor(Color.black.opacity(0.58))
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                }
                .rotationEffect(.degrees(Double(index) * 45))
                .offset(y: -138)
                .rotationEffect(.degrees(-Double(index) * 45))

                Text(naqiNumberLabel(for: index))
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundColor(naqiNumberTextColor(for: index))
                    .rotationEffect(.degrees(Double(index) * 45))
                    .offset(y: -95)
                    .rotationEffect(.degrees(-Double(index) * 45))
            }

            Circle()
                .stroke(Color.white.opacity(0.58), lineWidth: 1.2)
                .frame(width: 284, height: 284)

            Circle()
                .stroke(Color.black.opacity(0.12), lineWidth: 0.9)
                .frame(width: 284, height: 284)

            Circle()
                .stroke(Color.black.opacity(0.07), lineWidth: 0.9)
                .frame(width: 232, height: 232)

            Circle()
                .stroke(Color.black.opacity(0.07), lineWidth: 1)
                .frame(width: 176, height: 176)

            ForEach(0..<8, id: \.self) { index in
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .frame(width: 0.8, height: 58)
                    .offset(y: -114)
                    .rotationEffect(.degrees(Double(index) * 45))
            }
        }
    }

    @ViewBuilder
    private var outerRing: some View {
        if visualStyle == .minimal {
            originalMinimalOuterRing
        } else {
            styledOuterRing
        }
    }

    private var originalMinimalOuterRing: some View {
        ZStack {
            Circle()
                .stroke(baseStroke.opacity(0.18), lineWidth: 1.2)
                .frame(width: 316, height: 316)

            Circle()
                .stroke(baseStroke.opacity(0.12), lineWidth: 5)
                .frame(width: 304, height: 304)

            Circle()
                .stroke(accentStroke.opacity(diskType == .naqi ? 0.24 : 0.10), lineWidth: 1.2)
                .frame(width: 288, height: 288)
        }
    }

    private var styledOuterRing: some View {
        ZStack {
            Circle()
                .stroke(baseStroke.opacity(0.16), lineWidth: 1)
                .frame(width: 316, height: 316)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            accentStroke.opacity(0.18),
                            baseStroke.opacity(0.10),
                            accentStroke.opacity(0.34),
                            Color.white.opacity(colorScheme == .dark ? 0.05 : 0.42),
                            baseStroke.opacity(0.18),
                            accentStroke.opacity(0.18)
                        ],
                        center: .center
                    ),
                    lineWidth: 8
                )
                .frame(width: 304, height: 304)

            Circle()
                .stroke(accentStroke.opacity(diskType == .naqi ? 0.32 : 0.24), lineWidth: 1.4)
                .frame(width: 288, height: 288)
        }
    }

    @ViewBuilder
    private var mainDisk: some View {
        if visualStyle == .minimal {
            originalMinimalMainDisk
        } else {
            styledMainDisk
        }
    }

    private var originalMinimalMainDisk: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.10 : 0.98),
                            TAMETheme.fieldBackground.opacity(colorScheme == .dark ? 0.08 : 0.72),
                            TAMETheme.techGray.opacity(colorScheme == .dark ? 0.12 : 0.08)
                        ],
                        center: .center,
                        startRadius: 18,
                        endRadius: 152
                    )
                )
                .frame(width: 300, height: 300)

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.10 : 0.055), lineWidth: 16)
                .frame(width: 254, height: 254)

            Circle()
                .stroke(baseStroke.opacity(0.13), lineWidth: 1)
                .frame(width: 240, height: 240)

            Circle()
                .stroke(baseStroke.opacity(0.08), lineWidth: 1)
                .frame(width: 190, height: 190)
        }
    }

    private var styledMainDisk: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: gradientColors,
                        center: .center,
                        startRadius: 18,
                        endRadius: 152
                    )
                )
                .frame(width: 300, height: 300)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.clear,
                            Color.clear,
                            TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.18 : 0.045)
                        ],
                        center: .center,
                        startRadius: 112,
                        endRadius: 154
                    )
                )
                .frame(width: 300, height: 300)

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.16 : 0.10), lineWidth: 16)
                .frame(width: 254, height: 254)

            Circle()
                .stroke(baseStroke.opacity(0.16), lineWidth: 1)
                .frame(width: 240, height: 240)

            Circle()
                .stroke(baseStroke.opacity(0.08), lineWidth: 1)
                .frame(width: 190, height: 190)

            Circle()
                .stroke(Color.white.opacity(colorScheme == .dark ? 0.04 : 0.42), lineWidth: 1)
                .frame(width: 286, height: 286)
        }
    }

    private var degreeMarkers: some View {
        ZStack {
            ForEach(0..<72, id: \.self) { index in
                let primary = index.isMultiple(of: 6)
                let secondary = index.isMultiple(of: 3)
                Capsule(style: .circular)
                    .fill(primary ? baseStroke.opacity(0.86) : baseStroke.opacity(secondary ? 0.42 : 0.22))
                    .frame(width: primary ? 1.8 : 1, height: primary ? 14 : (secondary ? 9 : 5.5))
                    .offset(y: primary ? -141 : -145)
                    .rotationEffect(.degrees(Double(index) * 5))
            }

            ForEach(0..<12, id: \.self) { index in
                Text("\(index * 30)°")
                    .font(.system(size: visualStyle == .minimal ? 8 : 9, weight: .medium, design: .rounded))
                    .foregroundColor(baseStroke.opacity(visualStyle == .minimal ? 0.42 : 0.56))
                    .rotationEffect(.degrees(Double(index) * 30))
                    .offset(y: -118)
                    .rotationEffect(.degrees(-Double(index) * 30))
            }
        }
    }

    private var mountainMarkers: some View {
        ZStack {
            ForEach(Array(twentyFourMountains.enumerated()), id: \.offset) { index, mountain in
                VStack(spacing: visualStyle == .minimal ? 4 : 6) {
                    Capsule(style: .circular)
                        .fill(color(for: mountain.element))
                        .frame(width: visualStyle == .minimal ? 3 : 4, height: visualStyle == .minimal ? 3 : 4)

                    Text(mountain.name)
                        .font(.system(size: visualStyle == .minimal ? 9.5 : 11, weight: .medium, design: .rounded))
                        .foregroundColor(baseStroke.opacity(visualStyle == .minimal ? 0.72 : 1))
                }
                .rotationEffect(.degrees(Double(index) * 15))
                .offset(y: visualStyle == .minimal ? -132 : -135)
                .rotationEffect(.degrees(-Double(index) * 15))
            }
        }
    }

    private var earthlyBranchMarkers: some View {
        ZStack {
            ForEach(Array(earthlyBranches.enumerated()), id: \.offset) { index, branch in
                Text(branch)
                    .font(.system(size: visualStyle == .minimal ? 10.5 : 12, weight: .medium, design: .rounded))
                    .foregroundColor(accentStroke.opacity(visualStyle == .minimal ? 0.58 : 0.9))
                    .rotationEffect(.degrees(Double(index) * 30))
                    .offset(y: visualStyle == .minimal ? -106 : -108)
                    .rotationEffect(.degrees(-Double(index) * 30))
            }
        }
    }

    private var baguaMarkers: some View {
        ZStack {
            ForEach(Array(Bagua.allCases.enumerated()), id: \.offset) { index, bagua in
                VStack(spacing: visualStyle == .minimal ? 2 : 4) {
                    Text(bagua.localizedLabel)
                        .font(.system(size: visualStyle == .minimal ? 13 : 15, weight: .medium, design: .serif))
                        .foregroundColor(baguaColor.opacity(visualStyle == .minimal ? 0.78 : 1))

                    Text(directionText(for: index))
                        .font(.system(size: visualStyle == .minimal ? 7 : 8, weight: .medium, design: .rounded))
                        .foregroundColor(baseStroke.opacity(visualStyle == .minimal ? 0.34 : 0.46))
                }
                .rotationEffect(.degrees(Double(index) * 45))
                .offset(y: visualStyle == .minimal ? -84 : -82)
                .rotationEffect(.degrees(-Double(index) * 45))
            }
        }
    }

    private var centerDisk: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.12 : 0.98),
                            centerDiskColor.opacity(0.94),
                            TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.54 : 0.08)
                        ],
                        center: .topLeading,
                        startRadius: 4,
                        endRadius: 58
                    )
                )
                .frame(width: 98, height: 98)
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.36 : 0.10), radius: 9, x: 0, y: 5)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            Color.white.opacity(colorScheme == .dark ? 0.12 : 0.82),
                            TAMETheme.stardustGold.opacity(0.40),
                            baseStroke.opacity(0.18),
                            Color.white.opacity(colorScheme == .dark ? 0.08 : 0.72)
                        ],
                        center: .center
                    ),
                    lineWidth: 2.2
                )
                .frame(width: 98, height: 98)

            Circle()
                .stroke(baseStroke.opacity(0.12), lineWidth: 1)
                .frame(width: 70, height: 70)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white.opacity(0.96),
                            TAMETheme.stardustGold.opacity(0.82),
                            baseStroke.opacity(0.86)
                        ],
                        center: .topLeading,
                        startRadius: 1,
                        endRadius: 12
                    )
                )
                .frame(width: 13, height: 13)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(colorScheme == .dark ? 0.18 : 0.80), lineWidth: 1)
                }
                .shadow(color: TAMETheme.stardustGold.opacity(colorScheme == .dark ? 0.18 : 0.26), radius: 5, x: 0, y: 2)

            if diskType == .earth {
                CrosshairView(stroke: TAMETheme.stardustGold.opacity(0.74))
            }
        }
    }

    private var compassNeedle: some View {
        ZStack {
            InstrumentNeedleBody()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 0.86, green: 0.23, blue: 0.18).opacity(colorScheme == .dark ? 0.82 : 0.72), location: 0.00),
                            .init(color: Color(red: 0.68, green: 0.13, blue: 0.10).opacity(colorScheme == .dark ? 0.84 : 0.74), location: 0.33),
                            .init(color: Color(red: 0.58, green: 0.10, blue: 0.08).opacity(colorScheme == .dark ? 0.76 : 0.66), location: 1.00)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 11.2, height: 136)
                .offset(y: -68)
                .overlay {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(colorScheme == .dark ? 0.18 : 0.22))
                        .frame(width: 0.75, height: 80)
                        .offset(y: -82)
                }
                .shadow(color: Color(red: 0.70, green: 0.18, blue: 0.13).opacity(0.10), radius: 2, y: 1)

            Triangle()
                .fill(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.20 : 0.14))
                .frame(width: 17, height: 76)
                .rotationEffect(.degrees(180))
                .offset(y: 43)

            Circle()
                .fill(Color.white.opacity(colorScheme == .dark ? 0.88 : 0.96))
                .frame(width: 22, height: 22)
                .overlay {
                    Circle()
                        .stroke(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.58 : 0.48), lineWidth: 1.1)
                }
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.20 : 0.08), radius: 4, x: 0, y: 2)

            Circle()
                .fill(TAMETheme.deepBlueBlack.opacity(colorScheme == .dark ? 0.96 : 0.88))
                .frame(width: 6.5, height: 6.5)
        }
    }

    private var northPointer: some View {
        VStack(spacing: 8) {
            Capsule(style: .circular)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4.2, height: 74)
                .overlay(alignment: .top) {
                    Triangle()
                        .fill(Color.clear)
                        .frame(width: 14, height: 15)
                        .offset(y: -7.5)
                }
                .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.28 : 0.14), radius: 4, y: 1)
        }
        .offset(y: -116)
    }

    private func pointerBoundReadout(_ content: AnyView) -> some View {
        VStack(spacing: 0) {
            content

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            pointerColor.opacity(0.24),
                            pointerColor.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1.2, height: 10)

            Circle()
                .fill(TAMETheme.stardustGold.opacity(0.22))
                .frame(width: 6, height: 6)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.92), lineWidth: 1)
                }
                .shadow(color: TAMETheme.stardustGold.opacity(0.16), radius: 4, y: 2)
        }
        .offset(y: -222)
    }

    private var interferenceRipples: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(TAMETheme.brandAlert.opacity(0.16 - Double(index) * 0.03), lineWidth: 2)
                    .frame(width: 260 + CGFloat(index * 26), height: 260 + CGFloat(index * 26))
            }
        }
    }

    private var magneticIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(TAMETheme.brandAlert)
            Text("\(TAMEL10n.text("磁场干扰", "Magnetic Interference")) \(Int(magneticInterference))μT")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(baseStroke.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(indicatorBackground)
        .clipShape(Capsule())
    }

    private var levelIndicator: some View {
        VStack(spacing: 6) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(indicatorBackground)
                    .frame(width: 96, height: 48)

                RoundedRectangle(cornerRadius: 18)
                    .stroke(baseStroke.opacity(0.14), lineWidth: 1)
                    .frame(width: 96, height: 48)

                CrosshairView(stroke: baseStroke.opacity(0.2))
                    .frame(width: 28, height: 28)

                Circle()
                    .fill(levelBubbleColor)
                    .frame(width: 14, height: 14)
                    .offset(
                        x: clamped(levelOffset.roll, limit: 12),
                        y: clamped(levelOffset.pitch, limit: 12)
                    )
            }

            Text(TAMEL10n.text(
                "俯仰 \(String(format: "%.1f", levelOffset.pitch))°  横滚 \(String(format: "%.1f", levelOffset.roll))°",
                "Pitch \(String(format: "%.1f", levelOffset.pitch))°  Roll \(String(format: "%.1f", levelOffset.roll))°"
            ))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(baseStroke.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }

    private var accessibilityLabel: String {
        TAMEL10n.text(
            "罗盘盘面，角度 \(String(format: "%.1f", normalizedHeading)) 度",
            "Compass plate, heading \(String(format: "%.1f", normalizedHeading)) degrees"
        )
    }

    private var normalizedHeading: Double {
        let normalized = heading.truncatingRemainder(dividingBy: 360)
        return normalized >= 0 ? normalized : normalized + 360
    }

    private var currentMountain: Direction {
        Direction.from(angle: normalizedHeading)
    }

    private var oppositeMountain: Direction {
        currentMountain.opposite
    }

    private var currentMountainFamily: String {
        currentMountain.familyTitle
    }

    private var gradientColors: [Color] {
        switch visualStyle {
        case .classic:
            if colorScheme == .dark {
                return diskType == .earth
                    ? [Color(red: 0.34, green: 0.26, blue: 0.16), Color.black.opacity(0.94)]
                    : [Color(red: 0.16, green: 0.17, blue: 0.20), Color.black.opacity(0.84)]
            }

            return diskType == .earth
                ? [Color(red: 0.98, green: 0.95, blue: 0.88), Color(red: 0.83, green: 0.74, blue: 0.58).opacity(0.35)]
                : [Color(red: 0.95, green: 0.94, blue: 0.90), Color(red: 0.73, green: 0.66, blue: 0.54).opacity(0.20)]
        case .modern:
            if colorScheme == .dark {
                return diskType == .earth
                    ? [Color.white.opacity(0.06), Color.black.opacity(0.92)]
                    : [TAMETheme.stardustGold.opacity(0.16), Color.black.opacity(0.82)]
            }

            return diskType == .earth
                ? [Color.white, Color.gray.opacity(0.10)]
                : [TAMETheme.stardustGold.opacity(0.12), Color.white]
        case .minimal:
            if colorScheme == .dark {
                return diskType == .earth
                    ? [Color.white.opacity(0.03), Color.black.opacity(0.95)]
                    : [Color.white.opacity(0.05), Color.black.opacity(0.88)]
            }

            return diskType == .earth
                ? [Color.white, Color.black.opacity(0.03)]
                : [Color.white, Color.black.opacity(0.04)]
        }
    }

    private var baseStroke: Color {
        switch visualStyle {
        case .classic:
            if diskType == .naqi {
                return colorScheme == .dark
                    ? Color(red: 0.60, green: 0.90, blue: 0.82)
                    : Color(red: 0.14, green: 0.46, blue: 0.43)
            }

            return colorScheme == .dark
                ? Color(red: 0.96, green: 0.85, blue: 0.66)
                : Color(red: 0.47, green: 0.32, blue: 0.18)
        case .modern:
            if diskType == .naqi {
                return colorScheme == .dark ? TAMETheme.stardustGold : Color(red: 0.56, green: 0.45, blue: 0.26)
            }

            return colorScheme == .dark ? .white : .black
        case .minimal:
            if diskType == .naqi {
                return colorScheme == .dark ? Color.white.opacity(0.86) : Color.black.opacity(0.78)
            }

            return colorScheme == .dark ? Color.white.opacity(0.9) : Color.black.opacity(0.82)
        }
    }

    private var accentStroke: Color {
        switch visualStyle {
        case .classic:
            return diskType == .naqi
                ? Color(red: 0.49, green: 0.85, blue: 0.77)
                : Color(red: 0.86, green: 0.67, blue: 0.30)
        case .modern:
            return diskType == .naqi ? TAMETheme.moonWhite : Color(red: 0.84, green: 0.71, blue: 0.34)
        case .minimal:
            return diskType == .naqi
                ? TAMETheme.techGray.opacity(0.92)
                : Color.gray.opacity(colorScheme == .dark ? 0.8 : 0.52)
        }
    }

    private var baguaColor: Color {
        switch visualStyle {
        case .classic:
            return colorScheme == .dark
                ? Color(red: 0.92, green: 0.76, blue: 0.42)
                : Color(red: 0.72, green: 0.44, blue: 0.12)
        case .modern:
            return colorScheme == .dark
                ? Color(red: 0.90, green: 0.76, blue: 0.40)
                : Color(red: 0.80, green: 0.53, blue: 0.16)
        case .minimal:
            return colorScheme == .dark ? .white.opacity(0.88) : .black.opacity(0.76)
        }
    }

    private var centerDiskColor: Color {
        switch visualStyle {
        case .classic:
            return colorScheme == .dark
                ? Color(red: 0.18, green: 0.14, blue: 0.10).opacity(0.92)
                : Color(red: 0.97, green: 0.94, blue: 0.88)
        case .modern:
            return colorScheme == .dark ? Color.black.opacity(0.8) : Color.white.opacity(0.92)
        case .minimal:
            return colorScheme == .dark ? Color.black.opacity(0.86) : Color.white.opacity(0.96)
        }
    }

    private var indicatorBackground: Color {
        switch visualStyle {
        case .classic:
            return colorScheme == .dark
                ? Color(red: 0.96, green: 0.85, blue: 0.66).opacity(0.10)
                : Color(red: 0.47, green: 0.32, blue: 0.18).opacity(0.07)
        case .modern:
            return colorScheme == .dark ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
        case .minimal:
            return colorScheme == .dark ? Color.white.opacity(0.05) : Color.black.opacity(0.04)
        }
    }

    private var levelBubbleColor: Color {
        abs(levelOffset.pitch) <= 2 && abs(levelOffset.roll) <= 2 ? TAMETheme.stardustGold : TAMETheme.brandAlert
    }

    private var shadowColor: Color {
        switch visualStyle {
        case .classic:
            return colorScheme == .dark ? Color.black.opacity(0.48) : Color.black.opacity(0.12)
        case .modern:
            return colorScheme == .dark ? .black.opacity(0.4) : .black.opacity(0.08)
        case .minimal:
            return colorScheme == .dark ? .black.opacity(0.28) : .black.opacity(0.06)
        }
    }

    private var pointerColor: Color {
        switch diskType {
        case .earth:
            return visualStyle == .minimal ? TAMETheme.deepBlueBlack.opacity(0.88) : baseStroke
        case .naqi:
            return accentStroke.opacity(0.88)
        }
    }

    private var twentyFourMountains: [(name: String, element: Element)] {
        Direction.compassOrder.map { ($0.localizedLabel, $0.element) }
    }

    private var earthlyBranches: [String] {
        TAMEL10n.isEnglish
        ? ["Zi", "Chou", "Yin", "Mao", "Chen", "Si", "Wu", "Wei", "Shen", "You", "Xu", "Hai"]
        : ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    }

    private func naqiDirectionLabel(for index: Int) -> String {
        let labels = TAMEL10n.isEnglish
        ? ["S", "SW", "W", "NW", "N", "NE", "E", "SE"]
        : ["南", "坤", "西", "乾", "北", "艮", "东", "巽"]
        return labels[index]
    }

    private func naqiNumberLabel(for index: Int) -> String {
        ["9", "2", "7", "6", "1", "8", "3", "4"][index]
    }

    private func naqiNumberFill(for index: Int) -> Color {
        if naqiIsWaterZone(index: index) {
            return TAMETheme.deepBlueBlack.opacity(0.62)
        }

        return TAMETheme.stardustGold.opacity(0.34)
    }

    private func naqiOuterZoneFill(for index: Int) -> Color {
        if naqiIsWaterZone(index: index) {
            return TAMETheme.deepBlueBlack.opacity(0.14)
        }

        return TAMETheme.stardustGold.opacity(0.10)
    }

    private func naqiInnerZoneFill(for index: Int) -> Color {
        if naqiIsWaterZone(index: index) {
            return TAMETheme.deepBlueBlack.opacity(0.22)
        }

        return TAMETheme.stardustGold.opacity(0.16)
    }

    private func naqiNumberTextColor(for index: Int) -> Color {
        if naqiIsWaterZone(index: index) {
            return TAMETheme.moonWhite.opacity(0.92)
        }

        return TAMETheme.deepBlueBlack.opacity(0.76)
    }

    private func naqiIsWaterZone(index: Int) -> Bool {
        let naqiNumber = Int(naqiNumberLabel(for: index)) ?? 0

        switch period {
        case .qi, .ba, .jiu:
            // Current supported periods (7/8/9) are all in the lower cycle.
            // Standard San Yuan Naqi reference treats 1/2/3/4 sectors as the
            // favorable "see water" group, while 6/7/8/9 are the prosperous qi group.
            return [1, 2, 3, 4].contains(naqiNumber)
        }
    }

    private func directionText(for index: Int) -> String {
        TAMEL10n.isEnglish
        ? ["NW", "SW", "E", "SE", "N", "S", "NE", "W"][index]
        : ["西北", "西南", "东", "东南", "北", "南", "东北", "西"][index]
    }

    private func color(for element: Element) -> Color {
        switch element {
        case .wood:
            return visualStyle == .minimal
                ? TAMETheme.stardustGold.opacity(0.62)
                : Color(red: 0.48, green: 0.73, blue: 0.52)
        case .fire:
            return visualStyle == .minimal
                ? TAMETheme.stardustGold.opacity(0.72)
                : Color(red: 0.88, green: 0.44, blue: 0.33)
        case .earth:
            return visualStyle == .minimal
                ? TAMETheme.stardustGold.opacity(0.82)
                : Color(red: 0.78, green: 0.67, blue: 0.46)
        case .metal:
            return visualStyle == .minimal
                ? TAMETheme.techGray.opacity(0.78)
                : Color(red: 0.73, green: 0.77, blue: 0.81)
        case .water:
            return visualStyle == .minimal
                ? TAMETheme.deepBlueBlack.opacity(0.42)
                : Color(red: 0.37, green: 0.62, blue: 0.84)
        }
    }

    private func clamped(_ value: Double, limit: CGFloat) -> CGFloat {
        CGFloat(max(-Double(limit), min(Double(limit), value * 2.2)))
    }
}

private extension Direction {
    var familyTitle: String {
        switch self {
        case .jia, .yi, .bing, .ding, .geng, .xin, .ren, .gui:
            return TAMEL10n.text("天干", "Heavenly Stem")
        case .zi, .chou, .yin, .mao, .chen, .si, .wu, .wei, .shen, .you, .xu, .hai:
            return TAMEL10n.text("地支", "Earthly Branch")
        case .qian, .kun, .gen, .xun:
            return TAMEL10n.text("卦位", "Trigram Sector")
        }
    }
}

private struct CrosshairView: View {
    let stroke: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(stroke)
                .frame(width: 1, height: 28)

            Rectangle()
                .fill(stroke)
                .frame(width: 28, height: 1)
        }
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct InstrumentNeedleBody: Shape {
    func path(in rect: CGRect) -> Path {
        let midX = rect.midX
        let waistY = rect.minY + rect.height * 0.66
        let tailY = rect.maxY - rect.height * 0.08
        var path = Path()
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: waistY))
        path.addQuadCurve(
            to: CGPoint(x: midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX * 0.78, y: tailY)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: waistY),
            control: CGPoint(x: rect.maxX * 0.22, y: tailY)
        )
        path.closeSubpath()
        return path
    }
}

private struct SectorBandShape: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRadius: CGFloat
    let outerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let startOuter = point(center: center, radius: outerRadius, angle: startAngle)
        let endInner = point(center: center, radius: innerRadius, angle: endAngle)

        var path = Path()
        path.move(to: startOuter)
        path.addArc(
            center: center,
            radius: outerRadius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.addLine(to: endInner)
        path.addArc(
            center: center,
            radius: innerRadius,
            startAngle: endAngle,
            endAngle: startAngle,
            clockwise: true
        )
        path.addLine(to: startOuter)
        return path
    }

    private func point(center: CGPoint, radius: CGFloat, angle: Angle) -> CGPoint {
        CGPoint(
            x: center.x + cos(CGFloat(angle.radians)) * radius,
            y: center.y + sin(CGFloat(angle.radians)) * radius
        )
    }
}

struct CompassDiskView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CompassDiskView(
                heading: 127.5,
                visualStyle: .classic,
                magneticInterference: 36,
                isLocked: false,
                levelOffset: (1.8, -1.2)
            )
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)

            CompassDiskView(
                heading: 135,
                diskType: .naqi,
                visualStyle: .modern,
                magneticInterference: 112,
                isLocked: true,
                levelOffset: (8, -6)
            )
            .padding()
            .background(Color.black)
            .preferredColorScheme(.dark)
        }
    }
}
