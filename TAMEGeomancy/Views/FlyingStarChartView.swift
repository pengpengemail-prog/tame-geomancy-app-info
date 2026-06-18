import SwiftUI

enum FlyingStarSmokeScenario {
    case southResidence
    case naqiDrivenResidence
}

struct FlyingStarChartView: View {
    @State private var selectedDirection: Direction
    @State private var selectedYear: Int
    @State private var useNaqiBasis: Bool
    @State private var rawNaqiAngle: Double
    @State private var chart: CompleteFlyingStarPan?
    @State private var saveStatusMessage: String?
    @State private var appliedSmokeScenario = false
    @StateObject private var historyStore = HistoryStore.shared
    private let smokeScenario: FlyingStarSmokeScenario?

    init(
        initialSittingDirection: Direction = .zi,
        initialYear: Int = Calendar.current.component(.year, from: Date()),
        initialRawNaqiAngle: Double = 180,
        useNaqiBasis: Bool = false,
        smokeScenario: FlyingStarSmokeScenario? = nil
    ) {
        _selectedDirection = State(initialValue: initialSittingDirection)
        _selectedYear = State(initialValue: initialYear)
        _rawNaqiAngle = State(initialValue: initialRawNaqiAngle)
        _useNaqiBasis = State(initialValue: useNaqiBasis)
        self.smokeScenario = smokeScenario
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let saveStatusMessage {
                    TAMEStatusBanner(message: saveStatusMessage)
                }

                workspaceCard
                scenarioCard
                controlCard

                if let chart {
                    snapshotCard(chart)
                    chartGrid(chart)
                    summaryCard(chart)
                }
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .navigationTitle(TAMEL10n.text("飞星排盘", "Flying Star Chart"))
        .onAppear {
            runInitialScenarioIfNeeded()
        }
    }

    private var workspaceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前排盘", "Current Chart"), accent: "00")

            Text(TAMEL10n.text("这里先确认年份、坐向、元运与向盘依据，再进入九宫总盘与排盘摘要，适合作为飞星主流程的起点。", "This section summarizes the year, sitting direction, period cycle, and facing basis before you move into the nine-palace chart and notes."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("参考年份", "Year"), value: "\(selectedYear)")
                metricLine(index: "00.2", title: TAMEL10n.text("当前元运", "Period"), value: SanyuanJiuyun.from(year: selectedYear).localizedPeriodName)
                metricLine(index: "00.3", title: TAMEL10n.text("坐山朝向", "Sitting / Facing"), value: TAMEL10n.text("\(selectedDirection.localizedLabel) / \(selectedDirection.opposite.localizedLabel)", "\(selectedDirection.localizedLabel) / \(selectedDirection.opposite.localizedLabel)"))
                metricLine(index: "00.4", title: TAMEL10n.text("起盘方式", "Facing Basis"), value: useNaqiBasis ? TAMEL10n.text("纳气口起盘", "Opening-based") : TAMEL10n.text("标准朝向", "Standard facing"))
                metricLine(index: "00.5", title: TAMEL10n.text("当前重点", "Current Focus"), value: workspaceFocusSummary)
            }

            if useNaqiBasis, let point = currentNaqiPoint {
                Text(TAMEL10n.text("当前纳气盘换算为 \(String(format: "%.1f°", point.naqiAngle))，落在 \(point.direction.localizedLabel) 方，可直接作为向盘依据。", "The current adjusted opening angle is \(String(format: "%.1f°", point.naqiAngle)) in the \(point.direction.localizedLabel) sector and is ready to anchor the facing chart."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)

                Text(TAMEL10n.text("当前 \(currentPeriod.localizedPeriodName) 下，纳气盘口径与罗盘页一致：水区为 \(naqiWaterZoneSummary)，气区为 \(naqiQiZoneSummary)。", "In \(currentPeriod.localizedPeriodName), the Naqi basis matches the compass page: water zones are \(naqiWaterZoneSummary), while qi zones are \(naqiQiZoneSummary)."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }

    private func runInitialScenarioIfNeeded() {
        guard !appliedSmokeScenario else {
            generateChart()
            return
        }

        appliedSmokeScenario = true

        switch smokeScenario {
        case .southResidence:
            applySouthResidenceScenario()
        case .naqiDrivenResidence:
            applyNaqiDrivenScenario()
        case .none:
            generateChart()
        }
    }

    private var scenarioCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("快速带入", "Quick Setups"), accent: "01")

            Text(TAMEL10n.text("这里提供两种常见起步配置，方便先看到完整飞星盘，再按你的房屋实际情况继续微调。", "Two common starting setups are provided here so you can see a complete chart first and then fine-tune it to match the actual home."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 12) {
                scenarioButton(
                    title: TAMEL10n.text("九运南向宅", "Period 9 South Home"),
                    subtitle: TAMEL10n.text("默认朝南，直接排盘", "Standard south-facing layout"),
                    action: { applySouthResidenceScenario() }
                )

                scenarioButton(
                    title: TAMEL10n.text("纳气起盘", "Opening-Based Chart"),
                    subtitle: TAMEL10n.text("带入主纳气口角度", "Uses the primary opening angle"),
                    action: { applyNaqiDrivenScenario() }
                )
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 26, emphasized: true, shadow: true)
    }

    private var controlCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("排盘参数", "Chart Inputs"), accent: "02")

            Picker(TAMEL10n.text("坐山", "Sitting Direction"), selection: $selectedDirection) {
                ForEach(Direction.allCases) { direction in
                    Text(direction.localizedLabel).tag(direction)
                }
            }
            .pickerStyle(.menu)

            Stepper(TAMEL10n.text("参考年份 \(selectedYear)", "Reference Year \(selectedYear)"), value: $selectedYear, in: 1984...2043)

            Toggle(TAMEL10n.text("向盘按纳气口起盘", "Use opening angle for facing"), isOn: $useNaqiBasis)
                .tint(TAMETheme.stardustGold)

            if useNaqiBasis {
                VStack(alignment: .leading, spacing: 8) {
                    Text(TAMEL10n.text(
                        "纳气口地盘角度 \(String(format: "%.1f", rawNaqiAngle))°",
                        "Opening earth angle \(String(format: "%.1f", rawNaqiAngle))°"
                    ))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                    Slider(value: $rawNaqiAngle, in: 0...359.9, step: 0.5)
                        .tint(TAMETheme.stardustGold)
                    if let point = currentNaqiPoint {
                        Text(TAMEL10n.text("当前纳气依据：\(String(format: "%.1f°", point.naqiAngle)) · \(point.direction.localizedLabel)方 · 向星\(point.xiangStar)", "Current opening basis: \(String(format: "%.1f°", point.naqiAngle)) · \(point.direction.localizedLabel) sector · Facing star \(point.xiangStar)"))
                            .font(.system(size: 12.5, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                        Text(TAMEL10n.text("当前元运下参考：水区 \(naqiWaterZoneSummary) · 气区 \(naqiQiZoneSummary)", "Current period reference: Water \(naqiWaterZoneSummary) · Qi \(naqiQiZoneSummary)"))
                            .font(.system(size: 12.5, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                    }
                }
            }

            HStack(spacing: 12) {
                Button(TAMEL10n.text("重新排盘", "Regenerate")) {
                    generateChart()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(TAMEPrimaryActionButtonStyle())

                Button(TAMEL10n.text("保存记录", "Save Record")) {
                    saveRecord()
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(TAMESecondaryActionButtonStyle())
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func snapshotCard(_ chart: CompleteFlyingStarPan) -> some View {
        let center = chart.getPalaceInfo(row: 1, col: 1)

        return VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("当前排盘摘要", "Current Snapshot"), accent: "03")

            Text(TAMEL10n.text("\(selectedYear) 年 · \(SanyuanJiuyun.from(year: selectedYear).localizedPeriodName) · 坐\(selectedDirection.localizedLabel)朝\(selectedDirection.opposite.localizedLabel)", "\(selectedYear) · \(SanyuanJiuyun.from(year: selectedYear).localizedPeriodName) · Sitting \(selectedDirection.localizedLabel) / Facing \(selectedDirection.opposite.localizedLabel)"))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            HStack(spacing: 10) {
                snapshotPill(
                    title: TAMEL10n.text("元运", "Period"),
                    value: SanyuanJiuyun.from(year: selectedYear).star,
                    tint: TAMETheme.techGray
                )
                snapshotPill(
                    title: TAMEL10n.text("起盘方式", "Facing Basis"),
                    value: useNaqiBasis
                    ? TAMEL10n.text("纳气起盘", "Opening-Based")
                    : TAMEL10n.text("标准朝向", "Standard Facing"),
                    tint: useNaqiBasis ? TAMETheme.stardustGold : TAMETheme.techGray
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "03.1", title: TAMEL10n.text("中宫运星", "Center Yun"), value: "\(center.yunStar)")
                metricLine(index: "03.2", title: TAMEL10n.text("中宫山星", "Center Mountain"), value: "\(center.shanStar)")
                metricLine(index: "03.3", title: TAMEL10n.text("中宫向星", "Center Facing"), value: "\(center.xiangStar)")
            }

            Text(useNaqiBasis ? TAMEL10n.text("当前已按纳气口起向盘，适合联动坐向与纳气口一起观察。", "The chart is currently using the selected opening as its facing basis.") : TAMEL10n.text("当前按标准朝向起盘，适合先看基础九宫分布。", "The chart is currently using the standard facing direction as its basis."))
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func snapshotPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
            Text(value)
                .font(.system(size: 13, weight: .medium, design: .rounded))
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

    private func chartGrid(_ chart: CompleteFlyingStarPan) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("九宫飞星", "Nine-Palace Grid"), accent: "04")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(0..<3, id: \.self) { row in
                    ForEach(0..<3, id: \.self) { col in
                        let info = chart.getPalaceInfo(row: row, col: col)
                        VStack(spacing: 8) {
                            Text(positionName(row: row, col: col))
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextSecondary)

                            HStack(spacing: 4) {
                                Text("\(info.shanStar)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(TAMETheme.brandTextSecondary)
                                Text("\(info.yunStar)")
                                    .font(.system(size: 28, weight: .medium, design: .rounded))
                                    .foregroundColor(TAMETheme.brandTextPrimary)
                                Text("\(info.xiangStar)")
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                                    .foregroundColor(TAMETheme.stardustGold)
                            }

                            Text(info.level)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(levelColor(info.level))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .tameInstrumentCard(cornerRadius: 14, shadow: false)
                        .overlay(alignment: .bottomLeading) {
                            Capsule()
                                .fill(levelColor(info.level).opacity(0.16))
                                .frame(width: 42, height: 4)
                                .padding(.horizontal, 14)
                                .padding(.bottom, 10)
                        }
                    }
                }
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func summaryCard(_ chart: CompleteFlyingStarPan) -> some View {
        let center = chart.getPalaceInfo(row: 1, col: 1)
        return VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("排盘摘要", "Chart Notes"), accent: "05")
            Text(TAMEL10n.text("当前按 \(selectedDirection.localizedLabel) 山、\(selectedDirection.opposite.localizedLabel) 向、\(selectedYear) 年进行排盘。中宫运星为 \(center.yunStar)，山星为 \(center.shanStar)，向星为 \(center.xiangStar)。", "This chart uses \(selectedDirection.localizedLabel) sitting, \(selectedDirection.opposite.localizedLabel) facing, and year \(selectedYear). The center palace holds Yun \(center.yunStar), Mountain \(center.shanStar), and Facing \(center.xiangStar)."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
            if let point = currentNaqiPoint, useNaqiBasis {
                Text(TAMEL10n.text("向盘依据：按纳气口地盘 \(String(format: "%.1f°", rawNaqiAngle))，换算纳气盘 \(String(format: "%.1f°", point.naqiAngle))，以 \(point.direction.localizedLabel) 方起向盘。", "Facing basis: earth angle \(String(format: "%.1f°", rawNaqiAngle)), converted to adjusted opening angle \(String(format: "%.1f°", point.naqiAngle)), with the \(point.direction.localizedLabel) sector used as the facing start."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                Text(TAMEL10n.text("本次纳气参考沿用 \(currentPeriod.localizedPeriodName) 的分区口径：水区 \(naqiWaterZoneSummary)，气区 \(naqiQiZoneSummary)。", "This opening reference follows the \(currentPeriod.localizedPeriodName) zoning basis: water zones \(naqiWaterZoneSummary), qi zones \(naqiQiZoneSummary)."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            } else {
                Text(TAMEL10n.text("向盘依据：当前未启用纳气口起盘，默认按朝向 \(selectedDirection.opposite.localizedLabel) 方参考。", "Facing basis: opening-based mode is off, so the standard \(selectedDirection.opposite.localizedLabel) facing reference is used."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
            Text(TAMEL10n.text("吉凶等级仅供民俗文化参考，建议结合纳气口、户型与实际使用动线一起判断。", "All grading is for cultural reference only and should be reviewed alongside openings, layout, and circulation."))
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private func generateChart() {
        let period = SanyuanJiuyun.from(year: selectedYear)
        chart = FlyingStarCalculator.calculateCompletePan(
            sitting: selectedDirection,
            facing: selectedDirection.opposite,
            jiuyun: period,
            year: selectedYear,
            naqiAngle: useNaqiBasis ? currentNaqiPoint?.naqiAngle : nil
        )
    }

    private func saveRecord() {
        guard let chart else { return }
        let center = chart.getPalaceInfo(row: 1, col: 1)
        let basisText: String
        if let point = currentNaqiPoint, useNaqiBasis {
            basisText = TAMEL10n.text("向盘依据：纳气盘 \(String(format: "%.1f°", point.naqiAngle)) · \(point.direction.localizedLabel)方", "Facing basis: Opening \(String(format: "%.1f°", point.naqiAngle)) · \(point.direction.localizedLabel) sector")
        } else {
            basisText = TAMEL10n.text("向盘依据：默认按朝向 \(selectedDirection.opposite.localizedLabel) 方", "Facing basis: standard facing \(selectedDirection.opposite.localizedLabel)")
        }

        historyStore.save(
            category: .flyingStar,
            title: TAMEL10n.text("\(selectedDirection.localizedLabel)山飞星盘", "\(selectedDirection.localizedLabel) Flying Star Chart"),
            subtitle: TAMEL10n.text("\(selectedYear) 年 · 中宫 \(center.yunStar)", "\(selectedYear) · Center \(center.yunStar)"),
            details: [
                TAMEL10n.text("坐山：\(selectedDirection.localizedLabel)", "Sitting: \(selectedDirection.localizedLabel)"),
                TAMEL10n.text("朝向：\(selectedDirection.opposite.localizedLabel)", "Facing: \(selectedDirection.opposite.localizedLabel)"),
                TAMEL10n.text("元运：\(currentPeriod.localizedPeriodName) · \(currentPeriod.star)", "Period: \(currentPeriod.localizedPeriodName) · \(currentPeriod.star)"),
                basisText,
                TAMEL10n.text("纳气分区：水 \(naqiWaterZoneSummary) · 气 \(naqiQiZoneSummary)", "Naqi zoning: Water \(naqiWaterZoneSummary) · Qi \(naqiQiZoneSummary)"),
                TAMEL10n.text("中宫：运\(center.yunStar) 山\(center.shanStar) 向\(center.xiangStar)", "Center: Yun \(center.yunStar) Mountain \(center.shanStar) Facing \(center.xiangStar)")
            ]
        )
        saveStatusMessage = TAMEL10n.text("飞星排盘记录已保存，可到“历史记录”查看。", "Flying star record saved. You can review it in Records.")
    }

    private var currentPeriod: SanyuanJiuyun {
        SanyuanJiuyun.from(year: selectedYear)
    }

    private var naqiWaterZoneSummary: String {
        [("北", "N"), ("西南", "SW"), ("东", "E"), ("东南", "SE")]
            .map { TAMEL10n.text($0.0, $0.1) }
            .joined(separator: " / ")
    }

    private var naqiQiZoneSummary: String {
        [("南", "S"), ("西", "W"), ("西北", "NW"), ("东北", "NE")]
            .map { TAMEL10n.text($0.0, $0.1) }
            .joined(separator: " / ")
    }

    private var currentNaqiPoint: NaqiAnalyzer.NaqiPoint? {
        guard useNaqiBasis else { return nil }
        return NaqiAnalyzer.analyzeNaqiPoint(
            type: .mainDoor,
            name: TAMEL10n.text("纳气口", "Opening"),
            angle: rawNaqiAngle,
            yun: SanyuanJiuyun.from(year: selectedYear)
        )
    }

    private func positionName(row: Int, col: Int) -> String {
        let names = TAMEL10n.isEnglish
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
        return names[row][col]
    }

    private func levelColor(_ level: String) -> Color {
        switch level {
        case TAMEL10n.text("大吉", "Excellent"):
            return TAMETheme.stardustGold
        case TAMEL10n.text("吉", "Favorable"):
            return TAMETheme.moonWhite
        case TAMEL10n.text("平", "Balanced"):
            return TAMETheme.techGray
        default:
            return TAMETheme.brandAlert
        }
    }

    private func scenarioButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
                Text(subtitle)
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                Text(TAMEL10n.text("快速带入", "Load Preset"))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 16, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private func sectionHeading(title: String, accent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accent)
                .font(.system(size: 11, weight: .medium, design: .rounded))
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
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 32, alignment: .leading)

            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    private var workspaceFocusSummary: String {
        if let chart {
            let center = chart.getPalaceInfo(row: 1, col: 1)
            return TAMEL10n.text("中宫 运\(center.yunStar) 山\(center.shanStar) 向\(center.xiangStar)", "Center Yun \(center.yunStar) / Mountain \(center.shanStar) / Facing \(center.xiangStar)")
        }

        return TAMEL10n.text("等待排盘", "Awaiting chart")
    }

    private func applySouthResidenceScenario() {
        selectedDirection = .zi
        selectedYear = 2026
        useNaqiBasis = false
        rawNaqiAngle = 180
        generateChart()
    }

    private func applyNaqiDrivenScenario() {
        selectedDirection = .mao
        selectedYear = 2028
        useNaqiBasis = true
        rawNaqiAngle = 126
        generateChart()
    }
}

struct FlyingStarChartView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FlyingStarChartView()
        }
    }
}
