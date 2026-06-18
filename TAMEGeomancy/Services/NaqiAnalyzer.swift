import Foundation

/// 纳气口分析器
/// 用于分析房屋纳气口（大门、阳台、窗户等）的风水特性
/// 纳气盘使用天盘缝针（顺时针偏移地盘7.5°）
class NaqiAnalyzer {
    
    // MARK: - 纳气口类型
    
    /// 纳气口类型枚举
    enum NaqiType: String, CaseIterable {
        case mainDoor = "大门"
        case balcony = "阳台"
        case window = "窗户"
        case sideDoor = "侧门"
        case backDoor = "后门"

        var localizedTitle: String {
            switch self {
            case .mainDoor:
                return TAMEL10n.text("大门", "Main Door")
            case .balcony:
                return TAMEL10n.text("阳台", "Balcony")
            case .window:
                return TAMEL10n.text("窗户", "Window")
            case .sideDoor:
                return TAMEL10n.text("侧门", "Side Door")
            case .backDoor:
                return TAMEL10n.text("后门", "Rear Door")
            }
        }
        
        var importance: Int {
            switch self {
            case .mainDoor: return 5      // 最重要
            case .balcony: return 4
            case .window: return 2
            case .sideDoor: return 3
            case .backDoor: return 3
            }
        }
    }
    
    // MARK: - 气的类型
    
    /// 气的旺衰类型
    enum QiStatus: String {
        case wang = "旺气"      // 当运之气
        case sheng = "生气"     // 未来运之气
        case ping = "平气"      // 中性之气
        case tui = "退气"       // 上运之气
        case shuai = "衰气"     // 衰败之气

        var localizedTitle: String {
            switch self {
            case .wang: return TAMEL10n.text("旺气", "Prosperous Qi")
            case .sheng: return TAMEL10n.text("生气", "Growing Qi")
            case .ping: return TAMEL10n.text("平气", "Balanced Qi")
            case .tui: return TAMEL10n.text("退气", "Retreating Qi")
            case .shuai: return TAMEL10n.text("衰气", "Weak Qi")
            }
        }
        
        var description: String {
            if TAMEL10n.isEnglish {
            switch self {
            case .wang: return "Current prosperous qi"
            case .sheng: return "Future growing qi"
            case .ping: return "Balanced qi"
            case .tui: return "Retreating qi"
            case .shuai: return "Weak qi"
            }
        }

        switch self {
        case .wang: return "当运旺气，生机勃勃"
        case .sheng: return "未来生气，蓄势待发"
        case .ping: return "平和之气，不旺不衰"
        case .tui: return "退运之气，渐趋平淡"
        case .shuai: return "气场偏弱，宜谨慎参考"
        }
    }
    }
    
    // MARK: - 五行生克关系
    
    /// 五行生克关系
    enum WuxingRelation: String {
        case sheng = "相生"     // 生我或我生
        case ke = "相克"        // 克我或我克
        case bi = "比和"        // 同类
        case xie = "相泄"       // 泄我之气
        case hao = "相耗"       // 耗我之气
        case ping = "平和"      // 平和（理论上不会出现）
        
        var isFavorable: Bool {
            switch self {
            case .sheng, .bi, .ping: return true
            case .ke, .xie, .hao: return false
            }
        }
    }
    
    // MARK: - 纳气口数据结构
    
    /// 单个纳气口的完整分析数据
    struct NaqiPoint {
        let type: NaqiType              // 纳气口类型
        let name: String                // 自定义名称
        let angle: Double               // 罗盘角度（地盘角度）
        let naqiAngle: Double           // 纳气盘角度（天盘缝针，+7.5°）
        let direction: Direction        // 二十四山方位
        let element: Element            // 五行属性
        let yun: SanyuanJiuyun         // 当前运
        let yunElement: Element         // 当运五行
        let relation: WuxingRelation    // 与当运的生克关系
        let qiStatus: QiStatus          // 气的旺衰
        let xiangStar: Int              // 向星（从飞星盘获取）
        let analysis: String            // 吉凶分析
        let suggestions: [String]       // 建议
        
        /// 综合评分（0-100）
        var score: Int {
            var score = 50  // 基础分
            
            // 气的旺衰影响
            switch qiStatus {
            case .wang: score += 30
            case .sheng: score += 20
            case .ping: score += 0
            case .tui: score -= 10
            case .shuai: score -= 20
            }
            
            // 五行生克影响
            if relation.isFavorable {
                score += 15
            } else {
                score -= 15
            }
            
            // 向星旺衰影响
            let starStatus = FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: yun)
            switch starStatus {
            case .wang: score += 15
            case .sheng: score += 10
            case .tui: score -= 5
            case .shuai: score -= 10
            case .sha: score -= 20
            }
            
            return max(0, min(100, score))
        }
        
        /// 吉凶等级
        var level: String {
            switch score {
            case 80...100: return TAMEL10n.text("大吉", "Excellent")
            case 65...79: return TAMEL10n.text("吉", "Favorable")
            case 50...64: return TAMEL10n.text("平", "Balanced")
            case 35...49: return TAMEL10n.text("参考注意", "Observe")
            default: return TAMEL10n.text("较弱", "Cautious")
            }
        }
    }
    
    /// 多个纳气口的综合分析结果
    struct NaqiAnalysisResult {
        let points: [NaqiPoint]         // 所有纳气口
        let mainPoint: NaqiPoint?       // 主要纳气口（大门）
        let overallScore: Int           // 综合评分
        let overallLevel: String        // 综合等级
        let summary: String             // 总体概述
        let recommendations: [String]   // 综合建议
        
        /// 获取最佳纳气口
        var bestPoint: NaqiPoint? {
            return points.max(by: { $0.score < $1.score })
        }
        
        /// 获取最差纳气口
        var worstPoint: NaqiPoint? {
            return points.min(by: { $0.score < $1.score })
        }
    }
    
    // MARK: - 主要分析方法
    
    /// 分析单个纳气口
    /// - Parameters:
    ///   - type: 纳气口类型
    ///   - name: 自定义名称
    ///   - angle: 罗盘角度（地盘角度，0-360°）
    ///   - yun: 当前运（默认为当前时间对应的运）
    ///   - chart: 飞星排盘结果（可选，用于获取向星）
    /// - Returns: 纳气口分析数据
    static func analyzeNaqiPoint(
        type: NaqiType,
        name: String? = nil,
        angle: Double,
        yun: SanyuanJiuyun = .current,
        chart: CompleteFlyingStarPan? = nil
    ) -> NaqiPoint {
        // 1. 计算纳气盘角度（天盘缝针，顺时针偏移7.5°）
        let naqiAngle = normalized(angle + 7.5)
        
        // 2. 根据纳气盘角度判断二十四山方位
        let direction = Direction.from(angle: naqiAngle)
        
        // 3. 获取五行属性
        let element = direction.element
        
        // 4. 获取当运五行
        let yunElement = yun.element
        
        // 5. 分析五行生克关系
        let relation = analyzeWuxingRelation(from: element, to: yunElement)
        
        // 6. 以纳气口方位作为向盘依据，直接换算向星
        let xiangStar = resolveXiangStar(for: direction, chart: chart)

        // 7. 结合向星旺衰与五行关系判断纳气状态
        let qiStatus = analyzeQiStatus(xiangStar: xiangStar, relation: relation, yun: yun)
        
        // 8. 生成吉凶分析
        let analysis = generateAnalysis(
            type: type,
            direction: direction,
            element: element,
            relation: relation,
            qiStatus: qiStatus,
            xiangStar: xiangStar,
            yun: yun
        )
        
        // 9. 生成建议
        let suggestions = generateSuggestions(
            type: type,
            qiStatus: qiStatus,
            relation: relation,
            xiangStar: xiangStar,
            yun: yun
        )
        
        let displayName = name ?? type.localizedTitle
        
        return NaqiPoint(
            type: type,
            name: displayName,
            angle: angle,
            naqiAngle: naqiAngle,
            direction: direction,
            element: element,
            yun: yun,
            yunElement: yunElement,
            relation: relation,
            qiStatus: qiStatus,
            xiangStar: xiangStar,
            analysis: analysis,
            suggestions: suggestions
        )
    }
    
    /// 分析多个纳气口
    /// - Parameters:
    ///   - points: 纳气口信息数组 [(类型, 名称, 角度)]
    ///   - yun: 当前运
    ///   - chart: 飞星排盘结果
    /// - Returns: 综合分析结果
    static func analyzeMultiplePoints(
        points: [(type: NaqiType, name: String?, angle: Double)],
        yun: SanyuanJiuyun = .current,
        chart: CompleteFlyingStarPan? = nil
    ) -> NaqiAnalysisResult {
        
        // 分析每个纳气口
        let analyzedPoints = points.map { point in
            analyzeNaqiPoint(
                type: point.type,
                name: point.name,
                angle: point.angle,
                yun: yun,
                chart: chart
            )
        }
        
        // 找出主要纳气口（大门）
        let mainPoint = analyzedPoints.first(where: { $0.type == NaqiType.mainDoor })
        
        // 计算综合评分（加权平均）
        let totalWeight = analyzedPoints.reduce(0) { $0 + $1.type.importance }
        let weightedScore = analyzedPoints.reduce(0) { $0 + $1.score * $1.type.importance }
        let overallScore = totalWeight > 0 ? Int(weightedScore / totalWeight) : 50
        
        // 确定综合等级
        let overallLevel: String
        switch overallScore {
        case 80...100: overallLevel = TAMEL10n.text("大吉", "Excellent")
        case 65...79: overallLevel = TAMEL10n.text("吉", "Favorable")
        case 50...64: overallLevel = TAMEL10n.text("平", "Balanced")
        case 35...49: overallLevel = TAMEL10n.text("参考注意", "Observe")
        default: overallLevel = TAMEL10n.text("较弱", "Cautious")
        }
        
        // 生成总体概述
        let summary = generateOverallSummary(
            points: analyzedPoints,
            mainPoint: mainPoint,
            overallScore: overallScore
        )
        
        // 生成综合建议
        let recommendations = generateOverallRecommendations(
            points: analyzedPoints,
            overallScore: overallScore
        )
        
        return NaqiAnalysisResult(
            points: analyzedPoints,
            mainPoint: mainPoint,
            overallScore: overallScore,
            overallLevel: overallLevel,
            summary: summary,
            recommendations: recommendations
        )
    }
    
    // MARK: - 五行生克分析
    
    /// 分析两个五行之间的生克关系
    /// - Parameters:
    ///   - from: 纳气口五行
    ///   - to: 当运五行
    /// - Returns: 生克关系
    private static func analyzeWuxingRelation(from: Element, to: Element) -> WuxingRelation {
        if from == to {
            return .bi  // 比和
        }
        
        let shengRelations: [Element: Element] = [
            .wood: .fire,   // 木生火
            .fire: .earth,  // 火生土
            .earth: .metal, // 土生金
            .metal: .water, // 金生水
            .water: .wood   // 水生木
        ]
        
        if shengRelations[from] == to {
            return .xie  // 我生当运，主动泄气
        }
        
        if shengRelations[to] == from {
            return .sheng  // 当运生我
        }
        
        let keRelations: [Element: Element] = [
            .wood: .earth,  // 木克土
            .earth: .water, // 土克水
            .water: .fire,  // 水克火
            .fire: .metal,  // 火克金
            .metal: .wood   // 金克木
        ]
        
        if keRelations[from] == to {
            return .hao  // 我克当运，主动耗气
        }
        
        if keRelations[to] == from {
            return .ke  // 克我（凶）
        }
        
        return .ping  // 默认平和（实际不会到达这里）
    }
    
    /// 判断气的旺衰状态
    /// - Parameters:
    ///   - xiangStar: 纳气口对应的向星
    ///   - relation: 与当运的生克关系
    ///   - yun: 当前运
    /// - Returns: 气的旺衰状态
    private static func analyzeQiStatus(
        xiangStar: Int,
        relation: WuxingRelation,
        yun: SanyuanJiuyun
    ) -> QiStatus {
        let starStatus = FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: yun)
        let starScore: Int
        switch starStatus {
        case .wang: starScore = 4
        case .sheng: starScore = 2
        case .tui: starScore = -2
        case .shuai: starScore = -3
        case .sha: starScore = -4
        }

        let relationScore: Int
        switch relation {
        case .sheng, .bi: relationScore = 1
        case .ping: relationScore = 0
        case .xie: relationScore = -1
        case .hao, .ke: relationScore = -2
        }

        let total = starScore + relationScore
        switch total {
        case 4...:
            return .wang
        case 2...3:
            return .sheng
        case 0...1:
            return .ping
        case -2 ... -1:
            return .tui
        default:
            return .shuai
        }
    }
    
    // MARK: - 分析文本生成
    
    /// 生成吉凶分析文本
    private static func generateAnalysis(
        type: NaqiType,
        direction: Direction,
        element: Element,
        relation: WuxingRelation,
        qiStatus: QiStatus,
        xiangStar: Int,
        yun: SanyuanJiuyun
    ) -> String {
        if TAMEL10n.isEnglish {
            let elementName = element.localizedName.lowercased()
            let qiPhrase = qiStatus.description.lowercased()
            let starStage = starStatusEnglishLabel(FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: yun))
            var analysis = "\(type.localizedTitle) is at the \(direction.localizedLabel) sector, "
            analysis += "with a \(elementName) element profile and \(qiPhrase). "
            let yunElement = yun.element
            analysis += "It forms a \(relation.englishLabel) relationship with the current period \(yun.star) (\(yunElement.localizedLabel)). "
            let starName = FlyingStar.element(for: xiangStar)
            analysis += "Using the Naqi opening as the facing basis, the facing star is \(xiangStar) (\(starName.localizedLabel)) and is in a \(starStage) stage.\n\n"

            switch qiStatus {
            case .wang:
                analysis += "This sector aligns strongly with the active period and is a good reference point for core circulation."
            case .sheng:
                analysis += "This sector has future growth potential and can be observed as a secondary supportive opening."
            case .ping:
                analysis += "This sector reads as balanced and steady, without strong amplification."
            case .tui:
                analysis += "This sector is retreating and is better treated conservatively."
            case .shuai:
                analysis += "This sector is comparatively weak and is better used with caution."
            }

            return TAMEL10n.reviewSafeText(analysis)
        }

        var analysis = "\(type.localizedTitle)位于\(direction.localizedLabel)方，"
        analysis += "五行属\(element.localizedLabel)，"
        analysis += "收\(qiStatus.localizedTitle)。"
        
        let yunElement = yun.element
        analysis += "与当运\(yun.star)（\(yunElement.localizedLabel)）呈\(relation.localizedLabel)关系，"
        
        let starStatus = FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: yun)
        let starName = FlyingStar.element(for: xiangStar)
        analysis += "按纳气口起向盘，向星为\(xiangStar)（\(starName.localizedLabel)），属\(starStatus.localizedLabel)阶段。"
        
        analysis += "\n\n"
        switch qiStatus {
        case .wang:
            analysis += "此方位与当前元运配合度高，可作为重点观察的纳气参考。"
        case .sheng:
            analysis += "此方位具有后续提升空间，适合作为辅助纳气口持续观察。"
        case .ping:
            analysis += "此方位表现平稳，适合维持当前使用节奏。"
        case .tui:
            analysis += "此方位当前支持度偏弱，日常使用上宜更保守一些。"
        case .shuai:
            analysis += "此方位参考分值较低，建议结合采光、通风与动线一起复核。"
        }
        
        return TAMEL10n.reviewSafeText(analysis)
    }
    
    /// 生成建议
    private static func generateSuggestions(
        type: NaqiType,
        qiStatus: QiStatus,
        relation: WuxingRelation,
        xiangStar: Int,
        yun: SanyuanJiuyun
    ) -> [String] {
        var suggestions: [String] = []

        if TAMEL10n.isEnglish {
            switch qiStatus {
            case .wang:
                suggestions.append("Use this as a primary opening when possible.")
                if type == .mainDoor {
                    suggestions.append("Keep the entry bright and uncluttered to support stronger intake.")
                }
                suggestions.append("Soft moving decor or plants can reinforce this sector.")
            case .sheng:
                suggestions.append("Useful as a future-oriented supportive opening.")
                suggestions.append("Maintain it steadily without forcing heavy dependence.")
            case .ping:
                suggestions.append("No major adjustment is needed right now.")
                suggestions.append("Works as a secondary intake reference.")
            case .tui:
                suggestions.append("Avoid depending on this as the main opening.")
                suggestions.append("Reduce overuse if there are stronger options.")
            case .shuai:
                suggestions.append("Use this sector more cautiously.")
                if type != .mainDoor {
                    suggestions.append("Consider lowering long-term reliance on this opening.")
                } else {
                    suggestions.append("Keep the area clean and pair with calmer supportive materials.")
                }
            }

            let starStatus = FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: yun)
            if starStatus == .sha {
                suggestions.append("The facing star is cautionary, so observe this sector more carefully.")
            }

            if !relation.isFavorable {
                suggestions.append("Element balance is weaker here, so avoid overloading the sector.")
            }

            return suggestions.map(TAMEL10n.reviewSafeText)
        }
        
        switch qiStatus {
        case .wang:
            suggestions.append("可作为主要出入口，多加利用")
            if type == .mainDoor {
                suggestions.append("保持门口整洁明亮，有助于纳入旺气")
            }
            suggestions.append("此方位适合摆放绿植或流动装饰")
            
        case .sheng:
            suggestions.append("虽非当运，但可为未来布局")
            suggestions.append("适度使用，为将来蓄势")
            
        case .ping:
            suggestions.append("保持现状即可，无需特别调整")
            suggestions.append("可作为辅助纳气口使用")
            
        case .tui:
            suggestions.append("减少依赖，不宜作为主要出入口")
            suggestions.append("可适当减少开启频率，观察整体使用感受")
            
        case .shuai:
            suggestions.append("建议降低对此方位的长期依赖")
            if type != .mainDoor {
                suggestions.append("可先从减少高频开启开始做温和调整")
            } else {
                suggestions.append("保持区域整洁、明亮，并结合通风与动线一起复核")
            }
        }
        
        let starStatus = FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: yun)
        if starStatus == .sha {
            suggestions.append("向星处于需注意阶段，建议避免在该方位叠加过多干扰因素")
            suggestions.append("可优先从整洁度、采光和开启频率做轻量调整")
        }
        
        if !relation.isFavorable {
            suggestions.append("五行关系偏弱，可结合材质、色彩与空间使用习惯做平衡")
        }
        
        return suggestions.map(TAMEL10n.reviewSafeText)
    }
    
    /// 生成总体概述
    private static func generateOverallSummary(
        points: [NaqiPoint],
        mainPoint: NaqiPoint?,
        overallScore: Int
    ) -> String {
        if TAMEL10n.isEnglish {
            var summary = "This home currently tracks \(points.count) intake openings, with an overall score of \(overallScore)."

            if let main = mainPoint {
                summary += "\n\nThe main intake opening (\(main.type.localizedTitle)) is in the \(main.direction.localizedLabel) sector, carrying \(main.qiStatus.description.lowercased()) with a score of \(main.score) (\(main.level))."
            }

            let wangPoints = points.filter { $0.qiStatus == .wang }
            if !wangPoints.isEmpty {
                summary += "\n\n\(wangPoints.count) opening(s) are receiving prosperous qi: \(wangPoints.map { $0.name }.joined(separator: ", "))."
            }

            let weakPoints = points.filter { $0.qiStatus == .shuai }
            if !weakPoints.isEmpty {
                summary += "\n\n\(weakPoints.count) opening(s) read as comparatively weak and deserve more careful use."
            }

            return TAMEL10n.reviewSafeText(summary)
        }

        var summary = "本宅共有\(points.count)个纳气口，"
        summary += "综合评分\(overallScore)分。"
        
        if let main = mainPoint {
        summary += "\n\n主要纳气口（\(main.type.localizedTitle)）位于\(main.direction.localizedLabel)方，"
        summary += "收\(main.qiStatus.localizedTitle)，评分\(main.score)分（\(main.level)）。"
        }
        
        let wangPoints = points.filter { $0.qiStatus == .wang }
        if !wangPoints.isEmpty {
            summary += "\n\n有\(wangPoints.count)个纳气口收旺气，"
            summary += "分别为：\(wangPoints.map { $0.name }.joined(separator: "、"))。"
        }
        
        let shuaiPoints = points.filter { $0.qiStatus == .shuai }
        if !shuaiPoints.isEmpty {
            summary += "\n\n有\(shuaiPoints.count)个纳气口气场较弱，"
            summary += "建议适当调整。"
        }
        
        return TAMEL10n.reviewSafeText(summary)
    }
    
    /// 生成综合建议
    private static func generateOverallRecommendations(
        points: [NaqiPoint],
        overallScore: Int
    ) -> [String] {
        var recommendations: [String] = []

        if TAMEL10n.isEnglish {
            if overallScore >= 80 {
                recommendations.append("The intake structure is strong overall; keep the current pattern stable.")
                recommendations.append("Give slightly more weight to the strongest intake sector.")
            } else if overallScore >= 65 {
                recommendations.append("The intake structure is serviceable, with room to refine.")
                recommendations.append("Prioritize the best-performing opening in daily use.")
            } else if overallScore >= 50 {
                recommendations.append("The intake structure is balanced but not especially strong.")
                recommendations.append("Review whether the main opening should carry less dependence.")
            } else {
                recommendations.append("The intake structure would benefit from further adjustment.")
                recommendations.append("Treat major layout decisions with extra caution.")
            }

            if let best = points.max(by: { $0.score < $1.score }) {
                recommendations.append("Give more attention to \(best.name) (\(best.direction.localizedLabel)).")
            }

            if let worst = points.min(by: { $0.score < $1.score }),
               worst.score < 40 {
                recommendations.append("Reduce reliance on \(worst.name) (\(worst.direction.localizedLabel)).")
            }

            let elements = points.map { $0.element }
            let elementCounts = Dictionary(grouping: elements, by: { $0 }).mapValues { $0.count }
            if let dominant = elementCounts.max(by: { $0.value < $1.value }),
               dominant.value > points.count / 2 {
                recommendations.append("The opening mix leans toward \(dominant.key.localizedName.lowercased()) energy, so moderate the balance if needed.")
            }

            return recommendations.map(TAMEL10n.reviewSafeText)
        }
        
        if overallScore >= 80 {
            recommendations.append("整体纳气格局良好，继续保持")
            recommendations.append("可适当增加旺气方位的使用频率")
        } else if overallScore >= 65 {
            recommendations.append("纳气格局尚可，有提升空间")
            recommendations.append("建议优化主要纳气口的使用")
        } else if overallScore >= 50 {
            recommendations.append("纳气格局整体平稳，可继续观察主要纳气口表现")
            recommendations.append("建议复核日常高频开启的出入口与空间动线")
        } else {
            recommendations.append("纳气格局仍有优化空间")
            recommendations.append("建议结合采光、通风、整洁度与日常使用习惯做综合复核")
        }
        
        if let best = points.max(by: { $0.score < $1.score }) {
            recommendations.append("建议多利用\(best.name)（\(best.direction.localizedLabel)方）")
        }
        
        if let worst = points.min(by: { $0.score < $1.score }),
           worst.score < 40 {
            recommendations.append("建议减少使用\(worst.name)（\(worst.direction.localizedLabel)方）")
        }
        
        let elements = points.map { $0.element }
        let elementCounts = Dictionary(grouping: elements, by: { $0 }).mapValues { $0.count }
        if let dominant = elementCounts.max(by: { $0.value < $1.value }),
           dominant.value > points.count / 2 {
            recommendations.append("纳气口五行偏重\(dominant.key.localizedLabel)，可适当平衡")
        }
        
        return recommendations.map(TAMEL10n.reviewSafeText)
    }
    
    // MARK: - 辅助方法

    private static func resolveXiangStar(for direction: Direction, chart: CompleteFlyingStarPan?) -> Int {
        let mappedStar = FlyingStarCalculator.centerStar(for: direction)
        guard let chart else {
            return mappedStar
        }

        let chartStar = chart.xiangPan.stars[1][1]
        return chartStar == mappedStar ? chartStar : mappedStar
    }

    private static func normalized(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}

private extension NaqiAnalyzer.WuxingRelation {
    var localizedLabel: String {
        switch self {
        case .sheng: return TAMEL10n.text("相生", "Supportive")
        case .ke: return TAMEL10n.text("相克", "Controlling")
        case .bi: return TAMEL10n.text("比和", "Matching")
        case .xie: return TAMEL10n.text("相泄", "Draining")
        case .hao: return TAMEL10n.text("相耗", "Consuming")
        case .ping: return TAMEL10n.text("平和", "Neutral")
        }
    }

    var englishLabel: String {
        switch self {
        case .sheng: return "supportive"
        case .ke: return "controlling"
        case .bi: return "matching"
        case .xie: return "draining"
        case .hao: return "consuming"
        case .ping: return "neutral"
        }
    }
}

private extension NaqiAnalyzer {
    static func starStatusEnglishLabel(_ status: StarStatus) -> String {
        switch status {
        case .wang:
            return "current"
        case .sheng:
            return "rising"
        case .tui:
            return "retreating"
        case .shuai:
            return "weak"
        case .sha:
            return "cautionary"
        }
    }
}
