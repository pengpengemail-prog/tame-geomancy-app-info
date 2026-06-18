import Foundation

// 二十四山方位
enum Direction: String, CaseIterable, Identifiable {
    case ren = "壬"
    case zi = "子"
    case gui = "癸"
    case chou = "丑"
    case gen = "艮"
    case yin = "寅"
    case jia = "甲"
    case mao = "卯"
    case yi = "乙"
    case chen = "辰"
    case xun = "巽"
    case si = "巳"
    case bing = "丙"
    case wu = "午"
    case ding = "丁"
    case wei = "未"
    case kun = "坤"
    case shen = "申"
    case geng = "庚"
    case you = "酉"
    case xin = "辛"
    case xu = "戌"
    case qian = "乾"
    case hai = "亥"
    
    var id: String { rawValue }
    
    var chinese: String { rawValue }

    var localizedName: String {
        if !TAMEL10n.isEnglish {
            return rawValue
        }

        switch self {
        case .ren: return "Ren"
        case .zi: return "Zi"
        case .gui: return "Gui"
        case .chou: return "Chou"
        case .gen: return "Gen"
        case .yin: return "Yin"
        case .jia: return "Jia"
        case .mao: return "Mao"
        case .yi: return "Yi"
        case .chen: return "Chen"
        case .xun: return "Xun"
        case .si: return "Si"
        case .bing: return "Bing"
        case .wu: return "Wu"
        case .ding: return "Ding"
        case .wei: return "Wei"
        case .kun: return "Kun"
        case .shen: return "Shen"
        case .geng: return "Geng"
        case .you: return "You"
        case .xin: return "Xin"
        case .xu: return "Xu"
        case .qian: return "Qian"
        case .hai: return "Hai"
        }
    }

    var localizedLabel: String {
        TAMEL10n.isEnglish ? localizedName : chinese
    }
    
    var angle: Double {
        switch self {
        case .zi: return 0
        case .gui: return 15
        case .chou: return 30
        case .gen: return 45
        case .yin: return 60
        case .jia: return 75
        case .mao: return 90
        case .yi: return 105
        case .chen: return 120
        case .xun: return 135
        case .si: return 150
        case .bing: return 165
        case .wu: return 180
        case .ding: return 195
        case .wei: return 210
        case .kun: return 225
        case .shen: return 240
        case .geng: return 255
        case .you: return 270
        case .xin: return 285
        case .xu: return 300
        case .qian: return 315
        case .hai: return 330
        case .ren: return 345
        }
    }
    
    var element: Element {
        switch self {
        case .ren, .zi, .gui, .hai: return .water
        case .chou, .gen, .chen, .wei, .kun, .xu: return .earth
        case .yin, .jia, .mao, .yi, .xun: return .wood
        case .si, .bing, .wu, .ding: return .fire
        case .shen, .geng, .you, .xin, .qian: return .metal
        }
    }
    
    var opposite: Direction {
        let oppositeAngle = (angle + 180).truncatingRemainder(dividingBy: 360)
        return Direction.from(angle: oppositeAngle)
    }

    static let compassOrder: [Direction] = [
        .zi, .gui, .chou, .gen, .yin, .jia,
        .mao, .yi, .chen, .xun, .si, .bing,
        .wu, .ding, .wei, .kun, .shen, .geng,
        .you, .xin, .xu, .qian, .hai, .ren
    ]
    
    static func from(angle: Double) -> Direction {
        let positive = normalized(angle)
        let index = Int((positive + 7.5) / 15) % 24
        return Direction.compassOrder[index]
    }

    private static func normalized(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }
}

// 五行
enum Element: String {
    case wood = "木"
    case fire = "火"
    case earth = "土"
    case metal = "金"
    case water = "水"
    
    var chinese: String { rawValue }

    var localizedName: String {
        if !TAMEL10n.isEnglish {
            return rawValue
        }

        switch self {
        case .wood: return "Wood"
        case .fire: return "Fire"
        case .earth: return "Earth"
        case .metal: return "Metal"
        case .water: return "Water"
        }
    }

    var localizedLabel: String {
        TAMEL10n.isEnglish ? localizedName : chinese
    }
}

// 八卦
enum Bagua: String, CaseIterable, Identifiable {
    case qian = "乾"
    case kun = "坤"
    case zhen = "震"
    case xun = "巽"
    case kan = "坎"
    case li = "离"
    case gen = "艮"
    case dui = "兑"
    
    var id: String { rawValue }
    
    var chinese: String { rawValue }

    var localizedName: String {
        if !TAMEL10n.isEnglish {
            return rawValue
        }

        switch self {
        case .qian: return "Qian"
        case .kun: return "Kun"
        case .zhen: return "Zhen"
        case .xun: return "Xun"
        case .kan: return "Kan"
        case .li: return "Li"
        case .gen: return "Gen"
        case .dui: return "Dui"
        }
    }

    var localizedLabel: String {
        TAMEL10n.isEnglish ? localizedName : chinese
    }
    
    var angle: Double {
        switch self {
        case .qian: return 337.5
        case .kun: return 247.5
        case .zhen: return 97.5
        case .xun: return 157.5
        case .kan: return 7.5
        case .li: return 187.5
        case .gen: return 52.5
        case .dui: return 277.5
        }
    }
    
    var element: Element {
        switch self {
        case .qian, .dui: return .metal
        case .kun, .gen: return .earth
        case .zhen, .xun: return .wood
        case .kan: return .water
        case .li: return .fire
        }
    }
}
