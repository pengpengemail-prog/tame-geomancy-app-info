import SwiftUI

struct CompassView: View {
    @StateObject private var viewModel = CompassViewModel()
    @StateObject private var historyStore = HistoryStore.shared
    @Environment(\.tameActiveTab) private var activeTab
    @AppStorage("useTrueNorth") private var useTrueNorth = false
    @AppStorage("compassSize") private var compassSize = 1.0
    @AppStorage("showNaqiDisk") private var showNaqiDisk = true
    @AppStorage("compassOpacity") private var compassOpacity = 1.0
    @AppStorage("compassVisualStyle") private var compassVisualStyle = CompassDiskView.VisualStyle.minimal.rawValue
    @State private var saveStatusMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let saveStatusMessage {
                        TAMEStatusBanner(message: saveStatusMessage)
                    }

                    brandHeader

                    compassInstrumentPanel

                    if viewModel.usingSimulatedReadings {
                        simulatedBanner
                    }

                    headingSummary

                    controlsSection
                }
                .padding()
                .offset(y: -84)
            }
            .tameBrandPageBackground()
            .navigationTitle(TAMEL10n.text("罗盘测向", "Compass"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.lockHeading) {
                        Image(systemName: viewModel.isLocked ? "lock.fill" : "lock.open")
                            .foregroundColor(TAMETheme.brandTextPrimary)
                    }
                    .accessibilityLabel(viewModel.isLocked ? TAMEL10n.text("解除锁定", "Unlock heading") : TAMEL10n.text("锁定当前角度", "Lock current heading"))
                }
            }
            .onAppear {
                compassSize = Double(resolvedCompassScale)
                syncCompassLifecycle()
            }
            .onDisappear {
                viewModel.stopUpdating()
            }
            .tameOnChangeCompat(of: useTrueNorth) {
                if activeTab == .compass {
                    viewModel.updateConfiguration(useTrueNorth: useTrueNorth)
                }
            }
            .tameOnChangeCompat(of: activeTab) {
                syncCompassLifecycle()
            }
        }
    }

    private var resolvedVisualStyle: CompassDiskView.VisualStyle {
        CompassDiskView.VisualStyle(rawValue: compassVisualStyle) ?? .classic
    }

    private var resolvedCompassScale: CGFloat {
        CGFloat(min(max(compassSize, 0.85), 1.0))
    }

    private var brandHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text("01")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.18))
                    .frame(width: 24, height: 1)
            }

            TAMEBrandLockup(
                wordmarkColor: .black,
                primaryColor: .black,
                secondaryColor: TAMETheme.brandTextSecondary,
                wordmarkHeight: 18,
                spacing: 4
            )

            Text(TAMEL10n.text("双盘测向", "Dual Compass"))
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Text(TAMEL10n.text("地盘与纳气盘同步显示，适合现场快速确认坐向、偏移与主要纳气方向。", "Earth and Naqi plates are shown together for quickly confirming orientation, offset, and primary opening direction on site."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .tameBrandPanel(cornerRadius: 24, emphasized: false, shadow: false)
    }

    private var headingSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Text("01")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.14))
                    .frame(height: 1)
            }

            Text(TAMEL10n.text("实时读数", "Live Readings"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            HStack(alignment: .top, spacing: 18) {
                VStack(spacing: 10) {
                    compactMetricTextRow(
                        index: "01.1",
                        title: TAMEL10n.text("地盘角度", "Earth Heading"),
                        value: String(format: "%.1f°", viewModel.heading)
                    )
                    compactMetricTextRow(
                        index: "01.2",
                        title: TAMEL10n.text("当前方位", "Direction"),
                        value: viewModel.currentDirection
                    )
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                VStack(spacing: 10) {
                    compactMetricTextRow(
                        index: "01.3",
                        title: TAMEL10n.text("磁场", "Field"),
                        value: "\(Int(viewModel.magneticFieldStrength))μT"
                    )
                    compactMetricTextRow(
                        index: "01.4",
                        title: TAMEL10n.text("水平", "Level"),
                        value: String(format: "%.1f / %.1f", abs(viewModel.pitch), abs(viewModel.roll))
                    )
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }

            if showNaqiDisk {
                HStack(alignment: .top, spacing: 18) {
                    VStack(spacing: 10) {
                        compactMetricTextRow(
                            index: "01.5",
                            title: TAMEL10n.text("纳气角度", "Naqi Heading"),
                            value: String(format: "%.1f°", viewModel.naqiHeading)
                        )
                        compactMetricTextRow(
                            index: "01.6",
                            title: TAMEL10n.text("纳气方位", "Naqi Direction"),
                            value: Direction.from(angle: viewModel.naqiHeading).localizedLabel
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    VStack(alignment: .leading, spacing: 10) {
                        compactMetricTextRow(
                            index: "01.7",
                            title: TAMEL10n.text("北向模式", "North Mode"),
                            value: viewModel.northModeLabel
                        )

                        Text(TAMEL10n.text("水区：\(naqiWaterZoneSummary)  ·  气区：\(naqiQiZoneSummary)", "Water: \(naqiWaterZoneSummary)  ·  Qi: \(naqiQiZoneSummary)"))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            } else {
                compactMetricTextRow(
                    index: "01.5",
                    title: TAMEL10n.text("纳气盘", "Naqi Plate"),
                    value: TAMEL10n.text("已隐藏", "Hidden")
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
    }

    private var compassInstrumentPanel: some View {
        VStack(spacing: 10) {
            ZStack(alignment: .top) {
                CompassDiskView(
                    heading: viewModel.heading,
                    diskType: .earth,
                    visualStyle: resolvedVisualStyle,
                    magneticInterference: viewModel.magneticFieldStrength,
                    isLocked: viewModel.isLocked,
                    levelOffset: (viewModel.pitch, viewModel.roll),
                    period: .current,
                    externalReadout: AnyView(pointerFollowerReadout)
                )
                .scaleEffect(resolvedCompassScale)
                .opacity(compassOpacity)

                if showNaqiDisk {
                    CompassDiskView(
                        heading: viewModel.naqiHeading,
                        diskType: .naqi,
                        visualStyle: resolvedVisualStyle,
                        magneticInterference: viewModel.magneticFieldStrength,
                        isLocked: viewModel.isLocked,
                        levelOffset: (viewModel.pitch, viewModel.roll),
                        period: .current
                    )
                    .scaleEffect(resolvedCompassScale * 0.86)
                    .opacity(min(0.58, compassOpacity * 0.38))
                }
            }
            .frame(height: 456)
            .padding(.top, 2)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text("02")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.stardustGold)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.18))
                        .frame(height: 1)
                }

                Text(TAMEL10n.text("当前测量", "Current Reading"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)

                HStack(alignment: .top, spacing: 18) {
                    VStack(spacing: 10) {
                        compactMetricTextRow(
                            index: "02.1",
                            title: TAMEL10n.text("当前二十四山", "Current Mountain"),
                            value: currentDirection.localizedLabel
                        )
                        compactMetricTextRow(
                            index: "02.2",
                            title: TAMEL10n.text("对宫朝向", "Opposite Facing"),
                            value: oppositeDirection.localizedLabel
                        )
                        compactMetricTextRow(
                            index: "02.3",
                            title: TAMEL10n.text("纳气偏移后", "Naqi Offset Result"),
                            value: naqiDirection.localizedLabel
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)

                    VStack(spacing: 10) {
                        compactMetricTextRow(
                            index: "02.4",
                            title: TAMEL10n.text("五行", "Element"),
                            value: currentDirection.element.localizedLabel
                        )
                        compactMetricTextRow(
                            index: "02.5",
                            title: TAMEL10n.text("八卦参考", "Bagua"),
                            value: nearestBagua.localizedLabel
                        )
                        compactMetricTextRow(
                            index: "02.6",
                            title: TAMEL10n.text("当前元运", "Current Period"),
                            value: currentPeriod.localizedPeriodName
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }

                Text(TAMEL10n.text("当前地盘以 \(currentDirection.localizedLabel) 山参考，纳气盘固定顺时针偏移 7.5°，适合配合大门、阳台或主窗做收气观察。", "The earth plate is currently referenced to \(currentDirection.localizedLabel), and the Naqi plate keeps a fixed 7.5° clockwise offset for reviewing the main door, balcony, or major windows."))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)

                VStack(spacing: 8) {
                    compactStatusTextRow(
                        title: TAMEL10n.text("锁定状态", "Lock State"),
                        value: viewModel.isLocked ? TAMEL10n.text("已锁定", "Locked") : TAMEL10n.text("实时更新", "Live"),
                        tint: viewModel.isLocked ? TAMETheme.stardustGold : TAMETheme.techGray
                    )
                    compactStatusTextRow(
                        title: TAMEL10n.text("双盘状态", "Dual Plate"),
                        value: showNaqiDisk ? TAMEL10n.text("已开启", "Enabled") : TAMEL10n.text("已隐藏", "Hidden"),
                        tint: showNaqiDisk ? TAMETheme.stardustGold : TAMETheme.techGray
                    )
                }

                HStack(spacing: 12) {
                    Button(action: saveMeasurementRecord) {
                        Text(TAMEL10n.text("保存本次测量", "Save Measurement"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TAMESecondaryActionButtonStyle())

                    Button(action: viewModel.lockHeading) {
                        Text(viewModel.isLocked ? TAMEL10n.text("解除锁定", "Unlock Heading") : TAMEL10n.text("锁定当前角度", "Lock Current Heading"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(TAMEPrimaryActionButtonStyle())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .tameBrandPanel(cornerRadius: 28, emphasized: true)
    }

    private var pointerFollowerReadout: some View {
        VStack(spacing: 8) {
            Text(TAMEL10n.text("实时方位", "Live Reading"))
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .tracking(0.2)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 6) {
                pointerReadoutChip(
                    title: TAMEL10n.text("地盘", "Earth"),
                    value: currentDirection.localizedLabel,
                    detail: String(format: "%.1f°", viewModel.heading)
                )

                if showNaqiDisk {
                    pointerReadoutChip(
                        title: TAMEL10n.text("纳气", "Naqi"),
                        value: naqiDirection.localizedLabel,
                        detail: String(format: "%.1f°", viewModel.naqiHeading)
                    )
                }

                pointerReadoutChip(
                    title: TAMEL10n.text("五行", "Element"),
                    value: currentDirection.element.localizedLabel,
                    detail: oppositeDirection.localizedLabel
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.horizontal, 1)
        .frame(width: 196)
    }

    private func compactStatusTextRow(title: String, value: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(tint.opacity(0.9))
                .frame(width: 6, height: 6)

            Text(title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .padding(.vertical, 2)
    }

    private func compactMetricTextRow(index: String, title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 34, alignment: .leading)

            Text(title)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 8)

            Text(value)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
        }
        .padding(.vertical, 2)
    }

    private func pointerReadoutChip(title: String, value: String, detail: String) -> some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
                .tracking(0.2)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(detail)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, 1)
        .padding(.vertical, 1)
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("现场提示", "Field Notes"), accent: "03")

            Toggle(TAMEL10n.text("显示纳气盘（7.5° 偏移）", "Show Naqi Plate (7.5° Offset)"), isOn: $showNaqiDisk)
                .tint(TAMETheme.stardustGold)
                .foregroundColor(TAMETheme.brandTextPrimary)

            VStack(alignment: .leading, spacing: 10) {
                Text(TAMEL10n.text("罗盘样式", "Compass Style"))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Picker(TAMEL10n.text("罗盘样式", "Compass Style"), selection: $compassVisualStyle) {
                    ForEach(CompassDiskView.VisualStyle.allCases) { style in
                        Text(style.title).tag(style.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                Text(resolvedVisualStyle.summary)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            if useTrueNorth && !viewModel.trueNorthAvailable {
                Label(TAMEL10n.text("真北校正需要定位可用；当前先按磁北显示。", "True north needs location access; showing magnetic north for now."), systemImage: "location.slash")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandAlert.opacity(0.92))
            }

            if let sensorStatusMessage = viewModel.sensorStatusMessage {
                Label(sensorStatusMessage, systemImage: "sensor.tag.radiowaves.forward")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold.opacity(0.92))
            }

            HStack {
                Text(TAMEL10n.text("罗盘比例", "Compass Scale"))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Slider(value: $compassSize, in: 0.85...1.0, step: 0.05)
                    .tint(TAMETheme.stardustGold)

                Text("\(compassSize, specifier: "%.2f")x")
                    .font(.system(size: 14, weight: .regular, design: .rounded).monospacedDigit())
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            HStack {
                Text(TAMEL10n.text("显示透明度", "Opacity"))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Slider(value: $compassOpacity, in: 0.6...1.0, step: 0.05)
                    .tint(TAMETheme.stardustGold)

                Text("\(compassOpacity, specifier: "%.2f")")
                    .font(.system(size: 14, weight: .regular, design: .rounded).monospacedDigit())
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            Text(TAMEL10n.text("本工具用于方位与民俗参考分析，不构成科学或投资建议。", "This tool is for orientation review and cultural reference only."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
        }
        .padding(18)
        .tameBrandPanel(cornerRadius: 20)
    }

    private var currentDirection: Direction {
        Direction.from(angle: viewModel.heading)
    }

    private var oppositeDirection: Direction {
        currentDirection.opposite
    }

    private var currentPeriod: SanyuanJiuyun {
        .current
    }

    private var naqiDirection: Direction {
        Direction.from(angle: viewModel.naqiHeading)
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

    private var nearestBagua: Bagua {
        let target = viewModel.heading
        return Bagua.allCases.min { lhs, rhs in
            angleDistance(lhs.angle, target) < angleDistance(rhs.angle, target)
        } ?? .kan
    }

    private var simulatedBanner: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.title3)
                .foregroundColor(TAMETheme.stardustGold)

            VStack(alignment: .leading, spacing: 6) {
                Text(TAMEL10n.text("当前为参考读数", "Reference Readings Active"))
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(TAMEL10n.text("当前角度与磁场暂以参考读数显示；当设备支持实时传感器时，会自动切换为实时测向。", "The current angle and magnetic field are shown as reference readings for now. When live sensors are available, the view switches to real-time orientation automatically."))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(16)
        .tameBrandPanel(cornerRadius: 18)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(TAMETheme.brandCardFill())
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(TAMETheme.brandGlassOverlay)
                    .blendMode(.screen)
            }
    }

    private func syncCompassLifecycle() {
        guard activeTab == .compass else {
            viewModel.stopUpdating()
            return
        }

        viewModel.updateConfiguration(useTrueNorth: useTrueNorth)
        viewModel.startUpdating()
    }

    private func saveMeasurementRecord() {
        historyStore.save(
            category: .orientation,
            title: TAMEL10n.text("罗盘测向记录", "Compass Measurement"),
            subtitle: TAMEL10n.text("\(currentDirection.localizedLabel)山 \(String(format: "%.1f°", viewModel.heading))", "\(currentDirection.localizedLabel) · \(String(format: "%.1f°", viewModel.heading))"),
            details: [
                TAMEL10n.text("地盘角度：\(String(format: "%.1f°", viewModel.heading))", "Earth angle: \(String(format: "%.1f°", viewModel.heading))"),
                TAMEL10n.text("纳气角度：\(String(format: "%.1f°", viewModel.naqiHeading))", "Naqi angle: \(String(format: "%.1f°", viewModel.naqiHeading))"),
                TAMEL10n.text("当前二十四山：\(currentDirection.localizedLabel)", "Current mountain: \(currentDirection.localizedLabel)"),
                TAMEL10n.text("对宫朝向：\(oppositeDirection.localizedLabel)", "Opposite facing: \(oppositeDirection.localizedLabel)"),
                TAMEL10n.text("纳气偏移后：\(naqiDirection.localizedLabel)", "Naqi offset result: \(naqiDirection.localizedLabel)"),
                TAMEL10n.text("当前元运：\(currentPeriod.localizedPeriodName) · \(currentPeriod.star)", "Current period: \(currentPeriod.localizedPeriodName) · \(currentPeriod.star)"),
                TAMEL10n.text("五行：\(currentDirection.element.localizedLabel)", "Element: \(currentDirection.element.localizedLabel)"),
                TAMEL10n.text("八卦参考：\(nearestBagua.localizedLabel)", "Bagua reference: \(nearestBagua.localizedLabel)"),
                TAMEL10n.text("北向模式：\(viewModel.northModeLabel)", "North mode: \(viewModel.northModeLabel)"),
                TAMEL10n.text("磁场强度：\(Int(viewModel.magneticFieldStrength))μT", "Magnetic field: \(Int(viewModel.magneticFieldStrength))μT"),
                TAMEL10n.text("水平状态：俯仰 \(String(format: "%.1f", abs(viewModel.pitch))) / 横滚 \(String(format: "%.1f", abs(viewModel.roll)))", "Level state: pitch \(String(format: "%.1f", abs(viewModel.pitch))) / roll \(String(format: "%.1f", abs(viewModel.roll)))")
            ],
            notes: viewModel.usingSimulatedReadings
            ? TAMEL10n.text("当前记录来自参考读数。", "This record was saved from reference readings.")
            : ""
        )

        saveStatusMessage = TAMEL10n.text("罗盘测向记录已保存，可到“历史记录”查看。", "Compass measurement saved. You can review it in Records.")
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

    private func angleDistance(_ lhs: Double, _ rhs: Double) -> Double {
        let raw = abs(lhs - rhs).truncatingRemainder(dividingBy: 360)
        return min(raw, 360 - raw)
    }
}
