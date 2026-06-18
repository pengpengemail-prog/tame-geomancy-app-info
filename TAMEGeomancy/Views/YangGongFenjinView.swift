import SwiftUI

struct YangGongFenjinView: View {
    @StateObject private var compassViewModel = CompassViewModel()
    @StateObject private var historyStore = HistoryStore.shared
    @AppStorage("useTrueNorth") private var useTrueNorth = false
    @State private var selectedAngle: Double = 180
    @State private var useLiveHeading = true
    @State private var displayMode: YangGongDisplayMode = .guided
    @State private var projectName = TAMEL10n.text("现场立向记录", "On-site Orientation")
    @State private var fieldNotes = ""
    @State private var saveStatusMessage: String?
    @FocusState private var focusedField: FieldFocus?

    private var activeAngle: Double {
        useLiveHeading ? compassViewModel.heading : selectedAngle
    }

    private var reading: YangGongOrientationReading {
        YangGongCompassCalculator.reading(for: activeAngle)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let saveStatusMessage {
                    TAMEStatusBanner(message: saveStatusMessage)
                }

                heroCard
                workflowCard
                readingCard
                if displayMode == .professional {
                    fineLineCard
                } else {
                    guidedDetailCard
                }
                fieldRecordCard
                complianceNote
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .navigationTitle(TAMEL10n.text("杨公分金", "Yang Gong Lines"))
        .onAppear {
            compassViewModel.updateConfiguration(useTrueNorth: useTrueNorth)
            compassViewModel.startUpdating()
        }
        .onDisappear {
            compassViewModel.stopUpdating()
        }
        .tameOnChangeCompat(of: useTrueNorth) {
            compassViewModel.updateConfiguration(useTrueNorth: useTrueNorth)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("分金立向", "Line Review"), accent: "2.0")

            YangGongCompassDial(reading: reading)
                .frame(maxWidth: .infinity)
                .frame(height: 214)

            Text(TAMEL10n.text("先看线位是否稳定，再锁定角度与现场记录。专业数据可在下方切换查看。", "Check whether the line is stable, lock the angle, and save the field record. Professional data is available below."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            Picker(TAMEL10n.text("显示模式", "Display Mode"), selection: $displayMode) {
                ForEach(YangGongDisplayMode.allCases) { mode in
                    Text(mode.localizedTitle).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 10) {
                summaryPill(
                    title: TAMEL10n.text("当前结论", "Result"),
                    value: decisionTitle,
                    tint: boundaryStatusTint
                )
                summaryPill(
                    title: TAMEL10n.text("坐向", "Orientation"),
                    value: reading.orientationTitle,
                    tint: TAMETheme.stardustGold
                )
            }

            Toggle(TAMEL10n.text("使用实时罗盘读数", "Use Live Compass"), isOn: $useLiveHeading)
                .tint(TAMETheme.stardustGold)
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .padding(22)
        .tameBrandPanel(cornerRadius: 28, emphasized: true, shadow: true)
    }

    private var workflowCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("现场步骤", "Field Steps"), accent: "00")

            ZStack(alignment: .top) {
                Capsule()
                    .fill(TAMETheme.stardustGold.opacity(0.14))
                    .frame(height: 1)
                    .padding(.top, 19)

                HStack(alignment: .top, spacing: 10) {
                    workflowStage(
                        index: "1",
                        symbol: "scope",
                        title: TAMEL10n.text("测向", "Measure"),
                        detail: useLiveHeading
                        ? TAMEL10n.text("保持平稳，等待读数收敛。", "Hold steady and wait for the reading to settle.")
                        : TAMEL10n.text("当前角度已锁定，可复核或保存。", "The angle is locked; review or save it."),
                        tint: TAMETheme.stardustGold
                    )
                    workflowStage(
                        index: "2",
                        symbol: "checkmark.seal",
                        title: TAMEL10n.text("判断", "Check"),
                        detail: decisionMessage,
                        tint: TAMETheme.techGray
                    )
                    workflowStage(
                        index: "3",
                        symbol: "square.and.arrow.down",
                        title: TAMEL10n.text("记录", "Record"),
                        detail: nextActionMessage,
                        tint: TAMETheme.brandAlert
                    )
                }
            }

            HStack(spacing: 10) {
                Button(action: lockCurrentAngle) {
                    Label(TAMEL10n.text("锁定当前角度", "Lock Angle"), systemImage: "lock")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMEPrimaryActionButtonStyle())
                .disabled(!useLiveHeading)
                .opacity(useLiveHeading ? 1 : 0.62)

                Button(action: resumeLiveHeading) {
                    Label(TAMEL10n.text("重新测向", "Remeasure"), systemImage: "location")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private var readingCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("当前线位", "Current Line"), accent: "01")

            if !useLiveHeading {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(TAMEL10n.text("手动角度", "Manual Angle"))
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Spacer()

                        Text(String(format: "%.1f°", selectedAngle))
                            .font(.system(size: 14, weight: .medium, design: .rounded).monospacedDigit())
                            .foregroundColor(TAMETheme.brandTextPrimary)
                    }

                    Slider(value: $selectedAngle, in: 0...359.9, step: 0.1)
                        .tint(TAMETheme.stardustGold)
                }
                .padding(14)
                .tameInstrumentCard(cornerRadius: 16, shadow: false)
            }

            VStack(spacing: 10) {
                metricHeroTile(
                    index: "01.1",
                    title: TAMEL10n.text("测向角度", "Heading"),
                    value: String(format: "%.1f°", reading.normalizedAngle),
                    note: decisionMessage,
                    tint: boundaryStatusTint
                )

                HStack(spacing: 10) {
                    metricTile(
                        index: "01.2",
                        title: TAMEL10n.text("坐山朝向", "Sitting / Facing"),
                        value: reading.orientationTitle,
                        tint: TAMETheme.stardustGold
                    )
                    metricTile(
                        index: "01.3",
                        title: TAMEL10n.text("线位状态", "Line Status"),
                        value: boundaryStatusTitle,
                        tint: boundaryStatusTint
                    )
                }

                if displayMode == .professional {
                    HStack(spacing: 10) {
                        metricTile(
                            index: "01.4",
                            title: TAMEL10n.text("朝向山位", "Facing Mountain"),
                            value: reading.facingMountain.localizedLabel,
                            tint: TAMETheme.techGray
                        )
                        metricTile(
                            index: "01.5",
                            title: TAMEL10n.text("坐山山位", "Sitting Mountain"),
                            value: reading.sittingMountain.localizedLabel,
                            tint: TAMETheme.techGray
                        )
                    }
                }
            }

            Text(decisionMessage)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private var guidedDetailCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("保存前确认", "Before Saving"), accent: "02")

            boundaryBanner

            VStack(spacing: 10) {
                metricLine(index: "02.1", title: TAMEL10n.text("当前分金", "Fine Line"), value: reading.fenjin.title)
                metricLine(index: "02.2", title: TAMEL10n.text("复测建议", "Remeasure Note"), value: remeasureShortTitle)
            }

            DisclosureGroup {
                VStack(spacing: 10) {
                    metricLine(index: "P1", title: TAMEL10n.text("七十二龙", "72 Dragons"), value: reading.dragon.title)
                    metricLine(index: "P2", title: TAMEL10n.text("分金范围", "Fine-Line Range"), value: reading.fenjin.range.formattedLabel)
                    metricLine(index: "P3", title: TAMEL10n.text("离分金界", "Line Edge"), value: String(format: "%.1f°", reading.distanceToFenjinBoundary))
                    metricLine(index: "P4", title: TAMEL10n.text("离山界", "Mountain Edge"), value: String(format: "%.1f°", reading.distanceToMountainBoundary))
                }
                .padding(.top, 10)
            } label: {
                Text(TAMEL10n.text("查看专业详情", "Show Professional Details"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }
            .tint(TAMETheme.stardustGold)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 16, shadow: false)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private var fineLineCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("分金参考", "Fine-Line Reference"), accent: "02")

            HStack(spacing: 10) {
                summaryPill(
                    title: TAMEL10n.text("分金", "Fine Line"),
                    value: reading.fenjin.title,
                    tint: TAMETheme.stardustGold
                )
                summaryPill(
                    title: TAMEL10n.text("七十二龙", "72 Dragons"),
                    value: reading.dragon.title,
                    tint: TAMETheme.techGray
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "02.1", title: TAMEL10n.text("分金序号", "Fine-Line No."), value: "\(reading.fenjin.globalIndex) / 120")
                metricLine(index: "02.2", title: TAMEL10n.text("分金范围", "Fine-Line Range"), value: reading.fenjin.range.formattedLabel)
                metricLine(index: "02.3", title: TAMEL10n.text("分金中线", "Line Center"), value: String(format: "%.1f°", reading.fenjin.centerAngle))
                metricLine(index: "02.4", title: TAMEL10n.text("龙线序号", "Dragon No."), value: "\(reading.dragon.globalIndex) / 72")
                metricLine(index: "02.5", title: TAMEL10n.text("离山界", "Mountain Edge"), value: String(format: "%.1f°", reading.distanceToMountainBoundary))
                metricLine(index: "02.6", title: TAMEL10n.text("离分金界", "Line Edge"), value: String(format: "%.1f°", reading.distanceToFenjinBoundary))
            }

            boundaryBanner
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private var fieldRecordCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("现场记录", "Field Record"), accent: "03")

            VStack(alignment: .leading, spacing: 8) {
                Text(TAMEL10n.text("项目名称", "Project Name"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)

                TextField(TAMEL10n.text("输入项目或地点", "Enter project or location"), text: $projectName)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .projectName)
                    .padding(14)
                    .tameFieldStyle()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(TAMEL10n.text("来龙 / 水口 / 现场备注", "Dragon, Water Mouth, Field Notes"))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)

                TextEditor(text: $fieldNotes)
                    .focused($focusedField, equals: .fieldNotes)
                    .frame(minHeight: 96)
                    .padding(10)
                    .background(Color.clear)
                    .tameFieldStyle()
            }

            Button(action: saveRecord) {
                Label(TAMEL10n.text("保存分金立向记录", "Save Line Record"), systemImage: "square.and.arrow.down")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TAMEPrimaryActionButtonStyle())
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private var complianceNote: some View {
        Text(TAMEL10n.text("本模块用于传统文化参考、罗盘测向与现场记录整理，不提供医疗、投资、财富或命运承诺。", "This module is for cultural reference, compass measurement, and field documentation only. It does not provide medical, financial, wealth, or destiny claims."))
            .font(.system(size: 14, weight: .regular, design: .rounded))
            .foregroundColor(TAMETheme.brandTextMuted)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 2)
    }

    private var boundaryBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(boundaryStatusTint.opacity(0.9))
                .frame(width: 8, height: 8)
                .padding(.top, 5)

            VStack(alignment: .leading, spacing: 4) {
                Text(boundaryStatusTitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(boundaryStatusMessage)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
    }

    private var boundaryStatusTitle: String {
        reading.boundaryStatus.localizedTitle
    }

    private var boundaryStatusTint: Color {
        switch reading.boundaryStatus {
        case .stable:
            return TAMETheme.stardustGold
        case .nearFenjinBoundary:
            return TAMETheme.techGray
        case .nearMountainBoundary:
            return TAMETheme.brandAlert
        }
    }

    private var boundaryStatusMessage: String {
        switch reading.boundaryStatus {
        case .stable:
            return TAMEL10n.text("当前角度离主要边界较远，可作为稳定线位记录。", "The current angle is away from major boundaries and can be recorded as a stable line reference.")
        case .nearFenjinBoundary(let distance):
            return TAMEL10n.text("当前离分金边界约 \(String(format: "%.1f°", distance))，建议现场复测后再归档。", "This is about \(String(format: "%.1f°", distance)) from a fine-line boundary. Recheck on site before archiving.")
        case .nearMountainBoundary(let distance):
            return TAMEL10n.text("当前离二十四山边界约 \(String(format: "%.1f°", distance))，建议多次测向并记录环境条件。", "This is about \(String(format: "%.1f°", distance)) from a 24-mountain boundary. Take repeated readings and note site conditions.")
        }
    }

    private var decisionTitle: String {
        switch reading.boundaryStatus {
        case .stable:
            return TAMEL10n.text("可记录", "Ready")
        case .nearFenjinBoundary:
            return TAMEL10n.text("先复测", "Recheck")
        case .nearMountainBoundary:
            return TAMEL10n.text("谨慎记录", "Caution")
        }
    }

    private var decisionMessage: String {
        switch reading.boundaryStatus {
        case .stable:
            return TAMEL10n.text("当前线位较稳定，可锁定角度并填写现场备注。", "The line is stable enough to lock the angle and add field notes.")
        case .nearFenjinBoundary:
            return TAMEL10n.text("当前靠近分金边界，建议原地复测 2-3 次，再决定是否保存。", "This is close to a fine-line boundary. Take 2-3 readings before saving.")
        case .nearMountainBoundary:
            return TAMEL10n.text("当前接近二十四山交界，建议换手持姿势、避开金属干扰后复测。", "This is close to a 24-mountain boundary. Recheck after adjusting grip and avoiding metal interference.")
        }
    }

    private var nextActionMessage: String {
        if useLiveHeading {
            return TAMEL10n.text("读数稳定后点击“锁定当前角度”。", "Tap Lock Angle once the reading feels steady.")
        }

        return TAMEL10n.text("补充项目名称和现场备注后保存。", "Add the project name and notes, then save.")
    }

    private var remeasureShortTitle: String {
        switch reading.boundaryStatus {
        case .stable:
            return TAMEL10n.text("可保存", "Save")
        case .nearFenjinBoundary:
            return TAMEL10n.text("复测 2-3 次", "2-3 checks")
        case .nearMountainBoundary:
            return TAMEL10n.text("换姿势复测", "Adjust grip")
        }
    }

    private func lockCurrentAngle() {
        selectedAngle = reading.normalizedAngle
        useLiveHeading = false
    }

    private func resumeLiveHeading() {
        focusedField = nil
        useLiveHeading = true
    }

    private func saveRecord() {
        focusedField = nil
        historyStore.save(
            category: .yangGongFenjin,
            title: projectName.isEmpty ? TAMEL10n.text("杨公分金立向记录", "Yang Gong Line Record") : projectName,
            subtitle: "\(reading.orientationTitle) · \(reading.fenjin.title)",
            details: [
                TAMEL10n.text("测向角度：\(String(format: "%.1f°", reading.normalizedAngle))", "Heading: \(String(format: "%.1f°", reading.normalizedAngle))"),
                TAMEL10n.text("坐山朝向：\(reading.orientationTitle)", "Sitting / facing: \(reading.orientationTitle)"),
                TAMEL10n.text("朝向山位：\(reading.facingMountain.localizedLabel)", "Facing mountain: \(reading.facingMountain.localizedLabel)"),
                TAMEL10n.text("坐山山位：\(reading.sittingMountain.localizedLabel)", "Sitting mountain: \(reading.sittingMountain.localizedLabel)"),
                TAMEL10n.text("分金线位：\(reading.fenjin.title)", "Fine line: \(reading.fenjin.title)"),
                TAMEL10n.text("分金序号：\(reading.fenjin.globalIndex) / 120", "Fine-line number: \(reading.fenjin.globalIndex) / 120"),
                TAMEL10n.text("分金范围：\(reading.fenjin.range.formattedLabel)", "Fine-line range: \(reading.fenjin.range.formattedLabel)"),
                TAMEL10n.text("七十二龙：\(reading.dragon.title)", "72-dragon reference: \(reading.dragon.title)"),
                TAMEL10n.text("龙线序号：\(reading.dragon.globalIndex) / 72", "Dragon number: \(reading.dragon.globalIndex) / 72"),
                TAMEL10n.text("边界状态：\(boundaryStatusTitle)", "Boundary status: \(boundaryStatusTitle)"),
                TAMEL10n.text("离山界：\(String(format: "%.1f°", reading.distanceToMountainBoundary))", "Mountain edge distance: \(String(format: "%.1f°", reading.distanceToMountainBoundary))"),
                TAMEL10n.text("离分金界：\(String(format: "%.1f°", reading.distanceToFenjinBoundary))", "Fine-line edge distance: \(String(format: "%.1f°", reading.distanceToFenjinBoundary))"),
                TAMEL10n.text("北向模式：\(compassViewModel.northModeLabel)", "North mode: \(compassViewModel.northModeLabel)")
            ],
            notes: fieldNotes
        )

        saveStatusMessage = TAMEL10n.text("分金立向记录已保存，可到“历史记录”查看。", "Line record saved. You can review it in Records.")
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
                    .fill(TAMETheme.stardustGold.opacity(0.14))
                    .frame(height: 1)
            }
        }
    }

    private func metricHeroTile(index: String, title: String, value: String, note: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(index)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.18))
                    .frame(height: 1)

                Circle()
                    .fill(tint.opacity(0.9))
                    .frame(width: 8, height: 8)
            }

            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Text(value)
                .font(.system(size: 24, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(note)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            Capsule()
                .fill(tint.opacity(0.18))
                .frame(height: 3)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .tameInstrumentCard(cornerRadius: 18, shadow: false)
    }

    private func metricTile(index: String, title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(index)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Spacer(minLength: 0)

                Circle()
                    .fill(tint.opacity(0.9))
                    .frame(width: 7, height: 7)
            }

            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(tint.opacity(0.16))
                .frame(width: 24, height: 3)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
        }
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
    }

    private func summaryPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
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

    private func workflowStage(index: String, symbol: String, title: String, detail: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(tint.opacity(0.16), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)

                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(tint)
            }

            HStack(spacing: 8) {
                Text(index)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }

            Text(detail)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 2)
    }

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 38, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.14))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }
}

private enum YangGongDisplayMode: String, CaseIterable, Identifiable {
    case guided
    case professional

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .guided:
            return TAMEL10n.text("易用", "Guided")
        case .professional:
            return TAMEL10n.text("专业", "Pro")
        }
    }
}

private enum FieldFocus: Hashable {
    case projectName
    case fieldNotes
}

private struct YangGongCompassDial: View {
    let reading: YangGongOrientationReading

    var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 14) {
                GeometryReader { proxy in
                    let size = min(proxy.size.width, proxy.size.height)
                    dialCanvas(size: size)
                        .frame(width: size, height: size)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: 142, height: 142)

                VStack(spacing: 8) {
                    primaryReadoutCard
                    summaryPill(title: TAMEL10n.text("细分线", "Fine Line"), value: reading.fenjin.title)
                    summaryPill(title: TAMEL10n.text("边界", "Boundary"), value: reading.boundaryStatus.localizedTitle, tint: boundaryTint)
                }
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: 8) {
                summaryPill(title: TAMEL10n.text("方向组", "Direction Set"), value: reading.dragon.title)
                summaryPill(title: TAMEL10n.text("离边界", "Edge"), value: String(format: "%.1f°", reading.distanceToFenjinBoundary))
            }
        }
    }

    private func dialCanvas(size: CGFloat) -> some View {
        let outerRadius = size / 2
        let ringRadius = outerRadius * 0.80
        let needleLength = outerRadius * 0.64

        return ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(red: 253 / 255, green: 251 / 255, blue: 246 / 255),
                            Color(red: 247 / 255, green: 243 / 255, blue: 236 / 255)
                        ],
                        center: .center,
                        startRadius: outerRadius * 0.08,
                        endRadius: outerRadius * 1.02
                    )
                )
                .shadow(color: Color.black.opacity(0.05), radius: 12, x: 0, y: 8)

            Circle()
                .stroke(TAMETheme.brandHairline.opacity(0.7), lineWidth: 1)
                .padding(size * 0.045)

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(0.16), lineWidth: size * 0.028)
                .padding(size * 0.12)

            Circle()
                .stroke(TAMETheme.brandStroke.opacity(0.85), lineWidth: size * 0.014)
                .padding(size * 0.205)

            ForEach(0..<24, id: \.self) { index in
                let major = index % 6 == 0
                Capsule(style: .continuous)
                    .fill(major ? TAMETheme.stardustGold.opacity(0.92) : TAMETheme.brandStroke.opacity(0.92))
                    .frame(width: major ? 3.2 : 2, height: major ? size * 0.11 : size * 0.058)
                    .offset(y: -ringRadius)
                    .rotationEffect(.degrees(Double(index) * 15))
            }

            Group {
                Capsule(style: .continuous)
                    .fill(TAMETheme.brandHairline.opacity(0.36))
                    .frame(width: size * 0.50, height: 1)
                Capsule(style: .continuous)
                    .fill(TAMETheme.brandHairline.opacity(0.36))
                    .frame(width: 1, height: size * 0.50)
            }

            Circle()
                .fill(TAMETheme.stardustGold.opacity(0.045))
                .frame(width: size * 0.68, height: size * 0.68)

            ForEach(compassLabels) { label in
                Text(label.title)
                    .font(.system(size: label.isPrimary ? 14 : 13, weight: .medium, design: .rounded))
                    .foregroundColor(label.color)
                    .offset(y: -outerRadius * 0.62)
                    .rotationEffect(.degrees(label.angle))
            }

            Circle()
                .stroke(needleTint.opacity(0.22), lineWidth: size * 0.012)
                .frame(width: size * 0.52, height: size * 0.52)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [needleTint.opacity(0.95), needleTint.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4.5, height: needleLength)
                .offset(y: -needleLength / 2)
                .rotationEffect(.degrees(reading.normalizedAngle))
                .shadow(color: needleTint.opacity(0.22), radius: 8, x: 0, y: 2)

            centerHub(size: size)
        }
    }

    private func centerHub(size: CGFloat) -> some View {
        let hubSize = max(26, min(size * 0.17, 34))

        return ZStack {
            Circle()
                .fill(Color.white.opacity(0.96))
                .frame(width: hubSize, height: hubSize)
                .shadow(color: Color.black.opacity(0.05), radius: 7, x: 0, y: 3)

            Circle()
                .stroke(TAMETheme.stardustGold.opacity(0.48), lineWidth: 1)
                .frame(width: hubSize, height: hubSize)

            Circle()
                .fill(needleTint)
                .frame(width: hubSize * 0.23, height: hubSize * 0.23)
        }
    }

    private var primaryReadoutCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reading.orientationTitle)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(String(format: "%.1f°", reading.normalizedAngle))
                .font(.system(size: 23, weight: .medium, design: .rounded).monospacedDigit())
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(TAMETheme.brandHairline.opacity(0.82), lineWidth: 1)
        )
    }

    private func summaryPill(title: String, value: String, tint: Color = TAMETheme.stardustGold) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.92))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(tint.opacity(0.16), lineWidth: 1)
        )
    }

    private var needleTint: Color {
        switch reading.boundaryStatus {
        case .stable:
            return TAMETheme.stardustGold
        case .nearFenjinBoundary:
            return TAMETheme.techGray
        case .nearMountainBoundary:
            return TAMETheme.brandAlert
        }
    }

    private var boundaryTint: Color {
        switch reading.boundaryStatus {
        case .stable:
            return TAMETheme.stardustGold
        case .nearFenjinBoundary:
            return TAMETheme.techGray
        case .nearMountainBoundary:
            return TAMETheme.brandAlert
        }
    }

    private var compassLabels: [CompassLabel] {
        [
            .init(title: TAMEL10n.text("子", "N"), angle: 0, color: TAMETheme.brandTextPrimary, isPrimary: true),
            .init(title: TAMEL10n.text("卯", "E"), angle: 90, color: TAMETheme.brandTextMuted, isPrimary: false),
            .init(title: TAMEL10n.text("午", "S"), angle: 180, color: TAMETheme.brandTextMuted, isPrimary: false),
            .init(title: TAMEL10n.text("酉", "W"), angle: 270, color: TAMETheme.brandTextMuted, isPrimary: false)
        ]
    }

}

private struct CompassLabel: Identifiable {
    let title: String
    let angle: Double
    let color: Color
    let isPrimary: Bool

    var id: String { "\(title)-\(angle)" }
}
