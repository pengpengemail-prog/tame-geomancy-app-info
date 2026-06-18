import SwiftUI

struct OrientationNaqiInput: Identifiable, Equatable {
    let id: UUID
    var type: NaqiAnalyzer.NaqiType
    var name: String
    var angle: Double

    init(
        id: UUID = UUID(),
        type: NaqiAnalyzer.NaqiType,
        name: String,
        angle: Double
    ) {
        self.id = id
        self.type = type
        self.name = name
        self.angle = angle
    }
}

enum OrientationSmokeScenario {
    case southResidence
    case eastCornerResidence
}

struct OrientationAnalysisView: View {
    @State private var selectedType: NaqiAnalyzer.NaqiType = .mainDoor
    @State private var rawAngle: Double = 180
    @State private var constructionYear: Int = Calendar.current.component(.year, from: Date())
    @State private var selectedPointName: String = TAMEL10n.text("大门", "Main Door")
    @State private var selectedSittingDirection: Direction = .zi
    @State private var naqiInputs: [OrientationNaqiInput] = [
        OrientationNaqiInput(type: .mainDoor, name: TAMEL10n.text("大门", "Main Door"), angle: 180)
    ]
    @State private var result: NaqiAnalyzer.NaqiAnalysisResult?
    @State private var linkedChart: CompleteFlyingStarPan?
    @State private var saveStatusMessage: String?
    @State private var appliedSmokeScenario = false
    @StateObject private var historyStore = HistoryStore.shared
    private let smokeScenario: OrientationSmokeScenario?

    init(smokeScenario: OrientationSmokeScenario? = nil) {
        self.smokeScenario = smokeScenario
    }

    private var primaryPoint: NaqiAnalyzer.NaqiPoint? {
        result?.bestPoint ?? result?.mainPoint
    }

    private var currentPeriod: SanyuanJiuyun {
        SanyuanJiuyun.from(year: constructionYear)
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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let saveStatusMessage {
                    TAMEStatusBanner(message: saveStatusMessage)
                }

                workspaceCard
                demoScenarioCard
                inputCard

                if let result {
                    overviewCard(result)
                    pointListCard(result)
                    if let primaryPoint, let linkedChart {
                        flyingStarLinkCard(point: primaryPoint, chart: linkedChart)
                    }
                    suggestionCard(result)
                }
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .navigationTitle(TAMEL10n.text("坐向与纳气", "Orientation & Openings"))
        .onAppear {
            runInitialScenarioIfNeeded()
        }
    }

    private var workspaceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前纳气", "Current Openings"), accent: "00")

            Text(TAMEL10n.text("这里先确认建房年份、参考坐山、纳气口数量与当前主纳气。本页对纳气旺衰的判断，与罗盘页当前元运下的水区 / 气区口径保持一致。", "This section summarizes the build year, sitting reference, opening count, and current primary intake. The opening logic here follows the same period-based water and qi zoning shown on the compass page."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                naqiPill(
                    title: TAMEL10n.text("当前元运", "Current Period"),
                    value: currentPeriod.localizedPeriodName,
                    tint: TAMETheme.stardustGold
                )
                naqiPill(
                    title: TAMEL10n.text("主纳气口", "Primary Opening"),
                    value: primaryPoint?.name ?? TAMEL10n.text("待判断", "Pending"),
                    tint: primaryPoint == nil ? TAMETheme.techGray : TAMETheme.stardustGold
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("建房 / 入住年", "Build / Move-in"), value: "\(constructionYear)")
                metricLine(index: "00.2", title: TAMEL10n.text("参考坐山", "Sitting Reference"), value: selectedSittingDirection.localizedLabel)
                metricLine(index: "00.3", title: TAMEL10n.text("纳气口数量", "Openings"), value: "\(naqiInputs.count)")
                metricLine(index: "00.4", title: TAMEL10n.text("当前主纳气", "Primary Opening"), value: workspacePrimarySummary)
                metricLine(index: "00.5", title: TAMEL10n.text("飞星联动", "Linked Chart"), value: linkedChart == nil ? TAMEL10n.text("未生成", "Not generated") : TAMEL10n.text("已联动", "Linked"))
                metricLine(index: "00.6", title: TAMEL10n.text("纳气分区", "Naqi Zoning"), value: TAMEL10n.text("水 \(naqiWaterZoneSummary) · 气 \(naqiQiZoneSummary)", "Water \(naqiWaterZoneSummary) · Qi \(naqiQiZoneSummary)"))
            }

            if let result {
                Text(result.summary)
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }

    private func runInitialScenarioIfNeeded() {
        guard !appliedSmokeScenario else {
            analyze()
            return
        }

        appliedSmokeScenario = true

        switch smokeScenario {
        case .southResidence:
            applySouthFacingResidenceScenario()
        case .eastCornerResidence:
            applyEastFacingCornerScenario()
        case .none:
            analyze()
        }
    }

    private var demoScenarioCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("快速带入", "Quick Setups"), accent: "01")

            Text(TAMEL10n.text("这里提供两种常见住宅格局，点一下就会带入多处纳气口，并同步更新飞星摘要。", "Two common residential layouts are provided here. One tap brings in multiple openings and updates the linked Flying Star summary together."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 12) {
                demoScenarioButton(
                    title: TAMEL10n.text("南向住宅", "South-Facing Home"),
                    subtitle: TAMEL10n.text("大门 + 阳台 + 主窗", "Door + Balcony + Main Window"),
                    action: { applySouthFacingResidenceScenario() }
                )

                demoScenarioButton(
                    title: TAMEL10n.text("东向边户", "East Corner Unit"),
                    subtitle: TAMEL10n.text("入户门 + 转角窗", "Entry + Corner Window"),
                    action: { applyEastFacingCornerScenario() }
                )
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 26, emphasized: true, shadow: true)
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("纳气口录入", "Opening Inputs"), accent: "02")

            Picker(TAMEL10n.text("纳气口类型", "Opening Type"), selection: $selectedType) {
                ForEach(NaqiAnalyzer.NaqiType.allCases, id: \.rawValue) { type in
                    Text(type.localizedTitle).tag(type)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text(TAMEL10n.text("名称备注", "Label"))
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                TextField(TAMEL10n.text("如 主阳台 / 入户门", "Example: Main Balcony / Entry"), text: $selectedPointName)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .tameFieldStyle(cornerRadius: 12)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(TAMEL10n.text(
                    "地盘角度 \(String(format: "%.1f", rawAngle))°",
                    "Earth plate angle \(String(format: "%.1f", rawAngle))°"
                ))
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
                Slider(value: $rawAngle, in: 0...359.9, step: 0.5)
                    .tint(TAMETheme.stardustGold)
            }

            HStack(spacing: 12) {
                Button(action: addOrUpdateCurrentPoint) {
                    Label(TAMEL10n.text("加入比较", "Add to Comparison"), systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMEPrimaryActionButtonStyle())

                Button(action: analyze) {
                    Label(TAMEL10n.text("重新计算", "Recalculate"), systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
            }

            if naqiInputs.isEmpty {
                Text(TAMEL10n.text("请至少录入一个大门、阳台或窗户纳气口。", "Add at least one door, balcony, or window opening."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Text(TAMEL10n.text("当前比较列表", "Current Comparison"))
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    ForEach(naqiInputs) { point in
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(point.name)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(TAMETheme.brandTextPrimary)
                                Text("\(point.type.localizedTitle) · \(TAMEL10n.text("地盘", "Earth")) \(String(format: "%.1f°", point.angle))")
                                    .font(.system(size: 12, weight: .regular, design: .rounded))
                                    .foregroundColor(TAMETheme.brandTextSecondary)
                            }

                            Spacer()

                            Button(action: {
                                load(point)
                            }) {
                                Image(systemName: "pencil")
                            }
                            .buttonStyle(.plain)

                            Button(role: .destructive, action: {
                                remove(point.id)
                            }) {
                                Image(systemName: "trash")
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(12)
                        .tameInstrumentCard(cornerRadius: 14, shadow: false)
                    }
                }
            }

            Stepper(TAMEL10n.text("建房 / 入住年份 \(constructionYear)", "Build / Move-in Year \(constructionYear)"), value: $constructionYear, in: 1984...2043)

            Picker(TAMEL10n.text("参考坐山", "Sitting Direction"), selection: $selectedSittingDirection) {
                ForEach(Direction.allCases) { direction in
                    Text(direction.localizedLabel).tag(direction)
                }
            }
            .pickerStyle(.menu)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func overviewCard(_ result: NaqiAnalyzer.NaqiAnalysisResult) -> some View {
        let primary = primaryPoint

        return VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("纳气摘要", "Opening Summary"), accent: "03")

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(primary?.name ?? TAMEL10n.text("纳气综合", "Opening Overview"))
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                    Text(primary.map { "\($0.direction.localizedLabel) · \($0.element.localizedLabel) · \($0.level)" } ?? TAMEL10n.text("暂无纳气结果", "No Opening Result Yet"))
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(result.overallScore)")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                    Text(TAMEL10n.text("综合分", "Score"))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
            }

            VStack(spacing: 10) {
                metricLine(index: "03.1", title: TAMEL10n.text("纳气口", "Openings"), value: TAMEL10n.text("\(result.points.count) 处", "\(result.points.count)"))
                metricLine(index: "03.2", title: TAMEL10n.text("综合等级", "Overall"), value: result.overallLevel)
                metricLine(index: "03.3", title: TAMEL10n.text("主纳气", "Primary"), value: primary?.name ?? TAMEL10n.text("无", "None"))
                metricLine(index: "03.4", title: TAMEL10n.text("元运口径", "Period Basis"), value: "\(currentPeriod.localizedPeriodName) · \(currentPeriod.star)")
            }

            HStack(spacing: 10) {
                naqiPill(
                    title: TAMEL10n.text("综合评分", "Total Score"),
                    value: "\(result.overallScore)",
                    tint: TAMETheme.stardustGold
                )
                naqiPill(
                    title: TAMEL10n.text("联动飞星", "Linked Chart"),
                    value: linkedChart == nil ? TAMEL10n.text("未生成", "Not Ready") : TAMEL10n.text("已联动", "Linked"),
                    tint: linkedChart == nil ? TAMETheme.techGray : TAMETheme.stardustGold
                )
            }

            Text(result.summary)
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private func pointListCard(_ result: NaqiAnalyzer.NaqiAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("纳气口比较", "Opening Comparison"), accent: "04")

            ForEach(result.points, id: \.name) { point in
                let isPrimary = primaryPoint?.name == point.name && primaryPoint?.naqiAngle == point.naqiAngle

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.name)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                            Text("\(point.type.localizedTitle) · \(point.direction.localizedLabel) · \(point.qiStatus.localizedTitle)")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextSecondary)
                        }

                        Spacer()

                        Text(isPrimary ? TAMEL10n.text("主纳气 \(point.score)分", "Primary \(point.score)") : TAMEL10n.text("\(point.score)分", "\(point.score)"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill((isPrimary ? TAMETheme.stardustGold : TAMETheme.techGray).opacity(0.12))
                            )
                            .overlay {
                                Capsule()
                                    .stroke((isPrimary ? TAMETheme.stardustGold : TAMETheme.techGray).opacity(0.16), lineWidth: 1)
                            }
                            .foregroundColor(isPrimary ? TAMETheme.stardustGold : TAMETheme.brandTextMuted)
                    }

                    VStack(spacing: 8) {
                        metricLine(index: "04.1", title: TAMEL10n.text("地盘", "Earth"), value: String(format: "%.1f°", point.angle))
                        metricLine(index: "04.2", title: TAMEL10n.text("纳气盘", "Adjusted"), value: String(format: "%.1f°", point.naqiAngle))
                        metricLine(index: "04.3", title: TAMEL10n.text("向星", "Facing Star"), value: "\(point.xiangStar)")
                    }

                    Text(point.analysis)
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
                .padding(16)
                .tameInstrumentCard(cornerRadius: 18, shadow: false)
            }
        }
    }

    private func flyingStarLinkCard(point: NaqiAnalyzer.NaqiPoint, chart: CompleteFlyingStarPan) -> some View {
        let center = chart.getPalaceInfo(row: 1, col: 1)

        return VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("联动飞星", "Linked Flying Star"), accent: "05")

            HStack {
                NavigationLink(TAMEL10n.text("查看完整飞星盘", "Open Full Chart")) {
                    FlyingStarChartView(
                        initialSittingDirection: selectedSittingDirection,
                        initialYear: constructionYear,
                        initialRawNaqiAngle: point.angle,
                        useNaqiBasis: true
                    )
                }
                .font(.system(size: 12, weight: .medium, design: .rounded))
                Spacer()
            }

            Text(TAMEL10n.text("当前按\(selectedSittingDirection.localizedLabel)山、\(selectedSittingDirection.opposite.localizedLabel)向，并以\(point.name)的纳气盘 \(String(format: "%.1f°", point.naqiAngle))（\(point.direction.localizedLabel)方）起向盘。当前判断口径为\(currentPeriod.localizedPeriodName)，与罗盘页纳气盘分区保持一致。", "Using \(selectedSittingDirection.localizedLabel) sitting and \(selectedSittingDirection.opposite.localizedLabel) facing, with \(point.name) at adjusted angle \(String(format: "%.1f°", point.naqiAngle)) in the \(point.direction.localizedLabel) sector as the facing basis. The current basis follows \(currentPeriod.localizedPeriodName), consistent with the Naqi zoning on the compass page."))
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(spacing: 10) {
                metricLine(index: "05.1", title: TAMEL10n.text("运星", "Yun"), value: "\(center.yunStar)")
                metricLine(index: "05.2", title: TAMEL10n.text("山星", "Mountain"), value: "\(center.shanStar)")
                metricLine(index: "05.3", title: TAMEL10n.text("向星", "Facing"), value: "\(center.xiangStar)")
            }

            Text(TAMEL10n.text("中宫参考：运\(center.yunStar) / 山\(center.shanStar) / 向\(center.xiangStar)。建议结合完整九宫盘和户型动线一起判断。", "Center palace reference: Yun \(center.yunStar) / Mountain \(center.shanStar) / Facing \(center.xiangStar). Review together with the full 3x3 chart and floor-plan circulation."))
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func suggestionCard(_ result: NaqiAnalyzer.NaqiAnalysisResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("调整建议", "Reference Suggestions"), accent: "06")

            actionCard(
                title: TAMEL10n.text("保存纳气记录", "Save Opening Record"),
                subtitle: TAMEL10n.text("把当前多口比较、联动飞星摘要与建议一起归档到历史记录。", "Archive the current multi-opening comparison, linked chart summary, and suggestions into Records."),
                symbol: "square.and.arrow.down"
            ) {
                saveRecord(result: result)
            }

            ForEach(Array(result.recommendations.enumerated()), id: \.offset) { index, suggestion in
                HStack(alignment: .top, spacing: 10) {
                    Text("\(index + 1).")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.stardustGold)
                    Text(suggestion)
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func sectionHeading(title: String, accent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accent)
                .font(.system(size: 11, weight: .medium, design: .rounded))
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

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 32, alignment: .leading)

            Text(title)
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    private func naqiPill(title: String, value: String, tint: Color) -> some View {
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
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private func demoScenarioButton(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(subtitle)
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)

                Text(TAMEL10n.text("一键带入", "Load Demo"))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private var workspacePrimarySummary: String {
        guard let primaryPoint else {
            return TAMEL10n.text("等待判断", "Awaiting result")
        }

        return TAMEL10n.text("\(primaryPoint.name) · \(primaryPoint.qiStatus.localizedTitle)", "\(primaryPoint.name) · \(primaryPoint.qiStatus.localizedTitle)")
    }

    private func addOrUpdateCurrentPoint() {
        let finalName = selectedPointName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        ? selectedType.localizedTitle
        : selectedPointName.trimmingCharacters(in: .whitespacesAndNewlines)

        if let index = naqiInputs.firstIndex(where: { $0.name == finalName }) {
            naqiInputs[index].type = selectedType
            naqiInputs[index].angle = rawAngle
        } else {
            naqiInputs.append(
                OrientationNaqiInput(
                    type: selectedType,
                    name: finalName,
                    angle: rawAngle
                )
            )
        }

        analyze()
    }

    private func load(_ point: OrientationNaqiInput) {
        selectedType = point.type
        selectedPointName = point.name
        rawAngle = point.angle
    }

    private func remove(_ id: UUID) {
        naqiInputs.removeAll { $0.id == id }
        analyze()
    }

    private func analyze() {
        let yun = currentPeriod
        let points = naqiInputs.map {
            (type: $0.type, name: Optional($0.name), angle: $0.angle)
        }

        guard !points.isEmpty else {
            result = nil
            linkedChart = nil
            return
        }

        let preliminaryResult = NaqiAnalyzer.analyzeMultiplePoints(
            points: points,
            yun: yun
        )
        let basis = preliminaryResult.bestPoint ?? preliminaryResult.mainPoint

        linkedChart = FlyingStarCalculator.calculateCompletePan(
            sitting: selectedSittingDirection,
            facing: selectedSittingDirection.opposite,
            jiuyun: yun,
            year: constructionYear,
            naqiAngle: basis?.naqiAngle
        )

        result = NaqiAnalyzer.analyzeMultiplePoints(
            points: points,
            yun: yun,
            chart: linkedChart
        )
    }

    private func saveRecord(result: NaqiAnalyzer.NaqiAnalysisResult) {
        let flyingStarDetail: String
        if let linkedChart, let basis = primaryPoint {
            let center = linkedChart.getPalaceInfo(row: 1, col: 1)
            flyingStarDetail = TAMEL10n.text("联动飞星：\(selectedSittingDirection.localizedLabel)山 · 以\(basis.name)起向盘 · 中宫 运\(center.yunStar) 山\(center.shanStar) 向\(center.xiangStar)", "Linked chart: \(selectedSittingDirection.localizedLabel) sitting · based on \(basis.name) · center Yun \(center.yunStar) Mountain \(center.shanStar) Facing \(center.xiangStar)")
        } else {
            flyingStarDetail = TAMEL10n.text("联动飞星：未生成", "Linked chart: not generated")
        }

        var details = [
            TAMEL10n.text("纳气口数量：\(result.points.count)", "Opening count: \(result.points.count)"),
            TAMEL10n.text("综合评分：\(result.overallScore) 分 · \(result.overallLevel)", "Overall score: \(result.overallScore) · \(result.overallLevel)"),
            TAMEL10n.text("参考坐山：\(selectedSittingDirection.localizedLabel)", "Sitting reference: \(selectedSittingDirection.localizedLabel)"),
            TAMEL10n.text("当前元运：\(currentPeriod.localizedPeriodName) · \(currentPeriod.star)", "Current period: \(currentPeriod.localizedPeriodName) · \(currentPeriod.star)"),
            TAMEL10n.text("纳气分区：水 \(naqiWaterZoneSummary) · 气 \(naqiQiZoneSummary)", "Naqi zoning: Water \(naqiWaterZoneSummary) · Qi \(naqiQiZoneSummary)"),
            flyingStarDetail,
            TAMEL10n.text("概述：\(result.summary)", "Summary: \(result.summary)")
        ]

        if let primaryPoint {
            details.insert(
                TAMEL10n.text("主纳气口：\(primaryPoint.name) · \(String(format: "%.1f°", primaryPoint.naqiAngle)) · \(primaryPoint.direction.localizedLabel)方 · \(primaryPoint.qiStatus.localizedTitle)", "Primary opening: \(primaryPoint.name) · \(String(format: "%.1f°", primaryPoint.naqiAngle)) · \(primaryPoint.direction.localizedLabel) · \(primaryPoint.qiStatus.localizedTitle)"),
                at: 1
            )
        }

        details.append(contentsOf: result.points.map {
            TAMEL10n.text("\($0.name)：地盘 \(String(format: "%.1f°", $0.angle)) · 纳气 \(String(format: "%.1f°", $0.naqiAngle)) · \($0.direction.localizedLabel)方 · \($0.qiStatus.localizedTitle) · \($0.score)分", "\($0.name): Earth \(String(format: "%.1f°", $0.angle)) · Adjusted \(String(format: "%.1f°", $0.naqiAngle)) · \($0.direction.localizedLabel) · \($0.qiStatus.localizedTitle) · \($0.score)")
        })

        historyStore.save(
            category: .orientation,
            title: primaryPoint?.name ?? TAMEL10n.text("纳气比较", "Opening Comparison"),
            subtitle: TAMEL10n.text("共 \(result.points.count) 处 · \(result.overallLevel) · \(primaryPoint?.name ?? "未定")", "\(result.points.count) openings · \(result.overallLevel) · \(primaryPoint?.name ?? "Pending")"),
            details: details
        )
        saveStatusMessage = TAMEL10n.text("坐向与纳气记录已保存，可到“历史记录”继续查看。", "Orientation and opening record saved. You can review it in Records.")
    }

    private func applySouthFacingResidenceScenario() {
        selectedSittingDirection = .zi
        constructionYear = 2026
        selectedType = .mainDoor
        selectedPointName = TAMEL10n.text("大门", "Main Door")
        rawAngle = 182
        naqiInputs = [
            OrientationNaqiInput(type: .mainDoor, name: TAMEL10n.text("大门", "Main Door"), angle: 182),
            OrientationNaqiInput(type: .balcony, name: TAMEL10n.text("主阳台", "Main Balcony"), angle: 176),
            OrientationNaqiInput(type: .window, name: TAMEL10n.text("客厅主窗", "Living Room Window"), angle: 188)
        ]
        analyze()
    }

    private func applyEastFacingCornerScenario() {
        selectedSittingDirection = .you
        constructionYear = 2028
        selectedType = .mainDoor
        selectedPointName = TAMEL10n.text("入户门", "Entry Door")
        rawAngle = 96
        naqiInputs = [
            OrientationNaqiInput(type: .mainDoor, name: TAMEL10n.text("入户门", "Entry Door"), angle: 96),
            OrientationNaqiInput(type: .window, name: TAMEL10n.text("转角主窗", "Corner Window"), angle: 108),
            OrientationNaqiInput(type: .balcony, name: TAMEL10n.text("生活阳台", "Utility Balcony"), angle: 84)
        ]
        analyze()
    }
}

struct OrientationAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OrientationAnalysisView()
        }
    }
}
