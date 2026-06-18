import SwiftUI
import AVFoundation
import CoreLocation
import CoreMotion
import Photos
import UIKit

struct SettingsView: View {
    @EnvironmentObject private var premiumAccessStore: PremiumAccessStore
    @AppStorage(TAMEL10n.userDefaultsKey) private var localeOverride = TAMEAppLocale.zhHans.rawValue
    @AppStorage("useTrueNorth") private var useTrueNorth = false
    @AppStorage("compassSize") private var compassSize = 1.0
    @AppStorage("showNaqiDisk") private var showNaqiDisk = true
    @AppStorage("compassOpacity") private var compassOpacity = 1.0
    @AppStorage("compassVisualStyle") private var compassVisualStyle = CompassDiskView.VisualStyle.minimal.rawValue
    @StateObject private var historyStore = HistoryStore.shared
    @State private var backupDocument = HistoryBackupDocument(data: Data())
    @State private var showBackupExporter = false
    @State private var showBackupImporter = false
    @State private var showClearConfirmation = false
    @State private var backupStatusMessage: String?
    @State private var backupErrorMessage: String?
    @State private var permissionSnapshot = PermissionSnapshot.capture()
    @State private var focusedDestination: SettingsDeepLinkDestination?
    @State private var activePolicySheet: SettingsDocumentDestination?
    @State private var pendingInitialDestination: SettingsDeepLinkDestination?
    @StateObject private var permissionRequester = PermissionRequestCoordinator()

    init(initialDestination: SettingsDeepLinkDestination? = nil) {
        _pendingInitialDestination = State(initialValue: initialDestination)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    if focusedDestination == .permissions {
                        permissionFocusSection
                    }

                    settingsDashboardSection
                    settingsShortcutSection

                    brandSection(title: TAMEL10n.text("罗盘设置", "Compass"), accent: "01") {
                        Toggle(TAMEL10n.text("使用真北", "Use True North"), isOn: $useTrueNorth)
                            .tint(TAMETheme.stardustGold)
                        Toggle(TAMEL10n.text("显示纳气盘", "Show Naqi Plate"), isOn: $showNaqiDisk)
                            .tint(TAMETheme.stardustGold)

                        Picker(TAMEL10n.text("罗盘样式", "Compass Style"), selection: $compassVisualStyle) {
                            ForEach(CompassDiskView.VisualStyle.allCases) { style in
                                Text(style.title).tag(style.rawValue)
                            }
                        }

                        noteText((CompassDiskView.VisualStyle(rawValue: compassVisualStyle) ?? .classic).summary)
                        noteText(TAMEL10n.text("启用真北时会在需要时申请定位权限，用于北向校正；未启用时继续按磁北测向。", "When True North is enabled, location permission is requested only when needed for north correction; otherwise the compass keeps using magnetic north."))

                        sliderRow(title: TAMEL10n.text("罗盘大小", "Compass Scale"), valueText: String(format: "%.1fx", compassSize), value: $compassSize, range: 0.8...1.2, step: 0.1)
                        sliderRow(title: TAMEL10n.text("显示透明度", "Opacity"), valueText: String(format: "%.2f", compassOpacity), value: $compassOpacity, range: 0.6...1.0, step: 0.05)
                    }

                    brandSection(title: TAMEL10n.text("界面语言", "Language"), accent: "02") {
                        Picker(TAMEL10n.text("界面语言", "Interface Language"), selection: $localeOverride) {
                            ForEach(TAMEAppLocale.allCases, id: \.rawValue) { locale in
                                Text(locale.settingsTitle).tag(locale.rawValue)
                            }
                        }

                        noteText((TAMEAppLocale.parse(localeOverride) ?? .zhHans).settingsSummary)
                    }

                    brandSection(title: TAMEL10n.text("解锁与购买", "Unlock & Purchase"), accent: "03") {
                        metricRow(index: "03.1", title: TAMEL10n.text("当前状态", "Current Status"), value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("未解锁", "Locked"))
                        metricRow(index: "03.2", title: TAMEL10n.text("购买方式", "Purchase Type"), value: TAMEL10n.text("订阅制", "Subscription"))

                        Button(action: {
                            activePolicySheet = .premium
                        }) {
                            settingsNavRow(title: TAMEL10n.text("查看解锁方案", "View Unlock"), symbol: "sparkles")
                        }
                        .buttonStyle(.plain)

                        noteText(TAMEL10n.text("这里可以查看订阅方案、恢复购买，以及当前购买说明。", "Open this section to review subscription plans, restore purchases, and purchase details."))
                    }

                    brandSection(title: TAMEL10n.text("数据", "Data"), accent: "04") {
                        metricRow(index: "03.1", title: TAMEL10n.text("已保存记录", "Saved Records"), value: "\(historyStore.records.count)")
                        metricRow(index: "03.2", title: TAMEL10n.text("高级解锁", "Premium Access"), value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("未解锁", "Locked"))

                        NavigationLink(destination: PremiumUnlockView()) {
                            settingsNavRow(title: TAMEL10n.text("查看高级解锁", "Open Premium Access"), symbol: "sparkles")
                        }
                        .buttonStyle(.plain)

                        flatButton(TAMEL10n.text("导出本地备份", "Export Local Backup"), disabled: historyStore.records.isEmpty) {
                            prepareBackupExport()
                        }

                        flatButton(TAMEL10n.text("恢复历史记录", "Restore History")) {
                            showBackupImporter = true
                        }

                        if let backupStatusMessage {
                            noteText(backupStatusMessage)
                        }

                        Button(role: .destructive) {
                            showClearConfirmation = true
                        } label: {
                            Text(TAMEL10n.text("清空本地记录", "Clear Local Records"))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    brandSection(title: TAMEL10n.text("权限状态", "Permissions"), accent: "05") {
                        ForEach(permissionSnapshot.items) { item in
                            permissionRow(item)
                        }

                        HStack(spacing: 12) {
                            flatButton(TAMEL10n.text("刷新权限状态", "Refresh Status")) {
                                refreshPermissionSnapshot()
                            }

                            flatButton(TAMEL10n.text("打开系统设置", "Open System Settings")) {
                                openSystemSettings()
                            }
                        }

                        noteText(TAMEL10n.text("定位用于真北校正；运动与方向用于罗盘测向；相机和相册用于导入户型与保存报告。若设备暂不提供实时传感器，页面会显示参考读数。", "Location supports True North correction; motion and heading support compass orientation; camera and Photos are used for floor-plan import and report saving. If live sensors are not available, the app shows reference readings instead."))
                    }

                    brandSection(title: TAMEL10n.text("使用建议", "Usage Tips"), accent: "06") {
                        numberedNote("01", TAMEL10n.text("先在罗盘页确认房屋坐向，再进入分析专题查看纳气、飞星、流年与八宅结果。", "Start by confirming the house orientation on the compass screen, then move into the analysis topics for openings, Flying Star, annual review, and Eight-Mansion guidance."))
                        numberedNote("02", TAMEL10n.text("导入户型图后，请尽量准确标记立极点、大门、阳台与主窗，这会直接影响后续参考结果。", "After importing a floor plan, mark the center point, main door, balcony, and major windows as accurately as possible, as they directly affect the later references."))
                        numberedNote("03", TAMEL10n.text("应用内结论用于整理空间观察与民俗文化参考，不替代结构、安全、采光或居住舒适度判断。", "The in-app conclusions are meant to organize spatial observations and cultural reference, and do not replace decisions about structure, safety, daylight, or living comfort."))
                    }

                    brandSection(title: TAMEL10n.text("隐私与支持", "Privacy & Support"), accent: "07") {
                        NavigationLink(destination: PrivacyPolicyView()) {
                            settingsNavRow(title: TAMEL10n.text("查看隐私政策", "View Privacy Policy"), symbol: "hand.raised")
                        }

                        NavigationLink(destination: TermsOfUseView()) {
                            settingsNavRow(title: TAMEL10n.text("查看使用条款", "View Terms of Use"), symbol: "doc.text")
                        }

                        NavigationLink(destination: SupportCenterView()) {
                            settingsNavRow(title: TAMEL10n.text("查看支持与帮助", "View Support"), symbol: "questionmark.circle")
                        }

                        noteText(TAMEL10n.text("如需了解数据使用、权限用途或联系支持，可直接打开上方对应页面查看。", "Open the pages above whenever you want details about data use, permission purpose, or support contact."))
                    }
                    
                    brandSection(title: TAMEL10n.text("关于", "About"), accent: "08") {
                        metricRow(index: "07.1", title: TAMEL10n.text("版本", "Version"), value: "1.0.0")
                        noteText(TAMEL10n.text("本APP仅为民俗文化参考工具，不构成科学依据", "This app is for cultural reference only and is not a scientific instrument."))
                    }
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
            .navigationTitle(TAMEL10n.text("设置", "Settings"))
            .fileExporter(
                isPresented: $showBackupExporter,
                document: backupDocument,
                contentType: .json,
                defaultFilename: defaultBackupFilename
            ) { result in
                switch result {
                case .success:
                    backupStatusMessage = TAMEL10n.text("本地备份已生成，可保存到“文件”或分享给其他设备。", "The local backup is ready. You can save it to Files or share it to another device.")
                    backupErrorMessage = nil
                case .failure(let error):
                    backupErrorMessage = error.localizedDescription
                }
            }
            .fileImporter(
                isPresented: $showBackupImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: false
            ) { result in
                handleImportResult(result)
            }
            .confirmationDialog(
                TAMEL10n.text("确认清空本地记录？", "Clear all local records?"),
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button(TAMEL10n.text("清空全部记录", "Delete All Records"), role: .destructive) {
                    historyStore.clear()
                    backupStatusMessage = TAMEL10n.text("本地记录已清空。", "Local records have been cleared.")
                    backupErrorMessage = nil
                }
                Button(TAMEL10n.text("取消", "Cancel"), role: .cancel) {}
            } message: {
                Text(TAMEL10n.text("此操作会删除当前设备上的全部测量和分析记录，但不会影响你已经导出的备份文件。", "This deletes all measurements and analysis records on the current device, but it will not affect backup files you already exported."))
            }
            .alert(TAMEL10n.text("备份处理失败", "Backup Failed"), isPresented: Binding(
                get: { backupErrorMessage != nil },
                set: { newValue in
                    if !newValue {
                        backupErrorMessage = nil
                    }
                }
            )) {
                Button(TAMEL10n.text("知道了", "OK"), role: .cancel) {
                    backupErrorMessage = nil
                }
            } message: {
                Text(backupErrorMessage ?? TAMEL10n.text("发生未知错误", "An unknown error occurred."))
            }
            .sheet(item: $activePolicySheet) { destination in
                NavigationView {
                    policyDestinationView(for: destination)
                }
            }
            .onAppear {
                permissionRequester.onStatusChange = refreshPermissionSnapshot
                refreshPermissionSnapshot()
                if let destination = pendingInitialDestination {
                    handleDeepLinkDestination(destination)
                    pendingInitialDestination = nil
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .tameOpenSettingsDestination)) { output in
                guard let rawValue = output.object as? String,
                      let destination = SettingsDeepLinkDestination(rawValue: rawValue) else { return }
                handleDeepLinkDestination(destination)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                refreshPermissionSnapshot()
            }
            .tameOnChangeCompat(of: useTrueNorth) {
                if useTrueNorth {
                    permissionRequester.requestLocationAuthorization()
                }
                refreshPermissionSnapshot()
            }
        }
    }

    private var settingsDashboardSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前设置", "Current Settings"), accent: "00")

            Text(TAMEL10n.text("这里集中查看语言、罗盘模式、权限状态与本地记录设置，方便日常使用时快速调整。", "This area brings together language, compass mode, permission status, and local-record settings so they are easier to adjust in daily use."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            LazyVGrid(columns: dashboardColumns, spacing: 10) {
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("当前语言", "Language"),
                    value: currentLocale.settingsTitle,
                    symbol: "globe",
                    note: TAMEL10n.text("界面文本", "UI copy"),
                    tint: TAMETheme.stardustGold
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("罗盘模式", "North Mode"),
                    value: useTrueNorth ? TAMEL10n.text("真北", "True North") : TAMEL10n.text("磁北", "Magnetic North"),
                    symbol: "location.north.line",
                    note: TAMEL10n.text("测向基线", "Orientation basis"),
                    tint: TAMETheme.stardustGold
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("权限健康度", "Permission Health"),
                    value: permissionHealthSummary,
                    symbol: "checkmark.shield",
                    note: TAMEL10n.text("设备状态", "Device state"),
                    tint: TAMETheme.techGray
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("本地记录", "Local Records"),
                    value: "\(historyStore.records.count)",
                    symbol: "tray.full",
                    note: TAMEL10n.text("档案数量", "Saved items"),
                    tint: TAMETheme.stardustGold
                )
            }

            if let backupStatusMessage {
                noteText(backupStatusMessage)
            } else {
                noteText(TAMEL10n.text("这里集中放置语言、权限、备份与基础罗盘设置，方便日常使用时快速查看和调整。", "This section brings together language, permissions, backup, and core compass settings for quicker daily review and adjustment."))
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    private var settingsShortcutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("快捷操作", "Quick Actions"), accent: "00")

            LazyVGrid(columns: shortcutColumns, spacing: 12) {
                shortcutButton(
                    title: TAMEL10n.text("权限", "Permissions"),
                    subtitle: permissionHealthSummary,
                    symbol: "checklist",
                    action: {
                        focusedDestination = .permissions
                        refreshPermissionSnapshot()
                    }
                )

                shortcutButton(
                    title: TAMEL10n.text("备份", "Backup"),
                    subtitle: historyStore.records.isEmpty ? TAMEL10n.text("暂无记录", "No records") : TAMEL10n.text("导出本地数据", "Export local data"),
                    symbol: "externaldrive",
                    action: {
                        if historyStore.records.isEmpty {
                            backupStatusMessage = TAMEL10n.text("还没有可导出的本地记录。先保存一次测量或分析结果，再来导出备份。", "There are no local records to export yet. Save a measurement or analysis first, then export the backup.")
                            backupErrorMessage = nil
                        } else {
                            prepareBackupExport()
                        }
                    }
                )
                shortcutButton(
                    title: TAMEL10n.text("高级解锁", "Premium"),
                    subtitle: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("查看方案", "View plans"),
                    symbol: "sparkles",
                    action: {
                        activePolicySheet = .premium
                    }
                )

                shortcutButton(
                    title: TAMEL10n.text("支持", "Support"),
                    subtitle: TAMEL10n.text("帮助与联系", "Help and contact"),
                    symbol: "questionmark.bubble",
                    action: {
                        activePolicySheet = .support
                    }
                )

                shortcutButton(
                    title: TAMEL10n.text("系统设置", "System Settings"),
                    subtitle: TAMEL10n.text("处理权限受限", "Fix blocked access"),
                    symbol: "gearshape",
                    action: openSystemSettings
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }

    private var defaultBackupFilename: String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_Hans_CN")
        formatter.dateFormat = "yyyyMMdd-HHmm"
        return "TAME-Space-Compass-Backup-\(formatter.string(from: Date())).json"
    }

    private func prepareBackupExport() {
        do {
            backupDocument = try HistoryBackupDocument(data: historyStore.makeBackupData())
            backupStatusMessage = nil
            backupErrorMessage = nil
            showBackupExporter = true
        } catch {
            backupErrorMessage = error.localizedDescription
        }
    }

    private func handleDeepLinkDestination(_ destination: SettingsDeepLinkDestination) {
        refreshPermissionSnapshot()
        focusedDestination = destination == .permissions ? destination : nil
        activePolicySheet = nil

        switch destination {
        case .permissions:
            break
        case .backupExport:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if historyStore.records.isEmpty {
                    backupStatusMessage = TAMEL10n.text("还没有可导出的本地记录。先保存一次测量或分析结果，再来导出备份。", "There are no local records to export yet. Save a measurement or analysis first, then export the backup.")
                    backupErrorMessage = nil
                } else {
                    prepareBackupExport()
                }
            }
        case .backupImport:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                showBackupImporter = true
            }
        case .premium:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                activePolicySheet = .premium
            }
        case .privacyPolicy:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                activePolicySheet = .privacyPolicy
            }
        case .termsOfUse:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                activePolicySheet = .termsOfUse
            }
        case .support:
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                activePolicySheet = .support
            }
        }
    }

    @ViewBuilder
    private func policyDestinationView(for destination: SettingsDocumentDestination) -> some View {
        switch destination {
        case .premium:
            PremiumUnlockView()
        case .privacyPolicy:
            PrivacyPolicyView()
        case .termsOfUse:
            TermsOfUseView()
        case .support:
            SupportCenterView()
        }
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            do {
                let canAccess = url.startAccessingSecurityScopedResource()
                defer {
                    if canAccess {
                        url.stopAccessingSecurityScopedResource()
                    }
                }

                let data = try Data(contentsOf: url)
                let summary = try historyStore.importBackup(data: data)
                backupStatusMessage = summary.summaryText
                backupErrorMessage = nil
            } catch {
                backupErrorMessage = error.localizedDescription
            }
        case .failure(let error):
            backupErrorMessage = error.localizedDescription
        }
    }

    private func refreshPermissionSnapshot() {
        permissionSnapshot = PermissionSnapshot.capture()
    }

    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func handlePermissionAction(for item: PermissionSnapshot.Item) {
        switch item.state {
        case .blocked:
            openSystemSettings()
        case .pending:
            switch item.kind {
            case .location:
                permissionRequester.requestLocationAuthorization()
            case .motion:
                permissionRequester.requestMotionAuthorization()
            case .camera:
                AVCaptureDevice.requestAccess(for: .video) { _ in
                    DispatchQueue.main.async {
                        refreshPermissionSnapshot()
                    }
                }
            case .photoRead:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                    DispatchQueue.main.async {
                        refreshPermissionSnapshot()
                    }
                }
            case .photoAdd:
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { _ in
                    DispatchQueue.main.async {
                        refreshPermissionSnapshot()
                    }
                }
            }
        case .ready, .unavailable:
            break
        }
    }

    private func permissionRow(_ item: PermissionSnapshot.Item) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Circle()
                    .fill(item.state.tint)
                    .frame(width: 10, height: 10)

                Text(item.title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Spacer()

                Text(item.status)
                    .font(.caption.weight(.medium))
                    .foregroundColor(item.state.tint)
            }

            Text(item.detail)
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)

            if let actionTitle = item.actionTitle {
                Button(actionTitle) {
                    handlePermissionAction(for: item)
                }
                .font(.footnote.weight(.medium))
                .foregroundColor(item.state == .blocked ? TAMETheme.brandAlert : TAMETheme.stardustGold)
                .padding(.top, 4)
            }
        }
        .padding(14)
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
    }

    private var permissionFocusSection: some View {
        brandSection(title: TAMEL10n.text("权限速览", "Permission Snapshot"), accent: "00", emphasized: true) {
            ForEach(permissionSnapshot.items) { item in
                permissionRow(item)
            }

            noteText(TAMEL10n.text("这里会显示当前设备的定位、方向、相机与相册状态，方便你集中查看各项权限是否可用。", "This shows the current status of location, heading, camera, and Photos so you can review all permissions in one place."))

            flatButton(TAMEL10n.text("返回完整设置", "Back to Settings")) {
                focusedDestination = nil
            }
        }
    }

    private func brandSection<Content: View>(title: String, accent: String, emphasized: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: title, accent: accent)
            content()
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: emphasized, shadow: true)
    }

    private func sectionHeading(title: String, accent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accent)
                .font(.caption2.weight(.medium))
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

    private func noteText(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundColor(TAMETheme.brandTextSecondary)
    }

    private func metricRow(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.caption2.weight(.medium))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 32, alignment: .leading)

            Text(title)
                .font(.callout)
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.callout.weight(.medium))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    private func sliderRow(title: String, valueText: String, value: Binding<Double>, range: ClosedRange<Double>, step: Double) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .foregroundColor(TAMETheme.brandTextPrimary)
                Spacer()
                Text(valueText)
                    .font(.footnote.monospacedDigit())
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            Slider(value: value, in: range, step: step)
                .tint(TAMETheme.stardustGold)
        }
    }

    private func numberedNote(_ index: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(index)
                .font(.caption2.weight(.medium))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 24, alignment: .leading)

            Text(text)
                .font(.callout)
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
    }

    private func infoBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
            Text(body)
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
    }

    private func flatButton(_ title: String, disabled: Bool = false, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .frame(maxWidth: .infinity, alignment: .leading)
            .disabled(disabled)
            .opacity(disabled ? 0.4 : 1)
    }

    private func shortcutButton(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .labelStyle(.titleAndIcon)
                .frame(width: 0, height: 0)
                .opacity(0)

            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(TAMETheme.stardustGold.opacity(0.10))

                    Image(systemName: symbol)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(TAMETheme.stardustGold)
                }
                .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .multilineTextAlignment(.leading)

                    Text(TAMEL10n.text("立即处理", "Open"))
                        .font(.caption.weight(.medium))
                        .foregroundColor(TAMETheme.stardustGold)
                }

                Spacer(minLength: 0)

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
            .padding(16)
            .tameInstrumentCard(cornerRadius: 18, shadow: false)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }

    private func settingsNavRow(title: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TAMETheme.stardustGold.opacity(0.10))

                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(TAMETheme.stardustGold)
            }
            .frame(width: 30, height: 30)

            Text(title)
                .foregroundColor(TAMETheme.brandTextPrimary)
            Spacer()
            Image(systemName: "arrow.right")
                .font(.caption.weight(.medium))
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .padding(14)
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
        .accessibilityLabel(Text(title))
    }

    private var currentLocale: TAMEAppLocale {
        TAMEAppLocale.parse(localeOverride) ?? .zhHans
    }

    private var currentCompassStyle: CompassDiskView.VisualStyle {
        CompassDiskView.VisualStyle(rawValue: compassVisualStyle) ?? .classic
    }

    private var permissionHealthSummary: String {
        let readyCount = permissionSnapshot.items.filter { $0.state == .ready }.count
        let blockedCount = permissionSnapshot.items.filter { $0.state == .blocked }.count
        let pendingCount = permissionSnapshot.items.filter { $0.state == .pending }.count

        if blockedCount > 0 {
            return TAMEL10n.text("\(readyCount) 项可用 · \(blockedCount) 项受限", "\(readyCount) ready · \(blockedCount) blocked")
        }

        if pendingCount > 0 {
            return TAMEL10n.text("\(readyCount) 项可用 · \(pendingCount) 项待授权", "\(readyCount) ready · \(pendingCount) pending")
        }

        return TAMEL10n.text("权限状态正常", "Permissions look good")
    }

    private var dashboardColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    private var shortcutColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
    }
}

private struct PermissionSnapshot {
    enum PermissionKind {
        case location
        case motion
        case camera
        case photoRead
        case photoAdd
    }

    struct Item: Identifiable {
        let id = UUID()
        let kind: PermissionKind
        let title: String
        let status: String
        let detail: String
        let state: PermissionState

        var actionTitle: String? {
            switch state {
            case .pending:
                return TAMEL10n.text("立即申请", "Request Access")
            case .blocked:
                return TAMEL10n.text("打开系统设置", "Open Settings")
            case .ready, .unavailable:
                return nil
            }
        }
    }

    enum PermissionState: Equatable {
        case ready
        case pending
        case blocked
        case unavailable

        var tint: Color {
            switch self {
            case .ready:
                return .green
            case .pending:
                return .orange
            case .blocked:
                return .red
            case .unavailable:
                return .gray
            }
        }
    }

    let items: [Item]

    static func capture() -> PermissionSnapshot {
        let locationManager = CLLocationManager()
        let motionManager = CMMotionManager()

        return PermissionSnapshot(items: [
            locationItem(status: locationManager.authorizationStatus),
            motionItem(motionAvailable: motionManager.isDeviceMotionAvailable),
            cameraItem(),
            photoLibraryReadItem(),
            photoLibraryAddItem()
        ])
    }

    private static func locationItem(status: CLAuthorizationStatus) -> Item {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return Item(
                kind: .location,
                title: TAMEL10n.text("定位 / 真北校正", "Location / True North"),
                status: TAMEL10n.text("已允许", "Allowed"),
                detail: TAMEL10n.text("真北校正可正常使用；罗盘可在磁北和真北之间切换。", "True North correction is available, and the compass can switch between magnetic north and true north."),
                state: .ready
            )
        case .notDetermined:
            return Item(
                kind: .location,
                title: TAMEL10n.text("定位 / 真北校正", "Location / True North"),
                status: TAMEL10n.text("待申请", "Pending"),
                detail: TAMEL10n.text("可直接在这里申请；如果你打开“使用真北”，应用也会在需要时请求定位授权。", "You can request it here directly. The app also asks for location access when Use True North is turned on."),
                state: .pending
            )
        case .denied, .restricted:
            return Item(
                kind: .location,
                title: TAMEL10n.text("定位 / 真北校正", "Location / True North"),
                status: TAMEL10n.text("未允许", "Denied"),
                detail: TAMEL10n.text("当前只能按磁北测向；若要做真北校正，请到系统设置中开启定位。", "The app currently uses magnetic north only. Enable location in System Settings if you need True North correction."),
                state: .blocked
            )
        @unknown default:
            return Item(
                kind: .location,
                title: TAMEL10n.text("定位 / 真北校正", "Location / True North"),
                status: TAMEL10n.text("未知", "Unknown"),
                detail: TAMEL10n.text("系统未返回明确的定位权限状态，请稍后再试。", "The system did not return a clear location-permission state. Please try again later."),
                state: .pending
            )
        }
    }

    private static func motionItem(motionAvailable: Bool) -> Item {
        guard motionAvailable else {
            return Item(
                kind: .motion,
                title: TAMEL10n.text("运动与方向", "Motion & Heading"),
                status: TAMEL10n.text("当前设备不支持", "Not Supported"),
                detail: TAMEL10n.text("当前设备或环境没有可用的实时方向传感器，因此罗盘会先显示参考读数。", "Live heading sensors are not available on this device or in the current environment, so the compass shows reference readings for now."),
                state: .unavailable
            )
        }

        switch CMMotionActivityManager.authorizationStatus() {
        case .authorized:
            return Item(
                kind: .motion,
                title: TAMEL10n.text("运动与方向", "Motion & Heading"),
                status: TAMEL10n.text("已允许", "Allowed"),
                detail: TAMEL10n.text("罗盘可以读取设备姿态与方向数据，用于实时测向与水平提示。", "The compass can read device motion and heading for live orientation and leveling guidance."),
                state: .ready
            )
        case .notDetermined:
            return Item(
                kind: .motion,
                title: TAMEL10n.text("运动与方向", "Motion & Heading"),
                status: TAMEL10n.text("待申请", "Pending"),
                detail: TAMEL10n.text("可直接在这里申请；首次进入罗盘并开始测向时，应用也会主动检查并请求相关权限。", "You can request it here directly. The app also checks and requests it when live compass measurement starts."),
                state: .pending
            )
        case .denied, .restricted:
            return Item(
                kind: .motion,
                title: TAMEL10n.text("运动与方向", "Motion & Heading"),
                status: TAMEL10n.text("未允许", "Denied"),
                detail: TAMEL10n.text("罗盘无法读取实时姿态与方向；请到系统设置中允许“运动与健身”访问。", "The compass cannot read live motion or heading. Allow Motion & Fitness access in System Settings."),
                state: .blocked
            )
        @unknown default:
            return Item(
                kind: .motion,
                title: TAMEL10n.text("运动与方向", "Motion & Heading"),
                status: TAMEL10n.text("未知", "Unknown"),
                detail: TAMEL10n.text("系统未返回明确的运动权限状态，请稍后再试。", "The system did not return a clear motion-permission state. Please try again later."),
                state: .pending
            )
        }
    }

    private static func cameraItem() -> Item {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return Item(
                kind: .camera,
                title: TAMEL10n.text("相机 / 拍摄户型图", "Camera / Floor Plan Capture"),
                status: TAMEL10n.text("已允许", "Allowed"),
                detail: TAMEL10n.text("可直接拍摄户型图并进入九宫分析流程。", "You can capture a floor plan directly and continue into the 3x3 analysis flow."),
                state: .ready
            )
        case .notDetermined:
            return Item(
                kind: .camera,
                title: TAMEL10n.text("相机 / 拍摄户型图", "Camera / Floor Plan Capture"),
                status: TAMEL10n.text("待申请", "Pending"),
                detail: TAMEL10n.text("可直接在这里申请，也可以在进入拍摄时由系统弹出授权窗口。", "You can request it here directly, or let the system ask when capture starts."),
                state: .pending
            )
        case .denied, .restricted:
            return Item(
                kind: .camera,
                title: TAMEL10n.text("相机 / 拍摄户型图", "Camera / Floor Plan Capture"),
                status: TAMEL10n.text("未允许", "Denied"),
                detail: TAMEL10n.text("无法直接拍摄户型图；请到系统设置中开启相机权限，或改用相册导入。", "Direct floor-plan capture is unavailable. Enable camera access in System Settings or import from Photos instead."),
                state: .blocked
            )
        @unknown default:
            return Item(
                kind: .camera,
                title: TAMEL10n.text("相机 / 拍摄户型图", "Camera / Floor Plan Capture"),
                status: TAMEL10n.text("未知", "Unknown"),
                detail: TAMEL10n.text("系统未返回明确的相机权限状态，请稍后再试。", "The system did not return a clear camera-permission state. Please try again later."),
                state: .pending
            )
        }
    }

    private static func photoLibraryReadItem() -> Item {
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            return Item(
                kind: .photoRead,
                title: TAMEL10n.text("相册 / 导入户型图", "Photos / Import Floor Plan"),
                status: TAMEL10n.text("已允许", "Allowed"),
                detail: TAMEL10n.text("可从系统相册选择户型图；若是“有限照片”，只能读取你允许的部分素材。", "You can select floor plans from Photos. With limited access, only the items you allowed are readable."),
                state: .ready
            )
        case .notDetermined:
            return Item(
                kind: .photoRead,
                title: TAMEL10n.text("相册 / 导入户型图", "Photos / Import Floor Plan"),
                status: TAMEL10n.text("待申请", "Pending"),
                detail: TAMEL10n.text("可直接在这里申请；若你选择有限访问，应用只会读取你本次选中的户型图。", "You can request it here directly. With limited access, the app reads only the floor plans selected this time."),
                state: .pending
            )
        case .denied, .restricted:
            return Item(
                kind: .photoRead,
                title: TAMEL10n.text("相册 / 导入户型图", "Photos / Import Floor Plan"),
                status: TAMEL10n.text("未允许", "Denied"),
                detail: TAMEL10n.text("无法从系统相册读取户型图；请到系统设置中开启照片访问权限。", "The app cannot read floor plans from Photos. Enable photo-library access in System Settings."),
                state: .blocked
            )
        @unknown default:
            return Item(
                kind: .photoRead,
                title: TAMEL10n.text("相册 / 导入户型图", "Photos / Import Floor Plan"),
                status: TAMEL10n.text("未知", "Unknown"),
                detail: TAMEL10n.text("系统未返回明确的相册读取权限状态，请稍后再试。", "The system did not return a clear photo-library read state. Please try again later."),
                state: .pending
            )
        }
    }

    private static func photoLibraryAddItem() -> Item {
        switch PHPhotoLibrary.authorizationStatus(for: .addOnly) {
        case .authorized, .limited:
            return Item(
                kind: .photoAdd,
                title: TAMEL10n.text("相册 / 保存报告图片", "Photos / Save Report Image"),
                status: TAMEL10n.text("已允许", "Allowed"),
                detail: TAMEL10n.text("记录详情页可将报告图片直接保存到系统相册。", "The record detail page can save the report image directly to Photos."),
                state: .ready
            )
        case .notDetermined:
            return Item(
                kind: .photoAdd,
                title: TAMEL10n.text("相册 / 保存报告图片", "Photos / Save Report Image"),
                status: TAMEL10n.text("待申请", "Pending"),
                detail: TAMEL10n.text("可直接在这里申请，也可以在首次保存报告图片时由系统弹出授权窗口。", "You can request it here directly, or let the system ask the first time you save a report image."),
                state: .pending
            )
        case .denied, .restricted:
            return Item(
                kind: .photoAdd,
                title: TAMEL10n.text("相册 / 保存报告图片", "Photos / Save Report Image"),
                status: TAMEL10n.text("未允许", "Denied"),
                detail: TAMEL10n.text("无法把报告图片直接保存到相册；请到系统设置中允许“添加到照片”。", "The report image cannot be saved directly to Photos. Allow Add to Photos in System Settings."),
                state: .blocked
            )
        @unknown default:
            return Item(
                kind: .photoAdd,
                title: TAMEL10n.text("相册 / 保存报告图片", "Photos / Save Report Image"),
                status: TAMEL10n.text("未知", "Unknown"),
                detail: TAMEL10n.text("系统未返回明确的照片写入权限状态，请稍后再试。", "The system did not return a clear photo-write state. Please try again later."),
                state: .pending
            )
        }
    }
}

private enum SettingsDocumentDestination: String, Identifiable {
    case premium
    case privacyPolicy
    case termsOfUse
    case support

    var id: String { rawValue }
}

private final class PermissionRequestCoordinator: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let motionActivityManager = CMMotionActivityManager()
    var onStatusChange: (() -> Void)?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestLocationAuthorization() {
        guard locationManager.authorizationStatus == .notDetermined else {
            onStatusChange?()
            return
        }

        locationManager.requestWhenInUseAuthorization()
    }

    func requestMotionAuthorization() {
        guard CMMotionActivityManager.isActivityAvailable() else {
            onStatusChange?()
            return
        }

        let endDate = Date()
        let startDate = endDate.addingTimeInterval(-60)
        motionActivityManager.queryActivityStarting(from: startDate, to: endDate, to: .main) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.onStatusChange?()
            }
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onStatusChange?()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
