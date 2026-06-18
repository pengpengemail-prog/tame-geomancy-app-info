import SwiftUI

enum BazhaiSmokeScenario {
    case occupantMismatchAutoSave
    case eastGroupPreview
}

struct BazhaiView: View {
    @StateObject private var viewModel = BazhaiViewModel()
    @StateObject private var historyStore = HistoryStore.shared
    @State private var saveStatusMessage: String?
    @State private var appliedSmokeScenario = false
    private let smokeScenario: BazhaiSmokeScenario?

    init(smokeScenario: BazhaiSmokeScenario? = nil) {
        self.smokeScenario = smokeScenario
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let saveStatusMessage {
                        TAMEStatusBanner(message: saveStatusMessage)
                    }

                    bazhaiWorkspaceSection
                    scenarioSection
                    inputSection

                    if let analysis = viewModel.analysis {
                        summarySection(analysis: analysis)
                        sectorsSection(analysis: analysis)
                        roomSuggestionsSection(analysis: analysis)
                    } else {
                        emptyState
                    }
                }
                .padding()
                .padding(.bottom, TAMETheme.bottomContentInset)
            }
            .tameBrandPageBackground()
            .navigationTitle(TAMEL10n.text("八区建议", "Eight-Sector Planner"))
        }
        .onAppear {
            runInitialScenarioIfNeeded()
        }
    }

    private var bazhaiWorkspaceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前八区", "Eight-Sector Snapshot"), accent: "00")

            Text(TAMEL10n.text("这里先整理房屋坐山、出生年份、居住者资料联动状态与当前匹配结果，再进入八方位和房间布置建议。", "This section organizes the sitting direction, birth year, occupant-matching mode, and current fit result before you move into the eight-sector and room-planning guidance."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                summaryPill(
                    title: TAMEL10n.text("居住者联动", "Occupant Match"),
                    value: viewModel.useOccupantProfile ? TAMEL10n.text("已开启", "Enabled") : TAMEL10n.text("仅看房屋", "House Only"),
                    tint: viewModel.useOccupantProfile ? TAMETheme.stardustGold : TAMETheme.techGray
                )
                summaryPill(
                    title: TAMEL10n.text("当前状态", "Current State"),
                    value: bazhaiStatusSummary,
                    tint: TAMETheme.stardustGold
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("房屋坐山", "House Sitting"), value: viewModel.sittingDirection.localizedLabel)
                metricLine(index: "00.2", title: TAMEL10n.text("出生年份", "Birth Year"), value: viewModel.birthYearText.isEmpty ? TAMEL10n.text("未填写", "Not set") : viewModel.birthYearText)
                metricLine(index: "00.3", title: TAMEL10n.text("居住者联动", "Occupant Match"), value: viewModel.useOccupantProfile ? TAMEL10n.text("已开启", "Enabled") : TAMEL10n.text("仅看房屋", "House only"))
                metricLine(index: "00.4", title: TAMEL10n.text("当前状态", "Current State"), value: bazhaiStatusSummary)
                metricLine(index: "00.5", title: TAMEL10n.text("建议起手", "Suggested Start"), value: bazhaiSuggestedStart)
            }

            if let analysis = viewModel.analysis {
                Text(analysis.compatibilitySummary)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }

    private var scenarioSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("快速带入", "Quick Setups"), accent: "01")

            Text(TAMEL10n.text("这里提供两组常见房屋与居住者组合，方便先查看八区匹配和房间建议，再按你的信息继续调整。", "Two common house-and-occupant combinations are provided here so you can review the eight-sector match and room guidance before adjusting it to your own details."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 12) {
                scenarioButton(
                    title: TAMEL10n.text("东四命组合", "East Group Setup"),
                    subtitle: TAMEL10n.text("1992 · 北宅联动", "1992 · North House"),
                    action: { applyEastGroupScenario() }
                )

                scenarioButton(
                    title: TAMEL10n.text("西四命组合", "West Group Setup"),
                    subtitle: TAMEL10n.text("1987 · 西北宅联动", "1987 · Northwest House"),
                    action: { applyWestGroupScenario() }
                )
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 26, emphasized: true, shadow: true)
    }

    private func runInitialScenarioIfNeeded() {
        guard !appliedSmokeScenario else {
            viewModel.analyze()
            return
        }

        appliedSmokeScenario = true

        switch smokeScenario {
        case .occupantMismatchAutoSave:
            viewModel.sittingDirection = .north
            viewModel.birthYearText = "1992"
            viewModel.useOccupantProfile = true
            viewModel.analyze()
            saveRecord()
        case .eastGroupPreview:
            viewModel.sittingDirection = .north
            viewModel.birthYearText = "1992"
            viewModel.useOccupantProfile = true
            viewModel.analyze()
        case .none:
            viewModel.analyze()
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("房屋与资料参考", "House and Profile"), accent: "02")

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(TAMEL10n.text("房屋坐山", "House Sitting"))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    Picker(TAMEL10n.text("房屋坐山", "House Sitting"), selection: $viewModel.sittingDirection) {
                        ForEach(BazhaiDirection.allCases) { direction in
                            Text(direction.localizedLabel).tag(direction)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text(TAMEL10n.text("出生年份", "Birth Year"))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    TextField(TAMEL10n.text("如 1992", "Example: 1992"), text: $viewModel.birthYearText)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numberPad)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .tameFieldStyle(cornerRadius: 12)
                        .frame(width: 120)
                }
            }

            Toggle(TAMEL10n.text("同时参考居住者资料匹配", "Include occupant profile matching"), isOn: $viewModel.useOccupantProfile)
                .tint(TAMETheme.stardustGold)

            HStack(spacing: 10) {
                summaryPill(
                    title: TAMEL10n.text("房屋坐山", "House Sitting"),
                    value: viewModel.sittingDirection.localizedLabel,
                    tint: TAMETheme.stardustGold
                )
                summaryPill(
                    title: TAMEL10n.text("资料输入", "Birth Year"),
                    value: viewModel.birthYearText.isEmpty ? TAMEL10n.text("待填写", "Pending") : viewModel.birthYearText,
                    tint: viewModel.birthYearText.isEmpty ? TAMETheme.techGray : TAMETheme.stardustGold
                )
            }

            HStack(spacing: 12) {
                Button(action: viewModel.analyze) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text(TAMEL10n.text("开始分析", "Analyze"))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMEPrimaryActionButtonStyle())

                Button(action: saveRecord) {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text(TAMEL10n.text("保存记录", "Save Record"))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
                .disabled(viewModel.analysis == nil)
                .opacity(viewModel.analysis == nil ? 0.45 : 1)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private func summarySection(analysis: BazhaiAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("命宅摘要", "Compatibility Summary"), accent: "03")

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(TAMEL10n.text("\(analysis.houseGua.localizedLabel)宅", "\(analysis.houseGua.localizedLabel) House"))
                        .font(.system(size: 28, weight: .medium, design: .serif))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                    Text(TAMEL10n.text("\(analysis.houseType.localizedTitle) · 坐\(viewModel.sittingDirection.localizedLabel)朝\(analysis.facingDirection.localizedLabel)", "\(analysis.houseType.localizedTitle) · Sitting \(viewModel.sittingDirection.localizedLabel) / Facing \(analysis.facingDirection.localizedLabel)"))
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }

                Spacer()

                if let profile = analysis.mingGuaProfile, viewModel.useOccupantProfile {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(TAMEL10n.text("资料 \(profile.gua.localizedLabel)", "Profile \(profile.gua.localizedLabel)"))
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)
                        Text(profile.group.localizedTitle)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                    }
                }
            }

            Text(analysis.overallAdvice)
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            HStack(spacing: 10) {
                summaryPill(
                    title: TAMEL10n.text("宅型", "House Group"),
                    value: analysis.houseType.localizedTitle,
                    tint: TAMETheme.techGray
                )

                if let profile = analysis.mingGuaProfile, viewModel.useOccupantProfile {
                    summaryPill(
                        title: TAMEL10n.text("命宅匹配", "Occupant Match"),
                        value: profile.group == analysis.houseType
                        ? TAMEL10n.text("较协调", "Aligned")
                        : TAMEL10n.text("需细看", "Review Closely"),
                        tint: profile.group == analysis.houseType ? TAMETheme.stardustGold : TAMETheme.brandAlert
                    )
                }
            }

            Text(analysis.compatibilitySummary)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(spacing: 10) {
                metricLine(index: "03.1", title: TAMEL10n.text("吉位", "Helpful"), value: analysis.auspiciousDirections.map(\.localizedLabel).joined(separator: TAMEL10n.isEnglish ? ", " : "、"))
                metricLine(index: "03.2", title: TAMEL10n.text("参考规避", "Caution"), value: analysis.inauspiciousDirections.map(\.localizedLabel).joined(separator: TAMEL10n.isEnglish ? ", " : "、"))
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func summaryPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
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

    private func sectorsSection(analysis: BazhaiAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("八方位分布", "Eight Sectors"), accent: "04")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                ForEach(analysis.sectors) { sector in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(sector.direction.localizedLabel)
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                            Spacer()
                            Text(sector.position.localizedTitle)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(sector.position.isAuspicious ? TAMETheme.stardustGold : TAMETheme.brandAlert)
                        }

                        Text(sector.position.referenceDescription)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .tameInstrumentCard(cornerRadius: 18, shadow: false)
                    .overlay(alignment: .bottomLeading) {
                        Capsule()
                            .fill((sector.position.isAuspicious ? TAMETheme.stardustGold : TAMETheme.brandAlert).opacity(0.14))
                            .frame(width: 26, height: 4)
                            .padding(.horizontal, 14)
                            .padding(.bottom, 10)
                    }
                    .cornerRadius(16)
                }
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func roomSuggestionsSection(analysis: BazhaiAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("空间布置建议", "Room Suggestions"), accent: "05")

            actionCard(
                title: TAMEL10n.text("保存八区记录", "Save Eight-Sector Record"),
                subtitle: TAMEL10n.text("把房屋资料、居住者匹配、八方位与房间建议一起归档到历史记录。", "Archive the house profile, occupant match, sector layout, and room suggestions into Records."),
                symbol: "square.and.arrow.down"
            ) {
                saveRecord()
            }

            ForEach(analysis.roomSuggestions) { suggestion in
                VStack(alignment: .leading, spacing: 10) {
                    Text(suggestion.roomType)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(suggestion.reason)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    HStack(spacing: 10) {
                        tagRow(label: TAMEL10n.text("宜", "Use"), values: suggestion.recommendedDirections.map(\.localizedLabel), tint: TAMETheme.stardustGold)
                        tagRow(label: TAMEL10n.text("避", "Avoid"), values: suggestion.avoidDirections.map(\.localizedLabel), tint: TAMETheme.brandAlert)
                    }
                }
                .padding(16)
                .tameInstrumentCard(cornerRadius: 18, shadow: false)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func tagRow(label: String, values: [String], tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(tint)
            Text(values.isEmpty ? TAMEL10n.text("无", "None") : values.joined(separator: TAMEL10n.isEnglish ? ", " : "、"))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            sectionHeading(title: TAMEL10n.text("等待分析", "Awaiting Analysis"), accent: "03")

            Image(systemName: "house.and.flag")
                .font(.system(size: 40))
                .foregroundColor(TAMETheme.stardustGold)

            Text(TAMEL10n.text("选择房屋坐山后即可查看八区分布", "Choose a house sitting direction to view the eight sectors"))
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(TAMEL10n.text("分析结果仅供民俗文化参考，用于空间布置时建议结合实际采光、通风与动线。", "These results are for cultural reference only and should be reviewed alongside lighting, ventilation, and circulation."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private func saveRecord() {
        guard let analysis = viewModel.analysis else { return }

        var details = [
            TAMEL10n.text("房屋坐山：\(viewModel.sittingDirection.localizedLabel)", "House sitting: \(viewModel.sittingDirection.localizedLabel)"),
            TAMEL10n.text("房屋朝向：\(analysis.facingDirection.localizedLabel)", "House facing: \(analysis.facingDirection.localizedLabel)"),
            TAMEL10n.text("房屋分组：\(analysis.houseGua.localizedLabel)宅", "House group: \(analysis.houseGua.localizedLabel)"),
            TAMEL10n.text("宅型分组：\(analysis.houseType.localizedTitle)", "House group: \(analysis.houseType.localizedTitle)"),
            TAMEL10n.text("吉位：\(analysis.auspiciousDirections.map(\.localizedLabel).joined(separator: TAMEL10n.isEnglish ? ", " : "、"))", "Helpful sectors: \(analysis.auspiciousDirections.map(\.localizedLabel).joined(separator: ", "))"),
            TAMEL10n.text("参考规避：\(analysis.inauspiciousDirections.map(\.localizedLabel).joined(separator: TAMEL10n.isEnglish ? ", " : "、"))", "Caution sectors: \(analysis.inauspiciousDirections.map(\.localizedLabel).joined(separator: ", "))"),
            TAMEL10n.text("匹配摘要：\(analysis.compatibilitySummary)", "Compatibility: \(analysis.compatibilitySummary)")
        ]

        if let profile = analysis.mingGuaProfile, viewModel.useOccupantProfile {
            details.insert(TAMEL10n.text("资料：\(profile.gua.localizedLabel) · \(profile.group.localizedTitle)", "Profile: \(profile.gua.localizedLabel) · \(profile.group.localizedTitle)"), at: 4)
        }

        historyStore.save(
            category: .bazhai,
            title: TAMEL10n.text("\(analysis.houseGua.localizedLabel)宅八区分析", "\(analysis.houseGua.localizedLabel) House Review"),
            subtitle: TAMEL10n.text("\(analysis.houseType.localizedTitle) · 坐\(viewModel.sittingDirection.localizedLabel)朝\(analysis.facingDirection.localizedLabel)", "\(analysis.houseType.localizedTitle) · Sitting \(viewModel.sittingDirection.localizedLabel) / Facing \(analysis.facingDirection.localizedLabel)"),
            details: details
        )
        saveStatusMessage = TAMEL10n.text("八区建议记录已保存，可到“历史记录”查看。", "Eight-sector record saved. You can review it in Records.")
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
                Text(TAMEL10n.text("一键分析", "Analyze Demo"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
        }
        .buttonStyle(.plain)
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
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
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
                .multilineTextAlignment(.trailing)
        }
    }

    private var bazhaiStatusSummary: String {
        if let analysis = viewModel.analysis {
            return TAMEL10n.text("\(analysis.houseGua.localizedLabel)宅 · \(analysis.houseType.localizedTitle)", "\(analysis.houseGua.localizedLabel) House · \(analysis.houseType.localizedTitle)")
        }

        return TAMEL10n.text("等待分析", "Awaiting analysis")
    }

    private var bazhaiSuggestedStart: String {
        if viewModel.useOccupantProfile {
            return TAMEL10n.text("先看命宅匹配", "Check personal-house fit")
        }

        return TAMEL10n.text("先定房屋坐山", "Confirm house sitting first")
    }

    private func applyEastGroupScenario() {
        viewModel.sittingDirection = .north
        viewModel.birthYearText = "1992"
        viewModel.useOccupantProfile = true
        viewModel.analyze()
    }

    private func applyWestGroupScenario() {
        viewModel.sittingDirection = .northwest
        viewModel.birthYearText = "1987"
        viewModel.useOccupantProfile = true
        viewModel.analyze()
    }
}

struct BazhaiView_Previews: PreviewProvider {
    static var previews: some View {
        BazhaiView()
    }
}
