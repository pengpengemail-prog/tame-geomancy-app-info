import SwiftUI

struct ReferenceKnowledgeView: View {
    @StateObject private var historyStore = HistoryStore.shared
    @State private var saveStatusMessage: String?

    private let principles: [ReferencePrinciple] = [
        .init(
            index: "01.1",
            zhTitle: "先看真实居住感受",
            enTitle: "Start with real living comfort",
            zhSummary: "优先观察采光、通风、噪音、私密性、安全感与视线压迫，再决定是否需要做民俗参考上的缓和处理。",
            enSummary: "Review daylight, ventilation, noise, privacy, safety, and visual pressure first before adding any space-reference adjustment."
        ),
        .init(
            index: "01.2",
            zhTitle: "只做观察，不做恐吓",
            enTitle: "Observe without fear framing",
            zhSummary: "本页只提供环境观察角度与传统名词解释，不给出绝对吉凶，也不鼓励夸张化表达。",
            enSummary: "This page explains observation angles and traditional terms only. It avoids absolute fortune claims and fear-based wording."
        ),
        .init(
            index: "01.3",
            zhTitle: "改善以空间设计为先",
            enTitle: "Prioritize spatial design",
            zhSummary: "如果某类外部环境确实带来干扰，优先从动线、遮挡、软装、灯光与界面层次入手，而不是依赖复杂摆设。",
            enSummary: "If an outside condition truly creates stress, start with circulation, screening, soft furnishing, lighting, and layered boundaries instead of complex objects."
        )
    ]

    private let references: [ReferenceEntry] = [
        .init(
            index: "02.1",
            zhTitle: "路冲",
            enTitle: "Road Rush",
            zhSummary: "道路或动线正对门窗时，民俗上常提醒关注来向过直的问题，现实里更应先看噪音、扬尘、夜间车灯与私密性。",
            enSummary: "When a road or traffic line points straight at an opening, the note usually points to direct exposure. In practice, check noise, dust, headlights, and privacy first.",
            zhFocus: "重点观察：门前是否缺少缓冲、是否有连续车流直射、夜晚灯光是否直接进入室内。",
            enFocus: "Observe whether the entrance lacks a buffer, whether traffic aligns directly toward it, and whether headlights enter the room at night.",
            zhAdjustment: "缓和建议：增加前场过渡、绿植或屏风层次，让入口先转折再进入主要居住空间。",
            enAdjustment: "Adjustment idea: add a front transition zone, planting, or a screen layer so circulation bends before reaching the main living area."
        ),
        .init(
            index: "02.2",
            zhTitle: "反弓",
            enTitle: "Reverse Bow",
            zhSummary: "道路、水体或建筑曲线向外甩离、内侧弧面压力较强时，传统上会参考为外势不稳，现实则要先看噪音和视觉压迫。",
            enSummary: "When a road, water line, or building curve throws outward and presses inward, tradition reads it as unstable outer momentum. In practice, start with noise and visual pressure.",
            zhFocus: "重点观察：弯道是否靠得过近、是否形成持续车流噪音、窗外画面是否让人长期紧张。",
            enFocus: "Review whether the bend sits too close, whether it creates continuous traffic noise, and whether the exterior view feels persistently tense.",
            zhAdjustment: "缓和建议：提高窗帘与植物的层次感，弱化外弧线的冲击，同时提升室内安定感。",
            enAdjustment: "Adjustment idea: use layered curtains and planting to soften the curve impact while improving calmness inside."
        ),
        .init(
            index: "02.3",
            zhTitle: "天斩",
            enTitle: "Sky Cut",
            zhSummary: "两栋高楼之间形成狭长缝隙时，民俗上常视作压迫感来源，现实中更值得看风口、采光反差与心理感受。",
            enSummary: "A narrow gap between tall buildings is often treated as a source of pressure in tradition. In practice, look at wind channels, daylight contrast, and psychological comfort.",
            zhFocus: "重点观察：缝隙是否正对主要窗景、是否带来强风、是否让室内长期偏暗。",
            enFocus: "Check whether the gap aligns with primary windows, brings strong wind, or keeps the interior overly dim.",
            zhAdjustment: "缓和建议：通过窗景组织、纱帘、暖光和家具重心重组，降低“被切开”的视觉感受。",
            enAdjustment: "Adjustment idea: reorganize the window view with sheers, warmer lighting, and stronger furniture anchors to reduce the split visual effect."
        ),
        .init(
            index: "02.4",
            zhTitle: "尖角",
            enTitle: "Sharp Corner",
            zhSummary: "邻近建筑、构筑物或景观硬角直指门窗时，传统上会提醒视线冲击较强，现实中要先看角度、距离与反光。",
            enSummary: "When a nearby corner points at a door or window, tradition flags stronger visual impact. In practice, first review the angle, distance, and reflected light.",
            zhFocus: "重点观察：尖角是否真实可见、是否近距离直指、白天是否伴随玻璃或金属反射。",
            enFocus: "Observe whether the corner is truly visible, points at close range, and comes with glass or metal glare during the day.",
            zhAdjustment: "缓和建议：优先用遮挡和视线转移处理，例如百叶、植物、窗边陈设或调整主要座位朝向。",
            enAdjustment: "Adjustment idea: handle it with screening and sightline redirection, such as blinds, planting, window styling, or seat reorientation."
        ),
        .init(
            index: "02.5",
            zhTitle: "镰刀",
            enTitle: "Sickle Form",
            zhSummary: "高架、弯路或大型流线形成弧形切割时，传统上多认为外部动势较强；现实中更应评估安全感、噪音与节奏干扰。",
            enSummary: "When an overpass, bend, or major movement line forms a curved cutting gesture, tradition reads the outside momentum as strong. In practice, review safety, noise, and rhythm disruption.",
            zhFocus: "重点观察：弧形动线是否临近卧室或长期停留区、夜晚是否有持续光流或噪音干扰。",
            enFocus: "Check whether the curved movement line sits near bedrooms or long-stay zones, and whether night light trails or noise remain constant.",
            zhAdjustment: "缓和建议：静区尽量后退，强化卧室包裹感与遮光隔音，减少外部节奏直接进入休息空间。",
            enAdjustment: "Adjustment idea: pull quiet zones deeper inward and strengthen bedroom enclosure, blackout control, and sound insulation."
        )
    ]

    private let adjustmentTracks: [AdjustmentTrack] = [
        .init(
            index: "03.1",
            zhTitle: "入口缓冲",
            enTitle: "Entry buffering",
            zhSummary: "适用于路冲、直冲动线等场景。通过前场过渡、屏风、玄关柜或植物层次，减少一眼望穿与直线压迫。",
            enSummary: "Useful for road-rush or direct-flow conditions. Transitional entry layers, screens, consoles, or planting reduce straight-line pressure."
        ),
        .init(
            index: "03.2",
            zhTitle: "窗景软化",
            enTitle: "Window softening",
            zhSummary: "适用于尖角、反弓、天斩等场景。通过纱帘、百叶、绿植和陈设层次，把尖锐外部线条转化为更柔和的视觉界面。",
            enSummary: "Useful for sharp-corner, reverse-bow, and sky-cut conditions. Sheers, blinds, planting, and styled layers soften harsh exterior geometry."
        ),
        .init(
            index: "03.3",
            zhTitle: "静区后退",
            enTitle: "Pull quiet zones inward",
            zhSummary: "适用于镰刀、强车流、风口明显的场景。让卧室、冥想角或长期停留区尽量远离最强的外部扰动面。",
            enSummary: "Useful for sickle-form, heavy traffic, or strong wind-channel conditions. Keep bedrooms and long-stay quiet zones farther from the strongest disturbance edge."
        )
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerCard

                if let saveStatusMessage {
                    TAMEStatusBanner(message: saveStatusMessage)
                }

                principleSection
                referenceSection
                adjustmentSection

                Button(action: saveRecord) {
                    Label(TAMEL10n.text("保存本页参考", "Save This Reference"), systemImage: "square.and.arrow.down")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(TAMESecondaryActionButtonStyle())
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .navigationTitle(TAMEL10n.text("形煞参考", "Reference Notes"))
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("环境观察参考", "Environmental Reference"), accent: "01")

            Text(TAMEL10n.text("本页把常见形煞名词整理成可直接阅读的参考卡片，重点是帮助你观察真实居住环境，而不是制造焦虑。", "This page turns common traditional terms into practical reference cards so you can read the environment more clearly without creating anxiety."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            HStack(spacing: 10) {
                knowledgePill(
                    title: TAMEL10n.text("知识条目", "Topics"),
                    value: "\(references.count)",
                    tint: TAMETheme.stardustGold
                )
                knowledgePill(
                    title: TAMEL10n.text("缓和路径", "Adjustments"),
                    value: "\(adjustmentTracks.count)",
                    tint: TAMETheme.techGray
                )
            }

            VStack(spacing: 10) {
                metricRow(index: "01", title: TAMEL10n.text("知识条目", "Reference topics"), value: "\(references.count)")
                metricRow(index: "02", title: TAMEL10n.text("观察原则", "Observation rules"), value: "\(principles.count)")
                metricRow(index: "03", title: TAMEL10n.text("缓和路径", "Adjustment tracks"), value: "\(adjustmentTracks.count)")
            }

            Text(TAMEL10n.text("所有内容仅供空间参考，请优先结合采光、通风、结构、安全、噪音与隐私判断。", "All content is for space reference only. Please prioritize daylight, airflow, structure, safety, noise, and privacy in real decisions."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextMuted)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private var principleSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("观察原则", "Observation Rules"), accent: "02")

            ForEach(principles) { item in
                principleCard(item)
            }
        }
    }

    private var referenceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("常见形态", "Common Forms"), accent: "03")

            ForEach(references) { item in
                referenceCard(item)
            }
        }
    }

    private var adjustmentSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("缓和思路", "Adjustment Paths"), accent: "04")

            ForEach(adjustmentTracks) { item in
                adjustmentCard(item)
            }
        }
    }

    private func principleCard(_ item: ReferencePrinciple) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            indexRow(item.index)

            Text(item.localizedTitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(item.localizedSummary)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 20, shadow: false)
    }

    private func referenceCard(_ item: ReferenceEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            indexRow(item.index)

            Text(item.localizedTitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(item.localizedSummary)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            detailBlock(
                title: TAMEL10n.text("重点观察", "What to observe"),
                body: item.localizedFocus
            )

            detailBlock(
                title: TAMEL10n.text("缓和建议", "Adjustment idea"),
                body: item.localizedAdjustment
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 22, shadow: false)
    }

    private func adjustmentCard(_ item: AdjustmentTrack) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            indexRow(item.index)

            Text(item.localizedTitle)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(item.localizedSummary)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 20, shadow: false)
    }

    private func detailBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)

            Text(body)
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
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

    private func saveRecord() {
        let details = references.flatMap { item in
            [
                "\(item.localizedTitle): \(item.localizedSummary)",
                "\(TAMEL10n.text("重点观察", "What to observe")): \(item.localizedFocus)",
                "\(TAMEL10n.text("缓和建议", "Adjustment idea")): \(item.localizedAdjustment)"
            ]
        }

        historyStore.save(
            category: .reference,
            title: TAMEL10n.text("形煞参考摘录", "Reference Notes Extract"),
            subtitle: TAMEL10n.text("环境观察与民俗术语说明", "Environmental notes and traditional terms"),
            details: details
        )
        saveStatusMessage = TAMEL10n.text("形煞参考已保存，可到“历史记录”查看。", "Reference notes saved. You can review them in Records.")
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

    private func knowledgePill(title: String, value: String, tint: Color) -> some View {
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
}

private struct ReferencePrinciple: Identifiable {
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

private struct ReferenceEntry: Identifiable {
    let id = UUID()
    let index: String
    let zhTitle: String
    let enTitle: String
    let zhSummary: String
    let enSummary: String
    let zhFocus: String
    let enFocus: String
    let zhAdjustment: String
    let enAdjustment: String

    var localizedTitle: String {
        TAMEL10n.text(zhTitle, enTitle)
    }

    var localizedSummary: String {
        TAMEL10n.text(zhSummary, enSummary)
    }

    var localizedFocus: String {
        TAMEL10n.text(zhFocus, enFocus)
    }

    var localizedAdjustment: String {
        TAMEL10n.text(zhAdjustment, enAdjustment)
    }
}

private struct AdjustmentTrack: Identifiable {
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

struct ReferenceKnowledgeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ReferenceKnowledgeView()
        }
    }
}
