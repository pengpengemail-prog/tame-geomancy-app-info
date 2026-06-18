import Foundation

class FlyingStarCalculator {
    private static let palaceStarMap: [Direction: Int] = [
        .ren: 1, .zi: 1, .gui: 1,
        .chou: 8, .gen: 8, .yin: 8,
        .jia: 3, .mao: 3, .yi: 3,
        .chen: 4, .xun: 4, .si: 4,
        .bing: 9, .wu: 9, .ding: 9,
        .wei: 2, .kun: 2, .shen: 2,
        .geng: 7, .you: 7, .xin: 7,
        .xu: 6, .qian: 6, .hai: 6
    ]

    private static let yangMountains: Set<Direction> = [
        .qian, .kun, .gen, .xun,
        .yin, .shen, .si, .hai,
        .jia, .geng, .bing, .ren
    ]
    
    // MARK: - 运盘计算（当运星入中宫）
    static func calculateYunPan(jiuyun: SanyuanJiuyun) -> NinePalace {
        var palace = NinePalace()
        let centerStar = jiuyun.rawValue
        palace.fly(centerStar: centerStar, clockwise: true)
        return palace
    }
    
    // MARK: - 山盘计算（坐山星入中宫）
    static func calculateShanPan(sitting: Direction, jiuyun: SanyuanJiuyun) -> NinePalace {
        var palace = NinePalace()
        let centerStar = centerStar(for: sitting)
        let clockwise = isClockwise(sitting)
        palace.fly(centerStar: centerStar, clockwise: clockwise)
        return palace
    }
    
    // MARK: - 向盘计算（向星入中宫，由纳气口决定）
    static func calculateXiangPan(
        facing: Direction,
        jiuyun: SanyuanJiuyun,
        naqiAngle: Double? = nil
    ) -> NinePalace {
        var palace = NinePalace()
        let naqiDirection = naqiAngle.map { direction(for: $0) } ?? facing
        let centerStar = centerStar(for: naqiDirection)
        let clockwise = !isClockwise(naqiDirection) // 向盘与山盘相反
        palace.fly(centerStar: centerStar, clockwise: clockwise)
        return palace
    }
    
    // MARK: - 流年盘计算
    static func calculateLiunianPan(year: Int) -> NinePalace {
        var palace = NinePalace()
        let centerStar = getLiunianStar(year: year)
        palace.fly(centerStar: centerStar, clockwise: true)
        return palace
    }
    
    // MARK: - 完整飞星盘（运盘+山盘+向盘+流年盘）
    static func calculateCompletePan(
        sitting: Direction,
        facing: Direction,
        jiuyun: SanyuanJiuyun,
        year: Int,
        naqiAngle: Double? = nil
    ) -> CompleteFlyingStarPan {
        let yunPan = calculateYunPan(jiuyun: jiuyun)
        let shanPan = calculateShanPan(sitting: sitting, jiuyun: jiuyun)
        let xiangPan = calculateXiangPan(facing: facing, jiuyun: jiuyun, naqiAngle: naqiAngle)
        let liunianPan = calculateLiunianPan(year: year)
        
        return CompleteFlyingStarPan(
            yunPan: yunPan,
            shanPan: shanPan,
            xiangPan: xiangPan,
            liunianPan: liunianPan,
            jiuyun: jiuyun
        )
    }
    
    // MARK: - 辅助方法

    static func centerStar(for direction: Direction) -> Int {
        palaceStarMap[direction] ?? 5
    }

    static func centerStar(forAngle angle: Double, applyNaqiOffset: Bool = false) -> Int {
        let direction = direction(for: angle, applyNaqiOffset: applyNaqiOffset)
        return centerStar(for: direction)
    }

    static func direction(for angle: Double, applyNaqiOffset: Bool = false) -> Direction {
        let adjusted = applyNaqiOffset ? normalized(angle + 7.5) : normalized(angle)
        return Direction.from(angle: adjusted)
    }
    
    // 判断顺飞还是逆飞
    private static func isClockwise(_ direction: Direction) -> Bool {
        // 以二十四山阴阳划分作为顺逆飞依据
        return yangMountains.contains(direction)
    }
    
    // 计算流年星
    private static func getLiunianStar(year: Int) -> Int {
        // 以公历年份取模，2024 年对应三碧入中，逐年逆序递减
        let star = 11 - (year % 9)
        return star > 9 ? star - 9 : star
    }

    private static func normalized(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
    
    // MARK: - 旺衰判断
    static func getStarStatus(star: Int, jiuyun: SanyuanJiuyun) -> StarStatus {
        let currentStar = jiuyun.rawValue
        
        if star == currentStar {
            return .wang // 当运星
        } else if star == currentStar + 1 || (currentStar == 9 && star == 1) {
            return .sheng // 未来运星
        } else if star == currentStar - 1 || (currentStar == 1 && star == 9) {
            return .tui // 上运星
        } else if star == 5 || star == 2 {
            return .sha // 五黄二黑
        } else {
            return .shuai // 衰星
        }
    }
    
    // 获取星曜吉凶描述
    static func getStarDescription(star: Int, status: StarStatus) -> String {
        let statusText = status.localizedLabel

        if TAMEL10n.isEnglish {
            switch star {
            case 1: return "1 White Water · \(statusText) · Learning and rapport"
            case 2: return "2 Black Earth · \(statusText) · Wellness reference"
            case 3: return "3 Jade Wood · \(statusText) · Debate and movement"
            case 4: return "4 Green Wood · \(statusText) · Study and writing"
            case 5: return "5 Yellow Earth · \(statusText) · Use with care"
            case 6: return "6 White Metal · \(statusText) · Authority and drive"
            case 7: return "7 Red Metal · \(statusText) · Expression and transition"
            case 8: return "8 White Earth · \(statusText) · Wealth support"
            case 9: return "9 Purple Fire · \(statusText) · Visibility and expression"
            default: return ""
            }
        }

        switch star {
        case 1: return "一白水星·\(statusText)·文昌桃花"
        case 2: return "二黑土星·\(statusText)·病符（民俗参考）"
        case 3: return "三碧木星·\(statusText)·是非口舌"
        case 4: return "四绿木星·\(statusText)·文昌学业"
        case 5: return "五黄土星·\(statusText)·需注意（民俗参考）"
        case 6: return "六白金星·\(statusText)·武曲权贵"
        case 7: return "七赤金星·\(statusText)·破军桃花"
        case 8: return "八白土星·\(statusText)·财星旺运"
        case 9: return "九紫火星·\(statusText)·喜庆吉星"
        default: return ""
        }
    }
}

// MARK: - 完整飞星盘数据结构
struct CompleteFlyingStarPan {
    let yunPan: NinePalace      // 运盘
    let shanPan: NinePalace     // 山盘（人丁健康）
    let xiangPan: NinePalace    // 向盘（财运事业）
    let liunianPan: NinePalace  // 流年盘
    let jiuyun: SanyuanJiuyun
    
    // 获取某个宫位的完整信息
    func getPalaceInfo(row: Int, col: Int) -> PalaceInfo {
        let yunStar = yunPan.stars[row][col]
        let shanStar = shanPan.stars[row][col]
        let xiangStar = xiangPan.stars[row][col]
        let liunianStar = liunianPan.stars[row][col]
        
        let yunStatus = FlyingStarCalculator.getStarStatus(star: yunStar, jiuyun: jiuyun)
        let shanStatus = FlyingStarCalculator.getStarStatus(star: shanStar, jiuyun: jiuyun)
        let xiangStatus = FlyingStarCalculator.getStarStatus(star: xiangStar, jiuyun: jiuyun)
        
        return PalaceInfo(
            position: (row, col),
            yunStar: yunStar,
            shanStar: shanStar,
            xiangStar: xiangStar,
            liunianStar: liunianStar,
            yunStatus: yunStatus,
            shanStatus: shanStatus,
            xiangStatus: xiangStatus
        )
    }
    
    // 获取所有九宫信息
    func getAllPalaces() -> [[PalaceInfo]] {
        var result: [[PalaceInfo]] = []
        for i in 0..<3 {
            var row: [PalaceInfo] = []
            for j in 0..<3 {
                row.append(getPalaceInfo(row: i, col: j))
            }
            result.append(row)
        }
        return result
    }
}

// MARK: - 单个宫位信息
struct PalaceInfo {
    let position: (Int, Int)
    let yunStar: Int
    let shanStar: Int
    let xiangStar: Int
    let liunianStar: Int
    let yunStatus: StarStatus
    let shanStatus: StarStatus
    let xiangStatus: StarStatus
    
    // 综合吉凶评分（0-100）
    var score: Int {
        var total = 0
        
        // 运盘权重40%
        total += statusScore(yunStatus) * 40 / 100
        
        // 山盘权重30%
        total += statusScore(shanStatus) * 30 / 100
        
        // 向盘权重30%
        total += statusScore(xiangStatus) * 30 / 100
        
        return total
    }
    
    private func statusScore(_ status: StarStatus) -> Int {
        switch status {
        case .wang: return 100
        case .sheng: return 80
        case .tui: return 50
        case .shuai: return 30
        case .sha: return 10
        }
    }
    
    // 吉凶等级
    var level: String {
        TAMEL10n.flyingStarLevel(for: score)
    }
    
    // 简要描述
    var summary: String {
        let yunDesc = FlyingStarCalculator.getStarDescription(star: yunStar, status: yunStatus)
        return "\(level) · \(yunDesc)"
    }
}
