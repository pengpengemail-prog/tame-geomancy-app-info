import SwiftUI

enum AnnualFortuneSmokeScenario {
    case currentYear
    case houseLinked
}

struct AnnualFortuneView: View {
    @StateObject private var viewModel = AnnualFortuneViewModel()
    @StateObject private var historyStore = HistoryStore.shared
    @State private var saveStatusMessage: String?
    @State private var appliedSmokeScenario = false
    private let smokeScenario: AnnualFortuneSmokeScenario?

    init(smokeScenario: AnnualFortuneSmokeScenario? = nil) {
        self.smokeScenario = smokeScenario
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let saveStatusMessage {
                        TAMEStatusBanner(message: saveStatusMessage)
                    }

                    annualWorkspaceSection
                    scenarioSection
                    yearPickerSection
                    houseReferenceSection

                    if let chart = viewModel.annualChart {
                        annualChartSection(chart: chart)
                    }

                    if let analysis = viewModel.analysis {
                        annualOverviewSection(analysis: analysis)
                        fortuneAnalysisSection(analysis: analysis)
                        sectorInsightSection(analysis: analysis)
                    }
                }
                .padding()
                .padding(.bottom, TAMETheme.bottomContentInset)
            }
            .tameBrandPageBackground()
            .navigationTitle(TAMEL10n.text("年度布局", "Annual Layout"))
        }
        .onAppear {
            runInitialScenarioIfNeeded()
        }
    }

    private var annualWorkspaceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前年度", "Annual Snapshot"), accent: "00")

            Text(TAMEL10n.text("这里先确认当前年份、所属元运、房屋联动状态与年度参考重心，再进入九宫、方位与逐宫细评。", "This section summarizes the active year, period cycle, house-link mode, and yearly focus before you move into the chart, highlights, and sector details."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                focusPill(
                    title: TAMEL10n.text("房屋联动", "House Link"),
                    value: viewModel.useHouseFacingReference ? TAMEL10n.text("已开启", "Enabled") : TAMEL10n.text("仅看流年", "Annual Only"),
                    tint: viewModel.useHouseFacingReference ? TAMETheme.stardustGold : TAMETheme.techGray
                )
                focusPill(
                    title: TAMEL10n.text("年度重点", "Annual Focus"),
                    value: annualFocusSummary,
                    tint: TAMETheme.stardustGold
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("当前年份", "Year"), value: "\(viewModel.selectedYear)")
                metricLine(index: "00.2", title: TAMEL10n.text("所属元运", "Period"), value: viewModel.currentPeriod?.localizedPeriodName ?? SanyuanJiuyun.from(year: viewModel.selectedYear).localizedPeriodName)
                metricLine(index: "00.3", title: TAMEL10n.text("房屋联动", "House Link"), value: viewModel.useHouseFacingReference ? TAMEL10n.text("已开启", "Enabled") : TAMEL10n.text("仅看流年", "Annual only"))
                metricLine(index: "00.4", title: TAMEL10n.text("纳气口", "Opening Basis"), value: viewModel.useNaqiBasis ? TAMEL10n.text("\(viewModel.naqiPointName) · \(formattedNaqiAngle)°", "\(viewModel.naqiPointName) · \(formattedNaqiAngle)°") : TAMEL10n.text("未带入", "Not included"))
                metricLine(index: "00.5", title: TAMEL10n.text("年度重点", "Annual Focus"), value: annualFocusSummary)
            }

            if let analysis = viewModel.analysis {
                Text(analysis.yearTheme)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }

    private func runInitialScenarioIfNeeded() {
        guard !appliedSmokeScenario else {
            viewModel.loadCurrentYear()
            return
        }

        appliedSmokeScenario = true

        switch smokeScenario {
        case .currentYear:
            applyCurrentYearScenario()
        case .houseLinked:
            applyHouseLinkedScenario()
        case .none:
            viewModel.loadCurrentYear()
        }
    }

    private var scenarioSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("使用方式", "Usage Modes"), accent: "01")

            Text(TAMEL10n.text("可以只看当年的年度变化，也可以把房屋坐向与主开口一起带入判断。", "You can review the annual pattern on its own or include the house orientation and main opening together."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 12) {
                scenarioButton(
                    title: TAMEL10n.text("当前年份", "Current Year"),
                    subtitle: TAMEL10n.text("只看流年九宫", "Annual star grid only"),
                    action: { applyCurrentYearScenario() }
                )

                scenarioButton(
                    title: TAMEL10n.text("房屋联动", "House Linked"),
                    subtitle: TAMEL10n.text("坐向 + 主开口", "Sitting + main opening"),
                    action: { applyHouseLinkedScenario() }
                )
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 26, emphasized: true, shadow: true)
    }

    private var yearPickerSection: some View {
        VStack(spacing: 12) {
            sectionHeading(title: TAMEL10n.text("年份选择", "Year Selection"), accent: "02")

            HStack {
                Button(action: { viewModel.previousYear() }) {
                    Image(systemName: "chevron.left.circle.fill")
                        .font(.title2)
                }

                Spacer()

                VStack(spacing: 4) {
                    Text(TAMEL10n.text("\(viewModel.selectedYear)年", "\(viewModel.selectedYear)"))
                        .font(.system(size: 28, weight: .medium, design: .rounded))

                    if let period = viewModel.currentPeriod {
                        Text(period.localizedPeriodName)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                    }
                }

                Spacer()

                Button(action: { viewModel.nextYear() }) {
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.title2)
                }
            }

            HStack(spacing: 8) {
                ForEach([2024, 2025, 2026, 2027], id: \.self) { year in
                    Button(action: { viewModel.selectYear(year) }) {
                        Text("\(year)")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(viewModel.selectedYear == year ? Color.white : Color.white.opacity(0.96))
                            .foregroundColor(viewModel.selectedYear == year ? TAMETheme.deepBlueBlack : TAMETheme.brandTextPrimary)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(viewModel.selectedYear == year ? TAMETheme.stardustGold.opacity(0.22) : TAMETheme.brandHairline, lineWidth: 1)
                            }
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private var houseReferenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("房屋联动", "House Link"), accent: "03")

            Toggle(TAMEL10n.text("带入房屋坐向一起分析", "Analyze with house orientation"), isOn: $viewModel.useHouseFacingReference)
                .tint(TAMETheme.stardustGold)
                .tameOnChangeCompat(of: viewModel.useHouseFacingReference) {
                    viewModel.updateHouseReference()
                }

            if viewModel.useHouseFacingReference {
                Picker(TAMEL10n.text("参考坐山", "Sitting Reference"), selection: $viewModel.selectedSittingDirection) {
                    ForEach(Direction.allCases) { direction in
                        Text(direction.localizedLabel).tag(direction)
                    }
                }
                .pickerStyle(.menu)
                .tameOnChangeCompat(of: viewModel.selectedSittingDirection) {
                    viewModel.updateHouseReference()
                }

                Toggle(TAMEL10n.text("主开口参与年度判断", "Use opening for annual review"), isOn: $viewModel.useNaqiBasis)
                    .tint(TAMETheme.stardustGold)
                    .tameOnChangeCompat(of: viewModel.useNaqiBasis) {
                        viewModel.updateHouseReference()
                    }

                if viewModel.useNaqiBasis {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(TAMEL10n.text("主开口名称，如 大门 / 主阳台", "Opening name, e.g. Main Door / Balcony"), text: $viewModel.naqiPointName)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .tameFieldStyle(cornerRadius: 12)
                            .onSubmit {
                                viewModel.updateHouseReference()
                            }

                        Text(TAMEL10n.text("主开口地盘角度 \(formattedNaqiAngle)°", "Opening earth angle \(formattedNaqiAngle)°"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                        Slider(value: $viewModel.rawNaqiAngle, in: 0...359.9, step: 0.5)
                            .tint(TAMETheme.stardustGold)
                            .tameOnChangeCompat(of: viewModel.rawNaqiAngle) {
                                viewModel.updateHouseReference()
                            }
                    }
                }
            } else {
                Text(TAMEL10n.text("当前只按年度方位做参考。如需判断与你房屋的坐向、向方、主开口如何互动，请打开上方开关。", "This view currently uses annual directional sectors only. Enable the switch above to include house orientation and the main opening."))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func annualChartSection(chart: NinePalace) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("流年九宫飞星", "Annual Nine-Palace Stars"), accent: "04")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    ForEach(0..<3, id: \.self) { col in
                        annualPalaceCard(row: row, col: col, star: chart.stars[row][col])
                    }
                }
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func annualPalaceCard(row: Int, col: Int, star: Int) -> some View {
        let positionNames = TAMEL10n.isEnglish
        ? [
            ["Southeast", "South", "Southwest"],
            ["East", "Center", "West"],
            ["Northeast", "North", "Northwest"]
        ]
        : [
            ["东南", "南", "西南"],
            ["东", "中", "西"],
            ["东北", "北", "西北"]
        ]

        return VStack(spacing: 8) {
            Text(positionNames[row][col])
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Text("\(star)")
                .font(.system(size: 34, weight: .medium, design: .rounded))
                .foregroundColor(starColor(star))

            Text(starName(star))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(starColor(star).opacity(0.16))
                .frame(width: 30, height: 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
        }
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
    }

    private func annualOverviewSection(analysis: AnnualFortuneAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("年度联动摘要", "Annual Summary"), accent: "05")

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(TAMEL10n.text("中宫星：\(analysis.centerStar) · \(starName(analysis.centerStar))", "Center star: \(analysis.centerStar) · \(starName(analysis.centerStar))"))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                }

                Spacer()
            }

            Text(analysis.annualChartBasis)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(spacing: 10) {
                metricLine(index: "05.1", title: TAMEL10n.text("太岁", "Tai Sui"), value: analysis.taiSuiDirection.localizedLabel)
                metricLine(index: "05.2", title: TAMEL10n.text("岁破", "Sui Po"), value: analysis.suiPoDirection.localizedLabel)
                metricLine(index: "05.3", title: TAMEL10n.text("元运", "Period"), value: viewModel.currentPeriod?.localizedPeriodName ?? "")
            }

            HStack(spacing: 10) {
                focusPill(
                    title: TAMEL10n.text("年度基调", "Annual Tone"),
                    value: starName(analysis.centerStar),
                    tint: TAMETheme.stardustGold
                )
                focusPill(
                    title: TAMEL10n.text("联动方式", "Reference Mode"),
                    value: viewModel.useHouseFacingReference
                    ? TAMEL10n.text("已带入房屋", "House Linked")
                    : TAMEL10n.text("仅看流年", "Annual Only"),
                    tint: viewModel.useHouseFacingReference ? TAMETheme.stardustGold : TAMETheme.techGray
                )
            }

            actionCard(
                title: TAMEL10n.text("保存流年记录", "Save Annual Record"),
                subtitle: TAMEL10n.text("把年度九宫、太岁岁破、房屋联动摘要与方位建议一起归档到历史记录。", "Archive the annual chart, Tai Sui/Sui Po, house-linked summary, and sector guidance into Records."),
                symbol: "square.and.arrow.down"
            ) {
                saveRecord()
            }

            Text(analysis.yearTheme)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Text(analysis.houseAdvice)
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(analysis.summary)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func focusPill(title: String, value: String, tint: Color) -> some View {
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
                .fill(tint.opacity(0.18))
                .frame(width: 22, height: 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .tameInstrumentCard(cornerRadius: 14, shadow: false)
    }

    private func fortuneAnalysisSection(analysis: AnnualFortuneAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("方位宜忌", "Sector Highlights"), accent: "06")

            if !analysis.auspiciousDirections.isEmpty {
                fortuneCard(
                    title: TAMEL10n.text("吉星方位", "Helpful Sectors"),
                    icon: "star.fill",
                    color: TAMETheme.stardustGold,
                    directions: analysis.auspiciousDirections,
                    description: analysis.auspiciousAdvice
                )
            }

            if !analysis.inauspiciousDirections.isEmpty {
                fortuneCard(
                    title: TAMEL10n.text("需注意方位", "Watch Sectors"),
                    icon: "exclamationmark.triangle.fill",
                    color: TAMETheme.brandAlert,
                    directions: analysis.inauspiciousDirections,
                    description: analysis.inauspiciousAdvice
                )
            }

            if !analysis.remedies.isEmpty {
                remediesSection(remedies: analysis.remedies)
            }
        }
    }

    private func sectorInsightSection(analysis: AnnualFortuneAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("方位细评", "Sector Insights"), accent: "07")

            ForEach(analysis.sectorInsights.prefix(6)) { insight in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(insight.positionName) · \(insight.annualStarName)")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                            Text(TAMEL10n.text("\(insight.directionalRelationship) · 年度分值 \(insight.annualScore)", "\(insight.directionalRelationship) · score \(insight.annualScore)"))
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextSecondary)
                        }

                        Spacer()

                        Text(statusText(for: insight.annualStatus))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(statusColor(for: insight.annualStatus).opacity(0.10))
                            )
                            .overlay {
                                Capsule()
                                    .stroke(statusColor(for: insight.annualStatus).opacity(0.16), lineWidth: 1)
                            }
                            .foregroundColor(statusColor(for: insight.annualStatus))
                    }

                    Text(insight.summary)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
                .padding(16)
                .tameInstrumentCard(cornerRadius: 20, shadow: false)
            }
        }
    }

    private func fortuneCard(title: String, icon: String, color: Color, directions: [(Int, Int)], description: String) -> some View {
        let positionNames = TAMEL10n.isEnglish
        ? [
            ["Southeast", "South", "Southwest"],
            ["East", "Center", "West"],
            ["Northeast", "North", "Northwest"]
        ]
        : [
            ["东南", "南", "西南"],
            ["东", "中", "西"],
            ["东北", "北", "西北"]
        ]

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }

            Text(directions.map { positionNames[$0.0][$0.1] }.joined(separator: TAMEL10n.isEnglish ? ", " : "、"))
                .font(.system(size: 14.5, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(description)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .padding(20)
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(color.opacity(0.18), lineWidth: 1)
        }
        .tameInstrumentCard(cornerRadius: 20, shadow: false)
    }

    private func remediesSection(remedies: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(TAMETheme.stardustGold)
                Text(TAMEL10n.text("化解建议", "Reference Suggestions"))
                    .font(.system(size: 17, weight: .medium, design: .rounded))
            }

            ForEach(Array(remedies.enumerated()), id: \.offset) { index, remedy in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                    Text(remedy)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
            }
        }
        .padding(20)
        .tameInstrumentCard(cornerRadius: 20, shadow: false)
    }

    private func actionCard(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(TAMETheme.stardustGold)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .tameInstrumentCard(cornerRadius: 16, shadow: false)
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
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.14))
                    .frame(height: 1)
            }
        }
    }

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 32, alignment: .leading)

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

    private var formattedNaqiAngle: String {
        String(format: "%.1f", viewModel.rawNaqiAngle)
    }

    private var annualFocusSummary: String {
        if let analysis = viewModel.analysis {
            return TAMEL10n.text("中宫 \(analysis.centerStar) · 太岁 \(analysis.taiSuiDirection.localizedLabel)", "Center \(analysis.centerStar) · Tai Sui \(analysis.taiSuiDirection.localizedLabel)")
        }

        return TAMEL10n.text("等待年度结果", "Awaiting result")
    }

    private func saveRecord() {
        guard let analysis = viewModel.analysis else { return }
        historyStore.save(
            category: .annual,
            title: TAMEL10n.text("\(viewModel.selectedYear) 年年度布局", "\(viewModel.selectedYear) Annual Layout"),
            subtitle: TAMEL10n.text("中宫 \(analysis.centerStar) · 太岁 \(analysis.taiSuiDirection.localizedLabel)", "Center \(analysis.centerStar) · Tai Sui \(analysis.taiSuiDirection.localizedLabel)"),
            details: viewModel.recordDetails()
        )
        saveStatusMessage = TAMEL10n.text("年度布局记录已保存，可到“历史记录”查看。", "Annual layout record saved. Review it in Records.")
    }

    private func starColor(_ star: Int) -> Color {
        switch star {
        case 1, 6, 8, 9: return TAMETheme.stardustGold
        case 2, 5: return TAMETheme.brandAlert
        case 3, 4, 7: return TAMETheme.techGray
        default: return .primary
        }
    }

    private func starBackgroundColor(_ star: Int) -> Color {
        switch star {
        case 1, 6, 8, 9: return TAMETheme.stardustGold.opacity(0.12)
        case 2, 5: return TAMETheme.brandAlert.opacity(0.12)
        default: return TAMETheme.fieldBackground
        }
    }

    private func starName(_ star: Int) -> String {
        switch star {
        case 1: return TAMEL10n.text("一白贪狼", "1 White Tanlang")
        case 2: return TAMEL10n.text("二黑病符", "2 Black Illness")
        case 3: return TAMEL10n.text("三碧禄存", "3 Jade Lucun")
        case 4: return TAMEL10n.text("四绿文曲", "4 Green Wenqu")
        case 5: return TAMEL10n.text("五黄廉贞", "5 Yellow Lianzhen")
        case 6: return TAMEL10n.text("六白武曲", "6 White Wuqu")
        case 7: return TAMEL10n.text("七赤破军", "7 Red Pojun")
        case 8: return TAMEL10n.text("八白左辅", "8 White Zuofu")
        case 9: return TAMEL10n.text("九紫右弼", "9 Purple Youbi")
        default: return ""
        }
    }

    private func statusText(for status: StarStatus) -> String {
        switch status {
        case .wang: return TAMEL10n.text("旺", "Peak")
        case .sheng: return TAMEL10n.text("生", "Rising")
        case .tui: return TAMEL10n.text("退", "Fading")
        case .shuai: return TAMEL10n.text("衰", "Weak")
        case .sha: return TAMEL10n.text("注意", "Watch")
        }
    }

    private func statusColor(for status: StarStatus) -> Color {
        switch status {
        case .wang: return TAMETheme.stardustGold
        case .sheng: return TAMETheme.deepBlueBlack.opacity(0.72)
        case .tui, .shuai: return TAMETheme.techGray
        case .sha: return TAMETheme.brandAlert
        }
    }

    private func scenarioButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                Text(TAMEL10n.text("立即带入", "Load Preset"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 16, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private func applyCurrentYearScenario() {
        viewModel.useHouseFacingReference = false
        viewModel.useNaqiBasis = false
        viewModel.selectYear(Calendar.current.component(.year, from: Date()))
    }

    private func applyHouseLinkedScenario() {
        viewModel.useHouseFacingReference = true
        viewModel.selectedSittingDirection = .zi
        viewModel.useNaqiBasis = true
        viewModel.rawNaqiAngle = 182
        viewModel.naqiPointName = TAMEL10n.text("大门", "Main Door")
        viewModel.selectYear(2026)
        viewModel.updateHouseReference()
    }
}
