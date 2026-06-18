import SwiftUI

enum BazhaiDirection: String, CaseIterable, Identifiable {
    case north = "北"
    case northeast = "东北"
    case east = "东"
    case southeast = "东南"
    case south = "南"
    case southwest = "西南"
    case west = "西"
    case northwest = "西北"

    var id: String { rawValue }

    var localizedName: String {
        if !TAMEL10n.isEnglish {
            return rawValue
        }

        switch self {
        case .north: return "North"
        case .northeast: return "Northeast"
        case .east: return "East"
        case .southeast: return "Southeast"
        case .south: return "South"
        case .southwest: return "Southwest"
        case .west: return "West"
        case .northwest: return "Northwest"
        }
    }

    var localizedLabel: String {
        TAMEL10n.isEnglish ? localizedName : rawValue
    }

    var opposite: BazhaiDirection {
        switch self {
        case .north: return .south
        case .northeast: return .southwest
        case .east: return .west
        case .southeast: return .northwest
        case .south: return .north
        case .southwest: return .northeast
        case .west: return .east
        case .northwest: return .southeast
        }
    }
}

enum BazhaiPosition: String, CaseIterable, Identifiable {
    case shengqi = "生气"
    case tianyi = "天医"
    case yannian = "延年"
    case fuwei = "伏位"
    case huohai = "祸害"
    case liusha = "六煞"
    case wugui = "五鬼"
    case jueming = "绝命"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .shengqi:
            return TAMEL10n.text("生气", "Shengqi")
        case .tianyi:
            return TAMEL10n.text("天医", "Tianyi")
        case .yannian:
            return TAMEL10n.text("延年", "Yannian")
        case .fuwei:
            return TAMEL10n.text("伏位", "Fuwei")
        case .huohai:
            return TAMEL10n.text("祸害", "Huohai")
        case .liusha:
            return TAMEL10n.text("六煞", "Liusha")
        case .wugui:
            return TAMEL10n.text("五鬼", "Wugui")
        case .jueming:
            return TAMEL10n.text("绝命", "Jueming")
        }
    }

    var isAuspicious: Bool {
        switch self {
        case .shengqi, .tianyi, .yannian, .fuwei:
            return true
        case .huohai, .liusha, .wugui, .jueming:
            return false
        }
    }

    var referenceDescription: String {
        if TAMEL10n.isEnglish {
            switch self {
            case .shengqi:
                return "Often used for momentum, growth, and active living areas."
            case .tianyi:
                return "Often used for rest, care, and supportive sleeping areas."
            case .yannian:
                return "Often linked to stability and long-term relationship harmony."
            case .fuwei:
                return "Often used for calm, study, focus, and quieter routines."
            case .huohai:
                return "A lighter caution area; avoid overloading core functions here."
            case .liusha:
                return "Often treated as a noisy or distracting area in folk reference."
            case .wugui:
                return "Often treated as a volatile area; avoid key rest functions here."
            case .jueming:
                return "Usually treated as a stronger caution area in folk reference."
            }
        }

        switch self {
        case .shengqi:
            return "偏向事业拓展与活力提升，适合作为起居和办公重点位。"
        case .tianyi:
            return "偏向健康、照护与贵人助力，适合卧室与休息位。"
        case .yannian:
            return "偏向关系稳定与长期协同，适合主卧、会客区。"
        case .fuwei:
            return "偏向稳定、沉静与积累，适合学习、冥想或安静使用。"
        case .huohai:
            return "民俗上常作轻度干扰位，宜降低核心功能密度。"
        case .liusha:
            return "民俗上多与人际杂讯相关，宜保持清爽整洁。"
        case .wugui:
            return "民俗上常作波动位，宜避免承载重要休息功能。"
        case .jueming:
            return "民俗上常作重点规避位，宜减少长期停留与动线冲突。"
        }
    }
}

enum HouseType: String {
    case eastFour = "东四宅"
    case westFour = "西四宅"

    var localizedTitle: String {
        switch self {
        case .eastFour:
            return TAMEL10n.text("东四宅", "East Group House")
        case .westFour:
            return TAMEL10n.text("西四宅", "West Group House")
        }
    }
}

struct BazhaiSector: Identifiable {
    let direction: BazhaiDirection
    let position: BazhaiPosition

    var id: BazhaiDirection { direction }
}

struct RoomSuggestion: Identifiable {
    let roomType: String
    let recommendedDirections: [BazhaiDirection]
    let avoidDirections: [BazhaiDirection]
    let reason: String

    var id: String { roomType }
}

struct MingGuaProfile {
    let gua: Bagua
    let group: HouseType
}

struct BazhaiAnalysis {
    let houseGua: Bagua
    let houseType: HouseType
    let facingDirection: BazhaiDirection
    let sectors: [BazhaiSector]
    let auspiciousDirections: [BazhaiDirection]
    let inauspiciousDirections: [BazhaiDirection]
    let roomSuggestions: [RoomSuggestion]
    let overallAdvice: String
    let mingGuaProfile: MingGuaProfile?
    let compatibilitySummary: String
}

final class BazhaiViewModel: ObservableObject {
    @Published var sittingDirection: BazhaiDirection = .north
    @Published var analysis: BazhaiAnalysis?
    @Published var birthYearText: String = ""
    @Published var useOccupantProfile: Bool = false

    func analyze() {
        let houseGua = Self.calculateHouseGua(sitting: sittingDirection)
        let houseType = Self.determineHouseType(gua: houseGua)
        let sectors = Self.calculateEightDirections(gua: houseGua)
        let auspicious = sectors.filter(\.position.isAuspicious).map(\.direction)
        let inauspicious = sectors.filter { !$0.position.isAuspicious }.map(\.direction)
        let facing = sittingDirection.opposite
        let roomSuggestions = Self.generateRoomSuggestions(sectors: sectors)
        let overallAdvice = Self.generateOverallAdvice(houseType: houseType, sectors: sectors, facing: facing)
        let mingGuaProfile = useOccupantProfile ? parsedBirthYear.flatMap(Self.calculateMingGuaProfile) : nil
        let compatibilitySummary = Self.generateCompatibilitySummary(houseType: houseType, mingGuaProfile: mingGuaProfile)

        analysis = BazhaiAnalysis(
            houseGua: houseGua,
            houseType: houseType,
            facingDirection: facing,
            sectors: sectors,
            auspiciousDirections: auspicious,
            inauspiciousDirections: inauspicious,
            roomSuggestions: roomSuggestions,
            overallAdvice: overallAdvice,
            mingGuaProfile: mingGuaProfile,
            compatibilitySummary: compatibilitySummary
        )
    }

    var parsedBirthYear: Int? {
        Int(birthYearText.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    static func calculateHouseGua(sitting: BazhaiDirection) -> Bagua {
        switch sitting {
        case .north: return .kan
        case .northeast: return .gen
        case .east: return .zhen
        case .southeast: return .xun
        case .south: return .li
        case .southwest: return .kun
        case .west: return .dui
        case .northwest: return .qian
        }
    }

    static func determineHouseType(gua: Bagua) -> HouseType {
        switch gua {
        case .zhen, .xun, .li, .kan:
            return .eastFour
        case .qian, .kun, .gen, .dui:
            return .westFour
        }
    }

    static func calculateEightDirections(gua: Bagua) -> [BazhaiSector] {
        let mapping = bazhaiMap[gua] ?? [:]
        return BazhaiDirection.allCases.map { direction in
            BazhaiSector(direction: direction, position: mapping[direction] ?? .fuwei)
        }
    }

    static func calculateMingGuaProfile(birthYear: Int) -> MingGuaProfile {
        let lastTwoDigits = birthYear % 100
        let digitSum = lastTwoDigits
            .description
            .compactMap(\.wholeNumberValue)
            .reduce(0, +)

        let normalized = digitSum > 9
            ? digitSum.description.compactMap(\.wholeNumberValue).reduce(0, +)
            : digitSum

        let guaNumber = normalized == 0 ? 9 : normalized
        let bagua: Bagua

        switch guaNumber {
        case 1: bagua = .kan
        case 2: bagua = .kun
        case 3: bagua = .zhen
        case 4: bagua = .xun
        case 6: bagua = .qian
        case 7: bagua = .dui
        case 8: bagua = .gen
        case 9: bagua = .li
        default: bagua = .kan
        }

        return MingGuaProfile(gua: bagua, group: determineHouseType(gua: bagua))
    }

    private static func generateRoomSuggestions(sectors: [BazhaiSector]) -> [RoomSuggestion] {
        let sectorLookup = Dictionary(uniqueKeysWithValues: sectors.map { ($0.position, $0.direction) })
        let bedroomGood = compactDirections([.tianyi, .yannian], from: sectorLookup)
        let studyGood = compactDirections([.shengqi, .fuwei], from: sectorLookup)
        let livingGood = compactDirections([.shengqi, .yannian], from: sectorLookup)
        let avoidCore = compactDirections([.jueming, .wugui], from: sectorLookup)
        let utility = compactDirections([.huohai, .liusha], from: sectorLookup)

        return [
            RoomSuggestion(
                roomType: TAMEL10n.text("主卧", "Primary Bedroom"),
                recommendedDirections: bedroomGood,
                avoidDirections: avoidCore,
                reason: TAMEL10n.text("优先参考天医、延年位，偏向稳定休息与关系和谐。", "Prefer Tianyi and Yannian sectors for stable rest and relationship harmony.")
            ),
            RoomSuggestion(
                roomType: TAMEL10n.text("书房 / 工作区", "Study / Work Area"),
                recommendedDirections: studyGood,
                avoidDirections: utility,
                reason: TAMEL10n.text("生气、伏位更适合专注与持续输出。", "Shengqi and Fuwei are more suitable for focus and sustained work.")
            ),
            RoomSuggestion(
                roomType: TAMEL10n.text("客厅 / 会客区", "Living / Hosting Area"),
                recommendedDirections: livingGood,
                avoidDirections: avoidCore,
                reason: TAMEL10n.text("生气、延年位更利于家庭活动与会客动线。", "Shengqi and Yannian often suit family activity and hosting circulation.")
            ),
            RoomSuggestion(
                roomType: TAMEL10n.text("厨卫 / 杂物区", "Kitchen / Utility Area"),
                recommendedDirections: utility,
                avoidDirections: bedroomGood,
                reason: TAMEL10n.text("轻度参考位可承接次要功能，尽量不占用核心吉位。", "Secondary functions can sit in lighter-reference sectors to keep stronger sectors open.")
            )
        ]
    }

    private static func generateOverallAdvice(
        houseType: HouseType,
        sectors: [BazhaiSector],
        facing: BazhaiDirection
    ) -> String {
        let strongest = sectors.first(where: { $0.position == .shengqi })?.direction.localizedLabel ?? TAMEL10n.text("未识别", "Unresolved")
        let support = sectors.first(where: { $0.position == .tianyi })?.direction.localizedLabel ?? TAMEL10n.text("未识别", "Unresolved")
        let cautiousDirections = sectors
            .filter { !$0.position.isAuspicious }
            .map(\.direction.localizedLabel)
            .joined(separator: TAMEL10n.isEnglish ? ", " : "、")

        if TAMEL10n.isEnglish {
            return "This home belongs to the \(houseType.localizedTitle) and currently faces \(facing.localizedLabel). Where practical, keep key living, work, and rest zones closer to \(strongest) and \(support), while reserving \(cautiousDirections) for lighter supporting uses."
        }

        return "此宅为\(houseType.localizedTitle)，当前朝向为\(facing.localizedLabel)。起居、工作、主卧等核心空间可优先靠近\(strongest)与\(support)等参考吉位；\(cautiousDirections)等位置更适合承接次要功能。仅供民俗文化参考。"
    }

    private static func generateCompatibilitySummary(
        houseType: HouseType,
        mingGuaProfile: MingGuaProfile?
    ) -> String {
        guard let mingGuaProfile else {
            return TAMEL10n.text("未输入出生年份，当前先按宅卦完成基础分析。", "No birth year entered yet, so the current view focuses on the house gua first.")
        }

        if mingGuaProfile.group == houseType {
            return TAMEL10n.text(
                "命卦为\(mingGuaProfile.gua.localizedLabel)，属\(mingGuaProfile.group.localizedTitle)，与宅型分组一致，民俗上视为较协调。",
                "The personal gua is \(mingGuaProfile.gua.localizedLabel), within the \(mingGuaProfile.group.localizedTitle), and aligns with the current house grouping."
            )
        }

        return TAMEL10n.text(
            "命卦为\(mingGuaProfile.gua.localizedLabel)，属\(mingGuaProfile.group.localizedTitle)，与当前宅型分组不同；建议更重视卧室与工作区在吉位的落点。",
            "The personal gua is \(mingGuaProfile.gua.localizedLabel), within the \(mingGuaProfile.group.localizedTitle), and does not match the current house grouping, so bedroom and work-area placement deserve closer attention."
        )
    }

    private static func compactDirections(
        _ positions: [BazhaiPosition],
        from lookup: [BazhaiPosition: BazhaiDirection]
    ) -> [BazhaiDirection] {
        positions.compactMap { lookup[$0] }
    }

    private static let bazhaiMap: [Bagua: [BazhaiDirection: BazhaiPosition]] = [
        .kan: [
            .southeast: .shengqi, .east: .tianyi, .south: .yannian, .north: .fuwei,
            .west: .huohai, .northeast: .liusha, .southwest: .wugui, .northwest: .jueming
        ],
        .li: [
            .east: .shengqi, .southeast: .tianyi, .north: .yannian, .south: .fuwei,
            .southwest: .huohai, .northwest: .liusha, .west: .wugui, .northeast: .jueming
        ],
        .zhen: [
            .south: .shengqi, .north: .tianyi, .southeast: .yannian, .east: .fuwei,
            .northwest: .huohai, .west: .liusha, .northeast: .wugui, .southwest: .jueming
        ],
        .xun: [
            .north: .shengqi, .south: .tianyi, .east: .yannian, .southeast: .fuwei,
            .northeast: .huohai, .southwest: .liusha, .northwest: .wugui, .west: .jueming
        ],
        .qian: [
            .west: .shengqi, .northeast: .tianyi, .southwest: .yannian, .northwest: .fuwei,
            .south: .huohai, .southeast: .liusha, .north: .wugui, .east: .jueming
        ],
        .kun: [
            .northeast: .shengqi, .west: .tianyi, .northwest: .yannian, .southwest: .fuwei,
            .east: .huohai, .north: .liusha, .southeast: .wugui, .south: .jueming
        ],
        .gen: [
            .southwest: .shengqi, .northwest: .tianyi, .west: .yannian, .northeast: .fuwei,
            .southeast: .huohai, .south: .liusha, .east: .wugui, .north: .jueming
        ],
        .dui: [
            .northwest: .shengqi, .southwest: .tianyi, .northeast: .yannian, .west: .fuwei,
            .north: .huohai, .east: .liusha, .south: .wugui, .southeast: .jueming
        ]
    ]
}
