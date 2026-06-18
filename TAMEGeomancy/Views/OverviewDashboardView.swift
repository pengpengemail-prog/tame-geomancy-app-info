import SwiftUI

struct OverviewDashboardView: View {
    @Binding var selectedTab: RootTab
    @EnvironmentObject private var premiumAccessStore: PremiumAccessStore
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var historyStore = HistoryStore.shared

    private let moduleHighlights: [OverviewModule] = [
        .init(title: TAMEL10n.text("双盘罗盘", "Dual Compass"), subtitle: TAMEL10n.text("地盘 + 纳气盘 7.5° 固定偏移", "Earth ring + intake ring with a fixed 7.5° offset."), tint: TAMETheme.stardustGold, badgeStyle: .compass, destination: .compass),
        .init(title: TAMEL10n.text("杨公分金", "Yang Gong Lines"), subtitle: TAMEL10n.text("二十四山线位与现场立向记录", "24-mountain line review and on-site records."), tint: TAMETheme.stardustGold, badgeStyle: .yangGong, destination: .analysis(.yangGongFenjin)),
        .init(title: TAMEL10n.text("坐向纳气", "Orientation & Openings"), subtitle: TAMEL10n.text("大门、阳台、窗户纳气判断", "Review intake direction for doors, balconies, and windows."), tint: TAMETheme.stardustGold, badgeStyle: .naqi, destination: .analysis(.orientation)),
        .init(title: TAMEL10n.text("三元九运", "Period Guide"), subtitle: TAMEL10n.text("七运 / 八运 / 九运快速归运", "Switch quickly across Period 7, 8, and 9."), tint: TAMETheme.stardustGold, badgeStyle: .period, destination: .analysis(.jiuyun)),
        .init(title: TAMEL10n.text("飞星排盘", "Flying Star Chart"), subtitle: TAMEL10n.text("运盘、山盘、向盘与九宫格", "Inspect yun, mountain, facing stars, and the nine-palace grid."), tint: TAMETheme.stardustGold, badgeStyle: .stars, destination: .analysis(.flyingStar)),
        .init(title: TAMEL10n.text("年度布局", "Annual Layout"), subtitle: TAMEL10n.text("年度中宫编号与方位参考", "Track yearly center number and directional notes."), tint: TAMETheme.stardustGold, badgeStyle: .annual, destination: .analysis(.annual)),
        .init(title: TAMEL10n.text("户型分析", "Floor Plan"), subtitle: TAMEL10n.text("导入户型图、九宫与热力图", "Import a layout, review the grid, and overlay a heatmap."), tint: TAMETheme.stardustGold, badgeStyle: .layout, destination: .analysis(.floorPlan)),
        .init(title: TAMEL10n.text("八区建议", "Eight-Sector Planner"), subtitle: TAMEL10n.text("居住者资料、房屋分组与房间布置建议", "Match occupant and house profiles with room-planning advice."), tint: TAMETheme.stardustGold, badgeStyle: .bazhai, destination: .analysis(.bazhai)),
        .init(title: TAMEL10n.text("形煞参考", "Reference Guide"), subtitle: TAMEL10n.text("仅做环境观察与知识参考", "For environmental observation and reference only."), tint: TAMETheme.stardustGold, badgeStyle: .reference, destination: .analysis(.reference))
    ]

    private let quickEntries: [QuickEntry] = [
        .init(title: TAMEL10n.text("罗盘测向", "Compass Review"), subtitle: TAMEL10n.text("双盘实测", "Dual-ring live view"), detail: TAMEL10n.text("真北 / 锁向", "True north / lock"), tint: TAMETheme.stardustGold, badgeStyle: .compass, target: .compass),
        .init(title: TAMEL10n.text("专题分析", "Analysis"), subtitle: TAMEL10n.text("8 个页面", "8 pages"), detail: TAMEL10n.text("分金 / 飞星", "Lines / stars"), tint: TAMETheme.stardustGold, badgeStyle: .analysis, target: .analysis),
        .init(title: TAMEL10n.text("历史记录", "Records"), subtitle: TAMEL10n.text("查看与导出", "Review and export"), detail: TAMEL10n.text("备注 / 报告", "Notes / reports"), tint: TAMETheme.stardustGold, badgeStyle: .records, target: .records),
        .init(title: TAMEL10n.text("设置支持", "Settings & Support"), subtitle: TAMEL10n.text("政策与配置", "Policy and controls"), detail: TAMEL10n.text("权限 / 备份", "Permissions / backup"), tint: TAMETheme.stardustGold, badgeStyle: .settings, target: .settings)
    ]

    private let workflowEntries: [WorkflowEntry] = [
        .init(
            title: TAMEL10n.text("快速测向", "Quick Compass"),
            subtitle: TAMEL10n.text("进入双盘罗盘，查看地盘与纳气盘方位参考", "Open the dual compass and review the Earth and intake rings together."),
            footer: TAMEL10n.text("双盘参考", "Dual-ring view"),
            style: .compass,
            tint: TAMETheme.stardustGold,
            destination: .compass
        ),
        .init(
            title: TAMEL10n.text("户型分析", "Floor Plan Analysis"),
            subtitle: TAMEL10n.text("直接进入户型分析页，导入户型图后查看九宫与热力图", "Open the floor-plan page and review the grid and heatmap after importing a layout."),
            footer: TAMEL10n.text("进入户型页", "Open floor plans"),
            style: .floorPlan,
            tint: TAMETheme.stardustGold,
            destination: .floorPlan
        ),
        .init(
            title: TAMEL10n.text("记录与导出", "Records & Export"),
            subtitle: TAMEL10n.text("查看已保存内容，并从记录详情导出报告图片", "Review saved items and export report images from record details."),
            footer: TAMEL10n.text("从记录进入", "Open records"),
            style: .report,
            tint: TAMETheme.stardustGold,
            destination: .records
        ),
        .init(
            title: TAMEL10n.text("权限与帮助", "Permissions & Help"),
            subtitle: TAMEL10n.text("查看定位、运动、相机、相册状态与使用方式", "Check location, motion, camera, Photos, and guidance."),
            footer: TAMEL10n.text("常用说明", "Helpful notes"),
            style: .support,
            tint: TAMETheme.stardustGold,
            destination: .settingsSupport
        )
    ]

    private let spotlightEntries: [SpotlightEntry] = [
        .init(title: TAMEL10n.text("解锁与购买", "Unlock & Purchase"), subtitle: TAMEL10n.text("查看订阅方案", "View subscription plans"), badgeStyle: .settings, destination: .settings(.premium)),
        .init(title: TAMEL10n.text("杨公分金", "Yang Gong Lines"), subtitle: TAMEL10n.text("二十四山线位", "24-mountain lines"), badgeStyle: .yangGong, destination: .analysis(.yangGongFenjin)),
        .init(title: TAMEL10n.text("坐向纳气", "Orientation & Openings"), subtitle: TAMEL10n.text("主纳气口判断", "Primary opening review"), badgeStyle: .naqi, destination: .analysis(.orientation)),
        .init(title: TAMEL10n.text("三元九运", "Period Guide"), subtitle: TAMEL10n.text("快速切年", "Quick year switch"), badgeStyle: .period, destination: .analysis(.jiuyun)),
        .init(title: TAMEL10n.text("飞星排盘", "Flying Star Chart"), subtitle: TAMEL10n.text("九宫总盘", "Nine-palace chart"), badgeStyle: .stars, destination: .analysis(.flyingStar)),
        .init(title: TAMEL10n.text("年度布局", "Annual Layout"), subtitle: TAMEL10n.text("逐年参考", "Yearly review"), badgeStyle: .annual, destination: .analysis(.annual)),
        .init(title: TAMEL10n.text("八区建议", "Eight-Sector Planner"), subtitle: TAMEL10n.text("人屋匹配", "Profile match"), badgeStyle: .bazhai, destination: .analysis(.bazhai)),
        .init(title: TAMEL10n.text("本地备份", "Local Backup"), subtitle: TAMEL10n.text("导出 / 恢复", "Export / restore"), badgeStyle: .settings, destination: .settings(.backupExport))
    ]

    private var currentPeriod: SanyuanJiuyun {
        SanyuanJiuyun.current
    }

    private var latestRecord: AnalysisRecord? {
        historyStore.records.first
    }

    var body: some View {
        NavigationView {
            ScrollView {
            VStack(spacing: 24) {
                heroCard
                liveSummarySection
                quickEntrySection
                featureMatrixSection
                supportSection
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
            .navigationBarHidden(true)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text("00")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.35))
                    .frame(width: 36, height: 1)
            }

            TAMEBrandLockup(
                wordmarkColor: .black,
                primaryColor: .black,
                secondaryColor: TAMETheme.brandTextSecondary,
                wordmarkHeight: 32,
                spacing: 8
            )

            TAMEOverviewInstrumentPreview(currentPeriod: currentPeriod, recordCount: historyStore.records.count)

            Text(TAMEL10n.text("罗盘测向、专题分析与空间参考", "Compass readings, analysis, and spatial reference"))
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(TAMEL10n.text("从这里可以快速进入罗盘、户型、飞星、流年与记录页面，先测向，再查看对应空间参考会更顺手。", "Start here to move quickly into compass, floor-plan, Flying Star, annual, and record pages. Confirm orientation first, then open the matching spatial references."))
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            VStack(spacing: 10) {
                heroSpecRow(index: "01", title: TAMEL10n.text("主要功能", "Main features"), value: TAMEL10n.text("8 项", "8"))
                heroSpecRow(index: "02", title: TAMEL10n.text("常用入口", "Main tabs"), value: TAMEL10n.text("5 个", "5"))
                heroSpecRow(index: "03", title: TAMEL10n.text("报告分享", "Report sharing"), value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("待解锁", "Locked"))
            }

            HStack(spacing: 10) {
                heroPill(
                    title: TAMEL10n.text("视觉基调", "Visual Tone"),
                    value: TAMEL10n.text("白底极简", "White Minimal"),
                    tint: TAMETheme.techGray
                )
                heroPill(
                    title: TAMEL10n.text("当前元运", "Current Period"),
                    value: currentPeriod.localizedPeriodName,
                    tint: TAMETheme.stardustGold
                )
            }
        }
        .padding(22)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }

    private func heroPill(title: String, value: String, tint: Color) -> some View {
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

    private var liveSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("当前状态", "Live Snapshot"), accent: "00")

            Text(TAMEL10n.text("这里会结合当前年份和本地记录，帮助你更快看到当前元运、已保存内容，以及下一步更适合打开的页面。", "This area combines the current year and local records so you can quickly see the active period, saved content, and the next page worth opening."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("当前元运", "Current Period"), value: currentPeriod.localizedPeriodName)
                metricLine(index: "00.2", title: TAMEL10n.text("当运星", "Current Star"), value: currentPeriod.star)
                metricLine(index: "00.3", title: TAMEL10n.text("本地记录", "Saved Records"), value: "\(historyStore.records.count)")
                metricLine(index: "00.4", title: TAMEL10n.text("高级解锁", "Premium Access"), value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("可选方案", "Plans available"))
            }

            Button(action: {
                openSettings(.premium)
            }) {
                HStack(alignment: .center, spacing: 14) {
                    TAMEDashboardBadge(style: .settings, size: 46)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(TAMEL10n.text("解锁与购买", "Unlock & Purchase"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Text(TAMEL10n.text("查看订阅方案、恢复购买与使用说明。", "View subscription plans, restore purchase, and usage details."))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .tameInstrumentCard(cornerRadius: 18)
            }
            .buttonStyle(.plain)

            if let latestRecord {
                dashboardHighlightCard(record: latestRecord)
            }

            PremiumAccessInlineCard(
                title: TAMEL10n.text("高级解锁", "Premium Access"),
                summary: TAMEL10n.text("解锁报告分享与保存到相册能力。", "Unlock report sharing and save-to-Photos features."),
                actionTitle: TAMEL10n.text("查看解锁", "View Unlock")
            )
        }
    }

    private var quickEntrySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("主线入口", "Primary Paths"), accent: "01")

            VStack(spacing: 10) {
                ForEach(Array(quickEntries.enumerated()), id: \.element.id) { index, entry in
                    entryRow(entry, index: index + 1)
                }
            }
        }
    }

    private var featureMatrixSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("功能入口", "Feature Shortcuts"), accent: "03")

            LazyVGrid(columns: detailedCardColumns, spacing: 10) {
                ForEach(moduleHighlights) { module in
                    featureMatrixButton(module)
                }
            }
        }
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("使用提示", "Quick Notes"), accent: "04")

            Text(TAMEL10n.text("建议先在罗盘页确认房屋坐向，再进入专题页查看纳气、飞星、流年与户型分析结果。", "Start on the compass page to confirm the house orientation, then move into the topic pages for openings, Flying Star, annual review, and floor-plan analysis."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Text(TAMEL10n.text("导入户型图后，请尽量准确标记立极点、大门、阳台与主窗，这会直接影响后续参考结果。", "After importing a floor plan, mark the center point, main door, balcony, and major windows as accurately as possible, as they directly affect the later references."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)

            Text(TAMEL10n.text("本 APP 内容仅为民俗文化参考，非科学依据。", "This app is for cultural reference only and is not scientific guidance."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
        }
        .padding(.top, 2)
    }

    private var detailedCardColumns: [GridItem] {
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), spacing: 12)]
        }

        return Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    }

    private func entryRow(_ entry: QuickEntry, index: Int) -> some View {
        Button(action: { selectedTab = entry.target }) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Text(String(format: "%02d", index))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.stardustGold)

                        Rectangle()
                            .fill(TAMETheme.stardustGold.opacity(0.28))
                            .frame(width: 26, height: 1)
                    }

                    Text(entry.title)
                        .font(.system(size: 19, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(entry.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    Text(entry.detail)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextMuted)
                }

                Spacer(minLength: 12)

                VStack(alignment: .trailing, spacing: 10) {
                    TAMEDashboardBadge(style: entry.badgeStyle, size: 36)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .tameInstrumentCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
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

    private func featureMatrixButton(_ module: OverviewModule) -> some View {
        Button(action: { performOverviewModule(module.destination) }) {
            ZStack {
                featureMatrixBackground(module)

                HStack(alignment: .top, spacing: 12) {
                    TAMEDashboardBadge(style: module.badgeStyle, size: 50)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Text(module.indexLabel)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.stardustGold)

                            Rectangle()
                                .fill(TAMETheme.stardustGold.opacity(0.28))
                                .frame(width: 24, height: 1)
                        }

                        Text(module.title)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Text(module.subtitle)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        featureMatrixFooter(module)
                    }

                    Spacer(minLength: 0)

                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                }
                .frame(maxWidth: .infinity, minHeight: 114, alignment: .topLeading)
                .padding(14)
            }
            .tameInstrumentCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func featureMatrixFooter(_ module: OverviewModule) -> some View {
        HStack(spacing: 8) {
            Image(systemName: module.badgeStyle.minimalSymbol)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)

            Text(module.footerText)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.18))
                .frame(maxWidth: .infinity, maxHeight: 1)
        }
    }

    private func featureMatrixBackground(_ module: OverviewModule) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 249 / 255, green: 247 / 255, blue: 242 / 255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .center
                    )
                )
                .padding(1)

            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(module.tint.opacity(0.018))
                .offset(x: 40, y: 26)
                .blur(radius: 10)
        }
    }

    private func workflowButton(_ entry: WorkflowEntry) -> some View {
        Button(action: { performWorkflow(entry.destination) }) {
            HStack(alignment: .center, spacing: 12) {
                TAMEWorkflowBadge(style: entry.style, size: 40)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(entry.indexLabel)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.stardustGold)

                        Rectangle()
                            .fill(TAMETheme.stardustGold.opacity(0.28))
                            .frame(width: 24, height: 1)
                    }

                    Text(entry.title)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(entry.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(entry.footer)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextMuted)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .tameInstrumentCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func spotlightRow(_ entry: SpotlightEntry, index: Int) -> some View {
        Button(action: { performSpotlight(entry.destination) }) {
            HStack(alignment: .center, spacing: 14) {
                Text(String(format: "%02d", index))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
                    .frame(width: 30, alignment: .leading)

                TAMEDashboardBadge(style: entry.badgeStyle, size: 44)

                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(entry.subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 16)
            .tameInstrumentCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func performWorkflow(_ destination: WorkflowDestination) {
        switch destination {
        case .compass:
            selectedTab = .compass
        case .floorPlan:
            openAnalysis(.floorPlan)
        case .records:
            openRecords(.list)
        case .settingsSupport:
            openSettings(.permissions)
        }
    }

    private func performSpotlight(_ destination: SpotlightDestination) {
        switch destination {
        case .analysis(let destination):
            openAnalysis(destination)
        case .settings(let destination):
            openSettings(destination)
        }
    }

    private func performOverviewModule(_ destination: OverviewModuleDestination) {
        switch destination {
        case .compass:
            selectedTab = .compass
        case .analysis(let destination):
            openAnalysis(destination)
        }
    }

    private func heroSpecRow(index: String, title: String, value: String) -> some View {
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

    private func dashboardHighlightCard(record: AnalysisRecord) -> some View {
        Button(action: {
            openRecords(.list)
        }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(TAMEL10n.text("最近活动", "Latest Activity"))
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.stardustGold)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.18))
                        .frame(width: 22, height: 1)
                }

                Text(record.title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(record.subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextMuted)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .tameInstrumentCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 34, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    private func openAnalysis(_ destination: AnalysisDeepLinkDestination) {
        selectedTab = .analysis

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: .tameOpenAnalysisDestination,
                object: destination.rawValue
            )
        }
    }

    private func openRecords(_ destination: RecordsDeepLinkDestination) {
        selectedTab = .records

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: .tameOpenRecordsDestination,
                object: destination.rawValue
            )
        }
    }

    private func openSettings(_ destination: SettingsDeepLinkDestination) {
        selectedTab = .settings

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(
                name: .tameOpenSettingsDestination,
                object: destination.rawValue
            )
        }
    }
}

private struct OverviewModule: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let tint: Color
    let badgeStyle: TAMEDashboardBadgeStyle
    let destination: OverviewModuleDestination

    var indexLabel: String {
        switch badgeStyle {
        case .compass:
            return "03.1"
        case .yangGong:
            return "03.2"
        case .naqi:
            return "03.3"
        case .period:
            return "03.4"
        case .stars:
            return "03.5"
        case .annual:
            return "03.6"
        case .layout:
            return "03.7"
        case .bazhai:
            return "03.8"
        case .reference:
            return "03.9"
        case .analysis, .records, .settings:
            return "03.0"
        }
    }

    var footerText: String {
        switch badgeStyle {
        case .compass:
            return TAMEL10n.text("双盘同步", "Synced rings")
        case .yangGong:
            return TAMEL10n.text("分金立向", "Line review")
        case .naqi:
            return TAMEL10n.text("纳气判断", "Opening review")
        case .period:
            return TAMEL10n.text("七八九运", "Periods 7-9")
        case .stars:
            return TAMEL10n.text("九宫排盘", "Nine-palace grid")
        case .annual:
            return TAMEL10n.text("逐年查看", "Yearly review")
        case .layout:
            return TAMEL10n.text("热力叠加", "Heat overlay")
        case .bazhai:
            return TAMEL10n.text("命宅匹配", "Gua match")
        case .reference:
            return TAMEL10n.text("知识参考", "Reference")
        case .analysis, .records, .settings:
            return TAMEL10n.text("功能入口", "Feature entry")
        }
    }
}

private enum OverviewModuleDestination {
    case compass
    case analysis(AnalysisDeepLinkDestination)
}

private struct QuickEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let detail: String
    let tint: Color
    let badgeStyle: TAMEDashboardBadgeStyle
    let target: RootTab
}

private struct WorkflowEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let footer: String
    let style: TAMEWorkflowBadgeStyle
    let tint: Color
    let destination: WorkflowDestination

    var indexLabel: String {
        switch destination {
        case .compass:
            return "04.1"
        case .floorPlan:
            return "04.2"
        case .records:
            return "04.3"
        case .settingsSupport:
            return "04.4"
        }
    }
}

private enum WorkflowDestination {
    case compass
    case floorPlan
    case records
    case settingsSupport
}

private enum SpotlightDestination {
    case analysis(AnalysisDeepLinkDestination)
    case settings(SettingsDeepLinkDestination)
}

private struct SpotlightEntry: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let badgeStyle: TAMEDashboardBadgeStyle
    let destination: SpotlightDestination
}

struct OverviewDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        OverviewDashboardView(selectedTab: .constant(.overview))
    }
}

private struct TAMEOverviewInstrumentPreview: View {
    let currentPeriod: SanyuanJiuyun
    let recordCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                Text(TAMEL10n.text("现场仪表", "Field Console"))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
                    .lineLimit(1)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.18))
                    .frame(height: 1)
            }

            HStack(alignment: .center, spacing: 18) {
                miniCompass

                VStack(alignment: .leading, spacing: 12) {
                    instrumentMetricStack

                    miniGrid
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tameInstrumentCard(cornerRadius: 22, emphasized: true, shadow: false)
    }

    private var miniCompass: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.94),
                            TAMETheme.fieldBackground.opacity(0.90)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(TAMETheme.brandHairline.opacity(0.55), lineWidth: 1)
                }
                .shadow(color: TAMETheme.brandShadow.opacity(0.55), radius: 12, x: 0, y: 8)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            TAMETheme.fieldBackground,
                            TAMETheme.stardustGold.opacity(0.10),
                            TAMETheme.deepBlueBlack.opacity(0.025)
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 76
                    )
                )
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.92), lineWidth: 1)
                }
                .shadow(color: TAMETheme.brandShadow.opacity(0.86), radius: 14, x: 0, y: 8)
                .padding(5)

            Circle()
                .stroke(
                    AngularGradient(
                        colors: [
                            TAMETheme.deepBlueBlack.opacity(0.34),
                            TAMETheme.stardustGold.opacity(0.76),
                            Color.white.opacity(0.88),
                            TAMETheme.deepBlueBlack.opacity(0.22),
                            TAMETheme.stardustGold.opacity(0.68),
                            TAMETheme.deepBlueBlack.opacity(0.34)
                        ],
                        center: .center
                    ),
                    lineWidth: 4.6
                )
                .padding(7)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(0.11), lineWidth: 1.2)
                .padding(13)

            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .trim(from: 0.010, to: 0.068)
                    .stroke(
                        TAMETheme.stardustGold.opacity(index == 0 ? 0.72 : 0.32),
                        style: StrokeStyle(lineWidth: index == 0 ? 2.2 : 1.3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(Double(index) * 90 - 92))
                    .padding(15)
            }

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(0.09), lineWidth: 10)
                .padding(18)

            Circle()
                .stroke(TAMETheme.brandHairline.opacity(0.76), lineWidth: 1)
                .padding(28)

            Circle()
                .stroke(
                    TAMETheme.brandHairline.opacity(0.38),
                    style: StrokeStyle(lineWidth: 1, dash: [2, 5], dashPhase: 1)
                )
                .padding(45)

            ForEach(0..<72, id: \.self) { index in
                let primary = index % 18 == 0
                let secondary = index % 6 == 0
                Capsule(style: .continuous)
                    .fill(primary ? TAMETheme.deepBlueBlack.opacity(0.64) : TAMETheme.deepBlueBlack.opacity(secondary ? 0.28 : 0.13))
                    .frame(width: primary ? 2.5 : 1, height: primary ? 15 : (secondary ? 9 : 4.5))
                    .offset(y: -55)
                    .rotationEffect(.degrees(Double(index) * 5))
            }

            ForEach(0..<8, id: \.self) { index in
                Capsule(style: .continuous)
                    .fill(index % 2 == 0 ? TAMETheme.stardustGold.opacity(0.26) : TAMETheme.deepBlueBlack.opacity(0.13))
                    .frame(width: index % 2 == 0 ? 1.1 : 0.7, height: 66)
                    .rotationEffect(.degrees(Double(index) * 22.5))
            }

            ForEach(compassAxisLabels) { label in
                Text(label.title)
                    .font(.system(size: label.isPrimary ? 13 : 11, weight: label.isPrimary ? .semibold : .medium, design: .serif))
                    .foregroundColor(label.isPrimary ? TAMETheme.deepBlueBlack.opacity(0.90) : TAMETheme.deepBlueBlack.opacity(0.50))
                    .shadow(color: Color.white.opacity(0.8), radius: 2, x: 0, y: 1)
                    .offset(x: label.offset.width, y: label.offset.height)
            }

            InstrumentNeedleShape()
                .fill(TAMETheme.deepBlueBlack.opacity(0.34))
                .frame(width: 11, height: 54)
                .offset(y: 25)
                .rotationEffect(.degrees(202))
                .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            InstrumentNeedleShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.92),
                            TAMETheme.stardustGold,
                            TAMETheme.stardustGold.opacity(0.78),
                            TAMETheme.deepBlueBlack.opacity(0.22)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    InstrumentNeedleShape()
                        .stroke(TAMETheme.deepBlueBlack.opacity(0.22), lineWidth: 0.8)
                }
                .frame(width: 15, height: 68)
                .offset(y: -34)
                .rotationEffect(.degrees(22))
                .shadow(color: TAMETheme.stardustGold.opacity(0.28), radius: 8, x: 0, y: 3)

            Capsule(style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            TAMETheme.deepBlueBlack.opacity(0.58),
                            TAMETheme.deepBlueBlack.opacity(0.24)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3.4, height: 58)
                .offset(y: -28)
                .rotationEffect(.degrees(22))

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.white,
                            TAMETheme.fieldBackground,
                            TAMETheme.deepBlueBlack.opacity(0.035)
                        ],
                        center: .center,
                        startRadius: 3,
                        endRadius: 21
                    )
                )
                .frame(width: 40, height: 40)
                .overlay {
                    Circle()
                        .stroke(TAMETheme.brandHairline.opacity(0.82), lineWidth: 1)
                }
                .shadow(color: TAMETheme.brandShadow.opacity(0.9), radius: 7, x: 0, y: 3)

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(0.32), lineWidth: 2)
                .frame(width: 24, height: 24)

            Circle()
                .stroke(TAMETheme.deepBlueBlack.opacity(0.06), lineWidth: 5)
                .frame(width: 14, height: 14)

            Circle()
                .fill(TAMETheme.stardustGold.opacity(0.92))
                .frame(width: 6, height: 6)

            Circle()
                .trim(from: 0.56, to: 0.76)
                .stroke(Color.white.opacity(0.56), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 108, height: 108)
                .rotationEffect(.degrees(-18))
        }
        .frame(width: 148, height: 148)
    }

    private var miniGrid: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(TAMEL10n.text("九宫方位", "Nine-Palace Grid"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)

            VStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { column in
                            let cell = gridCell(row: row, column: column)
                            RoundedRectangle(cornerRadius: 9, style: .continuous)
                                .fill(cell.background)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                                        .stroke(cell.border, lineWidth: 1)
                                }
                                .overlay {
                                    VStack(spacing: 1) {
                                        Text(cell.title)
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(cell.foreground)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.74)

                                        Text(cell.subtitle)
                                            .font(.system(size: 14, weight: .regular, design: .rounded))
                                            .foregroundColor(TAMETheme.brandTextMuted)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.64)
                                    }
                                    .padding(.horizontal, 3)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .frame(height: 36)
                        }
                    }
                }
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(0.62))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(TAMETheme.brandHairline.opacity(0.65), lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var instrumentMetricStack: some View {
        VStack(spacing: 7) {
            instrumentMetricLine(
                title: TAMEL10n.text("空间周期", "Period"),
                value: currentPeriod.localizedPeriodName,
                tint: TAMETheme.stardustGold
            )
            instrumentMetricLine(
                title: TAMEL10n.text("本地记录", "Records"),
                value: "\(recordCount)",
                tint: recordCount > 0 ? TAMETheme.stardustGold : TAMETheme.techGray
            )
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.72))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(TAMETheme.brandHairline.opacity(0.68), lineWidth: 1)
        }
    }

    private func gridCell(row: Int, column: Int) -> (title: String, subtitle: String, background: Color, border: Color, foreground: Color) {
        let labels: [[(String, String, Color)]] = [
            [
                (TAMEL10n.text("西北", "NW"), TAMEL10n.text("乾", "Qian"), Color.white),
                (TAMEL10n.text("北", "N"), TAMEL10n.text("坎", "Kan"), Color.white),
                (TAMEL10n.text("东北", "NE"), TAMEL10n.text("艮", "Gen"), Color.white)
            ],
            [
                (TAMEL10n.text("西", "W"), TAMEL10n.text("兑", "Dui"), Color.white),
                (TAMEL10n.text("中宫", "Center"), TAMEL10n.text("中", "Center"), TAMETheme.stardustGold.opacity(0.14)),
                (TAMEL10n.text("东", "E"), TAMEL10n.text("震", "Zhen"), Color.white)
            ],
            [
                (TAMEL10n.text("西南", "SW"), TAMEL10n.text("坤", "Kun"), Color.white),
                (TAMEL10n.text("南", "S"), TAMEL10n.text("离", "Li"), Color.white),
                (TAMEL10n.text("东南", "SE"), TAMEL10n.text("巽", "Xun"), Color.white)
            ]
        ]

        let cell = labels[row][column]
        let isCenter = row == 1 && column == 1
        return (
            title: cell.0,
            subtitle: cell.1,
            background: isCenter ? TAMETheme.stardustGold.opacity(0.13) : Color.white.opacity(0.88),
            border: isCenter ? TAMETheme.stardustGold.opacity(0.30) : TAMETheme.brandHairline.opacity(0.72),
            foreground: TAMETheme.brandTextPrimary
        )
    }

    private func instrumentMetricLine(title: String, value: String, tint: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Rectangle()
                .fill(tint.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var compassAxisLabels: [CompassAxisLabel] {
        [
            .init(title: TAMEL10n.text("子", "N"), offset: CGSize(width: 0, height: -33), isPrimary: true),
            .init(title: TAMEL10n.text("卯", "E"), offset: CGSize(width: 33, height: 0), isPrimary: false),
            .init(title: TAMEL10n.text("午", "S"), offset: CGSize(width: 0, height: 33), isPrimary: false),
            .init(title: TAMEL10n.text("酉", "W"), offset: CGSize(width: -33, height: 0), isPrimary: false)
        ]
    }
}

private struct CompassAxisLabel: Identifiable {
    let title: String
    let offset: CGSize
    let isPrimary: Bool

    var id: String { "\(title)-\(offset.width)-\(offset.height)" }
}

private struct InstrumentNeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        path.move(to: CGPoint(x: midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - rect.width * 0.58))
        path.addQuadCurve(
            to: CGPoint(x: midX, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY - rect.width * 0.14)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - rect.width * 0.58),
            control: CGPoint(x: rect.minX, y: rect.maxY - rect.width * 0.14)
        )
        path.closeSubpath()
        return path
    }
}
