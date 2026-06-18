import SwiftUI
import AVFoundation
import Photos
import PhotosUI

private enum FloorPlanInteractionMode {
    case marker
    case centerPoint

    var localizedTitle: String {
        switch self {
        case .marker:
            return TAMEL10n.text("放置标记", "Place Markers")
        case .centerPoint:
            return TAMEL10n.text("调整立极点", "Move Center")
        }
    }
}

/// 户型图导入与九宫分析视图
struct FloorPlanAnalysisView: View {
    @StateObject private var viewModel = FloorPlanAnalysisViewModel()
    @StateObject private var historyStore = HistoryStore.shared
    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var importStatusMessage: String?
    @State private var importErrorMessage: String?
    @State private var saveStatusMessage: String?
    @State private var interactionMode: FloorPlanInteractionMode = .marker
    private let loadDemoOnAppear: Bool

    init(loadDemoOnAppear: Bool = false) {
        self.loadDemoOnAppear = loadDemoOnAppear
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    if let saveStatusMessage {
                        TAMEStatusBanner(message: saveStatusMessage)
                    }

                    workspaceSummarySection

                    if let image = viewModel.floorPlanImage {
                        // 户型图显示区域
                        floorPlanSection(image: image)
                    } else {
                        // 导入提示
                        importPromptSection
                    }
                    
                    // 九宫分析结果
                    if viewModel.hasAnalysis {
                        ninePalaceAnalysisSection
                    }
                }
                .padding()
                .padding(.bottom, TAMETheme.bottomContentInset)
            }
            .tameBrandPageBackground()
            .navigationTitle(TAMEL10n.text("户型图分析", "Floor Plan"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            loadDemoLayout()
                        }) {
                            Label(TAMEL10n.text("加载户型示意", "Load Layout Preview"), systemImage: "sparkles.rectangle.stack")
                        }
                        Button(action: beginPhotoLibraryImport) {
                            Label(TAMEL10n.text("从相册选择", "Import from Photos"), systemImage: "photo.on.rectangle")
                        }
                        Button(action: beginCameraCapture) {
                            Label(TAMEL10n.text("拍摄户型图", "Capture with Camera"), systemImage: "camera")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $viewModel.floorPlanImage, sourceType: .photoLibrary)
                    .onDisappear {
                        handleImportedImage(from: .photoLibrary)
                    }
            }
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $viewModel.floorPlanImage, sourceType: .camera)
                    .onDisappear {
                        handleImportedImage(from: .camera)
                    }
            }
            .alert(TAMEL10n.text("无法继续导入", "Unable to Continue"), isPresented: Binding(
                get: { importErrorMessage != nil },
                set: { newValue in
                    if !newValue {
                        importErrorMessage = nil
                    }
                }
            )) {
                Button(TAMEL10n.text("知道了", "OK"), role: .cancel) {
                    importErrorMessage = nil
                }
            } message: {
                Text(importErrorMessage ?? TAMEL10n.text("发生未知错误", "An unknown error occurred."))
            }
            .tameOnChangeCompat(of: viewModel.facingDirection) {
                if viewModel.floorPlanImage != nil {
                    viewModel.analyzeFloorPlan()
                }
            }
            .onAppear {
                if loadDemoOnAppear && viewModel.floorPlanImage == nil {
                    loadDemoLayout()
                }
            }
        }
    }

    private var workspaceSummarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前户型", "Current Layout"), accent: "00")

            Text(TAMEL10n.text("这里先整理导入状态、朝向、标记数量与纳气依据，再进入九宫叠图与房间评估，方便快速了解分析结果。", "This overview organizes import state, facing direction, marker count, and intake basis before you move into the nine-palace overlay and room review."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                floorPlanPill(
                    title: TAMEL10n.text("导入状态", "Import State"),
                    value: floorPlanStateLabel,
                    tint: TAMETheme.stardustGold
                )
                floorPlanPill(
                    title: TAMEL10n.text("热力图", "Heatmap"),
                    value: viewModel.showHeatmap ? TAMEL10n.text("已开启", "On") : TAMEL10n.text("已关闭", "Off"),
                    tint: viewModel.showHeatmap ? TAMETheme.stardustGold : TAMETheme.techGray
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "00.1", title: TAMEL10n.text("当前状态", "Current State"), value: floorPlanStateLabel)
                metricLine(index: "00.2", title: TAMEL10n.text("朝向参考", "Facing"), value: viewModel.facingDirection.localizedLabel)
                metricLine(index: "00.3", title: TAMEL10n.text("房间标记", "Markers"), value: "\(viewModel.roomMarkers.count)")
                metricLine(index: "00.4", title: TAMEL10n.text("立极点", "Center Point"), value: viewModel.formattedCenterPoint())
                metricLine(index: "00.5", title: TAMEL10n.text("纳气依据", "Intake Basis"), value: analysisBasisSummary)
            }

            HStack(spacing: 12) {
                workspaceActionButton(
                    title: TAMEL10n.text("户型示意", "Layout Preview"),
                    subtitle: TAMEL10n.text("先熟悉分析流程", "Learn the analysis flow"),
                    symbol: "sparkles.rectangle.stack",
                    action: loadDemoLayout
                )

                workspaceActionButton(
                    title: TAMEL10n.text("相册导入", "Import Photos"),
                    subtitle: TAMEL10n.text("读取真实户型图", "Use a real floor plan"),
                    symbol: "photo.on.rectangle",
                    action: beginPhotoLibraryImport
                )

                workspaceActionButton(
                    title: TAMEL10n.text("相机拍摄", "Camera Capture"),
                    subtitle: TAMEL10n.text("现场快速带入", "Capture on site"),
                    symbol: "camera",
                    action: beginCameraCapture
                )
            }

            if let importStatusMessage {
                Label(importStatusMessage, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 30, emphasized: true, shadow: true)
    }
    
    // MARK: - 户型图显示区域
    private func floorPlanSection(image: UIImage) -> some View {
        VStack(spacing: 16) {
            controlsPanel

            GeometryReader { geometry in
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(16)
                        .rotationEffect(.degrees(viewModel.facingDirection.angle - 180))

                    if let analysis = viewModel.analysis, viewModel.showHeatmap {
                        floorPlanHeatmapOverlay(analysis)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .allowsHitTesting(false)
                    }

                    // 九宫格叠加层
                    if viewModel.showGrid {
                        NinePalaceGridOverlay()
                            .stroke(TAMETheme.stardustGold.opacity(0.64), lineWidth: 2)
                            .allowsHitTesting(false)
                    }

                    Circle()
                        .fill(Color.red)
                        .frame(width: 14, height: 14)
                        .position(
                            x: viewModel.centerPoint.x * geometry.size.width,
                            y: viewModel.centerPoint.y * geometry.size.height
                        )

                    ForEach(viewModel.roomMarkers) { marker in
                        VStack(spacing: 4) {
                            Image(systemName: markerIcon(marker.type))
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                                .padding(8)
                                .background(markerColor(marker.type))
                                .clipShape(Circle())

                            Text(marker.type.localizedTitle)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .tameInstrumentCard(cornerRadius: 10, shadow: false)
                        }
                        .position(
                            x: marker.point.x * geometry.size.width,
                            y: marker.point.y * geometry.size.height
                        )
                        .onTapGesture {
                            viewModel.removeMarker(id: marker.id)
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            guard interactionMode == .centerPoint else { return }

                            let normalized = CGPoint(
                                x: min(max(value.location.x / geometry.size.width, 0), 1),
                                y: min(max(value.location.y / geometry.size.height, 0), 1)
                            )
                            viewModel.centerPoint = normalized
                        }
                        .onEnded { value in
                            let normalized = CGPoint(
                                x: min(max(value.location.x / geometry.size.width, 0), 1),
                                y: min(max(value.location.y / geometry.size.height, 0), 1)
                            )
                            let dx = value.location.x - value.startLocation.x
                            let dy = value.location.y - value.startLocation.y
                            let distance = sqrt(dx * dx + dy * dy)

                            if interactionMode == .marker && distance < 8 {
                                viewModel.addMarker(at: normalized)
                            } else if interactionMode == .centerPoint {
                                viewModel.centerPoint = normalized
                            }
                        }
                )
            }
            .frame(height: 360)
            
            HStack {
                if viewModel.isUsingDemoLayout {
                    Button(action: {
                        viewModel.resetLayout()
                        importStatusMessage = nil
                    }) {
                        Label(TAMEL10n.text("清除示意", "Clear Preview"), systemImage: "trash")
                    }
                    .buttonStyle(TAMESecondaryActionButtonStyle(tint: TAMETheme.brandAlert))
                }

                Button(action: { viewModel.showGrid.toggle() }) {
                    Label(viewModel.showGrid ? TAMEL10n.text("隐藏九宫格", "Hide Grid") : TAMEL10n.text("显示九宫格", "Show Grid"),
                          systemImage: viewModel.showGrid ? "eye.slash" : "eye")
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
                
                Spacer()
                
                Button(action: { viewModel.analyzeFloorPlan() }) {
                    Label(TAMEL10n.text("重新分析", "Reanalyze"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(TAMEPrimaryActionButtonStyle())

                Button(action: saveRecord) {
                    Label(TAMEL10n.text("保存", "Save"), systemImage: "square.and.arrow.down")
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
            }
        }
    }

    private var controlsPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("立极与标记", "Center Point & Markers"), accent: "01")

            HStack(spacing: 10) {
                floorPlanPill(
                    title: TAMEL10n.text("当前朝向", "Current Facing"),
                    value: viewModel.facingDirection.localizedLabel,
                    tint: TAMETheme.stardustGold
                )
                floorPlanPill(
                    title: TAMEL10n.text("交互模式", "Interaction"),
                    value: interactionMode.localizedTitle,
                    tint: interactionMode == .marker ? TAMETheme.stardustGold : TAMETheme.techGray
                )
            }

            Picker(TAMEL10n.text("朝向", "Facing"), selection: $viewModel.facingDirection) {
                ForEach(Direction.allCases) { direction in
                    Text(direction.localizedLabel).tag(direction)
                }
            }
            .pickerStyle(.menu)

            Picker(TAMEL10n.text("标记房间", "Marker Type"), selection: $viewModel.selectedMarkerType) {
                ForEach(FloorPlanRoomType.allCases) { type in
                    Text(type.localizedTitle).tag(type)
                }
            }
            .pickerStyle(.menu)

            HStack(spacing: 12) {
                Group {
                    if interactionMode == .marker {
                        Button(action: {
                            interactionMode = .marker
                        }) {
                            Text(TAMEL10n.text("放置标记", "Place Markers"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TAMEPrimaryActionButtonStyle())
                    } else {
                        Button(action: {
                            interactionMode = .marker
                        }) {
                            Text(TAMEL10n.text("放置标记", "Place Markers"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TAMESecondaryActionButtonStyle())
                    }
                }

                Group {
                    if interactionMode == .centerPoint {
                        Button(action: {
                            interactionMode = .centerPoint
                        }) {
                            Text(TAMEL10n.text("移动立极点", "Move Center"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TAMEPrimaryActionButtonStyle())
                    } else {
                        Button(action: {
                            interactionMode = .centerPoint
                        }) {
                            Text(TAMEL10n.text("移动立极点", "Move Center"))
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(TAMESecondaryActionButtonStyle())
                    }
                }
            }

            Toggle(TAMEL10n.text("显示吉凶热力图", "Show Heatmap"), isOn: $viewModel.showHeatmap)
                .tint(TAMETheme.stardustGold)

            heatmapLegend

            if let naqiResult = viewModel.currentNaqiResult(),
               let best = naqiResult.bestPoint {
                Text(
                    TAMEL10n.text(
                        "当前主纳气口：\(best.name) · \(String(format: "%.1f°", best.naqiAngle)) · \(best.direction.localizedLabel)方 · \(best.qiStatus.localizedTitle) · \(best.score)分",
                        "Primary intake: \(best.name) · \(String(format: "%.1f°", best.naqiAngle)) · \(best.direction.localizedLabel) sector · \(best.qiStatus.localizedTitle) · score \(best.score)"
                    )
                )
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            } else {
                Text(TAMEL10n.text("建议至少标记大门、阳台或窗户中的一项，向盘才会按纳气口起盘。", "Mark at least one main door, balcony, or window so the facing chart can use a real intake opening."))
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            Text(
                interactionMode == .marker
                ? TAMEL10n.text("当前为放置标记模式：轻点图片即可添加 \(viewModel.selectedMarkerType.localizedTitle)。大门、阳台、窗户会一起参与纳气比较。", "Marker mode is active: tap the image to place a \(viewModel.selectedMarkerType.localizedTitle). Doors, balconies, and windows are compared together for intake.")
                : TAMEL10n.text("当前为立极点模式：拖动图片即可重新定位立极点，松手后会自动刷新九宫与纳气结果。", "Center-point mode is active: drag on the image to reposition the center point, and the nine-palace and intake results refresh automatically.")
            )
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            if !viewModel.roomMarkers.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(TAMEL10n.text("当前标记", "Current Markers"))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    ForEach(viewModel.roomMarkers) { marker in
                        HStack(spacing: 10) {
                            Image(systemName: markerIcon(marker.type))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .padding(7)
                                .background(markerColor(marker.type))
                                .clipShape(Circle())

                            Text(marker.type.localizedTitle)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)

                            Spacer()

                            Button(TAMEL10n.text("删除", "Remove")) {
                                viewModel.removeMarker(id: marker.id)
                            }
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandAlert)
                        }
                        .padding(10)
                        .tameInstrumentCard(cornerRadius: 14, shadow: false)
                    }
                }
            }

            if let importStatusMessage {
                Label(importStatusMessage, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
        }
        .padding(16)
        .tameBrandPanel(cornerRadius: 20, shadow: true)
    }
    
    // MARK: - 导入提示
    private var importPromptSection: some View {
        VStack(spacing: 20) {
            VStack(alignment: .center, spacing: 10) {
                Text("01")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.28))
                    .frame(width: 40, height: 1)
            }

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(TAMETheme.stardustGold)
            
            Text(TAMEL10n.text("导入户型图", "Import a Floor Plan"))
                .font(.system(size: 26, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
            
            Text(TAMEL10n.text("从相册选择或拍摄户型图\n系统将自动进行九宫分析", "Choose a floor plan from Photos or capture one\nThe app will generate a nine-palace review automatically"))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 10) {
                floorPlanPill(
                    title: TAMEL10n.text("开始方式", "Start Mode"),
                    value: TAMEL10n.text("示意户型", "Starter Layout"),
                    tint: TAMETheme.stardustGold
                )
                floorPlanPill(
                    title: TAMEL10n.text("导入方式", "Import Routes"),
                    value: TAMEL10n.text("相册 / 拍摄", "Photos / Camera"),
                    tint: TAMETheme.techGray
                )
            }

            Button(action: loadDemoLayout) {
                Label(TAMEL10n.text("载入示意户型", "Load Starter Layout"), systemImage: "sparkles.rectangle.stack")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TAMEPrimaryActionButtonStyle())
            
            HStack(spacing: 16) {
                importActionCard(
                    title: TAMEL10n.text("相册导入", "Photos Import"),
                    subtitle: TAMEL10n.text("读取真实户型图并进入九宫分析", "Load a real floor plan and enter the nine-palace review."),
                    symbol: "photo.on.rectangle",
                    action: beginPhotoLibraryImport
                )
                
                importActionCard(
                    title: TAMEL10n.text("相机拍摄", "Camera Capture"),
                    subtitle: TAMEL10n.text("适合现场快速带入户型草图", "Useful for bringing in an on-site sketch quickly."),
                    symbol: "camera",
                    action: beginCameraCapture
                )
            }

            if let importStatusMessage {
                Label(importStatusMessage, systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Text(TAMEL10n.text("示意户型会自动带入立极点、大门、阳台、窗户和常见房间标记，方便先熟悉完整分析流程。", "The starter layout includes the center point, door, balcony, window, and common room markers so you can learn the full analysis flow first."))
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }
    
    // MARK: - 九宫分析结果
    private var ninePalaceAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("九宫飞星分析", "Nine-Palace Review"), accent: "02")
            
            if let analysis = viewModel.analysis {
                    // 九宫格展示
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(0..<3, id: \.self) { row in
                            ForEach(0..<3, id: \.self) { col in
                                palaceCard(info: analysis.palaces[row][col])
                            }
                        }
                    }
                
                // 吉凶方位总结
                summarySection(analysis: analysis)

                if let naqiResult = analysis.naqiResult, !naqiResult.points.isEmpty {
                    naqiAssessmentSection(analysis: analysis, result: naqiResult)
                }

                if !analysis.roomAssessments.isEmpty {
                    roomAssessmentSection(analysis: analysis)
                }
            }
        }
    }
    
    private func palaceCard(info: PalaceInfo) -> some View {
        VStack(spacing: 4) {
            Text(positionName(info.position))
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
            
            HStack(spacing: 2) {
                Text("\(info.shanStar)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(starColor(info.shanStar))
                
                Text("\(info.yunStar)")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)
                
                Text("\(info.xiangStar)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(starColor(info.xiangStar))
            }
            
            Text(info.yunStatus.localizedLabel)
                .font(.system(size: 10, weight: .regular, design: .rounded))
                .foregroundColor(statusColor(info.yunStatus))
        }
        .frame(maxWidth: .infinity)
        .padding(8)
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(statusColor(info.yunStatus).opacity(0.16))
                .frame(width: 24, height: 4)
                .padding(.horizontal, 8)
                .padding(.bottom, 6)
        }
        .tameInstrumentCard(cornerRadius: 12, shadow: false)
    }
    
    private func positionName(_ pos: (Int, Int)) -> String {
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
        return names[pos.0][pos.1]
    }
    
    private func summarySection(analysis: FloorPlanAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("方位建议", "Sector Suggestions"), accent: "03")

            if let primaryNaqiPoint = analysis.primaryNaqiPoint {
                VStack(alignment: .leading, spacing: 4) {
                    Text(TAMEL10n.text("向盘依据", "Facing Basis"))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                    Text(
                        TAMEL10n.text(
                            "\(analysis.analysisBasis)\n当前主纳气：\(primaryNaqiPoint.name) · \(primaryNaqiPoint.score) 分 · \(primaryNaqiPoint.level)",
                            "\(analysis.analysisBasis)\nPrimary intake: \(primaryNaqiPoint.name) · \(primaryNaqiPoint.score) · \(primaryNaqiPoint.level)"
                        )
                    )
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
            } else {
                Text(analysis.analysisBasis)
                    .font(.system(size: 12.5, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }
            
            if !analysis.auspiciousPositions.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(TAMETheme.stardustGold)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(TAMEL10n.text("吉位", "Helpful Sectors"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)
                        Text(analysis.auspiciousPositions.map { positionName($0) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、"))
                            .font(.system(size: 12.5, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                    }
                }
            }
            
            if !analysis.inauspiciousPositions.isEmpty {
                HStack(alignment: .top) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(TAMETheme.brandAlert)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(TAMEL10n.text("需注意方位", "Caution Sectors"))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)
                        Text(analysis.inauspiciousPositions.map { positionName($0) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、"))
                            .font(.system(size: 12.5, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                    }
                }
            }
            
            Text(analysis.recommendation)
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .padding(.top, 4)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 20, shadow: true)
    }

    private func naqiAssessmentSection(
        analysis: FloorPlanAnalysis,
        result: NaqiAnalyzer.NaqiAnalysisResult
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("纳气口比较", "Opening Comparison"), accent: "04")

            Text(result.summary)
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            ForEach(Array(result.points.enumerated()), id: \.element.name) { _, point in
                let isPrimary = analysis.primaryNaqiPoint?.name == point.name && analysis.primaryNaqiPoint?.naqiAngle == point.naqiAngle

                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(point.name)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                            Text("\(point.direction.localizedLabel) · \(point.qiStatus.localizedTitle) · \(TAMEL10n.text("向星", "Facing Star")) \(point.xiangStar)")
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextSecondary)
                        }

                        Spacer()

                        Text(
                            isPrimary
                            ? TAMEL10n.text("主纳气 \(point.score)分", "Primary \(point.score)")
                            : TAMEL10n.text("\(point.score)分", "\(point.score)")
                        )
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

                    Text(point.analysis)
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
                .padding(12)
                .tameInstrumentCard(cornerRadius: 18, shadow: false)
            }
        }
    }

    private func roomAssessmentSection(analysis: FloorPlanAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("房间落宫评估", "Room Placement Review"), accent: "05")

            ForEach(analysis.roomAssessments) { assessment in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(assessment.label)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                            Text(
                                TAMEL10n.text(
                                    "\(assessment.palaceName)宫 · \(assessment.heatLevel.localizedTitle) · 宫位 \(assessment.palaceScore) 分",
                                    "\(assessment.palaceName) · \(assessment.heatLevel.localizedTitle) · Sector \(assessment.palaceScore)"
                                )
                            )
                                .font(.system(size: 12, weight: .regular, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextSecondary)
                        }

                        Spacer()

                        Text(TAMEL10n.text("\(assessment.suitability.localizedTitle) \(assessment.suitabilityScore)分", "\(assessment.suitability.localizedTitle) \(assessment.suitabilityScore)"))
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(roomSuitabilityColor(assessment.suitability).opacity(0.12))
                            )
                            .overlay {
                                Capsule()
                                    .stroke(roomSuitabilityColor(assessment.suitability).opacity(0.16), lineWidth: 1)
                            }
                            .foregroundColor(roomSuitabilityColor(assessment.suitability))
                    }

                    Text(assessment.advice)
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    Text(TAMEL10n.text("纳气联动：\(assessment.naqiRelationshipSummary)", "Intake effect: \(assessment.naqiRelationshipSummary)"))
                        .font(.system(size: 12.5, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }
                .padding(12)
                .tameInstrumentCard(cornerRadius: 18, shadow: false)
            }
        }
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
                .frame(width: 36, alignment: .leading)

            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }

    private func workspaceActionButton(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(TAMETheme.stardustGold)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 104, alignment: .topLeading)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private func floorPlanPill(title: String, value: String, tint: Color) -> some View {
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
                .fill(tint.opacity(0.18))
                .frame(width: 22, height: 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .tameInstrumentCard(cornerRadius: 14, shadow: false)
    }

    private func importActionCard(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(TAMETheme.stardustGold)

                Text(title)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .topLeading)
            .padding(14)
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private var floorPlanStateLabel: String {
        if viewModel.isUsingDemoLayout {
            return TAMEL10n.text("户型示意", "Layout Preview")
        }

        if viewModel.floorPlanImage != nil {
            return TAMEL10n.text("已导入户型", "Floor Plan Loaded")
        }

        return TAMEL10n.text("等待导入", "Awaiting Import")
    }

    private var analysisBasisSummary: String {
        if let primary = viewModel.analysis?.primaryNaqiPoint {
            return TAMEL10n.text("\(primary.name) · \(primary.qiStatus.localizedTitle)", "\(primary.name) · \(primary.qiStatus.localizedTitle)")
        }

        if !viewModel.roomMarkers.isEmpty {
            return TAMEL10n.text("已标记 \(viewModel.markerSummary())", "Marked \(viewModel.markerSummary())")
        }

        return TAMEL10n.text("暂未建立纳气依据", "No intake basis yet")
    }
    
    private func starColor(_ star: Int) -> Color {
        switch star {
        case 1, 6, 8, 9: return TAMETheme.stardustGold
        case 2, 5, 7: return TAMETheme.brandAlert
        case 3, 4: return TAMETheme.techGray
        default: return .primary
        }
    }
    
    private func statusColor(_ status: StarStatus) -> Color {
        switch status {
        case .wang: return TAMETheme.stardustGold
        case .sheng: return TAMETheme.moonWhite
        case .tui, .shuai: return TAMETheme.techGray
        case .sha: return TAMETheme.brandAlert
        }
    }

    private func markerIcon(_ type: FloorPlanRoomType) -> String {
        switch type {
        case .mainDoor: return "door.left.hand.open"
        case .balcony: return "sun.max.fill"
        case .window: return "uiwindow.split.2x1"
        case .livingRoom: return "person.3.fill"
        case .bedroom: return "bed.double.fill"
        case .kitchen: return "fork.knife"
        case .bathroom: return "drop.fill"
        case .study: return "pencil.and.ruler.fill"
        }
    }

    private func markerColor(_ type: FloorPlanRoomType) -> Color {
        switch type {
        case .mainDoor: return TAMETheme.stardustGold
        case .balcony: return TAMETheme.moonWhite
        case .window: return TAMETheme.techGray
        case .livingRoom: return TAMETheme.stardustGold.opacity(0.90)
        case .bedroom: return TAMETheme.deepBlueBlack
        case .kitchen: return TAMETheme.brandAlert
        case .bathroom: return TAMETheme.techGray
        case .study: return TAMETheme.moonWhite.opacity(0.86)
        }
    }

    private var heatmapLegend: some View {
        HStack(spacing: 8) {
            legendPill(title: TAMEL10n.text("旺位", "Prime"), color: heatmapColor(.excellent))
            legendPill(title: TAMEL10n.text("吉位", "Supportive"), color: heatmapColor(.supportive))
            legendPill(title: TAMEL10n.text("平位", "Balanced"), color: heatmapColor(.balanced))
            legendPill(title: TAMEL10n.text("注意位", "Caution"), color: heatmapColor(.caution))
        }
        .font(.system(size: 10, weight: .medium, design: .rounded))
    }

    private func legendPill(title: String, color: Color) -> some View {
        Text(title)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(color)
            .cornerRadius(999)
    }

    private func floorPlanHeatmapOverlay(_ analysis: FloorPlanAnalysis) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { col in
                        heatmapCell(info: analysis.palaces[row][col])
                    }
                }
            }
        }
    }

    private func heatmapCell(info: PalaceInfo) -> some View {
        let level = viewModel.heatLevel(for: info)

        return VStack(spacing: 6) {
            Text(level.localizedTitle)
                .font(.system(size: 10, weight: .medium, design: .rounded))
            Text("\(info.score)")
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(.black.opacity(0.75))
        .background(heatmapColor(level))
        .overlay(
            Rectangle()
                .stroke(TAMETheme.moonWhite.opacity(0.22), lineWidth: 0.8)
        )
    }

    private func heatmapColor(_ level: FloorPlanHeatLevel) -> Color {
        switch level {
        case .excellent:
            return TAMETheme.stardustGold.opacity(0.34)
        case .supportive:
            return TAMETheme.stardustGold.opacity(0.24)
        case .balanced:
            return TAMETheme.moonWhite.opacity(0.22)
        case .caution:
            return TAMETheme.brandAlert.opacity(0.30)
        }
    }

    private func roomSuitabilityColor(_ suitability: FloorPlanRoomSuitability) -> Color {
        switch suitability {
        case .favorable:
            return TAMETheme.stardustGold
        case .acceptable:
            return TAMETheme.moonWhite
        case .caution:
            return TAMETheme.techGray
        case .avoid:
            return TAMETheme.brandAlert
        }
    }

    private func saveRecord() {
        guard let analysis = viewModel.analysis else { return }
        historyStore.save(
            category: .floorPlan,
            title: TAMEL10n.text("户型图分析", "Floor Plan Review"),
            subtitle: TAMEL10n.text("朝向 \(viewModel.facingDirection.localizedLabel) · 标记 \(viewModel.roomMarkers.count) 项", "Facing \(viewModel.facingDirection.localizedLabel) · \(viewModel.roomMarkers.count) markers"),
            details: viewModel.buildRecordDetails(analysis: analysis)
        )
        saveStatusMessage = TAMEL10n.text("户型分析记录已保存，可到“历史记录”继续查看。", "Floor-plan analysis saved. You can review it in Records.")
    }

    private func loadDemoLayout() {
        viewModel.loadDemoLayout()
        importStatusMessage = TAMEL10n.text("已载入一套示意户型，可直接检查立极点、纳气口、房间标记与九宫结果。", "A starter layout has been loaded. You can inspect the center point, intake openings, room markers, and nine-palace results right away.")
        importErrorMessage = nil
    }

    private func beginPhotoLibraryImport() {
        importErrorMessage = nil

        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            importStatusMessage = TAMEL10n.text("请选择一张户型图，导入后会自动开始九宫分析。", "Choose a floor plan and the nine-palace review will start automatically.")
            showImagePicker = true
        case .notDetermined:
            importStatusMessage = TAMEL10n.text("会打开系统选图器；若你选择有限访问，应用只会读取本次选中的户型图。", "The system picker will open. If you choose limited access, the app will only read the floor plan selected this time.")
            showImagePicker = true
        case .denied, .restricted:
            importErrorMessage = TAMEL10n.text("当前没有照片读取权限，请到系统设置里允许访问照片后再导入户型图。", "Photo access is unavailable. Please allow photo access in Settings before importing a floor plan.")
        @unknown default:
            importErrorMessage = TAMEL10n.text("系统暂时无法确认照片读取权限，请稍后重试。", "The system could not confirm photo permission right now. Please try again shortly.")
        }
    }

    private func beginCameraCapture() {
        importErrorMessage = nil

        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            importErrorMessage = TAMEL10n.text("当前设备暂不支持拍摄户型图，请改用相册导入或示意户型。", "This device does not support camera capture right now. Please use Photos import or the starter layout instead.")
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            importStatusMessage = TAMEL10n.text("拍摄完成后会自动带入户型分析。", "After capture, the floor plan will be loaded into the analysis automatically.")
            showCamera = true
        case .notDetermined:
            importStatusMessage = TAMEL10n.text("进入拍摄后，系统会在需要时请求相机权限。", "The system will request camera permission when capture begins, if needed.")
            showCamera = true
        case .denied, .restricted:
            importErrorMessage = TAMEL10n.text("当前没有相机权限，请到系统设置里允许访问相机后再拍摄户型图。", "Camera access is unavailable. Please allow camera access in Settings before capturing a floor plan.")
        @unknown default:
            importErrorMessage = TAMEL10n.text("系统暂时无法确认相机权限，请稍后重试。", "The system could not confirm camera permission right now. Please try again shortly.")
        }
    }

    private func handleImportedImage(from source: FloorPlanImportSource) {
        guard viewModel.floorPlanImage != nil else { return }
        importStatusMessage = source.successMessage
        importErrorMessage = nil
        viewModel.analyzeFloorPlan()
    }
}

private enum FloorPlanImportSource {
    case photoLibrary
    case camera

    var successMessage: String {
        switch self {
        case .photoLibrary:
            return TAMEL10n.text("户型图已从相册导入，可继续标记立极点与房间。", "Floor plan imported from Photos. You can continue placing the center point and room markers.")
        case .camera:
            return TAMEL10n.text("户型图已拍摄导入，可继续标记立极点与房间。", "Floor plan captured and imported. You can continue placing the center point and room markers.")
        }
    }
}

// MARK: - 九宫格叠加视图
struct NinePalaceGridOverlay: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let cellWidth = width / 3
        let cellHeight = height / 3
        
        // 垂直线
        for i in 1..<3 {
            let x = CGFloat(i) * cellWidth
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: height))
        }
        
        // 水平线
        for i in 1..<3 {
            let y = CGFloat(i) * cellHeight
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: width, y: y))
        }
        
        return path
    }
}

// MARK: - ImagePicker (UIKit 桥接)
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
