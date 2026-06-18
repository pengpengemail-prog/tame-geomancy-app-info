import SwiftUI
import Combine

struct AnnualFortuneHouseProfile {
    let sitting: Direction
    let facing: Direction
    let mainNaqiAngle: Double?
    let naqiPointName: String?

    var usesNaqiBasis: Bool {
        mainNaqiAngle != nil
    }
}

struct AnnualFortuneSectorInsight: Identifiable, Equatable {
    let id = UUID()
    let position: (Int, Int)
    let positionName: String
    let annualStar: Int
    let annualStarName: String
    let annualStatus: StarStatus
    let annualScore: Int
    let directionalRelationship: String
    let directionalAdjustment: Int
    let summary: String

    static func == (lhs: AnnualFortuneSectorInsight, rhs: AnnualFortuneSectorInsight) -> Bool {
        lhs.position.0 == rhs.position.0 &&
        lhs.position.1 == rhs.position.1 &&
        lhs.positionName == rhs.positionName &&
        lhs.annualStar == rhs.annualStar &&
        lhs.annualStarName == rhs.annualStarName &&
        lhs.annualStatus == rhs.annualStatus &&
        lhs.annualScore == rhs.annualScore &&
        lhs.directionalRelationship == rhs.directionalRelationship &&
        lhs.directionalAdjustment == rhs.directionalAdjustment &&
        lhs.summary == rhs.summary
    }
}

struct AnnualFortuneAnalysis {
    let auspiciousDirections: [(Int, Int)]
    let inauspiciousDirections: [(Int, Int)]
    let auspiciousAdvice: String
    let inauspiciousAdvice: String
    let remedies: [String]
    let centerStar: Int
    let summary: String
    let taiSuiDirection: Direction
    let suiPoDirection: Direction
    let yearTheme: String
    let houseAdvice: String
    let houseProfile: AnnualFortuneHouseProfile?
    let sectorInsights: [AnnualFortuneSectorInsight]
    let annualChartBasis: String
}

class AnnualFortuneViewModel: ObservableObject {
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var annualChart: NinePalace?
    @Published var analysis: AnnualFortuneAnalysis?
    @Published var currentPeriod: SanyuanJiuyun?
    @Published var selectedSittingDirection: Direction = .zi
    @Published var useHouseFacingReference: Bool = false
    @Published var useNaqiBasis: Bool = false
    @Published var rawNaqiAngle: Double = 180
    @Published var naqiPointName: String = TAMEL10n.text("大门", "Main Door")

    func loadCurrentYear() {
        selectYear(selectedYear)
    }

    func selectYear(_ year: Int) {
        selectedYear = year
        calculateAnnualFortune()
    }

    func previousYear() {
        if selectedYear > 1984 {
            selectedYear -= 1
            calculateAnnualFortune()
        }
    }

    func nextYear() {
        if selectedYear < 2043 {
            selectedYear += 1
            calculateAnnualFortune()
        }
    }

    func updateHouseReference() {
        calculateAnnualFortune()
    }

    func recordDetails() -> [String] {
        guard let analysis else { return [] }

        var details = [
            TAMEL10n.text("年份：\(selectedYear)", "Year: \(selectedYear)"),
            TAMEL10n.text("元运：\(currentPeriod?.star ?? SanyuanJiuyun.from(year: selectedYear).star)", "Period: \(currentPeriod?.star ?? SanyuanJiuyun.from(year: selectedYear).star)"),
            TAMEL10n.text("流年中宫星：\(analysis.centerStar) · \(starName(analysis.centerStar))", "Annual center star: \(analysis.centerStar) · \(starName(analysis.centerStar))"),
            TAMEL10n.text("太岁方：\(analysis.taiSuiDirection.localizedLabel)", "Tai Sui sector: \(analysis.taiSuiDirection.localizedLabel)"),
            TAMEL10n.text("岁破方：\(analysis.suiPoDirection.localizedLabel)", "Sui Po sector: \(analysis.suiPoDirection.localizedLabel)"),
            TAMEL10n.text("排盘依据：\(analysis.annualChartBasis)", "Chart basis: \(analysis.annualChartBasis)"),
            TAMEL10n.text("年度主题：\(analysis.yearTheme)", "Year theme: \(analysis.yearTheme)"),
            TAMEL10n.text("年度摘要：\(analysis.summary)", "Annual summary: \(analysis.summary)"),
            TAMEL10n.text("房屋联动：\(analysis.houseAdvice)", "House interaction: \(analysis.houseAdvice)"),
            TAMEL10n.text("吉方：\(formattedPositions(analysis.auspiciousDirections))", "Helpful sectors: \(formattedPositions(analysis.auspiciousDirections))"),
            TAMEL10n.text("需注意方位：\(formattedPositions(analysis.inauspiciousDirections))", "Watch sectors: \(formattedPositions(analysis.inauspiciousDirections))")
        ]

        details.append(contentsOf: analysis.sectorInsights.map {
            TAMEL10n.text(
                "方位细评：\($0.positionName) · \($0.annualStarName) · \($0.directionalRelationship) · \($0.summary)",
                "Sector insight: \($0.positionName) · \($0.annualStarName) · \($0.directionalRelationship) · \($0.summary)"
            )
        })

        if !analysis.remedies.isEmpty {
            details.append(contentsOf: analysis.remedies.map {
                TAMEL10n.text("化解建议：\($0)", "Reference suggestion: \($0)")
            })
        }

        return details
    }

    private func calculateAnnualFortune() {
        currentPeriod = SanyuanJiuyun.from(year: selectedYear)
        annualChart = FlyingStarCalculator.calculateLiunianPan(year: selectedYear)

        guard let chart = annualChart, let currentPeriod else { return }

        let houseProfile = currentHouseProfile()
        let taiSuiDirection = annualTaiSuiDirection(for: selectedYear)
        let suiPoDirection = taiSuiDirection.opposite

        var auspicious: [(Int, Int)] = []
        var inauspicious: [(Int, Int)] = []
        var remedySuggestions: [String] = []
        var insights: [AnnualFortuneSectorInsight] = []
        let centerStar = chart.stars[1][1]

        for row in 0..<3 {
            for col in 0..<3 {
                let star = chart.stars[row][col]
                let position = (row, col)
                let relationship = sectorRelationship(
                    for: position,
                    star: star,
                    houseProfile: houseProfile,
                    taiSui: taiSuiDirection,
                    suiPo: suiPoDirection
                )
                let score = annualDirectionScore(
                    star: star,
                    period: currentPeriod,
                    adjustment: relationship.adjustment
                )

                if score >= 2 {
                    auspicious.append(position)
                } else if score <= -1 {
                    inauspicious.append(position)
                }

                remedySuggestions.append(contentsOf: remedies(
                    for: star,
                    at: position,
                    relationship: relationship.label
                ))

                insights.append(
                    AnnualFortuneSectorInsight(
                        position: position,
                        positionName: positionName(row, col),
                        annualStar: star,
                        annualStarName: starName(star),
                        annualStatus: FlyingStarCalculator.getStarStatus(star: star, jiuyun: currentPeriod),
                        annualScore: score,
                        directionalRelationship: relationship.label,
                        directionalAdjustment: relationship.adjustment,
                        summary: relationship.summary
                    )
                )
            }
        }

        let auspiciousAdvice = generateAuspiciousAdvice(
            directions: auspicious,
            houseProfile: houseProfile
        )
        let inauspiciousAdvice = generateInauspiciousAdvice(
            directions: inauspicious,
            houseProfile: houseProfile
        )
        let yearTheme = generateYearTheme(
            centerStar: centerStar,
            taiSui: taiSuiDirection,
            suiPo: suiPoDirection
        )
        let houseAdvice = generateHouseAdvice(
            houseProfile: houseProfile,
            insights: insights,
            taiSui: taiSuiDirection,
            suiPo: suiPoDirection
        )
        let annualChartBasis = generateChartBasis(houseProfile: houseProfile)
        let summary = generateSummary(
            centerStar: centerStar,
            period: currentPeriod,
            auspicious: auspicious,
            inauspicious: inauspicious,
            houseAdvice: houseAdvice
        )

        analysis = AnnualFortuneAnalysis(
            auspiciousDirections: auspicious,
            inauspiciousDirections: inauspicious,
            auspiciousAdvice: auspiciousAdvice,
            inauspiciousAdvice: inauspiciousAdvice,
            remedies: Array(NSOrderedSet(array: remedySuggestions)) as? [String] ?? remedySuggestions,
            centerStar: centerStar,
            summary: summary,
            taiSuiDirection: taiSuiDirection,
            suiPoDirection: suiPoDirection,
            yearTheme: yearTheme,
            houseAdvice: houseAdvice,
            houseProfile: houseProfile,
            sectorInsights: insights.sorted { $0.annualScore > $1.annualScore },
            annualChartBasis: annualChartBasis
        )
    }

    private func currentHouseProfile() -> AnnualFortuneHouseProfile? {
        guard useHouseFacingReference else { return nil }

        let finalName = naqiPointName.trimmingCharacters(in: .whitespacesAndNewlines)
        return AnnualFortuneHouseProfile(
            sitting: selectedSittingDirection,
            facing: selectedSittingDirection.opposite,
            mainNaqiAngle: useNaqiBasis ? rawNaqiAngle : nil,
            naqiPointName: finalName.isEmpty ? TAMEL10n.text("大门", "Main Door") : finalName
        )
    }

    private func annualTaiSuiDirection(for year: Int) -> Direction {
        let earthlyBranches: [Direction] = [
            .zi, .chou, .yin, .mao, .chen, .si,
            .wu, .wei, .shen, .you, .xu, .hai
        ]
        let index = (year - 2020).positiveModulo(12)
        return earthlyBranches[index]
    }

    private func sectorRelationship(
        for position: (Int, Int),
        star: Int,
        houseProfile: AnnualFortuneHouseProfile?,
        taiSui: Direction,
        suiPo: Direction
    ) -> (label: String, adjustment: Int, summary: String) {
        let sectorDirection = directionForPosition(position)
        let relationToTaiSui = angularCloseness(from: sectorDirection, to: taiSui)
        let relationToSuiPo = angularCloseness(from: sectorDirection, to: suiPo)

        var labels: [String] = []
        var summaries: [String] = []
        var adjustment = 0

        if relationToTaiSui <= 15 {
            labels.append(TAMEL10n.text("临太岁", "Near Tai Sui"))
            adjustment -= 1
            summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))与太岁方接近，年度动作宜稳。", "\(positionName(position.0, position.1)) is close to Tai Sui this year, so changes are better kept steady."))
        } else if relationToSuiPo <= 15 {
            labels.append(TAMEL10n.text("近岁破", "Near Sui Po"))
            adjustment -= 2
            summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))靠近岁破方，更不宜冲动改动。", "\(positionName(position.0, position.1)) is close to Sui Po, so impulsive changes are less suitable."))
        }

        if let houseProfile {
            let facingDirection = useNaqiBasis && houseProfile.mainNaqiAngle != nil
                ? Direction.from(angle: normalized(houseProfile.mainNaqiAngle! + 7.5))
                : houseProfile.facing
            let sittingDirection = houseProfile.sitting
            let facingGap = angularCloseness(from: sectorDirection, to: facingDirection)
            let sittingGap = angularCloseness(from: sectorDirection, to: sittingDirection)

            if facingGap <= 15 {
                labels.append(TAMEL10n.text("近向方", "Near Facing"))
                switch FlyingStarCalculator.getStarStatus(star: star, jiuyun: currentPeriod ?? .current) {
                case .wang, .sheng:
                    adjustment += 2
                    summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))接近房屋向方，较易放大本年旺气表现。", "\(positionName(position.0, position.1)) sits close to the facing side and can amplify this year's stronger qi."))
                case .tui:
                    adjustment += 1
                    summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))接近房屋向方，仍可作为年度活动区参考。", "\(positionName(position.0, position.1)) stays near the facing side and can still work as a yearly activity reference."))
                case .shuai, .sha:
                    adjustment -= 2
                    summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))接近房屋向方，但年度星气偏弱，宜谨慎使用。", "\(positionName(position.0, position.1)) is near the facing side, but the yearly star is weaker, so use it more cautiously."))
                }
            } else if sittingGap <= 15 {
                labels.append(TAMEL10n.text("近坐山", "Near Sitting"))
                switch FlyingStarCalculator.getStarStatus(star: star, jiuyun: currentPeriod ?? .current) {
                case .wang, .sheng:
                    adjustment += 1
                    summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))接近坐山，适合偏静态的卧室或书房安排。", "\(positionName(position.0, position.1)) is near the sitting side and better suits calmer uses like bedrooms or studies."))
                case .tui:
                    summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))接近坐山，年度表现中性，以安稳为主。", "\(positionName(position.0, position.1)) is near the sitting side and reads neutral this year, so stability is the priority."))
                case .shuai, .sha:
                    adjustment -= 1
                    summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))接近坐山，宜减少长期受压与堆物。", "\(positionName(position.0, position.1)) is near the sitting side, so long-term pressure and clutter should be reduced."))
                }
            }
        }

        if labels.isEmpty {
            labels.append(TAMEL10n.text("中性", "Neutral"))
            summaries.append(TAMEL10n.text("\(positionName(position.0, position.1))与太岁、向方距离适中，可按年度星性单独参考。", "\(positionName(position.0, position.1)) sits at a moderate distance from Tai Sui and the facing side, so it can be read mainly by the annual star itself."))
        }

        return (labels.joined(separator: " · "), adjustment, summaries.joined(separator: " "))
    }

    private func generateAuspiciousAdvice(
        directions: [(Int, Int)],
        houseProfile: AnnualFortuneHouseProfile?
    ) -> String {
        if directions.isEmpty {
            return TAMEL10n.text("本年度暂无特别突出的旺位，宜以整体稳定与整洁为主。", "No standout prime sector appears this year, so overall stability and tidiness matter most.")
        }

        let names = directions.map { positionName($0.0, $0.1) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、")
        if let houseProfile {
            return TAMEL10n.text("本年度较适合优先利用\(names)等方位，可结合\(houseProfile.facing.localizedLabel)向的主要活动区、办公区或会客区一起参考。*仅供民俗文化参考", "This year favors sectors such as \(names). They can be reviewed together with the main activity, work, or hosting zones around the \(houseProfile.facing.localizedLabel) side. Cultural reference only.")
        }
        return TAMEL10n.text("本年度较适合优先利用\(names)等方位，可作为办公、会客、学习或主要活动区域参考。*仅供民俗文化参考", "This year favors sectors such as \(names), which can be referenced for work, hosting, study, or the main activity areas. Cultural reference only.")
    }

    private func generateInauspiciousAdvice(
        directions: [(Int, Int)],
        houseProfile: AnnualFortuneHouseProfile?
    ) -> String {
        if directions.isEmpty {
            return TAMEL10n.text("本年度无特别集中的注意方位，可继续观察实际使用感受。", "No heavily concentrated caution sector appears this year, so continue observing real use patterns.")
        }

        let names = directions.map { positionName($0.0, $0.1) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、")
        if let houseProfile {
            return TAMEL10n.text("建议减少对\(names)等方位的过度依赖，尤其在\(houseProfile.facing.localizedLabel)向动线附近更宜避免大改动。*仅供民俗文化参考", "It is better to rely less on sectors such as \(names), especially near circulation on the \(houseProfile.facing.localizedLabel) side where major changes are less ideal. Cultural reference only.")
        }
        return TAMEL10n.text("建议减少对\(names)等方位的过度依赖，涉及动线、装修或长期停留时可结合化解建议一起参考。*仅供民俗文化参考", "It is better to rely less on sectors such as \(names), especially when planning circulation, renovations, or long stays. Cultural reference only.")
    }

    private func generateSummary(
        centerStar: Int,
        period: SanyuanJiuyun,
        auspicious: [(Int, Int)],
        inauspicious: [(Int, Int)],
        houseAdvice: String
    ) -> String {
        let centerName = starName(centerStar)
        let auspiciousText = auspicious.isEmpty ? TAMEL10n.text("暂无明显旺位", "No standout prime sector") : auspicious.prefix(3).map { positionName($0.0, $0.1) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、")
        let inauspiciousText = inauspicious.isEmpty ? TAMEL10n.text("暂无集中注意位", "No concentrated caution sector") : inauspicious.prefix(3).map { positionName($0.0, $0.1) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、")
        return TAMEL10n.text("\(selectedYear) 年\(centerName)入中，当前处于\(period.star)。较可优先关注\(auspiciousText)，并留意\(inauspiciousText)的年度变化。\(houseAdvice)", "In \(selectedYear), \(centerName) enters the center while the current cycle is \(period.star). Prioritize \(auspiciousText), watch yearly changes around \(inauspiciousText), and read them together with the house guidance. \(houseAdvice)")
    }

    private func annualDirectionScore(
        star: Int,
        period: SanyuanJiuyun,
        adjustment: Int
    ) -> Int {
        var score: Int
        switch FlyingStarCalculator.getStarStatus(star: star, jiuyun: period) {
        case .wang:
            score = 3
        case .sheng:
            score = 2
        case .tui:
            score = 1
        case .shuai:
            score = -1
        case .sha:
            score = -3
        }

        if star == 4 {
            score += 1
        }

        if star == 3 || star == 7 {
            score -= 2
        }

        return score + adjustment
    }

    private func remedies(
        for star: Int,
        at position: (Int, Int),
        relationship: String
    ) -> [String] {
        let name = positionName(position.0, position.1)
        switch star {
        case 5:
            return [TAMEL10n.text("\(name)方位宜避免动土或重度施工，可用金属摆件作民俗参考调和。", "Avoid heavy renovation or ground-breaking in the \(name) sector; metal accents can be used as a cultural-reference balancing idea.")]
        case 2:
            return [TAMEL10n.text("\(name)方位宜保持通风整洁，健康相关区域可减少杂物堆积。", "Keep the \(name) sector ventilated and tidy, especially in health-related areas where clutter should be reduced.")]
        case 3:
            return [TAMEL10n.text("\(name)方位若容易引发争执，可用柔和灯光与低饱和陈设缓和氛围。", "If the \(name) sector tends to trigger friction, softer lighting and lower-saturation decor can calm the atmosphere.")]
        case 7:
            return [TAMEL10n.text("\(name)方位注意尖锐破损物件，减少噪音与过强金属感。", "Watch for sharp or damaged items in the \(name) sector, and reduce noise and overly harsh metallic cues.")]
        default:
            return relationship.contains(TAMEL10n.text("近岁破", "Near Sui Po")) ? [TAMEL10n.text("\(name)方位接近岁破，年度内如非必要可少做重度改动。", "The \(name) sector sits close to Sui Po, so major changes are better minimized this year unless necessary.")] : []
        }
    }

    private func generateYearTheme(
        centerStar: Int,
        taiSui: Direction,
        suiPo: Direction
    ) -> String {
        let core: String
        switch centerStar {
        case 1:
            core = TAMEL10n.text("偏向流动、人缘与外部机会", "leans toward mobility, relationships, and outside opportunities")
        case 2:
            core = TAMEL10n.text("更重视健康、节奏与稳定整理", "emphasizes health, pacing, and steady organization")
        case 3:
            core = TAMEL10n.text("容易带来意见碰撞，沟通方式更重要", "can bring stronger disagreement, so communication style matters more")
        case 4:
            core = TAMEL10n.text("利学习、考试、创作与文书表达", "supports study, exams, creativity, and written expression")
        case 5:
            core = TAMEL10n.text("宜稳不宜躁，少折腾、少大动", "favors steadiness over turbulence, with fewer major moves")
        case 6:
            core = TAMEL10n.text("利于决策、执行与职业推进", "supports decision-making, execution, and career momentum")
        case 7:
            core = TAMEL10n.text("重视边界、口舌与物品维护", "highlights boundaries, speech, and item upkeep")
        case 8:
            core = TAMEL10n.text("偏向积累、沉淀与居住稳定", "leans toward accumulation, consolidation, and residential stability")
        case 9:
            core = TAMEL10n.text("利曝光、喜庆、审美与内容表达", "supports visibility, celebration, aesthetics, and content expression")
        default:
            core = TAMEL10n.text("以平稳观察为主", "is best approached with calm observation")
        }

        return TAMEL10n.text("本年主题\(core)，太岁在\(taiSui.localizedLabel)方，岁破在\(suiPo.localizedLabel)方，涉及这两侧的施工与大改动更宜保守。", "This year's theme \(core). Tai Sui sits in the \(taiSui.localizedLabel) sector and Sui Po in the \(suiPo.localizedLabel) sector, so major construction or heavier changes on those sides are better approached conservatively.")
    }

    private func generateHouseAdvice(
        houseProfile: AnnualFortuneHouseProfile?,
        insights: [AnnualFortuneSectorInsight],
        taiSui: Direction,
        suiPo: Direction
    ) -> String {
        guard let houseProfile else {
            return TAMEL10n.text("当前未带入房屋坐向，以下结果以年度飞星方位为主。", "No house orientation is currently linked, so the results below rely mainly on annual flying-star sectors.")
        }

        let favorable = insights.filter { $0.annualScore >= 2 && $0.directionalAdjustment > 0 }
        let caution = insights.filter {
            $0.annualScore <= 0 && (
                $0.directionalRelationship.contains(TAMEL10n.text("近向方", "Near Facing")) ||
                $0.directionalRelationship.contains(TAMEL10n.text("近岁破", "Near Sui Po"))
            )
        }

        var segments: [String] = []
        if let best = favorable.first {
            segments.append(TAMEL10n.text("房屋按\(houseProfile.sitting.localizedLabel)山\(houseProfile.facing.localizedLabel)向参考时，\(best.positionName)较能承接年度顺势。", "For a house with a \(houseProfile.sitting.localizedLabel) sitting side and a \(houseProfile.facing.localizedLabel) facing side, \(best.positionName) is better placed to receive this year's favorable momentum."))
        } else {
            segments.append(TAMEL10n.text("房屋按\(houseProfile.sitting.localizedLabel)山\(houseProfile.facing.localizedLabel)向参考时，本年更适合以稳定布局为主。", "For a house with a \(houseProfile.sitting.localizedLabel) sitting side and a \(houseProfile.facing.localizedLabel) facing side, a steadier layout is the better fit this year."))
        }

        if let mainNaqiAngle = houseProfile.mainNaqiAngle {
            let naqiDirection = Direction.from(angle: normalized(mainNaqiAngle + 7.5))
            segments.append(
                TAMEL10n.text(
                    "\(houseProfile.naqiPointName ?? "主纳气口")按纳气盘换算落在\(naqiDirection.localizedLabel)方，可作为观察年度财气互动的重点。",
                    "\(houseProfile.naqiPointName ?? "Main opening") falls in the \(naqiDirection.localizedLabel) sector after Naqi conversion and is worth watching as a key point for annual intake interaction."
                )
            )
        }

        if let firstCaution = caution.first {
            segments.append(TAMEL10n.text("\(firstCaution.positionName)今年更宜避免大改动，尤其岁破在\(suiPo.localizedLabel)方、太岁在\(taiSui.localizedLabel)方时更要稳妥。", "\(firstCaution.positionName) is better kept free from major changes this year, especially with Sui Po in the \(suiPo.localizedLabel) sector and Tai Sui in the \(taiSui.localizedLabel) sector."))
        }

        return segments.joined(separator: " ")
    }

    private func generateChartBasis(houseProfile: AnnualFortuneHouseProfile?) -> String {
        guard let houseProfile else {
            return TAMEL10n.text("未带入房屋坐向，当前按年度流年盘做方位参考。", "No house orientation is linked, so the current review follows the annual flying-star chart only.")
        }

        if let mainNaqiAngle = houseProfile.mainNaqiAngle {
            let naqiDirection = Direction.from(angle: normalized(mainNaqiAngle + 7.5))
            return TAMEL10n.text("已带入\(houseProfile.sitting.localizedLabel)山\(houseProfile.facing.localizedLabel)向，并以\(houseProfile.naqiPointName ?? "主纳气口")纳气盘 \(String(format: "%.1f°", normalized(mainNaqiAngle + 7.5)))（\(naqiDirection.localizedLabel)方）联动年度方位。", "Using a \(houseProfile.sitting.localizedLabel) sitting side / \(houseProfile.facing.localizedLabel) facing side profile, with \(houseProfile.naqiPointName ?? "the main opening") at Naqi \(String(format: "%.1f°", normalized(mainNaqiAngle + 7.5))) in the \(naqiDirection.localizedLabel) sector as the basis for the annual directional review.")
        }

        return TAMEL10n.text("已带入\(houseProfile.sitting.localizedLabel)山\(houseProfile.facing.localizedLabel)向，当前按房屋坐向联动年度方位。", "Using a \(houseProfile.sitting.localizedLabel) sitting side / \(houseProfile.facing.localizedLabel) facing side profile as the basis for the annual directional review.")
    }

    private func directionForPosition(_ position: (Int, Int)) -> Direction {
        switch position {
        case (0, 0): return .xun
        case (0, 1): return .wu
        case (0, 2): return .kun
        case (1, 0): return .mao
        case (1, 1): return .zi
        case (1, 2): return .you
        case (2, 0): return .gen
        case (2, 1): return .zi
        case (2, 2): return .qian
        default: return .zi
        }
    }

    private func angularCloseness(from lhs: Direction, to rhs: Direction) -> Double {
        let raw = abs(lhs.angle - rhs.angle).truncatingRemainder(dividingBy: 360)
        return min(raw, 360 - raw)
    }

    private func starName(_ star: Int) -> String {
        switch star {
        case 1: return TAMEL10n.text("一白贪狼", "1 White Tanlang")
        case 2: return TAMEL10n.text("二黑病符", "2 Black Illness")
        case 3: return TAMEL10n.text("三碧禄存", "3 Jade Lucun")
        case 4: return TAMEL10n.text("四绿文曲", "4 Green Wenqu")
        case 5: return TAMEL10n.text("五黄廉贞", "5 Yellow Lianzhen")
        case 6: return TAMEL10n.text("六白武曲", "6 White Wuqu")
        case 7: return TAMEL10n.text("七赤破军", "7 Red Pojun")
        case 8: return TAMEL10n.text("八白左辅", "8 White Zuofu")
        case 9: return TAMEL10n.text("九紫右弼", "9 Purple Youbi")
        default: return TAMEL10n.text("未知星", "Unknown Star")
        }
    }

    private func positionName(_ row: Int, _ col: Int) -> String {
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
        return names[row][col]
    }

    private func formattedPositions(_ positions: [(Int, Int)]) -> String {
        guard !positions.isEmpty else { return TAMEL10n.text("无", "None") }
        return positions.map { positionName($0.0, $0.1) }.joined(separator: TAMEL10n.isEnglish ? ", " : "、")
    }

    private func normalized(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}

private extension Int {
    func positiveModulo(_ divisor: Int) -> Int {
        let result = self % divisor
        return result >= 0 ? result : result + divisor
    }
}
