import SwiftUI

struct ContentView: View {
    @State private var selectedTab: RootTab = .overview
    @State private var pendingLaunchRoute: AppDeepLinkRoute?
    private let initialAnalysisDestination: AnalysisDeepLinkDestination?
    private let initialRecordsDestination: RecordsDeepLinkDestination?
    private let initialSettingsDestination: SettingsDeepLinkDestination?
    private let tabItems: [RootTab] = [.overview, .compass, .analysis, .records, .settings]

    init(launchRoute: AppDeepLinkRoute? = nil) {
        switch launchRoute {
        case .tab(let target):
            _selectedTab = State(initialValue: target)
            _pendingLaunchRoute = State(initialValue: nil)
            initialAnalysisDestination = nil
            initialRecordsDestination = nil
            initialSettingsDestination = nil
        case .analysis(let destination):
            _selectedTab = State(initialValue: .analysis)
            _pendingLaunchRoute = State(initialValue: nil)
            initialAnalysisDestination = destination
            initialRecordsDestination = nil
            initialSettingsDestination = nil
        case .records(let destination):
            _selectedTab = State(initialValue: .records)
            _pendingLaunchRoute = State(initialValue: nil)
            initialAnalysisDestination = nil
            initialRecordsDestination = destination
            initialSettingsDestination = nil
        case .settings(let destination):
            _selectedTab = State(initialValue: .settings)
            _pendingLaunchRoute = State(initialValue: nil)
            initialAnalysisDestination = nil
            initialRecordsDestination = nil
            initialSettingsDestination = destination
        case nil:
            _pendingLaunchRoute = State(initialValue: nil)
            initialAnalysisDestination = nil
            initialRecordsDestination = nil
            initialSettingsDestination = nil
        }
    }

    var body: some View {
        currentTabView
            .tint(TAMETheme.stardustGold)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                brandTabBar
            }
            .background(TAMETheme.pageBackground.ignoresSafeArea())
            .onOpenURL { url in
                guard let route = AppDeepLinkRoute(url: url) else { return }
                handle(route)
            }
            .environment(\.tameActiveTab, selectedTab)
            .onAppear {
                if let route = pendingLaunchRoute {
                    handle(route)
                    pendingLaunchRoute = nil
                }
            }
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch selectedTab {
        case .overview:
            OverviewDashboardView(selectedTab: $selectedTab)
        case .compass:
            CompassView()
        case .analysis:
            AnalysisHubView(initialDestination: initialAnalysisDestination)
        case .records:
            RecordsView(initialDestination: initialRecordsDestination)
        case .settings:
            SettingsView(initialDestination: initialSettingsDestination)
        }
    }

    private var brandTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabItems, id: \.self) { tab in
                Button(action: { selectedTab = tab }) {
                    VStack(spacing: 7) {
                        Rectangle()
                            .fill(selectedTab == tab ? TAMETheme.stardustGold : Color.clear)
                            .frame(width: 28, height: 2)

                        Image(systemName: tab.systemImage)
                            .font(.system(size: 19, weight: selectedTab == tab ? .medium : .regular, design: .rounded))
                            .foregroundColor(selectedTab == tab ? TAMETheme.stardustGold : TAMETheme.brandTextPrimary)

                        Text(tab.title)
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(selectedTab == tab ? TAMETheme.stardustGold : TAMETheme.brandTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(TAMETheme.pageBackground)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(TAMETheme.brandHairline.opacity(0.7))
                .frame(height: 0.8)
        }
    }

    private func handle(_ route: AppDeepLinkRoute) {
        switch route {
        case .tab(let target):
            selectedTab = target
        case .analysis(let destination):
            selectedTab = .analysis
            dispatchDeepLinkNotification(name: .tameOpenAnalysisDestination, object: destination.rawValue)
        case .records(let destination):
            selectedTab = .records
            dispatchDeepLinkNotification(name: .tameOpenRecordsDestination, object: destination.rawValue)
        case .settings(let destination):
            selectedTab = .settings
            dispatchDeepLinkNotification(name: .tameOpenSettingsDestination, object: destination.rawValue)
        }
    }

    private func dispatchDeepLinkNotification(name: Notification.Name, object: String) {
        let dispatchDelays: [Double] = [0.12, 0.45, 0.9]

        for delay in dispatchDelays {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                NotificationCenter.default.post(name: name, object: object)
            }
        }
    }
}

private struct TAMEActiveTabKey: EnvironmentKey {
    static let defaultValue: RootTab = .overview
}

extension EnvironmentValues {
    var tameActiveTab: RootTab {
        get { self[TAMEActiveTabKey.self] }
        set { self[TAMEActiveTabKey.self] = newValue }
    }
}

enum RootTab: Hashable {
    case overview
    case compass
    case analysis
    case records
    case settings

    init?(url: URL) {
        guard url.scheme?.lowercased() == "tamegeomancy" else { return nil }
        let components = url.pathComponents.filter { $0 != "/" }

        if url.host == "tab", let name = components.first {
            self.init(rawValue: name)
            return
        }

        if components.count >= 2, components[0] == "tab" {
            self.init(rawValue: components[1])
            return
        }

        return nil
    }

    init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "overview":
            self = .overview
        case "compass":
            self = .compass
        case "analysis":
            self = .analysis
        case "records":
            self = .records
        case "settings":
            self = .settings
        default:
            return nil
        }
    }
}

private extension RootTab {
    var title: String {
        switch self {
        case .overview:
            return TAMEL10n.text("总览", "Overview")
        case .compass:
            return TAMEL10n.text("罗盘", "Compass")
        case .analysis:
            return TAMEL10n.text("分析", "Analysis")
        case .records:
            return TAMEL10n.text("记录", "Records")
        case .settings:
            return TAMEL10n.text("设置", "Settings")
        }
    }

    var systemImage: String {
        switch self {
        case .overview:
            return "square.grid.2x2"
        case .compass:
            return "location.circle"
        case .analysis:
            return "chart.bar"
        case .records:
            return "folder"
        case .settings:
            return "gearshape"
        }
    }
}

enum AppDeepLinkRoute: Equatable {
    case tab(RootTab)
    case analysis(AnalysisDeepLinkDestination)
    case records(RecordsDeepLinkDestination)
    case settings(SettingsDeepLinkDestination)

    init?(url: URL) {
        guard url.scheme?.lowercased() == "tamegeomancy" else { return nil }

        let components = url.pathComponents.filter { $0 != "/" }
        let host = url.host?.lowercased()

        if let host, components.isEmpty, let target = RootTab(rawValue: host) {
            self = .tab(target)
            return
        }

        switch host {
        case "tab":
            guard let name = components.first, let target = RootTab(rawValue: name) else { return nil }
            self = .tab(target)
        case "analysis":
            guard let name = components.first,
                  let destination = AnalysisDeepLinkDestination(rawValue: name) else { return nil }
            self = .analysis(destination)
        case "records":
            guard let name = components.first,
                  let destination = RecordsDeepLinkDestination(rawValue: name) else { return nil }
            self = .records(destination)
        case "settings":
            guard let name = components.first,
                  let destination = SettingsDeepLinkDestination(rawValue: name) else { return nil }
            self = .settings(destination)
        default:
            if components.count >= 2, components[0] == "tab", let target = RootTab(rawValue: components[1]) {
                self = .tab(target)
            } else if components.count >= 2, components[0] == "analysis", let destination = AnalysisDeepLinkDestination(rawValue: components[1]) {
                self = .analysis(destination)
            } else if components.count >= 2, components[0] == "records", let destination = RecordsDeepLinkDestination(rawValue: components[1]) {
                self = .records(destination)
            } else if components.count >= 2, components[0] == "settings", let destination = SettingsDeepLinkDestination(rawValue: components[1]) {
                self = .settings(destination)
            } else {
                return nil
            }
        }
    }
}

enum AnalysisDeepLinkDestination: String, CaseIterable {
    case orientation
    case orientationDemo = "orientation-demo"
    case yangGongFenjin = "yanggong-fenjin"
    case jiuyun
    case flyingStar = "flying-star"
    case flyingStarDemo = "flying-star-demo"
    case annual
    case annualDemo = "annual-demo"
    case floorPlan = "floor-plan"
    case floorPlanDemo = "floor-plan-demo"
    case bazhai
    case bazhaiSmoke = "bazhai-smoke"
    case reference
}

extension AnalysisDeepLinkDestination: Identifiable {
    var id: String { rawValue }
}

enum RecordsDeepLinkDestination: String, CaseIterable {
    case list
    case bazhaiList = "bazhai-list"
    case sharePreview = "share-preview"
}

enum SettingsDeepLinkDestination: String, CaseIterable {
    case permissions
    case backupExport = "backup-export"
    case backupImport = "backup-import"
    case premium
    case privacyPolicy = "privacy-policy"
    case termsOfUse = "terms-of-use"
    case support = "support"
}

extension Notification.Name {
    static let tameOpenAnalysisDestination = Notification.Name("tame.open.analysis.destination")
    static let tameOpenRecordsDestination = Notification.Name("tame.open.records.destination")
    static let tameOpenSettingsDestination = Notification.Name("tame.open.settings.destination")
}

enum AppLaunchRouteResolver {
    static func resolve(processInfo: ProcessInfo = .processInfo) -> AppDeepLinkRoute? {
        resolve(arguments: processInfo.arguments, environment: processInfo.environment)
    }

    static func resolve(arguments: [String], environment: [String: String]) -> AppDeepLinkRoute? {
        if let optionIndex = arguments.firstIndex(of: "-TAMELaunchRoute") {
            let nextIndex = arguments.index(after: optionIndex)
            if nextIndex < arguments.endIndex,
               let route = parseRoute(arguments[nextIndex]) {
                return route
            }
        }

        if let optionIndex = arguments.firstIndex(of: "--tame-launch-route") {
            let nextIndex = arguments.index(after: optionIndex)
            if nextIndex < arguments.endIndex,
               let route = parseRoute(arguments[nextIndex]) {
                return route
            }
        }

        if let inlineOption = arguments.first(where: { $0.hasPrefix("--tame-launch-route=") }) {
            let value = String(inlineOption.dropFirst("--tame-launch-route=".count))
            if let route = parseRoute(value) {
                return route
            }
        }

        if let environmentValue = environment["TAME_LAUNCH_ROUTE"],
           let route = parseRoute(environmentValue) {
            return route
        }

        return nil
    }

    private static func parseRoute(_ rawValue: String) -> AppDeepLinkRoute? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed) else { return nil }
        return AppDeepLinkRoute(url: url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
