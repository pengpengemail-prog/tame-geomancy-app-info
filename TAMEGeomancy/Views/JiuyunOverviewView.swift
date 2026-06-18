import SwiftUI

struct JiuyunOverviewView: View {
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var saveStatusMessage: String?
    @StateObject private var historyStore = HistoryStore.shared

    private var period: SanyuanJiuyun {
        SanyuanJiuyun.from(year: selectedYear)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let saveStatusMessage {
                    TAMEStatusBanner(message: saveStatusMessage)
                }

                selectionCard
                overviewCard
                strategyCard
                comparisonCard
                timelineCard
            }
            .padding()
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .navigationTitle(TAMEL10n.text("三元九运", "Period Guide"))
    }

    private var selectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("年份选择", "Year Selection"), accent: "01")

            Stepper(TAMEL10n.text("查看年份 \(selectedYear)", "Viewing Year \(selectedYear)"), value: $selectedYear, in: 1984...2043)

            HStack(spacing: 12) {
                quickYearButton(2003)
                quickYearButton(2023)
                quickYearButton(2024)
                quickYearButton(2043)
            }

            Button(TAMEL10n.text("保存到记录", "Save to Records")) {
                historyStore.save(
                    category: .jiuyun,
                    title: TAMEL10n.text("\(selectedYear) 年归运", "\(selectedYear) Period Mapping"),
                    subtitle: "\(period.localizedPeriodName) · \(period.star)",
                    details: [
                        TAMEL10n.text("年份：\(selectedYear)", "Year: \(selectedYear)"),
                        TAMEL10n.text("所属元运：\(period.localizedPeriodName)", "Assigned period: \(period.localizedPeriodName)"),
                        TAMEL10n.text("五行：\(period.element.localizedLabel)", "Element: \(period.element.localizedLabel)"),
                        TAMEL10n.text("旺方：\(periodFocusDirection)", "Prime sector: \(periodFocusDirection)"),
                        TAMEL10n.text("行业倾向：\(periodIndustryFocus)", "Industry focus: \(periodIndustryFocus)"),
                        TAMEL10n.text("空间策略：\(periodSpaceStrategy)", "Space strategy: \(periodSpaceStrategy)")
                    ]
                )
                saveStatusMessage = TAMEL10n.text("三元九运记录已保存，可到“历史记录”查看。", "Period-cycle record saved. You can review it in Records.")
            }
            .font(.system(size: 12, weight: .medium, design: .rounded))
            .buttonStyle(TAMESecondaryActionButtonStyle())
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private var overviewCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("当前元运", "Current Period"), accent: "02")

            Text(period.localizedPeriodName)
                .font(.system(size: 30, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(TAMEL10n.text("\(period.star) · 五行 \(period.element.localizedLabel)", "\(period.star) · \(period.element.localizedLabel)"))
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(spacing: 10) {
                metricLine(index: "02.1", title: TAMEL10n.text("旺方", "Prime Sector"), value: periodFocusDirection)
                metricLine(index: "02.2", title: TAMEL10n.text("行业倾向", "Industry Focus"), value: periodIndustryFocus)
                metricLine(index: "02.3", title: TAMEL10n.text("空间策略", "Space Strategy"), value: periodSpaceStrategy)
            }

            Text(periodInsight)
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private var strategyCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("空间提示", "Period Notes"), accent: "03")

            VStack(spacing: 10) {
                strategyRow(index: "03.1", title: TAMEL10n.text("当前节奏", "Current Tone"), body: periodInsight)
                strategyRow(index: "03.2", title: TAMEL10n.text("适合关注", "Worth Emphasizing"), body: periodSpaceNarrative)
                strategyRow(index: "03.3", title: TAMEL10n.text("应用场景", "Useful Context"), body: periodUseCase)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private var comparisonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("元运对照", "Period Comparison"), accent: "04")

            Text(TAMEL10n.text("同一套房屋在不同元运下，观察重点会变化。下面这组对比更适合做方案理解，而不是替代实地判断。", "The same property can be read with different emphasis across major periods. This comparison is meant for understanding and not as a substitute for site judgment."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(spacing: 10) {
                comparisonRow(period: .qi, index: "04.1")
                comparisonRow(period: .ba, index: "04.2")
                comparisonRow(period: .jiu, index: "04.3")
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private var timelineCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("时间表", "Timeline"), accent: "05")

            ForEach(Array(SanyuanJiuyun.allCases.enumerated()), id: \.element.rawValue) { index, item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(String(format: "05.%d", index + 1))
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.stardustGold)

                            Text("\(item.localizedPeriodName) · \(item.star)")
                                .font(.system(size: 17, weight: .medium, design: .rounded))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                        }
                        Text(item.period)
                            .font(.system(size: 12.5, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextSecondary)
                    }
                    Spacer()
                    Text(item.element.localizedLabel)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .tameInstrumentCard(cornerRadius: 10, shadow: false)
                }
                .padding(14)
                .tameInstrumentCard(cornerRadius: 16, shadow: false)
            }
        }
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private var periodInsight: String {
        switch period {
        case .qi:
            return TAMEL10n.text("七运以七赤金为主，适合参考金气、沟通效率与旧盘收尾。", "Period 7 centers on 7 Red Metal and is often referenced for metal energy, communication, and legacy-cycle wrap-up.")
        case .ba:
            return TAMEL10n.text("八运以八白土为主，更强调稳健积累、地产与长期布局。", "Period 8 centers on 8 White Earth and emphasizes steady accumulation, property themes, and long-term planning.")
        case .jiu:
            return TAMEL10n.text("九运以九紫火为主，常用于参考曝光、审美、内容表达与女性能量。", "Period 9 centers on 9 Purple Fire and is commonly referenced for visibility, aesthetics, content expression, and feminine energy.")
        }
    }

    private var periodFocusDirection: String {
        switch period {
        case .qi:
            return TAMEL10n.text("偏西与金气相关方位", "West-leaning and metal-related sectors")
        case .ba:
            return TAMEL10n.text("中宫、东北与土气相关方位", "Center, northeast, and earth-related sectors")
        case .jiu:
            return TAMEL10n.text("离宫、南向与火气相关方位", "Li palace, southern, and fire-related sectors")
        }
    }

    private var periodIndustryFocus: String {
        switch period {
        case .qi:
            return TAMEL10n.text("传播、沟通、交易与效率型行业", "Communication, trading, and efficiency-driven industries")
        case .ba:
            return TAMEL10n.text("地产、居住、长期积累与稳定运营", "Property, living, long-horizon accumulation, and stable operations")
        case .jiu:
            return TAMEL10n.text("审美、内容、女性消费、品牌曝光与影像表达", "Aesthetics, content, women-focused consumption, brand visibility, and visual expression")
        }
    }

    private var periodSpaceStrategy: String {
        switch period {
        case .qi:
            return TAMEL10n.text("更看重沟通效率与旧格局收尾", "Prioritize communication efficiency and legacy-layout wrap-up")
        case .ba:
            return TAMEL10n.text("更看重稳定居住、储备与长期布局", "Prioritize residential stability, reserves, and long-term planning")
        case .jiu:
            return TAMEL10n.text("更看重曝光界面、南向采光与内容表达", "Prioritize visible presentation, southern daylight, and expressive content zones")
        }
    }

    private var periodSpaceNarrative: String {
        switch period {
        case .qi:
            return TAMEL10n.text("适合检查空间里与沟通、流转、效率相关的区域是否顺手，旧房也更适合做收尾和整理。", "Review whether spaces tied to communication, flow, and efficiency feel smooth. Older properties also suit wrap-up and consolidation work here.")
        case .ba:
            return TAMEL10n.text("更适合关注长期居住舒适度、稳定动线、储物与沉淀型空间安排。", "Give more attention to long-term living comfort, stable circulation, storage, and spaces designed for gradual accumulation.")
        case .jiu:
            return TAMEL10n.text("更适合关注面向展示的界面、审美氛围、南向活动区，以及与内容表达相关的房间使用方式。", "Focus more on presentation-facing surfaces, aesthetic atmosphere, south-oriented activity zones, and rooms used for content or expressive work.")
        }
    }

    private var periodUseCase: String {
        switch period {
        case .qi:
            return TAMEL10n.text("适合复盘旧房格局、交易型空间与高沟通频率场景。", "Useful for older properties, transaction-oriented spaces, and high-communication environments.")
        case .ba:
            return TAMEL10n.text("适合住宅、资产型空间、长期运营场景与稳定型家庭布局。", "Useful for residences, asset-oriented spaces, long-running operations, and stable family layouts.")
        case .jiu:
            return TAMEL10n.text("适合品牌展示、直播拍摄、内容生产、美学体验与更重视外显气质的空间。", "Useful for brand presentation, livestream shooting, content creation, aesthetic experiences, and spaces that rely on visible character.")
        }
    }

    private func comparisonRow(period item: SanyuanJiuyun, index: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(index)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.18))
                    .frame(width: 22, height: 1)
            }

            Text("\(item.localizedPeriodName) · \(item.star)")
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(comparisonNarrative(for: item))
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 18, shadow: false)
    }

    private func comparisonNarrative(for item: SanyuanJiuyun) -> String {
        switch item {
        case .qi:
            return TAMEL10n.text("如果同一房屋放在七运观察，重点更偏向效率、口才、交易与旧格局如何顺势收尾。", "When the same property is read in Period 7, the emphasis leans more toward efficiency, speech, transaction flow, and how an older layout wraps up smoothly.")
        case .ba:
            return TAMEL10n.text("放在八运观察时，更强调稳定沉淀、居住舒适、资产属性与长期使用耐性。", "Read in Period 8, the emphasis shifts toward stability, residential comfort, asset character, and long-term durability.")
        case .jiu:
            return TAMEL10n.text("放在九运观察时，更重视南向界面、审美表达、曝光感与更外显的空间气质。", "Read in Period 9, more weight falls on southern presentation, aesthetic expression, visibility, and a more outward-facing spatial character.")
        }
    }

    private func quickYearButton(_ year: Int) -> some View {
        Button(action: { selectedYear = year }) {
            Text("\(year)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(selectedYear == year ? TAMETheme.stardustGold.opacity(0.14) : TAMETheme.fieldBackground)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(selectedYear == year ? TAMETheme.stardustGold.opacity(0.22) : TAMETheme.brandHairline, lineWidth: 1)
                }
                .foregroundColor(selectedYear == year ? TAMETheme.deepBlueBlack : TAMETheme.brandTextPrimary)
        }
        .buttonStyle(.plain)
    }

    private func strategyRow(index: String, title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(index)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.stardustGold)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.18))
                    .frame(width: 22, height: 1)
            }

            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(body)
                .font(.system(size: 12.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .tameInstrumentCard(cornerRadius: 18, shadow: false)
    }

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 34, alignment: .leading)

            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)
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
}

struct JiuyunOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            JiuyunOverviewView()
        }
    }
}
