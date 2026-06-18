import Foundation
import StoreKit

enum TAMEPremiumEntitlement: String, CaseIterable, Identifiable {
    case reportExport
    case reportSaveToPhotos
    case premiumStatus

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .reportExport:
            return TAMEL10n.text("报告分享", "Report Sharing")
        case .reportSaveToPhotos:
            return TAMEL10n.text("保存到相册", "Save to Photos")
        case .premiumStatus:
            return TAMEL10n.text("高级会员身份", "Premium Membership")
        }
    }

    var localizedSummary: String {
        switch self {
        case .reportExport:
            return TAMEL10n.text("导出更完整的图文报告并调起系统分享。", "Export richer image-based reports and share them through the system sheet.")
        case .reportSaveToPhotos:
            return TAMEL10n.text("将品牌化分析报告直接保存到系统相册。", "Save branded analysis reports directly to Photos.")
        case .premiumStatus:
            return TAMEL10n.text("订阅期间解锁报告分享与保存到相册能力。", "Unlock report sharing and save-to-Photos access while subscribed.")
        }
    }
}

enum TAMEPremiumUnlockKind: String, CaseIterable, Identifiable {
    case monthly
    case yearly
    case lifetime // legacy one-time unlock: still honored, no longer sold

    var id: String { rawValue }

    /// Plans actually offered for purchase in the paywall.
    static var purchasableCases: [TAMEPremiumUnlockKind] { [.monthly, .yearly] }

    var productID: String {
        switch self {
        case .monthly:
            return "com.tame.geomancy.premium.monthly2"
        case .yearly:
            return "com.tame.geomancy.premium.yearly2"
        case .lifetime:
            return "com.tame.geomancy.premium.lifetime"
        }
    }

    var localizedTitle: String {
        switch self {
        case .monthly:
            return TAMEL10n.text("按月订阅", "Monthly")
        case .yearly:
            return TAMEL10n.text("按年订阅", "Yearly")
        case .lifetime:
            return TAMEL10n.text("永久解锁", "Lifetime Unlock")
        }
    }

    var localizedBillingSummary: String {
        switch self {
        case .monthly:
            return TAMEL10n.text("按月自动续期，可随时取消", "Auto-renews monthly, cancel anytime")
        case .yearly:
            return TAMEL10n.text("含 3 天免费试用，之后按年自动续期", "3-day free trial, then auto-renews yearly")
        case .lifetime:
            return TAMEL10n.text("一次购买，永久使用", "One purchase, permanent access")
        }
    }

    var fallbackPriceText: String {
        switch self {
        case .monthly:
            return TAMEL10n.text("App Store 定价 / 月", "App Store pricing / mo")
        case .yearly:
            return TAMEL10n.text("App Store 定价 / 年", "App Store pricing / yr")
        case .lifetime:
            return TAMEL10n.text("App Store 定价", "App Store pricing")
        }
    }

    var recommended: Bool {
        self == .yearly
    }
}

struct TAMEPremiumUnlockCard: Identifiable {
    let id: String
    let kind: TAMEPremiumUnlockKind
    let title: String
    let priceText: String
    let billingText: String
    let unlockNoteText: String
    let highlightText: String?
    let product: Product?
    let isActive: Bool
}

@MainActor
final class PremiumAccessStore: ObservableObject {
    enum AccessState: Equatable {
        case loading
        case free
        case active(productID: String)
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var activeProductIDs: Set<String> = []
    @Published private(set) var accessState: AccessState = .loading
    @Published private(set) var isLoadingProducts = false
    @Published private(set) var isRefreshingEntitlements = false
    @Published private(set) var purchasingProductID: String?
    @Published private(set) var actionMessage: String?
    @Published private(set) var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    init() {
        updatesTask = observeTransactions()

        Task {
            await refresh()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    var hasPremiumAccess: Bool {
        !activeProductIDs.isEmpty
    }

    var activePlanTitle: String {
        guard let activeKind = activePlanKind else {
            return TAMEL10n.text("未解锁", "Not Unlocked")
        }

        return activeKind.localizedTitle
    }

    var accessSummary: String {
        if hasPremiumAccess {
            return TAMEL10n.text("已解锁报告导出与保存到相册能力。", "Report sharing and save-to-Photos features are unlocked.")
        }

        return TAMEL10n.text("可解锁报告导出与保存到相册能力。", "Unlock report sharing and save-to-Photos features.")
    }

    var paywallTitle: String {
        TAMEL10n.text("高级解锁", "Premium Access")
    }

    var paywallSubtitle: String {
        TAMEL10n.text("保留核心罗盘与分析体验，把报告导出与保存等专业输出能力放进高级订阅。", "Keep the core compass and analysis experience free, and unlock report export and save features with a premium subscription.")
    }

    var premiumBenefits: [TAMEPremiumEntitlement] {
        TAMEPremiumEntitlement.allCases
    }

    var planCards: [TAMEPremiumUnlockCard] {
        TAMEPremiumUnlockKind.purchasableCases.map { kind in
            if let product = products.first(where: { $0.id == kind.productID }) {
                return TAMEPremiumUnlockCard(
                    id: product.id,
                    kind: kind,
                    title: kind.localizedTitle,
                    priceText: product.displayPrice,
                    billingText: kind.localizedBillingSummary,
                    unlockNoteText: defaultUnlockNoteText(for: kind),
                    highlightText: kind.recommended ? TAMEL10n.text("更划算", "Best Value") : nil,
                    product: product,
                    isActive: activeProductIDs.contains(product.id)
                )
            }

            return TAMEPremiumUnlockCard(
                id: kind.productID,
                kind: kind,
                title: kind.localizedTitle,
                priceText: kind.fallbackPriceText,
                billingText: kind.localizedBillingSummary,
                unlockNoteText: defaultUnlockNoteText(for: kind),
                highlightText: kind.recommended ? TAMEL10n.text("更划算", "Best Value") : nil,
                product: nil,
                isActive: activeProductIDs.contains(kind.productID)
            )
        }
    }

    func refresh() async {
        await requestProducts()
        await refreshEntitlements()
    }

    func clearMessages() {
        actionMessage = nil
        errorMessage = nil
    }

    func purchase(plan: TAMEPremiumUnlockCard) async {
        guard let product = plan.product else {
            errorMessage = TAMEL10n.text("暂时还没有从 App Store 取到解锁商品，请稍后再试。", "The unlock product is not available from the App Store yet. Please try again shortly.")
            return
        }

        await purchase(product: product)
    }

    func purchase(product: Product) async {
        purchasingProductID = product.id
        actionMessage = nil
        errorMessage = nil

        defer {
            purchasingProductID = nil
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                actionMessage = TAMEL10n.text("高级解锁已完成。你现在可以导出并保存报告图片。", "Premium access is unlocked. You can now export and save report images.")
            case .pending:
                actionMessage = TAMEL10n.text("购买请求已提交，正在等待 App Store 确认。", "The purchase is pending App Store confirmation.")
            case .userCancelled:
                actionMessage = TAMEL10n.text("本次没有完成购买，你仍可继续浏览免费内容。", "No purchase was completed. You can continue using the free experience.")
            @unknown default:
                errorMessage = TAMEL10n.text("发生了未识别的购买结果，请稍后再试。", "An unknown purchase result occurred. Please try again.")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        actionMessage = nil
        errorMessage = nil

        do {
            try await AppStore.sync()
            await refreshEntitlements()

            if hasPremiumAccess {
                actionMessage = TAMEL10n.text("已恢复你的高级解锁。", "Your premium access has been restored.")
            } else {
                actionMessage = TAMEL10n.text("没有找到可恢复的高级解锁。", "No premium purchase was found to restore.")
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func requestProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let storeProducts = try await Product.products(for: TAMEPremiumUnlockKind.purchasableCases.map(\.productID))
            products = storeProducts
                .filter { $0.type == .autoRenewable || $0.type == .nonConsumable }
                .sorted { lhs, rhs in
                    let lhsRank = rank(for: lhs.id)
                    let rhsRank = rank(for: rhs.id)
                    return lhsRank < rhsRank
                }
        } catch {
            products = []
            errorMessage = error.localizedDescription
        }
    }

    private func refreshEntitlements() async {
        isRefreshingEntitlements = true
        defer { isRefreshingEntitlements = false }

        var collectedIDs = Set<String>()

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard TAMEPremiumUnlockKind.allCases.map(\.productID).contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }

            collectedIDs.insert(transaction.productID)
        }

        activeProductIDs = collectedIDs

        if let activeProductID = rankSortedActiveProductIDs.first {
            accessState = .active(productID: activeProductID)
        } else if isLoadingProducts {
            accessState = .loading
        } else {
            accessState = .free
        }
    }

    private var rankSortedActiveProductIDs: [String] {
        activeProductIDs.sorted { rank(for: $0) < rank(for: $1) }
    }

    private var activePlanKind: TAMEPremiumUnlockKind? {
        rankSortedActiveProductIDs.compactMap { productID in
            TAMEPremiumUnlockKind.allCases.first(where: { $0.productID == productID })
        }.first
    }

    private func rank(for productID: String) -> Int {
        switch productID {
        case TAMEPremiumUnlockKind.yearly.productID:
            return 0
        case TAMEPremiumUnlockKind.monthly.productID:
            return 1
        case TAMEPremiumUnlockKind.lifetime.productID:
            return 2
        default:
            return 99
        }
    }

    private func observeTransactions() -> Task<Void, Never> {
        Task.detached(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard let self else { break }

                if case .verified(let transaction) = result {
                    await transaction.finish()
                }

                await self.refreshEntitlements()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let signed):
            return signed
        case .unverified:
            throw StoreKitError.unknown
        }
    }

    private func defaultUnlockNoteText(for kind: TAMEPremiumUnlockKind) -> String {
        switch kind {
        case .monthly:
            return TAMEL10n.text("随时可在系统设置中取消", "Cancel anytime in Settings")
        case .yearly:
            return TAMEL10n.text("先免费试用 3 天，确认后才扣费", "Free for 3 days, charged only after trial")
        case .lifetime:
            return TAMEL10n.text("无周期扣费", "No recurring billing")
        }
    }
}
