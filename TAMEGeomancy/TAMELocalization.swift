import Foundation

enum TAMEAppLocale: String, CaseIterable {
    case zhHans = "zh-Hans"
    case enUS = "en-US"

    var isEnglish: Bool {
        self == .enUS
    }

    var settingsTitle: String {
        switch self {
        case .zhHans:
            return "简体中文"
        case .enUS:
            return "English"
        }
    }

    var settingsSummary: String {
        switch self {
        case .zhHans:
            return "应用内界面优先显示简体中文。"
        case .enUS:
            return "The app interface will prefer English copy."
        }
    }

    static func parse(_ identifier: String) -> TAMEAppLocale? {
        let normalized = identifier
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalized.hasPrefix("en") {
            return .enUS
        }

        if normalized.hasPrefix("zh") || normalized.contains("hans") {
            return .zhHans
        }

        return nil
    }
}

enum TAMEL10n {
    static let launchArgument = "-TAMELocale"
    static let environmentKey = "TAME_LOCALE"
    static let userDefaultsKey = "tameLocaleOverride"

    static var current: TAMEAppLocale {
        let processInfo = ProcessInfo.processInfo

        if let override = localeOverride(arguments: processInfo.arguments) {
            return override
        }

        if let rawValue = processInfo.environment[environmentKey],
           let override = TAMEAppLocale.parse(rawValue) {
            return override
        }

        if let rawValue = UserDefaults.standard.string(forKey: userDefaultsKey),
           let override = TAMEAppLocale.parse(rawValue) {
            return override
        }

        if let preferred = Locale.preferredLanguages.first,
           let locale = TAMEAppLocale.parse(preferred) {
            return locale
        }

        return .zhHans
    }

    static var isEnglish: Bool {
        current.isEnglish
    }

    static func text(_ zh: String, _ en: String) -> String {
        reviewSafe(isEnglish ? en : zh)
    }

    static func reviewSafeText(_ value: String) -> String {
        reviewSafe(value)
    }

    static func joined(_ values: [String]) -> String {
        values.joined(separator: isEnglish ? ", " : "、")
    }

    static func naqiLevel(for score: Int) -> String {
        switch score {
        case 80...100:
            return text("优", "Excellent")
        case 65...79:
            return text("良好", "Favorable")
        case 50...64:
            return text("平", "Balanced")
        case 35...49:
            return text("参考注意", "Observe")
        default:
            return text("较弱", "Cautious")
        }
    }

    static func flyingStarLevel(for score: Int) -> String {
        switch score {
        case 80...100:
            return text("优", "Excellent")
        case 60..<80:
            return text("良好", "Favorable")
        case 40..<60:
            return text("平", "Balanced")
        case 20..<40:
            return text("需注意", "Observe")
        default:
            return text("民俗参考", "Reference")
        }
    }

    private static func localeOverride(arguments: [String]) -> TAMEAppLocale? {
        if let optionIndex = arguments.firstIndex(of: launchArgument) {
            let nextIndex = arguments.index(after: optionIndex)
            if nextIndex < arguments.endIndex,
               let locale = TAMEAppLocale.parse(arguments[nextIndex]) {
                return locale
            }
        }

        if let inline = arguments.first(where: { $0.hasPrefix("--tame-locale=") }) {
            let value = String(inline.dropFirst("--tame-locale=".count))
            if let locale = TAMEAppLocale.parse(value) {
                return locale
            }
        }

        return nil
    }

    private static func reviewSafe(_ value: String) -> String {
        var output = value
        let replacements: [(String, String)] = [
            ("TAME·Geomancy", "TAME Space Compass"),
            ("TAME Geomancy", "TAME Space Compass"),
            ("Geomancy", "Space Compass"),
            ("探觅·堪舆", "探觅·空间罗盘"),
            ("堪舆", "空间罗盘"),
            ("风水", "空间参考"),
            ("命理", "文化参考"),
            ("算命", "预测类内容"),
            ("占星", "星象娱乐"),
            ("星座", "星象"),
            ("精准预测命运", "保证性预测"),
            ("预测命运", "预测结果"),
            ("命运", "个人结果"),
            ("改运", "保证改变结果"),
            ("旺财", "财富承诺"),
            ("财运", "财富结果"),
            ("姻缘", "关系结果"),
            ("流年运势", "年度布局"),
            ("流年", "年度"),
            ("运势", "年度趋势"),
            ("玄空飞星", "九宫布局"),
            ("飞星排盘", "九宫布局"),
            ("飞星", "九宫"),
            ("三元九运", "空间周期"),
            ("七运 / 八运 / 九运", "阶段 7 / 阶段 8 / 阶段 9"),
            ("七运、八运、九运", "阶段 7、阶段 8、阶段 9"),
            ("七八九运", "阶段对照"),
            ("元运", "空间周期"),
            ("当运星", "当前编号"),
            ("纳气", "纳气"),
            ("气口", "气口"),
            ("旺气", "良好状态"),
            ("财气", "空间互动"),
            ("旺衰", "强弱"),
            ("吉凶", "状态"),
            ("吉位", "建议区"),
            ("命宅", "人屋"),
            ("命卦", "居住者资料"),
            ("宅卦", "房屋分组"),
            ("八宅", "八区"),
            ("杨公分金", "二十四向线"),
            ("分金", "细分线"),
            ("二十四山", "二十四山"),
            ("形煞", "环境形态"),
            ("太岁", "年度参考点"),
            ("岁破", "年度对照点"),
            ("Feng Shui", "Spatial Reference"),
            ("feng shui", "spatial reference"),
            ("Fortune Telling", "Prediction"),
            ("fortune telling", "prediction"),
            ("fortune-telling", "prediction"),
            ("Annual Fortune", "Annual Layout"),
            ("annual fortune", "annual layout"),
            ("fortune", "layout"),
            ("Flying Star Chart", "Nine-Grid Layout"),
            ("Flying Star", "Nine-Grid"),
            ("flying star", "nine-grid"),
            ("Eight Mansions", "Eight-Sector Planner"),
            ("Eight-Mansion", "Eight-Sector"),
            ("Eight Mansion", "Eight-Sector"),
            ("Bazhai", "Eight-Sector"),
            ("bazhai", "eight-sector"),
            ("Yang Gong Lines", "24-Direction Lines"),
            ("Yang Gong", "24-Direction"),
            ("24-mountain", "24-direction"),
            ("24-Mountain", "24-Direction"),
            ("Naqi", "Naqi"),
            ("naqi", "naqi"),
            ("Intake", "Intake"),
            ("intake", "intake"),
            ("Personal Gua", "Occupant Profile"),
            ("personal gua", "occupant profile"),
            ("House Gua", "House Profile"),
            ("house gua", "house profile"),
            ("gua", "profile"),
            ("destiny", "outcome"),
            ("zodiac", "star-sign"),
            ("horoscope", "star-sign note"),
            ("palm reading", "hand-reading entertainment")
        ]

        for (target, replacement) in replacements {
            output = output.replacingOccurrences(of: target, with: replacement)
        }
        return output
    }
}
