import SwiftUI
import Combine
import UIKit

enum FloorPlanRoomType: String, CaseIterable, Identifiable {
    case mainDoor = "大门"
    case balcony = "阳台"
    case window = "窗户"
    case livingRoom = "客厅"
    case bedroom = "卧室"
    case kitchen = "厨房"
    case bathroom = "卫生间"
    case study = "书房"

    var id: String { rawValue }

    var localizedTitle: String {
        switch self {
        case .mainDoor: return TAMEL10n.text("大门", "Main Door")
        case .balcony: return TAMEL10n.text("阳台", "Balcony")
        case .window: return TAMEL10n.text("窗户", "Window")
        case .livingRoom: return TAMEL10n.text("客厅", "Living Room")
        case .bedroom: return TAMEL10n.text("卧室", "Bedroom")
        case .kitchen: return TAMEL10n.text("厨房", "Kitchen")
        case .bathroom: return TAMEL10n.text("卫生间", "Bathroom")
        case .study: return TAMEL10n.text("书房", "Study")
        }
    }
}

struct FloorPlanRoomMarker: Identifiable, Equatable {
    let id: UUID
    let type: FloorPlanRoomType
    let point: CGPoint

    init(id: UUID = UUID(), type: FloorPlanRoomType, point: CGPoint) {
        self.id = id
        self.type = type
        self.point = point
    }
}

/// 户型图分析数据模型
struct FloorPlanAnalysis {
    let palaces: [[PalaceInfo]]
    let auspiciousPositions: [(Int, Int)]
    let inauspiciousPositions: [(Int, Int)]
    let recommendation: String
    let mainDoorNaqi: NaqiAnalyzer.NaqiPoint?
    let naqiResult: NaqiAnalyzer.NaqiAnalysisResult?
    let primaryNaqiPoint: NaqiAnalyzer.NaqiPoint?
    let analysisBasis: String
    let roomAssessments: [FloorPlanRoomAssessment]

    init(
        palaces: [[PalaceInfo]],
        auspiciousPositions: [(Int, Int)],
        inauspiciousPositions: [(Int, Int)],
        recommendation: String,
        mainDoorNaqi: NaqiAnalyzer.NaqiPoint? = nil,
        naqiResult: NaqiAnalyzer.NaqiAnalysisResult? = nil,
        primaryNaqiPoint: NaqiAnalyzer.NaqiPoint? = nil,
        analysisBasis: String = "",
        roomAssessments: [FloorPlanRoomAssessment] = []
    ) {
        self.palaces = palaces
        self.auspiciousPositions = auspiciousPositions
        self.inauspiciousPositions = inauspiciousPositions
        self.recommendation = recommendation
        self.mainDoorNaqi = mainDoorNaqi
        self.naqiResult = naqiResult
        self.primaryNaqiPoint = primaryNaqiPoint
        self.analysisBasis = analysisBasis
        self.roomAssessments = roomAssessments
    }
}

enum FloorPlanHeatLevel: String {
    case excellent = "旺位"
    case supportive = "吉位"
    case balanced = "平位"
    case caution = "注意位"

    var localizedTitle: String {
        switch self {
        case .excellent: return TAMEL10n.text("旺位", "Prime")
        case .supportive: return TAMEL10n.text("吉位", "Supportive")
        case .balanced: return TAMEL10n.text("平位", "Balanced")
        case .caution: return TAMEL10n.text("注意位", "Caution")
        }
    }
}

enum FloorPlanRoomSuitability: String {
    case favorable = "适合"
    case acceptable = "可用"
    case caution = "需调整"
    case avoid = "不宜"

    var localizedTitle: String {
        switch self {
        case .favorable: return TAMEL10n.text("适合", "Best Fit")
        case .acceptable: return TAMEL10n.text("可用", "Usable")
        case .caution: return TAMEL10n.text("需调整", "Adjust")
        case .avoid: return TAMEL10n.text("不宜", "Avoid")
        }
    }
}

struct FloorPlanRoomAssessment: Identifiable, Equatable {
    let id: UUID
    let label: String
    let type: FloorPlanRoomType
    let palace: (Int, Int)
    let palaceName: String
    let palaceScore: Int
    let suitabilityScore: Int
    let heatLevel: FloorPlanHeatLevel
    let suitability: FloorPlanRoomSuitability
    let naqiRelationshipSummary: String
    let naqiAdjustment: Int
    let distanceToPrimaryNaqi: Double?
    let isNearPrimaryNaqi: Bool
    let advice: String

    var summary: String {
        TAMEL10n.text(
            "\(label)：\(palaceName)宫 · \(suitability.localizedTitle) · \(suitabilityScore)分",
            "\(label): \(palaceName) · \(suitability.localizedTitle) · \(suitabilityScore)"
        )
    }

    static func == (lhs: FloorPlanRoomAssessment, rhs: FloorPlanRoomAssessment) -> Bool {
        lhs.id == rhs.id &&
        lhs.label == rhs.label &&
        lhs.type == rhs.type &&
        lhs.palace.0 == rhs.palace.0 &&
        lhs.palace.1 == rhs.palace.1 &&
        lhs.palaceName == rhs.palaceName &&
        lhs.palaceScore == rhs.palaceScore &&
        lhs.suitabilityScore == rhs.suitabilityScore &&
        lhs.heatLevel == rhs.heatLevel &&
        lhs.suitability == rhs.suitability &&
        lhs.naqiRelationshipSummary == rhs.naqiRelationshipSummary &&
        lhs.naqiAdjustment == rhs.naqiAdjustment &&
        lhs.distanceToPrimaryNaqi == rhs.distanceToPrimaryNaqi &&
        lhs.isNearPrimaryNaqi == rhs.isNearPrimaryNaqi &&
        lhs.advice == rhs.advice
    }
}

private enum FloorPlanNaqiDistanceBand {
    case sameOpening
    case near
    case supportive
    case distant
}

/// 户型图分析 ViewModel
class FloorPlanAnalysisViewModel: ObservableObject {
    @Published var floorPlanImage: UIImage?
    @Published var showGrid: Bool = true
    @Published var showHeatmap: Bool = true
    @Published var analysis: FloorPlanAnalysis?
    @Published var isAnalyzing: Bool = false
    @Published var isUsingDemoLayout: Bool = false
    @Published var centerPoint: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @Published var facingDirection: Direction = .wu
    @Published var roomMarkers: [FloorPlanRoomMarker] = []
    @Published var selectedMarkerType: FloorPlanRoomType = .mainDoor
    
    var hasAnalysis: Bool {
        analysis != nil
    }
    
    /// 分析户型图
    func analyzeFloorPlan() {
        guard floorPlanImage != nil else { return }
        
        isAnalyzing = true
        
        // 模拟分析过程（实际项目中可以接入 AI 识别）
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.performAnalysis()
            self?.isAnalyzing = false
        }
    }
    
    private func performAnalysis() {
        // 获取当前元运
        let jiuyun = SanyuanJiuyun.current
        
        let facing = facingDirection
        let sitting = facing.opposite
        let year = Calendar.current.component(.year, from: Date())
        let naqiMarkerInputs = currentNaqiMarkerInputs()
        let provisionalNaqiResult = naqiMarkerInputs.isEmpty ? nil : NaqiAnalyzer.analyzeMultiplePoints(
            points: naqiMarkerInputs,
            yun: jiuyun
        )
        let primaryNaqiBasis = preferredNaqiBasis(from: provisionalNaqiResult)
        
        // 计算完整飞星盘
        let chart = FlyingStarCalculator.calculateCompletePan(
            sitting: sitting,
            facing: facing,
            jiuyun: jiuyun,
            year: year,
            naqiAngle: primaryNaqiBasis?.naqiAngle
        )

        let naqiResult = naqiMarkerInputs.isEmpty ? nil : NaqiAnalyzer.analyzeMultiplePoints(
            points: naqiMarkerInputs,
            yun: jiuyun,
            chart: chart
        )
        let mainDoorNaqi = naqiResult?.mainPoint
        let primaryNaqiPoint = preferredNaqiBasis(from: naqiResult)
        
        // 获取所有九宫信息
        let palaces = chart.getAllPalaces()
        
        // 分析吉凶方位
        var auspicious: [(Int, Int)] = []
        var inauspicious: [(Int, Int)] = []
        
        for i in 0..<3 {
            for j in 0..<3 {
                let info = palaces[i][j]
                if info.score >= 70 {
                    auspicious.append((i, j))
                } else if info.score < 40 {
                    inauspicious.append((i, j))
                }
            }
        }

        let roomAssessments = buildRoomAssessments(
            palaces: palaces,
            primaryNaqiPoint: primaryNaqiPoint
        )
        
        // 生成建议
        let recommendation = generateRecommendation(
            auspicious: auspicious,
            inauspicious: inauspicious,
            mainDoorNaqi: mainDoorNaqi,
            primaryNaqiPoint: primaryNaqiPoint,
            naqiResult: naqiResult,
            roomAssessments: roomAssessments
        )

        let analysisBasis = primaryNaqiPoint.map {
            let basisLabel = $0.type == .mainDoor
                ? TAMEL10n.text("大门纳气口", "main intake opening")
                : TAMEL10n.text("\($0.name)纳气口", "\($0.name) intake opening")
            return TAMEL10n.text(
                "已按\(basisLabel)起向盘：\($0.direction.localizedLabel)方 · \($0.qiStatus.localizedTitle) · 向星\($0.xiangStar)",
                "Facing chart based on the \(basisLabel): \($0.direction.localizedLabel) sector · \($0.qiStatus.localizedTitle) · Facing star \($0.xiangStar)"
            )
        } ?? TAMEL10n.text(
            "未标记大门/阳台/窗户，当前暂按朝向\(facing.localizedLabel)方的默认向盘参考",
            "No door, balcony, or window is marked yet, so the chart currently uses the default facing basis for the \(facing.localizedLabel) sector."
        )
        
        analysis = FloorPlanAnalysis(
            palaces: palaces,
            auspiciousPositions: auspicious,
            inauspiciousPositions: inauspicious,
            recommendation: recommendation,
            mainDoorNaqi: mainDoorNaqi,
            naqiResult: naqiResult,
            primaryNaqiPoint: primaryNaqiPoint,
            analysisBasis: analysisBasis,
            roomAssessments: roomAssessments
        )
    }
    
    /// 生成建议文案
    private func generateRecommendation(
        auspicious: [(Int, Int)],
        inauspicious: [(Int, Int)],
        mainDoorNaqi: NaqiAnalyzer.NaqiPoint?,
        primaryNaqiPoint: NaqiAnalyzer.NaqiPoint?,
        naqiResult: NaqiAnalyzer.NaqiAnalysisResult?,
        roomAssessments: [FloorPlanRoomAssessment]
    ) -> String {
        var text = ""

        if let primaryNaqiPoint {
            text += TAMEL10n.text(
                "\(primaryNaqiPoint.name)位于\(primaryNaqiPoint.direction.localizedLabel)方，当前为\(primaryNaqiPoint.qiStatus.localizedTitle)（\(primaryNaqiPoint.level)），可作为本次向盘起盘依据。",
                "\(primaryNaqiPoint.name) sits in the \(primaryNaqiPoint.direction.localizedLabel) sector and currently reads as \(primaryNaqiPoint.qiStatus.localizedTitle) (\(primaryNaqiPoint.level)), making it the clearest facing anchor for this review."
            )
            if let mainDoorNaqi,
               primaryNaqiPoint.type != .mainDoor,
               primaryNaqiPoint.score > mainDoorNaqi.score {
                text += TAMEL10n.text(
                    " 对比后，\(primaryNaqiPoint.name)纳气强于大门，更适合作为当前向盘参考。",
                    " Compared with the main door, \(primaryNaqiPoint.name) performs better and serves as the stronger facing reference right now."
                )
            }
        } else {
            text += TAMEL10n.text(
                "当前未标记大门、阳台或窗户，本次仅按整体朝向进行九宫参考。",
                "No main door, balcony, or window is marked yet, so this review currently relies on the overall facing direction only."
            )
        }

        if let naqiResult, let best = naqiResult.bestPoint {
            text += TAMEL10n.text(
                " 已识别 \(naqiResult.points.count) 处纳气口，其中\(best.name)得分最高（\(best.score)分）。",
                " \(naqiResult.points.count) intake openings were identified, with \(best.name) currently scoring highest at \(best.score)."
            )
        }
        
        if !auspicious.isEmpty {
            let positions = auspicious.map { positionName($0) }.joined(separator: listSeparator)
            text += TAMEL10n.text(
                " 建议将主要活动区域（客厅、书房、卧室）布置在\(positions)。",
                " Main daily-use rooms such as the living room, study, and bedrooms are better placed in \(positions)."
            )
        }
        
        if !inauspicious.isEmpty {
            let positions = inauspicious.map { positionName($0) }.joined(separator: listSeparator)
            text += TAMEL10n.text(
                " 需注意\(positions)，可考虑作为储物间或卫生间使用。",
                " Use extra caution in \(positions); these sectors are better kept for storage or supporting functions."
            )
        }

        if let primaryNaqiPoint {
            let receivingRooms = roomAssessments.filter {
                [.livingRoom, .bedroom, .study].contains($0.type) && $0.naqiAdjustment > 0
            }
            if !receivingRooms.isEmpty {
                let summary = receivingRooms.prefix(2).map {
                    TAMEL10n.text("\($0.label)更靠近\(primaryNaqiPoint.name)", "\($0.label) is closer to \(primaryNaqiPoint.name)")
                }.joined(separator: listSeparator)
                text += TAMEL10n.text(
                    " \(summary)，较易承接当前主纳气。",
                    " \(summary), so these rooms are more likely to receive the current main intake."
                )
            }

            let drainingRooms = roomAssessments.filter {
                [.kitchen, .bathroom].contains($0.type) && $0.naqiAdjustment < 0 && $0.isNearPrimaryNaqi
            }
            if !drainingRooms.isEmpty {
                let summary = drainingRooms.prefix(2).map(\.label).joined(separator: listSeparator)
                text += TAMEL10n.text(
                    " \(summary)靠近\(primaryNaqiPoint.name)，布置时宜更注意避免消耗旺气。",
                    " \(summary) is close to \(primaryNaqiPoint.name), so layout decisions should avoid draining the stronger intake."
                )
            }
        }

        let priorityAdjustments = roomAssessments.filter { $0.suitability == .avoid || $0.suitability == .caution }
        if !priorityAdjustments.isEmpty {
            let summary = priorityAdjustments.prefix(3).map {
                TAMEL10n.text(
                    "\($0.label)在\($0.palaceName)宫\($0.suitability.localizedTitle)",
                    "\($0.label) is in the \($0.palaceName) sector and marked \( $0.suitability.localizedTitle )"
                )
            }.joined(separator: listSeparator)
            text += TAMEL10n.text(
                " 当前标记房间中，\(summary)。",
                " Among the marked rooms, \(summary)."
            )
        } else if !roomAssessments.isEmpty {
            let favorableRooms = roomAssessments.filter { $0.suitability == .favorable }
            if !favorableRooms.isEmpty {
                let summary = favorableRooms.prefix(3).map {
                    TAMEL10n.text("\($0.label)在\($0.palaceName)宫", "\($0.label) is in the \($0.palaceName) sector")
                }.joined(separator: listSeparator)
                text += TAMEL10n.text(
                    " 已标记房间里，\(summary)相对更稳。",
                    " Among the marked rooms, \(summary) appears comparatively stronger."
                )
            }
        }
        
        if text.isEmpty {
            text = TAMEL10n.text(
                "整体布局较为平衡，可根据个人喜好安排空间功能。",
                "The current layout is relatively balanced, so room functions can be arranged with more flexibility."
            )
        }

        if !roomMarkers.isEmpty {
            text += TAMEL10n.text(
                " 当前已标记：\(markerSummary())。",
                " Marked items: \(markerSummary())."
            )
        }
        
        text += TAMEL10n.text("\n\n*以上分析仅供民俗文化参考", "\n\n*For cultural reference only")
        
        return text
    }
    
    func positionName(_ pos: (Int, Int)) -> String {
        let names = TAMEL10n.isEnglish ? [
            ["Southeast", "South", "Southwest"],
            ["East", "Center", "West"],
            ["Northeast", "North", "Northwest"]
        ] : [
            ["东南", "南", "西南"],
            ["东", "中", "西"],
            ["东北", "北", "西北"]
        ]
        return names[pos.0][pos.1]
    }

    func palacePosition(for point: CGPoint) -> (Int, Int) {
        let clampedX = min(max(point.x, 0), 0.999_999)
        let clampedY = min(max(point.y, 0), 0.999_999)
        let col = min(Int(clampedX * 3), 2)
        let row = min(Int(clampedY * 3), 2)
        return (row, col)
    }

    func buildRoomAssessments(
        palaces: [[PalaceInfo]],
        primaryNaqiPoint: NaqiAnalyzer.NaqiPoint? = nil
    ) -> [FloorPlanRoomAssessment] {
        guard !roomMarkers.isEmpty else { return [] }

        var typeCounters: [FloorPlanRoomType: Int] = [:]
        let duplicatedTypes = Dictionary(grouping: roomMarkers, by: \.type)
            .mapValues { $0.count > 1 }
        let primaryNaqiMarker = markerForPrimaryNaqi(primaryNaqiPoint)

        return roomMarkers.map { marker in
            typeCounters[marker.type, default: 0] += 1
            let label: String
            if duplicatedTypes[marker.type] == true {
                label = "\(marker.type.localizedTitle) \(typeCounters[marker.type] ?? 1)"
            } else {
                label = marker.type.localizedTitle
            }

            let palace = palacePosition(for: marker.point)
            let palaceInfo = palaces[palace.0][palace.1]
            let palaceName = positionName(palace)
            let palaceHeatLevel = heatLevel(for: palaceInfo)
            let naqiInfluence = roomNaqiInfluence(
                for: marker,
                primaryNaqiPoint: primaryNaqiPoint,
                primaryNaqiMarker: primaryNaqiMarker
            )
            let suitabilityScore = roomSuitabilityScore(
                for: marker.type,
                palace: palaceInfo,
                naqiAdjustment: naqiInfluence.adjustment
            )
            let suitability = roomSuitability(for: suitabilityScore)
            let advice = roomAdvice(
                label: label,
                type: marker.type,
                palaceName: palaceName,
                palace: palaceInfo,
                suitability: suitability
            )

            return FloorPlanRoomAssessment(
                id: marker.id,
                label: label,
                type: marker.type,
                palace: palace,
                palaceName: palaceName,
                palaceScore: palaceInfo.score,
                suitabilityScore: suitabilityScore,
                heatLevel: palaceHeatLevel,
                suitability: suitability,
                naqiRelationshipSummary: naqiInfluence.summary,
                naqiAdjustment: naqiInfluence.adjustment,
                distanceToPrimaryNaqi: naqiInfluence.distance,
                isNearPrimaryNaqi: naqiInfluence.isNear,
                advice: advice
            )
        }
    }

    func formattedPositions(_ positions: [(Int, Int)]) -> String {
        guard !positions.isEmpty else { return TAMEL10n.text("无", "None") }
        return positions.map { positionName($0) }.joined(separator: listSeparator)
    }

    func markerSummary() -> String {
        guard !roomMarkers.isEmpty else { return TAMEL10n.text("无", "None") }

        var orderedNames: [String] = []
        for marker in roomMarkers where !orderedNames.contains(marker.type.localizedTitle) {
            orderedNames.append(marker.type.localizedTitle)
        }
        return orderedNames.joined(separator: listSeparator)
    }

    func formattedCenterPoint() -> String {
        "x \(String(format: "%.2f", centerPoint.x)) / y \(String(format: "%.2f", centerPoint.y))"
    }

    func heatLevel(for palace: PalaceInfo) -> FloorPlanHeatLevel {
        switch palace.score {
        case 80...100:
            return .excellent
        case 60..<80:
            return .supportive
        case 40..<60:
            return .balanced
        default:
            return .caution
        }
    }

    func buildRecordDetails(analysis: FloorPlanAnalysis) -> [String] {
        var details = [
            TAMEL10n.text("立极点：\(formattedCenterPoint())", "Center point: \(formattedCenterPoint())"),
            TAMEL10n.text("朝向：\(facingDirection.localizedLabel)", "Facing direction: \(facingDirection.localizedLabel)"),
            TAMEL10n.text("向盘依据：\(analysis.analysisBasis)", "Facing basis: \(analysis.analysisBasis)"),
            TAMEL10n.text("吉位：\(formattedPositions(analysis.auspiciousPositions))", "Helpful sectors: \(formattedPositions(analysis.auspiciousPositions))"),
            TAMEL10n.text("注意位：\(formattedPositions(analysis.inauspiciousPositions))", "Caution sectors: \(formattedPositions(analysis.inauspiciousPositions))"),
            TAMEL10n.text("房间标记：\(markerSummary())", "Marked rooms: \(markerSummary())"),
            TAMEL10n.text("建议：\(analysis.recommendation)", "Recommendation: \(analysis.recommendation)")
        ]

        if let mainDoorNaqi = analysis.mainDoorNaqi {
            details.insert(
                TAMEL10n.text(
                    "大门纳气：\(String(format: "%.1f", mainDoorNaqi.naqiAngle))° · \(mainDoorNaqi.direction.localizedLabel)方 · \(mainDoorNaqi.qiStatus.localizedTitle)",
                    "Main door intake: \(String(format: "%.1f", mainDoorNaqi.naqiAngle))° · \(mainDoorNaqi.direction.localizedLabel) sector · \(mainDoorNaqi.qiStatus.localizedTitle)"
                ),
                at: 3
            )
        }

        if let primaryNaqiPoint = analysis.primaryNaqiPoint {
            details.insert(
                TAMEL10n.text(
                    "主要纳气口：\(primaryNaqiPoint.name) · \(String(format: "%.1f", primaryNaqiPoint.naqiAngle))° · \(primaryNaqiPoint.direction.localizedLabel)方 · \(primaryNaqiPoint.qiStatus.localizedTitle) · \(primaryNaqiPoint.score)分",
                    "Primary intake opening: \(primaryNaqiPoint.name) · \(String(format: "%.1f", primaryNaqiPoint.naqiAngle))° · \(primaryNaqiPoint.direction.localizedLabel) sector · \(primaryNaqiPoint.qiStatus.localizedTitle) · score \(primaryNaqiPoint.score)"
                ),
                at: 3
            )
        }

        if let naqiResult = analysis.naqiResult, !naqiResult.points.isEmpty {
            details.append(TAMEL10n.text("纳气概览：\(naqiResult.summary)", "Intake summary: \(naqiResult.summary)"))
            details.append(contentsOf: naqiResult.points.map {
                TAMEL10n.text(
                    "纳气口评估：\($0.name) · \($0.direction.localizedLabel)方 · \($0.qiStatus.localizedTitle) · \($0.score)分",
                    "Intake opening review: \($0.name) · \($0.direction.localizedLabel) sector · \($0.qiStatus.localizedTitle) · score \($0.score)"
                )
            })
        }

        if !analysis.roomAssessments.isEmpty {
            details.append(contentsOf: analysis.roomAssessments.map {
                TAMEL10n.text(
                    "房间评估：\($0.summary) · 纳气联动：\(formattedNaqiAdjustment($0.naqiAdjustment))分 · \($0.naqiRelationshipSummary) · \($0.advice)",
                    "Room review: \($0.summary) · Intake effect: \(formattedNaqiAdjustment($0.naqiAdjustment)) · \($0.naqiRelationshipSummary) · \($0.advice)"
                )
            })
        }

        return details
    }

    func addMarker(at point: CGPoint) {
        roomMarkers.append(FloorPlanRoomMarker(type: selectedMarkerType, point: point))
        refreshAnalysisIfNeeded()
    }

    func loadDemoLayout() {
        floorPlanImage = Self.makeDemoFloorPlanImage()
        centerPoint = CGPoint(x: 0.50, y: 0.52)
        facingDirection = .wu
        roomMarkers = [
            FloorPlanRoomMarker(type: .mainDoor, point: CGPoint(x: 0.18, y: 0.17)),
            FloorPlanRoomMarker(type: .balcony, point: CGPoint(x: 0.52, y: 0.90)),
            FloorPlanRoomMarker(type: .window, point: CGPoint(x: 0.86, y: 0.32)),
            FloorPlanRoomMarker(type: .livingRoom, point: CGPoint(x: 0.54, y: 0.66)),
            FloorPlanRoomMarker(type: .bedroom, point: CGPoint(x: 0.22, y: 0.64)),
            FloorPlanRoomMarker(type: .bedroom, point: CGPoint(x: 0.80, y: 0.67)),
            FloorPlanRoomMarker(type: .kitchen, point: CGPoint(x: 0.78, y: 0.20)),
            FloorPlanRoomMarker(type: .bathroom, point: CGPoint(x: 0.42, y: 0.20)),
            FloorPlanRoomMarker(type: .study, point: CGPoint(x: 0.18, y: 0.40))
        ]
        selectedMarkerType = .mainDoor
        isUsingDemoLayout = true
        performAnalysis()
    }

    func removeMarker(id: UUID) {
        roomMarkers.removeAll { $0.id == id }
        refreshAnalysisIfNeeded()
    }

    func resetLayout() {
        floorPlanImage = nil
        analysis = nil
        isAnalyzing = false
        isUsingDemoLayout = false
        centerPoint = CGPoint(x: 0.5, y: 0.5)
        facingDirection = .wu
        roomMarkers = []
        selectedMarkerType = .mainDoor
    }

    private func refreshAnalysisIfNeeded() {
        guard floorPlanImage != nil, analysis != nil else { return }
        performAnalysis()
    }

    func currentMainDoorAngle() -> Double? {
        guard let marker = roomMarkers.first(where: { $0.type == .mainDoor }) else {
            return nil
        }
        return angle(for: marker.point)
    }

    func currentMainDoorNaqiPoint(yun: SanyuanJiuyun = .current) -> NaqiAnalyzer.NaqiPoint? {
        guard let angle = currentMainDoorAngle() else {
            return nil
        }

        return NaqiAnalyzer.analyzeNaqiPoint(
            type: .mainDoor,
            name: TAMEL10n.text("大门", "Main Door"),
            angle: angle,
            yun: yun
        )
    }

    func currentNaqiMarkerInputs() -> [(type: NaqiAnalyzer.NaqiType, name: String?, angle: Double)] {
        roomMarkers.compactMap { marker in
            guard let naqiType = naqiType(for: marker.type),
                  let angle = angle(for: marker.point) else {
                return nil
            }
            return (type: naqiType, name: marker.type.localizedTitle, angle: angle)
        }
    }

    func currentNaqiResult(
        yun: SanyuanJiuyun = .current,
        chart: CompleteFlyingStarPan? = nil
    ) -> NaqiAnalyzer.NaqiAnalysisResult? {
        let points = currentNaqiMarkerInputs()
        guard !points.isEmpty else { return nil }
        return NaqiAnalyzer.analyzeMultiplePoints(points: points, yun: yun, chart: chart)
    }

    private func preferredNaqiBasis(from result: NaqiAnalyzer.NaqiAnalysisResult?) -> NaqiAnalyzer.NaqiPoint? {
        guard let result else { return nil }
        if let best = result.bestPoint {
            return best
        }
        return result.mainPoint
    }

    private func naqiType(for roomType: FloorPlanRoomType) -> NaqiAnalyzer.NaqiType? {
        switch roomType {
        case .mainDoor:
            return .mainDoor
        case .balcony:
            return .balcony
        case .window:
            return .window
        default:
            return nil
        }
    }

    private func angle(for point: CGPoint) -> Double? {
        let dx = point.x - centerPoint.x
        let dy = centerPoint.y - point.y
        let distance = sqrt(dx * dx + dy * dy)
        guard distance > 0.02 else {
            return nil
        }

        let radians = atan2(dx, dy)
        let degrees = radians * 180 / .pi
        return degrees >= 0 ? degrees : degrees + 360
    }

    private func roomSuitabilityScore(
        for type: FloorPlanRoomType,
        palace: PalaceInfo,
        naqiAdjustment: Int = 0
    ) -> Int {
        let baseScore: Int

        switch type {
        case .mainDoor:
            baseScore = adjustedScore(base: palace.score, delta: palace.score >= 70 ? 8 : -4)
        case .balcony:
            baseScore = adjustedScore(base: palace.score, delta: palace.score >= 65 ? 10 : 2)
        case .window:
            baseScore = adjustedScore(base: palace.score, delta: palace.score >= 65 ? 6 : 0)
        case .livingRoom:
            baseScore = adjustedScore(base: palace.score, delta: palace.score >= 70 ? 6 : 0)
        case .bedroom:
            let healthPenalty = [2, 5].contains(palace.shanStar) || [2, 5].contains(palace.yunStar) ? -12 : 4
            baseScore = adjustedScore(base: palace.score, delta: healthPenalty)
        case .study:
            let focusBonus = [1, 4].contains(palace.yunStar) || [1, 4].contains(palace.shanStar) || [1, 4].contains(palace.xiangStar) ? 12 : 2
            baseScore = adjustedScore(base: palace.score, delta: focusBonus)
        case .kitchen:
            switch palace.score {
            case 80...100: baseScore = 42
            case 60..<80: baseScore = 58
            case 40..<60: baseScore = 82
            case 25..<40: baseScore = 68
            default: baseScore = 46
            }
        case .bathroom:
            switch palace.score {
            case 80...100: baseScore = 32
            case 60..<80: baseScore = 48
            case 40..<60: baseScore = 78
            case 25..<40: baseScore = 60
            default: baseScore = 38
            }
        }

        return adjustedScore(base: baseScore, delta: naqiAdjustment)
    }

    private func roomSuitability(for score: Int) -> FloorPlanRoomSuitability {
        switch score {
        case 75...100:
            return .favorable
        case 55..<75:
            return .acceptable
        case 40..<55:
            return .caution
        default:
            return .avoid
        }
    }

    private func roomAdvice(
        label: String,
        type: FloorPlanRoomType,
        palaceName: String,
        palace: PalaceInfo,
        suitability: FloorPlanRoomSuitability
    ) -> String {
        switch type {
        case .mainDoor:
            switch suitability {
            case .favorable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，宫位较旺，适合作为主要纳气与进出动线。",
                    "\(label) sits in the \(palaceName) sector and is strong enough to serve as the main intake and entry route."
                )
            case .acceptable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，整体可用，宜保持门厅明亮整洁。",
                    "\(label) sits in the \(palaceName) sector and is workable overall; keep the entry bright and tidy."
                )
            case .caution:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，宫位一般，可通过整洁与缓冲过道减轻杂乱感。",
                    "\(label) sits in the \(palaceName) sector; use tidiness and a buffer zone to soften clutter."
                )
            case .avoid:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，作为主纳气口时更要避免压迫、堆物与阴暗。",
                    "\(label) sits in a weaker \(palaceName) sector, so avoid crowding, storage buildup, and dimness if it remains the main intake."
                )
            }
        case .balcony:
            switch suitability {
            case .favorable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，采光与纳气条件相对更佳，适合承担较强纳气作用。",
                    "\(label) sits in the \(palaceName) sector with stronger light and intake potential, so it can support a more important opening role."
                )
            case .acceptable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，作为辅助纳气口可用，宜保持通透与整洁。",
                    "\(label) sits in the \(palaceName) sector and works as a secondary intake opening when kept open and tidy."
                )
            case .caution:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，纳气一般，建议减少遮挡并保持采光。",
                    "\(label) sits in the \(palaceName) sector with average intake, so reduce blockages and preserve daylight."
                )
            case .avoid:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，不宜承担主要纳气角色。",
                    "\(label) sits in a weaker \(palaceName) sector and should not act as the primary intake opening."
                )
            }
        case .window:
            switch suitability {
            case .favorable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，可作为较好的辅助纳气与采光口。",
                    "\(label) sits in the \(palaceName) sector and can work well as a secondary intake and daylight source."
                )
            case .acceptable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，整体可用，宜保持空气流通。",
                    "\(label) sits in the \(palaceName) sector and is generally usable; maintain airflow."
                )
            case .caution:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，纳气一般，可结合其他开口共同判断。",
                    "\(label) sits in the \(palaceName) sector with average intake, so read it together with other openings."
                )
            case .avoid:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，建议减少作为主要开窗纳气依据。",
                    "\(label) sits in a weaker \(palaceName) sector and is not ideal as the main window intake reference."
                )
            }
        case .livingRoom:
            switch suitability {
            case .favorable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，适合做主要活动与会客区。",
                    "\(label) sits in the \(palaceName) sector and suits the main activity and hosting zone."
                )
            case .acceptable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，可作为日常活动区，宜保持通透。",
                    "\(label) sits in the \(palaceName) sector and works for everyday activity if kept open and breathable."
                )
            case .caution:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，若是核心活动区可把高频座位再向吉位偏移。",
                    "\(label) sits in the \(palaceName) sector; if this is the main activity zone, shift high-use seating closer to stronger sectors."
                )
            case .avoid:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，不宜承载全家最核心的长期活动。",
                    "\(label) sits in a weaker \(palaceName) sector and is not ideal for the household's core long-term activity zone."
                )
            }
        case .bedroom:
            switch suitability {
            case .favorable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，适合做静区或主卧。",
                    "\(label) sits in the \(palaceName) sector and suits a quiet room or primary bedroom."
                )
            case .acceptable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，作为卧室可用，宜保持安静与整洁。",
                    "\(label) sits in the \(palaceName) sector and can serve as a bedroom when kept calm and tidy."
                )
            case .caution:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，睡眠区尽量避免杂乱与长期受压。",
                    "\(label) sits in the \(palaceName) sector; keep the sleep zone free from clutter and long-term pressure."
                )
            case .avoid:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，不宜作为长期主卧优先使用。",
                    "\(label) sits in a weaker \(palaceName) sector and should not be the first choice for a long-term primary bedroom."
                )
            }
        case .kitchen:
            if palace.score >= 60 {
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，会占用较旺区域，若条件允许可把更旺位置留给客厅或卧室。",
                    "\(label) sits in the \(palaceName) sector and occupies a stronger area; if possible, reserve prime sectors for the living room or bedrooms."
                )
            } else if palace.score >= 40 {
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，作为动火区相对合适，注意火水分离与通风。",
                    "\(label) sits in the \(palaceName) sector and is fairly suitable for a cooking zone; keep fire and water separate with good ventilation."
                )
            } else {
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，宜更注意清洁、排烟与火源管理。",
                    "\(label) sits in a weaker \(palaceName) sector, so cleanliness, ventilation, and fire control matter more."
                )
            }
        case .bathroom:
            if palace.score >= 60 {
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，容易压到较旺区域，宜保持干爽、常闭门并强化排湿。",
                    "\(label) sits in the \(palaceName) sector and may weigh on a stronger area, so keep it dry, closed, and well ventilated."
                )
            } else if palace.score >= 40 {
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，相对可用，重点保持通风与整洁。",
                    "\(label) sits in the \(palaceName) sector and is relatively workable; focus on ventilation and cleanliness."
                )
            } else {
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，湿气叠加时更要注意维护与排风。",
                    "\(label) sits in a weaker \(palaceName) sector, so moisture control and exhaust become even more important."
                )
            }
        case .study:
            switch suitability {
            case .favorable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，较利专注、阅读与长期学习工位。",
                    "\(label) sits in the \(palaceName) sector and supports focus, reading, and long-form study."
                )
            case .acceptable:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，可作为书房使用，宜加强采光与收纳。",
                    "\(label) sits in the \(palaceName) sector and can function as a study; strengthen lighting and storage."
                )
            case .caution:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫，建议减少干扰并补足照明。",
                    "\(label) sits in the \(palaceName) sector; reduce distractions and improve lighting."
                )
            case .avoid:
                return TAMEL10n.text(
                    "\(label)落在\(palaceName)宫偏弱位，不宜作为长期主工位。",
                    "\(label) sits in a weaker \(palaceName) sector and is not ideal for the primary long-term work spot."
                )
            }
        }
    }

    private func adjustedScore(base: Int, delta: Int) -> Int {
        min(100, max(0, base + delta))
    }

    private func formattedNaqiAdjustment(_ adjustment: Int) -> String {
        adjustment > 0 ? "+\(adjustment)" : "\(adjustment)"
    }

    private func markerForPrimaryNaqi(_ primaryNaqiPoint: NaqiAnalyzer.NaqiPoint?) -> FloorPlanRoomMarker? {
        guard let primaryNaqiPoint else { return nil }

        return roomMarkers
            .filter { naqiType(for: $0.type) == primaryNaqiPoint.type }
            .compactMap { marker -> (FloorPlanRoomMarker, Double)? in
                guard let markerAngle = angle(for: marker.point) else { return nil }
                return (marker, angularDistance(markerAngle, primaryNaqiPoint.angle))
            }
            .min(by: { $0.1 < $1.1 })?
            .0
    }

    private func angularDistance(_ lhs: Double, _ rhs: Double) -> Double {
        let raw = abs(lhs - rhs).truncatingRemainder(dividingBy: 360)
        return min(raw, 360 - raw)
    }

    private func roomNaqiInfluence(
        for marker: FloorPlanRoomMarker,
        primaryNaqiPoint: NaqiAnalyzer.NaqiPoint?,
        primaryNaqiMarker: FloorPlanRoomMarker?
    ) -> (summary: String, adjustment: Int, distance: Double?, isNear: Bool) {
        guard let primaryNaqiPoint, let primaryNaqiMarker else {
            return (TAMEL10n.text("未设置主纳气口，本项暂按落宫单独参考。", "No primary intake opening is set, so this item is evaluated by sector only for now."), 0, nil, false)
        }

        let distance = pointDistance(marker.point, primaryNaqiMarker.point)
        let band: FloorPlanNaqiDistanceBand
        if marker.id == primaryNaqiMarker.id {
            band = .sameOpening
        } else {
            band = naqiDistanceBand(for: distance)
        }

        let adjustment = naqiAdjustment(
            for: marker.type,
            band: band,
            qiStatus: primaryNaqiPoint.qiStatus
        )
        let summary = naqiRelationshipSummary(
            for: marker.type,
            band: band,
            qiStatus: primaryNaqiPoint.qiStatus,
            primaryName: primaryNaqiPoint.name
        )

        return (
            summary,
            adjustment,
            distance,
            band == .sameOpening || band == .near
        )
    }

    private func pointDistance(_ lhs: CGPoint, _ rhs: CGPoint) -> Double {
        let dx = lhs.x - rhs.x
        let dy = lhs.y - rhs.y
        return sqrt(dx * dx + dy * dy)
    }

    private func naqiDistanceBand(for distance: Double) -> FloorPlanNaqiDistanceBand {
        switch distance {
        case ..<0.22:
            return .near
        case ..<0.40:
            return .supportive
        default:
            return .distant
        }
    }

    private func naqiAdjustment(
        for type: FloorPlanRoomType,
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus
    ) -> Int {
        switch type {
        case .livingRoom, .bedroom, .study:
            return beneficialRoomNaqiAdjustment(band: band, qiStatus: qiStatus)
        case .kitchen, .bathroom:
            return drainingRoomNaqiAdjustment(band: band, qiStatus: qiStatus)
        case .mainDoor, .balcony, .window:
            return openingNaqiAdjustment(band: band, qiStatus: qiStatus)
        }
    }

    private func beneficialRoomNaqiAdjustment(
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus
    ) -> Int {
        switch band {
        case .sameOpening:
            return 0
        case .near:
            switch qiStatus {
            case .wang: return 12
            case .sheng: return 10
            case .ping: return 4
            case .tui: return -6
            case .shuai: return -10
            }
        case .supportive:
            switch qiStatus {
            case .wang: return 6
            case .sheng: return 5
            case .ping: return 2
            case .tui: return -3
            case .shuai: return -5
            }
        case .distant:
            return 0
        }
    }

    private func drainingRoomNaqiAdjustment(
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus
    ) -> Int {
        switch band {
        case .sameOpening:
            return 0
        case .near:
            switch qiStatus {
            case .wang: return -12
            case .sheng: return -10
            case .ping: return -4
            case .tui: return -4
            case .shuai: return -6
            }
        case .supportive:
            switch qiStatus {
            case .wang: return -6
            case .sheng: return -5
            case .ping: return -2
            case .tui: return -2
            case .shuai: return -3
            }
        case .distant:
            return 0
        }
    }

    private func openingNaqiAdjustment(
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus
    ) -> Int {
        switch band {
        case .sameOpening:
            switch qiStatus {
            case .wang: return 10
            case .sheng: return 8
            case .ping: return 3
            case .tui: return -4
            case .shuai: return -8
            }
        case .near:
            switch qiStatus {
            case .wang: return 3
            case .sheng: return 2
            case .ping: return 1
            case .tui: return 0
            case .shuai: return -2
            }
        case .supportive:
            switch qiStatus {
            case .wang, .sheng: return 1
            case .ping, .tui: return 0
            case .shuai: return -1
            }
        case .distant:
            return 0
        }
    }

    private func naqiRelationshipSummary(
        for type: FloorPlanRoomType,
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus,
        primaryName: String
    ) -> String {
        if [.mainDoor, .balcony, .window].contains(type), band == .sameOpening {
            return TAMEL10n.text(
                "\(primaryName)当前即主纳气口，直接作为本次向盘起盘依据。",
                "\(primaryName) is the primary intake opening and directly anchors this facing chart."
            )
        }

        switch type {
        case .livingRoom, .bedroom, .study:
            return beneficialRoomNaqiSummary(band: band, qiStatus: qiStatus, primaryName: primaryName)
        case .kitchen, .bathroom:
            return drainingRoomNaqiSummary(band: band, qiStatus: qiStatus, primaryName: primaryName)
        case .mainDoor, .balcony, .window:
            return openingNaqiSummary(band: band, qiStatus: qiStatus, primaryName: primaryName)
        }
    }

    private func beneficialRoomNaqiSummary(
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus,
        primaryName: String
    ) -> String {
        switch band {
        case .sameOpening:
            return TAMEL10n.text("当前房间标记与主纳气口重合，请检查标记是否准确。", "This room marker overlaps the primary intake opening. Please verify the placement.")
        case .near:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("靠近\(primaryName)，较易承接当前\(qiStatus.localizedTitle)。", "Close to \(primaryName), so it more easily receives the current favorable intake.")
            case .ping:
                return TAMEL10n.text("靠近\(primaryName)，可承接较平稳的纳气。", "Close to \(primaryName), so it can receive a steadier intake.")
            case .tui, .shuai:
                return TAMEL10n.text("靠近\(primaryName)，但当前纳气偏弱，长期核心使用宜更谨慎。", "Close to \(primaryName), but the current intake is weaker, so core long-term use should be more cautious.")
            }
        case .supportive:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("与\(primaryName)同侧，仍能辅助承接当前\(qiStatus.localizedTitle)。", "On the same side as \(primaryName), so it can still support the current favorable intake.")
            case .ping:
                return TAMEL10n.text("与\(primaryName)同侧，纳气承接相对平稳。", "On the same side as \(primaryName), so the intake relationship stays relatively stable.")
            case .tui, .shuai:
                return TAMEL10n.text("与\(primaryName)同侧，但主纳气偏弱，宜以落宫条件为主。", "On the same side as \(primaryName), but the main intake is weaker, so sector quality matters more.")
            }
        case .distant:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("离\(primaryName)较远，对承接当前旺气的帮助有限。", "Far from \(primaryName), so its ability to receive the stronger intake is limited.")
            case .ping:
                return TAMEL10n.text("离\(primaryName)较远，主纳气带动较弱。", "Far from \(primaryName), so the main intake has less pull here.")
            case .tui, .shuai:
                return TAMEL10n.text("离\(primaryName)较远，可减少偏弱纳气的直接影响。", "Far from \(primaryName), which can reduce the direct effect of weaker intake.")
            }
        }
    }

    private func drainingRoomNaqiSummary(
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus,
        primaryName: String
    ) -> String {
        switch band {
        case .sameOpening:
            return TAMEL10n.text("当前房间标记与主纳气口重合，请检查标记是否准确。", "This room marker overlaps the primary intake opening. Please verify the placement.")
        case .near:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("靠近\(primaryName)，容易占用并消耗当前\(qiStatus.localizedTitle)。", "Close to \(primaryName), so it can consume the current favorable intake.")
            case .ping:
                return TAMEL10n.text("靠近\(primaryName)，会占用较平稳的纳气，宜控制湿气与杂乱。", "Close to \(primaryName), so it uses a steadier intake; control moisture and clutter.")
            case .tui, .shuai:
                return TAMEL10n.text("靠近\(primaryName)，当前纳气偏弱，更要注意通风与干爽。", "Close to \(primaryName), and with weaker intake, ventilation and dryness matter even more.")
            }
        case .supportive:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("与\(primaryName)同侧，需注意避免过度占用较旺纳气。", "On the same side as \(primaryName), so avoid over-consuming the stronger intake.")
            case .ping:
                return TAMEL10n.text("与\(primaryName)同侧，宜保持整洁，减少对纳气的干扰。", "On the same side as \(primaryName), so keep it tidy to reduce intake disturbance.")
            case .tui, .shuai:
                return TAMEL10n.text("与\(primaryName)同侧，偏弱纳气与湿热叠加时更要注意维护。", "On the same side as \(primaryName); when weaker intake meets dampness or heat, upkeep matters more.")
            }
        case .distant:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("离\(primaryName)较远，对主纳气的直接消耗相对较小。", "Far from \(primaryName), so it draws less directly from the main intake.")
            case .ping:
                return TAMEL10n.text("离\(primaryName)较远，对主纳气影响相对有限。", "Far from \(primaryName), so its impact on the main intake is relatively limited.")
            case .tui, .shuai:
                return TAMEL10n.text("离\(primaryName)较远，但仍应以自身通风排湿条件为主。", "Far from \(primaryName), but its own ventilation and moisture control still matter most.")
            }
        }
    }

    private func openingNaqiSummary(
        band: FloorPlanNaqiDistanceBand,
        qiStatus: NaqiAnalyzer.QiStatus,
        primaryName: String
    ) -> String {
        switch band {
        case .sameOpening:
            return TAMEL10n.text(
                "\(primaryName)当前即主纳气口，直接作为本次向盘起盘依据。",
                "\(primaryName) is the primary intake opening and directly anchors this facing chart."
            )
        case .near:
            switch qiStatus {
            case .wang, .sheng:
                return TAMEL10n.text("靠近\(primaryName)，可作为辅助通风采光口共同参考。", "Close to \(primaryName), so it can be considered as a supporting opening for airflow and daylight.")
            case .ping:
                return TAMEL10n.text("靠近\(primaryName)，可作为较平稳的辅助纳气口。", "Close to \(primaryName), so it can act as a steadier secondary intake opening.")
            case .tui, .shuai:
                return TAMEL10n.text("靠近\(primaryName)，当前纳气偏弱，辅助作用有限。", "Close to \(primaryName), but the current intake is weaker, so its supporting role is limited.")
            }
        case .supportive:
            return TAMEL10n.text("与\(primaryName)同侧，适合与主纳气口一起综合判断。", "On the same side as \(primaryName), so it should be reviewed together with the main intake opening.")
        case .distant:
            return TAMEL10n.text("离\(primaryName)较远，作为辅助纳气口时宜结合整体朝向判断。", "Far from \(primaryName), so it should be judged as a secondary opening together with the overall facing direction.")
        }
    }

    private static func makeDemoFloorPlanImage(size: CGSize = CGSize(width: 1400, height: 1050)) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let cgContext = context.cgContext

            let background = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 0.97, green: 0.95, blue: 0.90, alpha: 1).cgColor,
                    UIColor(red: 0.93, green: 0.91, blue: 0.85, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 1]
            )

            if let background {
                cgContext.drawLinearGradient(
                    background,
                    start: CGPoint(x: rect.minX, y: rect.minY),
                    end: CGPoint(x: rect.maxX, y: rect.maxY),
                    options: []
                )
            }

            let shell = UIBezierPath(
                roundedRect: CGRect(x: 90, y: 90, width: 1220, height: 870),
                cornerRadius: 36
            )
            UIColor.white.setFill()
            shell.fill()

            UIColor(red: 0.18, green: 0.19, blue: 0.22, alpha: 1).setStroke()
            shell.lineWidth = 22
            shell.stroke()

            let roomFillColors: [UIColor] = [
                UIColor(red: 0.93, green: 0.96, blue: 1.00, alpha: 1),
                UIColor(red: 0.95, green: 0.98, blue: 0.94, alpha: 1),
                UIColor(red: 1.00, green: 0.96, blue: 0.92, alpha: 1),
                UIColor(red: 0.96, green: 0.93, blue: 0.98, alpha: 1)
            ]

            let rooms: [(CGRect, UIColor, String)] = [
                (CGRect(x: 120, y: 120, width: 320, height: 250), roomFillColors[0], TAMEL10n.text("玄关 / 书房", "Entry / Study")),
                (CGRect(x: 440, y: 120, width: 280, height: 250), roomFillColors[1], TAMEL10n.text("卫浴", "Bath")),
                (CGRect(x: 720, y: 120, width: 360, height: 250), roomFillColors[2], TAMEL10n.text("厨房", "Kitchen")),
                (CGRect(x: 1080, y: 120, width: 200, height: 250), roomFillColors[0], TAMEL10n.text("设备区", "Utility")),
                (CGRect(x: 120, y: 370, width: 420, height: 260), roomFillColors[3], TAMEL10n.text("次卧", "Guest Bed")),
                (CGRect(x: 540, y: 370, width: 620, height: 360), roomFillColors[1], TAMEL10n.text("客厅", "Living")),
                (CGRect(x: 1160, y: 370, width: 120, height: 360), roomFillColors[2], TAMEL10n.text("景窗", "Window")),
                (CGRect(x: 120, y: 630, width: 360, height: 220), roomFillColors[0], TAMEL10n.text("书房", "Study")),
                (CGRect(x: 480, y: 730, width: 430, height: 120), roomFillColors[2], TAMEL10n.text("阳台", "Balcony")),
                (CGRect(x: 910, y: 730, width: 370, height: 220), roomFillColors[3], TAMEL10n.text("主卧", "Primary Bed"))
            ]

            for (roomRect, fillColor, title) in rooms {
                let path = UIBezierPath(roundedRect: roomRect, cornerRadius: 22)
                fillColor.setFill()
                path.fill()

                UIColor(red: 0.25, green: 0.27, blue: 0.31, alpha: 1).setStroke()
                path.lineWidth = 8
                path.stroke()

                let paragraph = NSMutableParagraphStyle()
                paragraph.alignment = .center
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 34, weight: .semibold),
                    .foregroundColor: UIColor(red: 0.26, green: 0.28, blue: 0.31, alpha: 1),
                    .paragraphStyle: paragraph
                ]
                let textRect = CGRect(
                    x: roomRect.minX + 12,
                    y: roomRect.midY - 24,
                    width: roomRect.width - 24,
                    height: 48
                )
                (title as NSString).draw(in: textRect, withAttributes: attributes)
            }

            let accent = UIColor(red: 0.15, green: 0.54, blue: 0.86, alpha: 1)
            let labelParagraph = NSMutableParagraphStyle()
            labelParagraph.alignment = .center
            let labelAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .bold),
                .foregroundColor: accent,
                .paragraphStyle: labelParagraph
            ]

            let annotations: [(CGRect, String)] = [
                (CGRect(x: 128, y: 158, width: 110, height: 36), TAMEL10n.text("入户门", "Entry Door")),
                (CGRect(x: 650, y: 885, width: 120, height: 36), TAMEL10n.text("南向阳台", "South Balcony")),
                (CGRect(x: 1132, y: 480, width: 120, height: 36), TAMEL10n.text("主采光窗", "Main Window"))
            ]

            for (labelRect, title) in annotations {
                (title as NSString).draw(in: labelRect, withAttributes: labelAttributes)
            }
        }
    }

    private var listSeparator: String {
        TAMEL10n.isEnglish ? ", " : "、"
    }
}
