import SwiftUI
import UIKit

private struct PolicySectionData: Identifiable {
    let id = UUID()
    let title: String
    let paragraphs: [String]
}

private struct PolicyDocumentView: View {
    let title: String
    let subtitle: String
    let sections: [PolicySectionData]
    let footer: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard

                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 8) {
                            Text(String(format: "%02d", index + 1))
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.stardustGold)

                            Rectangle()
                                .fill(TAMETheme.stardustGold.opacity(0.18))
                                .frame(width: 22, height: 1)
                        }

                        Text(section.title)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        ForEach(section.paragraphs, id: \.self) { paragraph in
                            Text(paragraph)
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .tameInstrumentCard(cornerRadius: 20, shadow: false)
                }

                if let footer, !footer.isEmpty {
                    Text(footer)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                }
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 24)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading(title: title, accent: "00")
            Text(subtitle)
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
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
}

struct PrivacyPolicyView: View {
    private var sections: [PolicySectionData] {
        [
            PolicySectionData(
                title: TAMEL10n.text("概述", "Overview"),
                paragraphs: [
                    TAMEL10n.text("TAME Space Compass（探觅·空间罗盘）是一款离线运行的空间参考工具，用于查看罗盘坐向、开口参考、九宫布局、户型分析与空间方向建议。", "TAME Space Compass is an offline spatial-reference utility for compass readings, opening review, nine-grid layouts, floor-plan analysis, and directional suggestions."),
                    TAMEL10n.text("我们尽量减少数据收集与传输，当前版本不要求注册账号，也不以内建方式上传分析记录。", "We keep data collection and transmission to a minimum. The current release does not require sign-in and does not upload analysis records by default.")
                ]
            ),
            PolicySectionData(
                title: TAMEL10n.text("数据与本地存储", "Local Storage"),
                paragraphs: [
                    TAMEL10n.text("户型图、分析记录、用户备注与方向数据默认仅保存在设备本地。", "Floor-plan images, analysis records, notes, and directional data are stored on your device by default."),
                    TAMEL10n.text("只有在你主动打开系统分享面板时，相关内容才会由 iOS 分享机制发送到你选择的目标应用或服务。", "Content is only passed to another app or service when you explicitly open the system share sheet and choose a destination.")
                ]
            ),
            PolicySectionData(
                title: TAMEL10n.text("权限用途", "Permissions"),
                paragraphs: [
                    TAMEL10n.text("定位：用于真北校正，可选开启。", "Location: optional, used for true-north correction."),
                    TAMEL10n.text("运动与方向：用于罗盘方向与姿态测量。", "Motion and direction: used for compass heading and posture measurement."),
                    TAMEL10n.text("相机与相册：用于导入户型图与保存分享图。", "Camera and Photos: used to import floor plans and save shared reports.")
                ]
            ),
            PolicySectionData(
                title: TAMEL10n.text("第三方服务", "Third-Party Services"),
                paragraphs: [
                    TAMEL10n.text("当前版本不包含第三方登录、广告组件、在线支付或行为追踪组件。", "The current release does not include third-party sign-in, ad components, online payments, or behavior-tracking components."),
                    TAMEL10n.text("如果未来接入新的外部服务，相关说明会在应用内同步更新。", "If new external services are added in the future, the related explanations will be updated inside the app.")
                ]
            )
        ]
    }

    var body: some View {
        PolicyDocumentView(
            title: TAMEL10n.text("隐私政策", "Privacy Policy"),
            subtitle: TAMEL10n.text("当前版本以本地使用为主，尽量减少数据上传与外部依赖。", "This release is designed for local use first, with minimal data transfer and external dependency."),
            sections: sections,
            footer: TAMEL10n.text("如你使用系统分享功能，相关内容只会按你的选择发送到目标应用或服务。", "When you use the system share feature, content is sent only to the app or service you choose.")
        )
    }
}

struct TermsOfUseView: View {
    private var sections: [PolicySectionData] {
        [
            PolicySectionData(
                title: TAMEL10n.text("产品定位", "Product Positioning"),
                paragraphs: [
                    TAMEL10n.text("本应用为民俗文化参考工具，用于方位查看、九宫布局整理、户型分析记录与空间方向建议。", "This app is a cultural-reference utility for directional review, nine-grid layouts, floor-plan notes, and spatial suggestions."),
                    TAMEL10n.text("本应用不提供医疗、金融、法律或命运保证，不构成改运、财富或收益承诺。", "It does not provide medical, financial, legal, or destiny guarantees, and it does not promise fortune, wealth, or returns.")
                ]
            ),
            PolicySectionData(
                title: TAMEL10n.text("使用限制", "Use Restrictions"),
                paragraphs: [
                    TAMEL10n.text("不得将本应用用于违法活动、欺诈宣传、医疗诊断替代、金融投资保证或任何需要确定性专业结论的场景。", "The app must not be used for illegal activity, deceptive promotion, replacement of medical diagnosis, investment guarantees, or any scenario that requires deterministic professional conclusions."),
                    TAMEL10n.text("用户应结合采光、通风、安全、结构与居住舒适度进行综合判断。", "Users should make decisions together with daylight, ventilation, safety, structure, and living comfort.")
                ]
            ),
            PolicySectionData(
                title: TAMEL10n.text("用户内容", "User Content"),
                paragraphs: [
                    TAMEL10n.text("用户导入的户型图、备注和分析记录默认保存在本地。", "Imported floor plans, notes, and analysis records are stored locally by default."),
                    TAMEL10n.text("用户应自行确保其导入内容的合法使用权。", "Users are responsible for ensuring they have the lawful right to use imported content.")
                ]
            ),
            PolicySectionData(
                title: TAMEL10n.text("免责声明", "Disclaimer"),
                paragraphs: [
                    TAMEL10n.text("本应用内容仅为民俗文化参考，非科学依据，不构成任何现实承诺。", "All content is provided as cultural reference only, is not scientific evidence, and does not constitute real-world guarantees."),
                    TAMEL10n.text("部分功能与说明会随版本迭代持续调整，请以应用内最新页面为准。", "Some features and explanations may continue to evolve with later releases, so please refer to the latest pages inside the app.")
                ]
            )
        ]
    }

    var body: some View {
        PolicyDocumentView(
            title: TAMEL10n.text("使用条款", "Terms of Use"),
            subtitle: TAMEL10n.text("请将应用作为文化与空间参考工具使用，而非确定性专业建议。", "Use the app as a cultural and spatial reference tool rather than a source of deterministic professional advice."),
            sections: sections,
            footer: TAMEL10n.text("请结合采光、通风、安全、结构与居住舒适度进行综合判断。", "Please make decisions together with daylight, ventilation, safety, structure, and living comfort.")
        )
    }
}

struct SupportCenterView: View {
    @State private var mailStatusMessage: String?

    private let supportEmail = "pengpengemail@gmail.com"

    private var checks: [SupportChecklistItem] {
        [
            .init(
                index: "01.1",
                zhTitle: "使用罗盘时",
                enTitle: "When using the compass",
                zhSummary: "确认远离大块金属、电梯井、强磁设备，并尽量保持设备水平。",
                enSummary: "Stay away from large metal objects, elevator shafts, and strong magnetic devices, and keep the phone as level as possible."
            ),
            .init(
                index: "01.2",
                zhTitle: "需要真北时",
                enTitle: "When you need true north",
                zhSummary: "如果需要真北，请先确认定位权限已开启；不开启定位时应用仍可按磁北工作。",
                enSummary: "If you need true north, confirm location access first. The app still works with magnetic north when location is off."
            ),
            .init(
                index: "01.3",
                zhTitle: "导入户型前",
                enTitle: "Before importing a floor plan",
                zhSummary: "优先准备轮廓清晰的户型图，并在立极点、大门、阳台、主窗位置做准确标记。",
                enSummary: "Prepare a clear floor plan and mark the center point, main door, balcony, and major windows as accurately as possible."
            )
        ]
    }

    private var faqs: [SupportFAQ] {
        [
            .init(
                index: "02.1",
                zhQuestion: "为什么罗盘角度会跳动？",
                enQuestion: "Why does the compass jump?",
                zhAnswer: "通常和磁场干扰、金属环境、电梯井、设备姿态变化或真北校正尚未稳定有关。",
                enAnswer: "This is usually caused by magnetic interference, nearby metal, elevator shafts, posture changes, or true-north correction that has not stabilized yet."
            ),
            .init(
                index: "02.2",
                zhQuestion: "不开定位还能用吗？",
                enQuestion: "Can I use it without location access?",
                zhAnswer: "可以。不开定位时应用仍可按磁北工作，只是不会做真北校正。",
                enAnswer: "Yes. The app still works with magnetic north; it simply skips true-north correction."
            ),
            .init(
                index: "02.3",
                zhQuestion: "户型图会上传吗？",
                enQuestion: "Are floor plans uploaded?",
                zhAnswer: "不会。当前版本默认本地使用，只有你主动打开系统分享面板时内容才会离开设备。",
                enAnswer: "No. This release is local-first, and content leaves the device only when you explicitly use the system share sheet."
            ),
            .init(
                index: "02.4",
                zhQuestion: "保存到相册失败怎么办？",
                enQuestion: "What if saving to Photos fails?",
                zhAnswer: "请先检查“添加到照片”权限是否开启；如果系统权限受限，也可能导致保存失败。",
                enAnswer: "Check whether Add to Photos permission is enabled. Saving may also fail when system access is restricted."
            )
        ]
    }

    private var contactTips: [String] {
        [
            TAMEL10n.text("如果罗盘读数看起来不稳定，可说明当时的大致环境，例如是否靠近金属、电梯或其他可能影响磁场的设备。", "If the compass reading feels unstable, describe the surrounding environment, such as whether you were near metal, elevators, or other devices that may affect the magnetic field."),
            TAMEL10n.text("如果是户型分析结果与预期不一致，可简单说明导入方式，以及你认为偏差最明显的位置。", "If a floor-plan result does not match your expectation, briefly describe how the plan was imported and where the mismatch feels most obvious."),
            TAMEL10n.text("如果是分享、保存图片或权限相关问题，可补充大致操作步骤，以及系统当时弹出的提示内容。", "For sharing, image saving, or permission-related issues, include the approximate steps you took and any system prompts that appeared.")
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard

                if let mailStatusMessage {
                    Text(mailStatusMessage)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 8)
                }

                supportContactCard
                checklistSection
                faqSection
                issueReportSection

                Text(TAMEL10n.text("如需反馈问题，建议附上设备型号、系统版本和复现步骤，方便更快定位。", "When reporting an issue, include the device model, system version, and reproduction steps so it can be checked faster."))
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 8)
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 24)
        }
        .navigationTitle(TAMEL10n.text("支持与帮助", "Support"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeading(title: TAMEL10n.text("支持中心", "Support Center"), accent: "00")

            Text(TAMEL10n.text("这里集中放常见问题、使用建议与联系入口，方便在日常使用中快速找到帮助。", "This page brings together common questions, usage tips, and contact access so you can find help more easily during everyday use."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                supportPill(
                    title: TAMEL10n.text("检查清单", "Checklist"),
                    value: "\(checks.count)",
                    tint: TAMETheme.stardustGold
                )
                supportPill(
                    title: TAMEL10n.text("常见问题", "FAQs"),
                    value: "\(faqs.count)",
                    tint: TAMETheme.techGray
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private var supportContactCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("联系支持", "Contact Support"), accent: "01")

            metricRow(index: "01", title: TAMEL10n.text("支持邮箱", "Support Email"), value: supportEmail)

            Text(TAMEL10n.text("若需要人工支持，可通过系统邮件联系。来信时建议附上设备型号、系统版本与问题出现步骤。", "If you need direct help, you can contact support through the system Mail app. It helps to include the device model, system version, and the steps that led to the issue."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Button(action: openSupportMail) {
                Text(TAMEL10n.text("打开邮件联系支持", "Email Support"))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(TAMESecondaryActionButtonStyle())
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private var checklistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("使用建议", "Usage Tips"), accent: "02")

            ForEach(checks) { item in
                supportNoteCard(index: item.index, title: item.localizedTitle, body: item.localizedSummary)
            }
        }
    }

    private var faqSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("常见问题", "Common Questions"), accent: "03")

            ForEach(faqs) { item in
                VStack(alignment: .leading, spacing: 8) {
                    indexRow(item.index)

                    Text(item.localizedQuestion)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(item.localizedAnswer)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .tameInstrumentCard(cornerRadius: 20, shadow: false)
            }
        }
    }

    private var issueReportSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("反馈时可说明", "Helpful Details"), accent: "04")

            ForEach(Array(contactTips.enumerated()), id: \.offset) { index, tip in
                supportNoteCard(
                    index: String(format: "04.%d", index + 1),
                    title: TAMEL10n.text("说明现场情况", "Context to Share"),
                    body: tip
                )
            }
        }
    }

    private func supportNoteCard(index: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            indexRow(index)

            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(body)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 20, shadow: false)
    }

    private func openSupportMail() {
        guard let url = URL(string: "mailto:\(supportEmail)") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
            mailStatusMessage = nil
        } else {
            mailStatusMessage = TAMEL10n.text("当前设备没有可用的邮件应用，请检查系统邮件设置后再试。", "No available mail app was found on this device. Please check your Mail setup and try again.")
        }
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

    private func metricRow(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 24, alignment: .leading)

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

    private func supportPill(title: String, value: String, tint: Color) -> some View {
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
                .fill(tint.opacity(0.18))
                .frame(width: 22, height: 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .tameInstrumentCard(cornerRadius: 14, shadow: false)
    }

    private func indexRow(_ index: String) -> some View {
        HStack(spacing: 8) {
            Text(index)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.18))
                .frame(width: 22, height: 1)
        }
    }
}

private struct SupportChecklistItem: Identifiable {
    let id = UUID()
    let index: String
    let zhTitle: String
    let enTitle: String
    let zhSummary: String
    let enSummary: String

    var localizedTitle: String {
        TAMEL10n.text(zhTitle, enTitle)
    }

    var localizedSummary: String {
        TAMEL10n.text(zhSummary, enSummary)
    }
}

private struct SupportFAQ: Identifiable {
    let id = UUID()
    let index: String
    let zhQuestion: String
    let enQuestion: String
    let zhAnswer: String
    let enAnswer: String

    var localizedQuestion: String {
        TAMEL10n.text(zhQuestion, enQuestion)
    }

    var localizedAnswer: String {
        TAMEL10n.text(zhAnswer, enAnswer)
    }
}

struct PolicyCenterView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView { PrivacyPolicyView() }
            NavigationView { TermsOfUseView() }
            NavigationView { SupportCenterView() }
        }
    }
}
