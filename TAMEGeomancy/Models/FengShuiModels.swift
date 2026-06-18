import Foundation

// 三元九运
enum SanyuanJiuyun: Int, CaseIterable {
    case qi = 7   // 七运 1984-2003
    case ba = 8   // 八运 2004-2023
    case jiu = 9  // 九运 2024-2043
    
    var period: String {
        switch self {
        case .qi: return "1984-2003"
        case .ba: return "2004-2023"
        case .jiu: return "2024-2043"
        }
    }

    var localizedPeriodName: String {
        switch self {
        case .qi:
            return TAMEL10n.text("七运", "Period 7")
        case .ba:
            return TAMEL10n.text("八运", "Period 8")
        case .jiu:
            return TAMEL10n.text("九运", "Period 9")
        }
    }
    
    var star: String {
        if TAMEL10n.isEnglish {
            switch self {
            case .qi: return "7 Red Metal"
            case .ba: return "8 White Earth"
            case .jiu: return "9 Purple Fire"
            }
        }

        switch self {
        case .qi: return "七赤金"
        case .ba: return "八白土"
        case .jiu: return "九紫火"
        }
    }
    
    var element: Element {
        switch self {
        case .qi: return .metal
        case .ba: return .earth
        case .jiu: return .fire
        }
    }
    
    static func from(year: Int) -> SanyuanJiuyun {
        if year >= 1984 && year <= 2003 {
            return .qi
        } else if year >= 2004 && year <= 2023 {
            return .ba
        } else {
            return .jiu
        }
    }
    
    static var current: SanyuanJiuyun {
        let year = Calendar.current.component(.year, from: Date())
        return from(year: year)
    }
}

// 玄空飞星
struct FlyingStar {
    let number: Int
    let element: Element
    let status: StarStatus
    
    var chinese: String {
        if TAMEL10n.isEnglish {
            switch number {
            case 1: return "1 White Water"
            case 2: return "2 Black Earth"
            case 3: return "3 Jade Wood"
            case 4: return "4 Green Wood"
            case 5: return "5 Yellow Earth"
            case 6: return "6 White Metal"
            case 7: return "7 Red Metal"
            case 8: return "8 White Earth"
            case 9: return "9 Purple Fire"
            default: return ""
            }
        }

        switch number {
        case 1: return "一白水"
        case 2: return "二黑土"
        case 3: return "三碧木"
        case 4: return "四绿木"
        case 5: return "五黄土"
        case 6: return "六白金"
        case 7: return "七赤金"
        case 8: return "八白土"
        case 9: return "九紫火"
        default: return ""
        }
    }
    
    static func element(for number: Int) -> Element {
        switch number {
        case 1: return .water
        case 2, 5, 8: return .earth
        case 3, 4: return .wood
        case 6, 7: return .metal
        case 9: return .fire
        default: return .earth
        }
    }
}

enum StarStatus: String {
    case wang = "旺"      // 当运星
    case sheng = "生"     // 未来运星
    case tui = "退"       // 上运星
    case shuai = "衰"     // 更早运星
    case sha = "煞"       // 五黄二黑

    var localizedLabel: String {
        switch self {
        case .wang:
            return TAMEL10n.text("旺", "Current")
        case .sheng:
            return TAMEL10n.text("生", "Future")
        case .tui:
            return TAMEL10n.text("退", "Retreating")
        case .shuai:
            return TAMEL10n.text("衰", "Weak")
        case .sha:
            return TAMEL10n.text("煞", "Caution")
        }
    }
}

// 九宫格
struct NinePalace {
    var stars: [[Int]] = Array(repeating: Array(repeating: 0, count: 3), count: 3)
    
    // 洛书顺序
    static let luoshuOrder = [
        [4, 9, 2],
        [3, 5, 7],
        [8, 1, 6]
    ]
    
    mutating func fly(centerStar: Int, clockwise: Bool = true) {
        // 洛书飞星顺序：中宫开始，按洛书轨迹飞布
        // 顺飞：中→西北→西→东北→南→北→西南→东→东南
        // 逆飞：中→东南→东→西南→北→南→东北→西→西北
        
        // 先设置中宫
        stars[1][1] = centerStar
        
        // 飞星顺序（按洛书位置）
        let sequence = clockwise ? 
            [6, 2, 8, 4, 9, 3, 7, 1] :  // 顺飞：6乾2坤8艮4巽9离3震7兑1坎
            [1, 7, 3, 9, 4, 8, 2, 6]    // 逆飞：反向
        
        var currentStar = centerStar
        for luoshuPos in sequence {
            currentStar = currentStar % 9 + 1
            let (row, col) = positionToCoordinate(luoshuPos)
            stars[row][col] = currentStar
        }
    }
    
    private func positionToCoordinate(_ position: Int) -> (Int, Int) {
        for i in 0..<3 {
            for j in 0..<3 {
                if NinePalace.luoshuOrder[i][j] == position {
                    return (i, j)
                }
            }
        }
        return (1, 1)
    }
}
