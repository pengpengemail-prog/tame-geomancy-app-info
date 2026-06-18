import SwiftUI
import StoreKit

struct PremiumUnlockView: View {
    @EnvironmentObject private var premiumAccessStore: PremiumAccessStore

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                heroSection
                benefitsSection
                planSection
                supportSection
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 24)
        }
        .navigationTitle(TAMEL10n.text("高级解锁", "Premium Access"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if premiumAccessStore.products.isEmpty {
                await premiumAccessStore.refresh()
            }
        }
        .alert(
            TAMEL10n.text("解锁提示", "Unlock Notice"),
            isPresented: Binding(
                get: { premiumAccessStore.errorMessage != nil || premiumAccessStore.actionMessage != nil },
                set: { newValue in
                    if !newValue {
                        premiumAccessStore.clearMessages()
                    }
                }
            )
        ) {
            Button(TAMEL10n.text("明白", "Got It"), role: .cancel) {
                premiumAccessStore.clearMessages()
            }
        } message: {
            Text(premiumAccessStore.errorMessage ?? premiumAccessStore.actionMessage ?? "")
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                TAMEFeatureBadge(icon: "sparkles", accentIcon: "crown.fill", tint: TAMETheme.stardustGold, size: 58)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Text("00")
                            .font(.caption2.weight(.medium))
                            .foregroundColor(TAMETheme.stardustGold)

                        Rectangle()
                            .fill(TAMETheme.stardustGold.opacity(0.28))
                            .frame(width: 34, height: 1)
                    }

                    Text(premiumAccessStore.paywallTitle)
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(premiumAccessStore.paywallSubtitle)
                        .font(.callout)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .lineSpacing(3)
                }
            }

            LazyVGrid(columns: heroColumns, spacing: 10) {
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("当前状态", "Current Status"),
                    value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("免费版", "Free"),
                    symbol: premiumAccessStore.hasPremiumAccess ? "checkmark.seal.fill" : "sparkles",
                    note: TAMEL10n.text("使用权限", "Access"),
                    tint: premiumAccessStore.hasPremiumAccess ? TAMETheme.stardustGold : TAMETheme.techGray
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("当前方案", "Current Plan"),
                    value: premiumAccessStore.activePlanTitle,
                    symbol: "creditcard.fill",
                    note: TAMEL10n.text("App Store 购买", "App Store billing"),
                    tint: TAMETheme.stardustGold
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("解锁方式", "Unlock Type"),
                    value: TAMEL10n.text("订阅制", "Subscription"),
                    symbol: "arrow.triangle.2.circlepath",
                    note: TAMEL10n.text("月 / 年可选", "Monthly / yearly"),
                    tint: TAMETheme.stardustGold
                )
            }

            Text(premiumAccessStore.accessSummary)
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 28, emphasized: true, shadow: true)
    }

    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("解锁内容", "Unlocked Features"), accent: "01")

            ForEach(premiumAccessStore.premiumBenefits) { benefit in
                HStack(alignment: .top, spacing: 12) {
                    TAMEFeatureBadge(icon: "sparkles", accentIcon: "star.fill", tint: TAMETheme.stardustGold, size: 44)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(benefit.localizedTitle)
                            .font(.headline.weight(.medium))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Text(benefit.localizedSummary)
                            .font(.footnote)
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .tameInstrumentCard(cornerRadius: 18, shadow: false)
            }
        }
    }

    private var planSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("解锁方案", "Unlock"), accent: "02")

            if premiumAccessStore.isLoadingProducts && premiumAccessStore.planCards.allSatisfy({ $0.product == nil }) {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .tint(TAMETheme.stardustGold)
            }

            ForEach(premiumAccessStore.planCards) { plan in
                planCard(plan)
            }

            HStack(spacing: 12) {
                Button(TAMEL10n.text("恢复购买", "Restore Purchases")) {
                    Task {
                        await premiumAccessStore.restorePurchases()
                    }
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())

                Button(TAMEL10n.text("刷新价格", "Refresh Products")) {
                    Task {
                        await premiumAccessStore.refresh()
                    }
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
            }

            Text(TAMEL10n.text("这是自动续期订阅，通过 App Store 管理。基准价为按月 US$2.99、按年 US$14.99（含 3 天免费试用）。付费将在确认购买时计入 Apple ID，并在每个周期结束前 24 小时自动续期，除非提前关闭。年订阅试用期结束后才会扣费。你可随时在「设置 › Apple ID › 订阅」中管理或取消，取消于当前周期结束后生效。实际价格以你设备所在 App Store 商店页为准。", "This is an auto-renewing subscription managed by the App Store. Baseline pricing is US$2.99/month and US$14.99/year (with a 3-day free trial). Payment is charged to your Apple ID at confirmation and renews 24 hours before each period ends unless turned off. The yearly trial is charged only after it ends. Manage or cancel anytime in Settings › Apple ID › Subscriptions; cancellation takes effect at the end of the current period. Final pricing follows the storefront on your device."))
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)
        }
    }

    private func planCard(_ plan: TAMEPremiumUnlockCard) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                TAMEFeatureBadge(
                    icon: plan.isActive ? "checkmark.seal.fill" : "sparkles",
                    accentIcon: plan.isActive ? "lock.open.fill" : "creditcard.fill",
                    tint: TAMETheme.stardustGold,
                    size: 46
                )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                    Text(plan.title)
                            .font(.headline.weight(.medium))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        if let highlightText = plan.highlightText {
                            Text(highlightText)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(TAMETheme.stardustGold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(TAMETheme.stardustGold.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    Text(plan.priceText)
                        .font(.title2.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(plan.billingText)
                        .font(.footnote)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                }

                Spacer()

                if plan.isActive {
                    Text(TAMEL10n.text("当前", "Active"))
                        .font(.caption2.weight(.medium))
                        .foregroundColor(TAMETheme.stardustGold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(TAMETheme.stardustGold.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Text(plan.unlockNoteText)
                .font(.footnote.weight(.medium))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Group {
                if plan.isActive {
                    Button(TAMEL10n.text("已在使用", "Currently Active")) {
                        Task {
                            await premiumAccessStore.purchase(plan: plan)
                        }
                    }
                    .buttonStyle(TAMESecondaryActionButtonStyle())
                } else {
                    Button(TAMEL10n.text("继续", "Continue")) {
                        Task {
                            await premiumAccessStore.purchase(plan: plan)
                        }
                    }
                    .buttonStyle(TAMEPrimaryActionButtonStyle())
                }
            }
            .frame(maxWidth: .infinity)
            .disabled(plan.isActive || premiumAccessStore.purchasingProductID == plan.id)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 22, shadow: false)
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("解锁说明", "Unlock Notes"), accent: "03")

            NavigationLink(destination: TermsOfUseView()) {
                supportRow(
                    title: TAMEL10n.text("使用条款", "Terms of Use"),
                    subtitle: TAMEL10n.text("查看解锁相关说明与产品定位", "Review terms related to unlock and product positioning."),
                    symbol: "doc.text"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: PrivacyPolicyView()) {
                supportRow(
                    title: TAMEL10n.text("隐私政策", "Privacy Policy"),
                    subtitle: TAMEL10n.text("查看本地数据、权限与解锁相关说明", "Review local-data, permission, and unlock-related details."),
                    symbol: "hand.raised"
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func supportRow(title: String, subtitle: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(TAMETheme.stardustGold.opacity(0.10))

                Image(systemName: symbol)
                    .font(.callout.weight(.medium))
                    .foregroundColor(TAMETheme.stardustGold)
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.medium))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.caption.weight(.medium))
                .foregroundColor(TAMETheme.brandTextMuted)
        }
        .padding(16)
        .tameInstrumentCard(cornerRadius: 18, shadow: false)
    }

    private func sectionHeading(title: String, accent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accent)
                .font(.caption2.weight(.medium))
                .foregroundColor(TAMETheme.stardustGold)

            HStack(spacing: 12) {
                Text(title)
                    .font(.title3.weight(.medium))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.14))
                    .frame(height: 1)
            }
        }
    }

    private var heroColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }
}

struct PremiumAccessInlineCard: View {
    @EnvironmentObject private var premiumAccessStore: PremiumAccessStore
    let title: String
    let summary: String
    let actionTitle: String

    var body: some View {
        NavigationLink(destination: PremiumUnlockView()) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    TAMEFeatureBadge(icon: "sparkles", accentIcon: "star.fill", tint: TAMETheme.stardustGold, size: 54)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline.weight(.medium))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Text(summary)
                            .font(.footnote)
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                HStack {
                    Text(premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : actionTitle)
                        .font(.footnote.weight(.medium))
                        .foregroundColor(premiumAccessStore.hasPremiumAccess ? TAMETheme.stardustGold : TAMETheme.brandTextPrimary)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextMuted)
                }
            }
            .padding(18)
            .tameInstrumentCard(cornerRadius: 20, shadow: false)
        }
        .buttonStyle(.plain)
    }
}

struct PremiumUnlockView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PremiumUnlockView()
                .environmentObject(PremiumAccessStore())
        }
    }
}
