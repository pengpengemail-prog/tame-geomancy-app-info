import SwiftUI

struct AnalysisHubView: View {
    @State private var navigationPath: [AnalysisDeepLinkDestination] = []
    @State private var activeDestinationLegacy: AnalysisDeepLinkDestination?
    @State private var pendingInitialDestination: AnalysisDeepLinkDestination?
    @StateObject private var historyStore = HistoryStore.shared

    init(initialDestination: AnalysisDeepLinkDestination? = nil) {
        _pendingInitialDestination = State(initialValue: initialDestination)
    }

    private let coreModules: [AnalysisModule] = [
        .init(title: TAMEL10n.text("坐向与开口", "Orientation & Openings"), subtitle: TAMEL10n.text("查看大门、阳台、窗户开口方向与强弱", "Review door, balcony, and window opening direction and strength."), detail: TAMEL10n.text("开口判断", "Openings"), tint: TAMETheme.stardustGold, badgeStyle: .naqi, deepLink: .orientation),
        .init(title: TAMEL10n.text("二十四向线", "24-Direction Lines"), subtitle: TAMEL10n.text("二十四向线位、细分线与现场立向记录", "Review 24-direction lines, fine divisions, and on-site orientation records."), detail: TAMEL10n.text("线位记录", "Line Review"), tint: TAMETheme.stardustGold, badgeStyle: .yangGong, deepLink: .yangGongFenjin),
        .init(title: TAMEL10n.text("空间周期", "Period Guide"), subtitle: TAMEL10n.text("阶段 7、阶段 8、阶段 9 自动对照", "Switch across Period 7, 8, and 9 with auto matching."), detail: TAMEL10n.text("阶段对照", "Periods"), tint: TAMETheme.stardustGold, badgeStyle: .period, deepLink: .jiuyun),
        .init(title: TAMEL10n.text("九宫布局", "Nine-Grid Layout"), subtitle: TAMEL10n.text("九宫盘查看运盘、山盘、向盘", "Inspect layout, mountain, and facing references in the nine-grid."), detail: TAMEL10n.text("九宫盘", "Nine-Grid"), tint: TAMETheme.stardustGold, badgeStyle: .stars, deepLink: .flyingStar),
        .init(title: TAMEL10n.text("年度布局", "Annual Layout"), subtitle: TAMEL10n.text("逐年查看中宫编号与方位参考", "Track yearly center number and directional changes."), detail: TAMEL10n.text("逐年变化", "Yearly"), tint: TAMETheme.stardustGold, badgeStyle: .annual, deepLink: .annual)
    ]

    private let advancedModules: [AnalysisModule] = [
        .init(title: TAMEL10n.text("户型图分析", "Floor Plan Analysis"), subtitle: TAMEL10n.text("导入户型图、立极、房间标记与热力图", "Import a layout, place the center point, and review room heat zones."), detail: TAMEL10n.text("热力叠加", "Heatmap"), tint: TAMETheme.stardustGold, badgeStyle: .layout, deepLink: .floorPlan),
        .init(title: TAMEL10n.text("八区建议", "Eight-Sector Planner"), subtitle: TAMEL10n.text("居住者资料与房屋分组匹配、空间布置建议", "Match occupant and house profiles with room-planning suggestions."), detail: TAMEL10n.text("人屋匹配", "Profile Match"), tint: TAMETheme.stardustGold, badgeStyle: .bazhai, deepLink: .bazhai),
        .init(title: TAMEL10n.text("形煞参考", "Reference Guide"), subtitle: TAMEL10n.text("路冲、反弓、天斩等知识参考", "Browse folk-reference notes on common environmental forms."), detail: TAMEL10n.text("知识参考", "Guide"), tint: TAMETheme.stardustGold, badgeStyle: .reference, deepLink: .reference)
    ]

    private var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    private var recommendedDestination: AnalysisDeepLinkDestination {
        historyStore.records.isEmpty ? .orientation : .flyingStar
    }

    private var recommendedTitle: String {
        switch recommendedDestination {
        case .orientation:
            return TAMEL10n.text("坐向与开口", "Orientation & Openings")
        case .flyingStar:
            return TAMEL10n.text("九宫布局", "Nine-Grid Layout")
        default:
            return TAMEL10n.text("九宫布局", "Nine-Grid Layout")
        }
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack(path: $navigationPath) {
                    mainContent
                        .navigationDestination(for: AnalysisDeepLinkDestination.self) { destination in
                            destinationView(for: destination)
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .tameOpenAnalysisDestination)) { output in
                            guard let rawValue = output.object as? String,
                                  let destination = AnalysisDeepLinkDestination(rawValue: rawValue) else { return }
                            navigationPath = [destination]
                        }
                }
            } else {
                NavigationView {
                    mainContent
                        .onReceive(NotificationCenter.default.publisher(for: .tameOpenAnalysisDestination)) { output in
                            guard let rawValue = output.object as? String,
                                  let destination = AnalysisDeepLinkDestination(rawValue: rawValue) else { return }
                            activeDestinationLegacy = destination
                        }
                        .sheet(item: $activeDestinationLegacy) { destination in
                            NavigationView {
                                destinationView(for: destination)
                            }
                        }
                }
            }
        }
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                introCard
                dashboardCard
                featuredSection
                moduleSection(title: TAMEL10n.text("核心分析", "Core Analysis"), accent: "03", modules: coreModules)
                moduleSection(title: TAMEL10n.text("空间专题", "Spatial Topics"), accent: "04", modules: advancedModules)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 24)
        }
        .navigationTitle(TAMEL10n.text("专题分析", "Analysis"))
        .onAppear {
            guard let destination = pendingInitialDestination else { return }
            handleInitialDestination(destination)
            pendingInitialDestination = nil
        }
    }

    private var introCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text("01")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.22))
                    .frame(width: 40, height: 1)
            }

            Text(TAMEL10n.text("专题分析", "Analysis Topics"))
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(TAMEL10n.text("这里汇集坐向、九宫、年度、户型与八区等常用参考，点开对应卡片即可直接进入。", "This page brings together orientation, nine-grid, annual, floor-plan, and eight-sector references. Open any card to jump straight in."))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                hubPill(
                    title: TAMEL10n.text("常用专题", "Core Topics"),
                    value: "\(coreModules.count)",
                    tint: TAMETheme.stardustGold
                )
                hubPill(
                    title: TAMEL10n.text("空间参考", "Spatial Topics"),
                    value: "\(advancedModules.count)",
                    tint: TAMETheme.techGray
                )
            }

            VStack(spacing: 10) {
                introSpecRow(index: "01", title: TAMEL10n.text("常用专题", "Core topics"), value: TAMEL10n.text("\(coreModules.count) 项", "\(coreModules.count)"))
                introSpecRow(index: "02", title: TAMEL10n.text("空间参考", "Spatial topics"), value: TAMEL10n.text("\(advancedModules.count) 项", "\(advancedModules.count)"))
                introSpecRow(index: "03", title: TAMEL10n.text("推荐入口", "Featured Entry"), value: TAMEL10n.text("1 条", "1"))
            }
        }
        .padding(22)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }

    private var dashboardCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("当前入口", "Current Entry"), accent: "00")

            Text(TAMEL10n.text("这里会结合当前年份和你的本地记录，给出更适合当前节奏的进入方式。", "This dashboard combines the current year and your local records to suggest a fitting way to begin."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            HStack(spacing: 10) {
                hubPill(
                    title: TAMEL10n.text("当前元运", "Current Period"),
                    value: SanyuanJiuyun.from(year: currentYear).localizedPeriodName,
                    tint: TAMETheme.stardustGold
                )
                hubPill(
                    title: TAMEL10n.text("本地记录", "Local Records"),
                    value: "\(historyStore.records.count)",
                    tint: historyStore.records.isEmpty ? TAMETheme.techGray : TAMETheme.stardustGold
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("当前年份", "Current Year"), value: "\(currentYear)")
                metricLine(index: "00.2", title: TAMEL10n.text("当前元运", "Current Period"), value: SanyuanJiuyun.from(year: currentYear).localizedPeriodName)
                metricLine(index: "00.3", title: TAMEL10n.text("已保存分析", "Saved Analyses"), value: "\(historyStore.records.count)")
                metricLine(index: "00.4", title: TAMEL10n.text("建议先看", "Suggested First"), value: recommendedTitle)
            }

            Button(action: { openDestination(recommendedDestination) }) {
                HStack(alignment: .center, spacing: 12) {
                    TAMEDashboardBadge(style: recommendedBadgeStyle, size: 40)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(TAMEL10n.text("立即进入", "Open Now"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Text(TAMEL10n.text("直接进入 \(recommendedTitle)，更适合作为当前这一步的起点。", "Jump straight into \(recommendedTitle), which is the best starting point for this moment."))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .tameInstrumentCard(cornerRadius: 18)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 26, shadow: true)
    }

    private func moduleSection(title: String, accent: String, modules: [AnalysisModule]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: title, accent: accent)

            VStack(spacing: 12) {
                ForEach(modules) { module in
                    moduleLink(module)
                }
            }
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("推荐入口", "Featured Entry"), accent: "02")

            featuredLink
        }
    }

    @ViewBuilder
    private func moduleLink(_ module: AnalysisModule) -> some View {
        if #available(iOS 16.0, *) {
            NavigationLink(value: module.deepLink) {
                moduleCard(module)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(destination: destinationView(for: module.deepLink)) {
                moduleCard(module)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var featuredLink: some View {
        if #available(iOS 16.0, *) {
            NavigationLink(value: AnalysisDeepLinkDestination.floorPlan) {
                featuredCard
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(destination: destinationView(for: .floorPlan)) {
                featuredCard
            }
            .buttonStyle(.plain)
        }
    }

    private func introSpecRow(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 24, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.18))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    private func hubPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(tint.opacity(0.16))
                .frame(width: 20, height: 3)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
    }

    private func sectionHeading(title: String, accent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accent)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)

            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 22, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Rectangle()
                    .fill(TAMETheme.deepBlueBlack.opacity(0.06))
                    .frame(height: 1)
            }
        }
    }

    private func moduleCard(_ module: AnalysisModule) -> some View {
        HStack(alignment: .center, spacing: 16) {
            moduleVisual(module)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(module.indexLabel)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.stardustGold)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.28))
                        .frame(width: 24, height: 1)
                }

                Text(module.title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(module.subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                moduleDetailRow(module)
            }

            Spacer(minLength: 8)

            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .tameInstrumentCard(cornerRadius: 18)
    }

    @ViewBuilder
    private func moduleVisual(_ module: AnalysisModule) -> some View {
        if module.deepLink == .yangGongFenjin {
            TAMEYangGongEntryGlyph()
        } else {
            TAMEDashboardBadge(style: module.badgeStyle, size: 42)
        }
    }

    private var featuredCard: some View {
        HStack(alignment: .center, spacing: 16) {
            TAMEWorkflowBadge(style: .floorPlan, size: 44)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text("02.1")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.stardustGold)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.28))
                        .frame(width: 24, height: 1)
                }

                Text(TAMEL10n.text("打开户型分析", "Open Floor Plan Analysis"))
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(TAMEL10n.text("直接进入户型分析页面，自行导入户型图后查看立极点、房间标记、九宫叠加与热力图。", "Open the floor-plan page directly, then import your layout and review the center point, room markers, grid overlay, and heatmap."))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(TAMETheme.stardustGold)

                    Text(TAMEL10n.text("九宫与热力图", "Grid and Heatmap"))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.18))
                        .frame(maxWidth: .infinity, maxHeight: 1)
                }
            }

            Spacer(minLength: 8)

            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .tameInstrumentCard(cornerRadius: 18)
    }

    private func moduleDetailRow(_ module: AnalysisModule) -> some View {
        HStack(spacing: 8) {
            Image(systemName: module.badgeStyle.minimalSymbol)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(module.tint)

            Text(module.detail)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.18))
                .frame(maxWidth: .infinity, maxHeight: 1)
        }
    }

    private var recommendedBadgeStyle: TAMEDashboardBadgeStyle {
        switch recommendedDestination {
        case .orientation:
            return .naqi
        case .flyingStar:
            return .stars
        default:
            return .analysis
        }
    }

    private func openDestination(_ destination: AnalysisDeepLinkDestination) {
        if #available(iOS 16.0, *) {
            navigationPath = [destination]
        } else {
            activeDestinationLegacy = destination
        }
    }

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 34, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AnalysisDeepLinkDestination) -> some View {
        switch destination {
        case .orientation:
            OrientationAnalysisView()
        case .orientationDemo:
            OrientationAnalysisView(smokeScenario: .southResidence)
        case .yangGongFenjin:
            YangGongFenjinView()
        case .jiuyun:
            JiuyunOverviewView()
        case .flyingStar:
            FlyingStarChartView()
        case .flyingStarDemo:
            FlyingStarChartView(smokeScenario: .naqiDrivenResidence)
        case .annual:
            AnnualFortuneView()
        case .annualDemo:
            AnnualFortuneView(smokeScenario: .houseLinked)
        case .floorPlan:
            FloorPlanAnalysisView()
        case .floorPlanDemo:
            FloorPlanAnalysisView(loadDemoOnAppear: true)
        case .bazhai:
            BazhaiView()
        case .bazhaiSmoke:
            BazhaiView(smokeScenario: .eastGroupPreview)
        case .reference:
            ReferenceKnowledgeView()
        }
    }

    private func handleInitialDestination(_ destination: AnalysisDeepLinkDestination) {
        if #available(iOS 16.0, *) {
            navigationPath = [destination]
        } else {
            activeDestinationLegacy = destination
        }
    }
}

private struct AnalysisModule: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let detail: String
    let tint: Color
    let badgeStyle: TAMEDashboardBadgeStyle
    let deepLink: AnalysisDeepLinkDestination

    var indexLabel: String {
        switch deepLink {
        case .orientation:
            return "03.1"
        case .yangGongFenjin:
            return "03.2"
        case .jiuyun:
            return "03.3"
        case .flyingStar:
            return "03.4"
        case .annual:
            return "03.5"
        case .floorPlan:
            return "04.1"
        case .bazhai:
            return "04.2"
        case .reference:
            return "04.3"
        default:
            return "00.0"
        }
    }
}

struct AnalysisHubView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisHubView()
    }
}

private struct TAMEYangGongEntryGlyph: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            TAMETheme.emphasizedCardBackground
                        ],
                        center: .center,
                        startRadius: 6,
                        endRadius: 34
                    )
                )
                .overlay {
                    Circle()
                        .stroke(TAMETheme.brandHairline, lineWidth: 0.9)
                }

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(0.16), lineWidth: 4)
                .padding(8)

            ForEach(0..<24, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index % 6 == 0 ? TAMETheme.stardustGold : TAMETheme.brandHairline)
                    .frame(width: index % 6 == 0 ? 2.4 : 1.5, height: index % 6 == 0 ? 8 : 5)
                    .offset(y: -25)
                    .rotationEffect(.degrees(Double(index) * 15))
            }

            Capsule(style: .continuous)
                .fill(TAMETheme.stardustGold)
                .frame(width: 3, height: 28)
                .offset(y: -11)
                .rotationEffect(.degrees(33))

            Circle()
                .fill(Color.white)
                .frame(width: 20, height: 20)
                .overlay {
                    Circle()
                        .stroke(TAMETheme.brandHairline, lineWidth: 0.9)
                }

            Text(TAMEL10n.text("分", "L"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .frame(width: 58, height: 58)
        .shadow(color: TAMETheme.brandShadow.opacity(0.7), radius: 10, y: 6)
    }
}
