import SwiftUI
import UIKit

@main
struct TAMEGeomancyApp: App {
    @AppStorage("appAppearance") private var appAppearance = AppAppearance.system.rawValue
    @AppStorage(TAMEL10n.userDefaultsKey) private var localeOverride = TAMEAppLocale.zhHans.rawValue
    @StateObject private var premiumAccessStore = PremiumAccessStore()

    init() {
        configureTabBarAppearance()
    }

    private var resolvedAppearance: AppAppearance {
        AppAppearance(rawValue: appAppearance) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView(launchRoute: AppLaunchRouteResolver.resolve())
                .preferredColorScheme(resolvedAppearance.colorScheme)
                .id(localeOverride)
                .environmentObject(premiumAccessStore)
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.white
        appearance.backgroundEffect = nil
        appearance.shadowColor = UIColor(TAMETheme.deepBlueBlack.opacity(0.08))

        let normalColor = UIColor(TAMETheme.deepBlueBlack.opacity(0.7))
        let selectedColor = UIColor(TAMETheme.stardustGold)
        let normalAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: normalColor
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11, weight: .bold),
            .foregroundColor: selectedColor
        ]

        [appearance.stackedLayoutAppearance, appearance.inlineLayoutAppearance, appearance.compactInlineLayoutAppearance].forEach { layout in
            layout.normal.iconColor = normalColor
            layout.normal.titleTextAttributes = normalAttributes
            layout.selected.iconColor = selectedColor
            layout.selected.titleTextAttributes = selectedAttributes
        }

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = normalColor
    }
}
