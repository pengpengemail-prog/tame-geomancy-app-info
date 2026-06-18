import XCTest
import UIKit
@testable import TAMEGeomancy

final class DirectionTests: XCTestCase {
    
    func testDirectionFromAngle() {
        // 测试正北（子）
        let north = Direction.from(angle: 0)
        XCTAssertEqual(north.chinese, "子")
        
        // 测试正东（卯）
        let east = Direction.from(angle: 90)
        XCTAssertEqual(east.chinese, "卯")
        
        // 测试正南（午）
        let south = Direction.from(angle: 180)
        XCTAssertEqual(south.chinese, "午")
        
        // 测试正西（酉）
        let west = Direction.from(angle: 270)
        XCTAssertEqual(west.chinese, "酉")
    }

    func testDirectionBoundaries() {
        XCTAssertEqual(Direction.from(angle: 7.4), .zi)
        XCTAssertEqual(Direction.from(angle: 7.5), .gui)
        XCTAssertEqual(Direction.from(angle: 352.4), .ren)
        XCTAssertEqual(Direction.from(angle: 352.5), .zi)
    }
    
    func testDirectionElement() {
        let water = Direction.from(angle: 0)
        XCTAssertEqual(water.element, .water)
        
        let wood = Direction.from(angle: 90)
        XCTAssertEqual(wood.element, .wood)
        
        let fire = Direction.from(angle: 180)
        XCTAssertEqual(fire.element, .fire)
        
        let metal = Direction.from(angle: 270)
        XCTAssertEqual(metal.element, .metal)
    }

    func testOppositeDirection() {
        XCTAssertEqual(Direction.zi.opposite, .wu)
        XCTAssertEqual(Direction.mao.opposite, .you)
        XCTAssertEqual(Direction.ren.opposite, .bing)
    }
}

final class YangGongCompassCalculatorTests: XCTestCase {

    func testReadingMapsCenterAngleToFacingSittingAndFenjin() {
        let reading = YangGongCompassCalculator.reading(for: 0)

        XCTAssertEqual(reading.normalizedAngle, 0, accuracy: 0.001)
        XCTAssertEqual(reading.facingMountain, .zi)
        XCTAssertEqual(reading.sittingMountain, .wu)
        XCTAssertEqual(reading.orientationTitle, "坐午向子")
        XCTAssertEqual(reading.fenjin.indexInMountain, 3)
        XCTAssertEqual(reading.fenjin.globalIndex, 3)
        XCTAssertEqual(reading.fenjin.title, "子山第3分金")
        XCTAssertEqual(reading.dragon.indexInMountain, 2)
        XCTAssertEqual(reading.dragon.globalIndex, 2)
        XCTAssertEqual(reading.distanceToMountainBoundary, 7.5, accuracy: 0.001)
        XCTAssertEqual(reading.distanceToFenjinBoundary, 1.5, accuracy: 0.001)
        XCTAssertEqual(reading.boundaryStatus, .stable)
    }

    func testMountainBoundaryUsesHalfOpenSectors() {
        XCTAssertEqual(YangGongCompassCalculator.reading(for: 352.49).facingMountain, .ren)

        let firstZiFenjin = YangGongCompassCalculator.reading(for: 352.5)
        XCTAssertEqual(firstZiFenjin.facingMountain, .zi)
        XCTAssertEqual(firstZiFenjin.fenjin.indexInMountain, 1)
        XCTAssertEqual(firstZiFenjin.boundaryStatus, .nearMountainBoundary(distance: 0))

        let lastZiFenjin = YangGongCompassCalculator.reading(for: 7.49)
        XCTAssertEqual(lastZiFenjin.facingMountain, .zi)
        XCTAssertEqual(lastZiFenjin.fenjin.indexInMountain, 5)

        let firstGuiFenjin = YangGongCompassCalculator.reading(for: 7.5)
        XCTAssertEqual(firstGuiFenjin.facingMountain, .gui)
        XCTAssertEqual(firstGuiFenjin.fenjin.indexInMountain, 1)
        XCTAssertEqual(firstGuiFenjin.fenjin.globalIndex, 6)
    }

    func testWrappedFenjinRangeContainsAnglesAcrossZero() {
        let fenjin = YangGongCompassCalculator.reading(for: 0).fenjin

        XCTAssertTrue(fenjin.range.wrapsZero)
        XCTAssertEqual(fenjin.range.start, 358.5, accuracy: 0.001)
        XCTAssertEqual(fenjin.range.end, 1.5, accuracy: 0.001)
        XCTAssertTrue(fenjin.range.contains(359.5))
        XCTAssertTrue(fenjin.range.contains(0))
        XCTAssertFalse(fenjin.range.contains(2))
    }

    func testNormalizesNegativeAndLargeAngles() {
        let negative = YangGongCompassCalculator.reading(for: -1)
        XCTAssertEqual(negative.normalizedAngle, 359, accuracy: 0.001)
        XCTAssertEqual(negative.facingMountain, .zi)
        XCTAssertEqual(negative.fenjin.indexInMountain, 3)

        let large = YangGongCompassCalculator.reading(for: 361.5)
        XCTAssertEqual(large.normalizedAngle, 1.5, accuracy: 0.001)
        XCTAssertEqual(large.facingMountain, .zi)
        XCTAssertEqual(large.fenjin.indexInMountain, 4)
        XCTAssertEqual(large.boundaryStatus, .nearFenjinBoundary(distance: 0))
    }

    func testBoundaryStatusPrioritizesMountainBeforeFenjinBoundary() {
        let mountainBoundary = YangGongCompassCalculator.reading(for: 7.5, boundaryThreshold: 0.5)
        XCTAssertEqual(mountainBoundary.boundaryStatus, .nearMountainBoundary(distance: 0))

        let fenjinBoundary = YangGongCompassCalculator.reading(for: 1.5, boundaryThreshold: 0.5)
        XCTAssertEqual(fenjinBoundary.boundaryStatus, .nearFenjinBoundary(distance: 0))

        let stable = YangGongCompassCalculator.reading(for: 0, boundaryThreshold: 0.5)
        XCTAssertEqual(stable.boundaryStatus, .stable)
    }
}

final class SanyuanJiuyunTests: XCTestCase {
    
    func testJiuyunFromYear() {
        // 七运
        XCTAssertEqual(SanyuanJiuyun.from(year: 1990), .qi)
        
        // 八运
        XCTAssertEqual(SanyuanJiuyun.from(year: 2010), .ba)
        
        // 九运
        XCTAssertEqual(SanyuanJiuyun.from(year: 2024), .jiu)
        XCTAssertEqual(SanyuanJiuyun.from(year: 2043), .jiu)
    }
    
    func testJiuyunProperties() {
        let jiuyun = SanyuanJiuyun.jiu
        XCTAssertEqual(jiuyun.star, "九紫火")
        XCTAssertEqual(jiuyun.element, .fire)
        XCTAssertEqual(jiuyun.period, "2024-2043")
    }
}

final class FlyingStarTests: XCTestCase {
    
    func testFlyingStarElement() {
        XCTAssertEqual(FlyingStar.element(for: 1), .water)
        XCTAssertEqual(FlyingStar.element(for: 2), .earth)
        XCTAssertEqual(FlyingStar.element(for: 3), .wood)
        XCTAssertEqual(FlyingStar.element(for: 6), .metal)
        XCTAssertEqual(FlyingStar.element(for: 9), .fire)
    }
    
    func testStarStatus() {
        let jiuyun = SanyuanJiuyun.jiu
        
        // 当运星
        XCTAssertEqual(FlyingStarCalculator.getStarStatus(star: 9, jiuyun: jiuyun), .wang)
        
        // 未来运星
        XCTAssertEqual(FlyingStarCalculator.getStarStatus(star: 1, jiuyun: jiuyun), .sheng)
        
        // 上运星
        XCTAssertEqual(FlyingStarCalculator.getStarStatus(star: 8, jiuyun: jiuyun), .tui)
        
        // 五黄二黑
        XCTAssertEqual(FlyingStarCalculator.getStarStatus(star: 5, jiuyun: jiuyun), .sha)
        XCTAssertEqual(FlyingStarCalculator.getStarStatus(star: 2, jiuyun: jiuyun), .sha)
    }

    func testCenterStarUsesBaguaPalaces() {
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .zi), 1)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .ren), 1)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .gen), 8)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .mao), 3)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .xun), 4)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .wu), 9)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .kun), 2)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .you), 7)
        XCTAssertEqual(FlyingStarCalculator.centerStar(for: .qian), 6)
    }

    func testLiunianCenterStarMatchesYearSequence() {
        XCTAssertEqual(FlyingStarCalculator.calculateLiunianPan(year: 2024).stars[1][1], 3)
        XCTAssertEqual(FlyingStarCalculator.calculateLiunianPan(year: 2025).stars[1][1], 2)
        XCTAssertEqual(FlyingStarCalculator.calculateLiunianPan(year: 2026).stars[1][1], 1)
        XCTAssertEqual(FlyingStarCalculator.calculateLiunianPan(year: 2027).stars[1][1], 9)
    }

    func testXiangPanCanUseNaqiAngleAsFacingBasis() {
        let xiangPan = FlyingStarCalculator.calculateXiangPan(
            facing: .gui,
            jiuyun: .jiu,
            naqiAngle: 22.5
        )

        XCTAssertEqual(xiangPan.stars[1][1], 8)
    }

    func testDirectionForRawAngleWithNaqiOffset() {
        XCTAssertEqual(FlyingStarCalculator.direction(for: 180, applyNaqiOffset: true), .ding)
        XCTAssertEqual(FlyingStarCalculator.centerStar(forAngle: 180, applyNaqiOffset: true), 9)
    }
}

final class NinePalaceTests: XCTestCase {
    
    func testNinePalaceFly() {
        var palace = NinePalace()
        palace.fly(centerStar: 9, clockwise: true)
        
        // 检查中宫
        XCTAssertEqual(palace.stars[1][1], 9)
        
        // 检查其他宫位是否正确飞布
        XCTAssertTrue(palace.stars.flatMap { $0 }.allSatisfy { $0 >= 1 && $0 <= 9 })
    }
    
    func testYunPanCalculation() {
        let jiuyun = SanyuanJiuyun.jiu
        let yunPan = FlyingStarCalculator.calculateYunPan(jiuyun: jiuyun)
        
        // 九运，九星入中宫
        XCTAssertEqual(yunPan.stars[1][1], 9)
    }
}

final class NaqiAnalyzerTests: XCTestCase {

    func testNaqiPointUsesOffsetDirectionAndDerivedXiangStar() {
        let point = NaqiAnalyzer.analyzeNaqiPoint(
            type: .mainDoor,
            angle: 15,
            yun: .jiu
        )

        XCTAssertEqual(point.naqiAngle, 22.5, accuracy: 0.001)
        XCTAssertEqual(point.direction, .chou)
        XCTAssertEqual(point.xiangStar, 8)
        XCTAssertEqual(point.qiStatus, .tui)
    }

    func testNaqiPointCanCaptureCurrentPeriodProsperousQi() {
        let point = NaqiAnalyzer.analyzeNaqiPoint(
            type: .balcony,
            angle: 172.5,
            yun: .jiu
        )

        XCTAssertEqual(point.naqiAngle, 180, accuracy: 0.001)
        XCTAssertEqual(point.direction, .wu)
        XCTAssertEqual(point.xiangStar, 9)
        XCTAssertEqual(point.qiStatus, .wang)
    }

    func testAnalyzeMultiplePointsCanIdentifyBestNaqiOpening() {
        let result = NaqiAnalyzer.analyzeMultiplePoints(
            points: [
                (type: .mainDoor, name: "大门", angle: 0),
                (type: .balcony, name: "阳台", angle: 172.5),
                (type: .window, name: "窗户", angle: 247.5)
            ],
            yun: .jiu
        )

        XCTAssertEqual(result.mainPoint?.name, "大门")
        XCTAssertEqual(result.bestPoint?.name, "阳台")
        XCTAssertEqual(result.bestPoint?.qiStatus, .wang)
        XCTAssertTrue(result.summary.contains("共有3个纳气口"))
    }

    func testAnalyzeMultiplePointsPreservesNamedBestPointForChartBasis() throws {
        let result = NaqiAnalyzer.analyzeMultiplePoints(
            points: [
                (type: .mainDoor, name: "入户门", angle: 15),
                (type: .balcony, name: "主阳台", angle: 172.5)
            ],
            yun: .jiu
        )

        XCTAssertEqual(result.bestPoint?.name, "主阳台")
        XCTAssertEqual(try XCTUnwrap(result.bestPoint).naqiAngle, 180, accuracy: 0.001)
    }
}

final class BazhaiTests: XCTestCase {

    func testHouseGuaMapping() {
        XCTAssertEqual(BazhaiViewModel.calculateHouseGua(sitting: .north), .kan)
        XCTAssertEqual(BazhaiViewModel.calculateHouseGua(sitting: .west), .dui)
        XCTAssertEqual(BazhaiViewModel.calculateHouseGua(sitting: .northeast), .gen)
    }

    func testHouseTypeMapping() {
        XCTAssertEqual(BazhaiViewModel.determineHouseType(gua: .kan), .eastFour)
        XCTAssertEqual(BazhaiViewModel.determineHouseType(gua: .qian), .westFour)
    }

    func testBazhaiSectorDistribution() {
        let sectors = BazhaiViewModel.calculateEightDirections(gua: .kan)
        XCTAssertEqual(sectors.count, 8)
        XCTAssertEqual(sectors.first(where: { $0.direction == .southeast })?.position, .shengqi)
        XCTAssertEqual(sectors.first(where: { $0.direction == .northwest })?.position, .jueming)
    }

    func testMingGuaProfile() {
        let profile = BazhaiViewModel.calculateMingGuaProfile(birthYear: 1992)
        XCTAssertEqual(profile.gua, .kun)
        XCTAssertEqual(profile.group, .westFour)
    }
}

final class FloorPlanAnalysisViewModelTests: XCTestCase {

    func testLoadDemoLayoutProducesImageMarkersAndAnalysis() {
        let viewModel = FloorPlanAnalysisViewModel()

        viewModel.loadDemoLayout()

        XCTAssertNotNil(viewModel.floorPlanImage)
        XCTAssertTrue(viewModel.isUsingDemoLayout)
        XCTAssertEqual(viewModel.roomMarkers.count, 9)
        XCTAssertEqual(viewModel.roomMarkers.first?.type, .mainDoor)
        XCTAssertEqual(viewModel.facingDirection, .wu)
        XCTAssertNotNil(viewModel.analysis)
        XCTAssertTrue(viewModel.hasAnalysis)
    }

    func testMainDoorAngleAndNaqiPointDerivation() throws {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.centerPoint = CGPoint(x: 0.5, y: 0.5)
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .mainDoor, point: CGPoint(x: 0.5, y: 0.2))
        ]

        XCTAssertEqual(try XCTUnwrap(viewModel.currentMainDoorAngle()), 0, accuracy: 0.001)

        let naqiPoint = viewModel.currentMainDoorNaqiPoint(yun: .jiu)
        XCTAssertEqual(naqiPoint?.direction, .gui)
        XCTAssertEqual(naqiPoint?.xiangStar, 1)
    }

    func testMarkerSummaryDeduplicatesInInsertionOrder() {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .mainDoor, point: CGPoint(x: 0.2, y: 0.2)),
            FloorPlanRoomMarker(type: .bedroom, point: CGPoint(x: 0.4, y: 0.5)),
            FloorPlanRoomMarker(type: .mainDoor, point: CGPoint(x: 0.7, y: 0.2))
        ]

        XCTAssertEqual(viewModel.markerSummary(), "大门、卧室")
    }

    func testFormattedPositionsAndCenterPoint() {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.centerPoint = CGPoint(x: 0.33, y: 0.67)

        XCTAssertEqual(viewModel.formattedPositions([(0, 0), (1, 1), (2, 2)]), "东南、中、西北")
        XCTAssertEqual(viewModel.formattedCenterPoint(), "x 0.33 / y 0.67")
    }

    func testPalacePositionMappingUsesThreeByThreeGrid() {
        let viewModel = FloorPlanAnalysisViewModel()

        XCTAssertEqual(viewModel.palacePosition(for: CGPoint(x: 0.10, y: 0.10)).0, 0)
        XCTAssertEqual(viewModel.palacePosition(for: CGPoint(x: 0.10, y: 0.10)).1, 0)
        XCTAssertEqual(viewModel.palacePosition(for: CGPoint(x: 0.50, y: 0.50)).0, 1)
        XCTAssertEqual(viewModel.palacePosition(for: CGPoint(x: 0.50, y: 0.50)).1, 1)
        XCTAssertEqual(viewModel.palacePosition(for: CGPoint(x: 0.95, y: 0.95)).0, 2)
        XCTAssertEqual(viewModel.palacePosition(for: CGPoint(x: 0.95, y: 0.95)).1, 2)
    }

    func testRoomAssessmentsReflectRoomSuitabilityRules() {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .study, point: CGPoint(x: 0.2, y: 0.2)),
            FloorPlanRoomMarker(type: .kitchen, point: CGPoint(x: 0.5, y: 0.2)),
            FloorPlanRoomMarker(type: .bathroom, point: CGPoint(x: 0.8, y: 0.8))
        ]

        let palaces = [
            [makeStudyFriendlyPalace(), makePalace(score: 55), makePalace(score: 55)],
            [makePalace(score: 55), makePalace(score: 62), makePalace(score: 55)],
            [makePalace(score: 55), makePalace(score: 55), makePalace(score: 88)]
        ]

        let assessments = viewModel.buildRoomAssessments(palaces: palaces)

        XCTAssertEqual(assessments.count, 3)
        XCTAssertEqual(assessments[0].label, "书房")
        XCTAssertEqual(assessments[0].palaceName, "东南")
        XCTAssertEqual(assessments[0].suitability, .favorable)
        XCTAssertTrue(assessments[0].advice.contains("长期学习工位"))
        XCTAssertEqual(assessments[0].naqiAdjustment, 0)

        XCTAssertEqual(assessments[1].label, "厨房")
        XCTAssertEqual(assessments[1].suitability, .favorable)
        XCTAssertTrue(assessments[1].advice.contains("动火区相对合适"))
        XCTAssertEqual(assessments[1].naqiAdjustment, 0)

        XCTAssertEqual(assessments[2].label, "卫生间")
        XCTAssertEqual(assessments[2].suitability, .avoid)
        XCTAssertTrue(assessments[2].advice.contains("压到较旺区域"))
        XCTAssertEqual(assessments[2].naqiAdjustment, 0)
        XCTAssertTrue(assessments[2].naqiRelationshipSummary.contains("未设置主纳气口"))
    }

    func testLivingRoomNearProsperousPrimaryNaqiGetsBonus() throws {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.centerPoint = CGPoint(x: 0.5, y: 0.5)
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .balcony, point: CGPoint(x: 0.5, y: 0.8)),
            FloorPlanRoomMarker(type: .livingRoom, point: CGPoint(x: 0.5, y: 0.68))
        ]

        let primary = try XCTUnwrap(viewModel.currentNaqiResult(yun: .jiu)?.bestPoint)
        let palaces = [
            [makePalace(score: 55), makePalace(score: 55), makePalace(score: 55)],
            [makePalace(score: 55), makePalace(score: 62), makePalace(score: 55)],
            [makePalace(score: 55), makePalace(score: 76), makePalace(score: 55)]
        ]

        let assessments = viewModel.buildRoomAssessments(
            palaces: palaces,
            primaryNaqiPoint: primary
        )

        let livingRoom = try XCTUnwrap(assessments.first(where: { $0.type == .livingRoom }))
        XCTAssertEqual(livingRoom.suitabilityScore, 88)
        XCTAssertEqual(livingRoom.naqiAdjustment, 12)
        XCTAssertTrue(livingRoom.isNearPrimaryNaqi)
        XCTAssertTrue(livingRoom.naqiRelationshipSummary.contains("靠近阳台"))
        XCTAssertTrue(livingRoom.naqiRelationshipSummary.contains("旺气"))
    }

    func testBathroomNearProsperousPrimaryNaqiGetsPenalty() throws {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.centerPoint = CGPoint(x: 0.5, y: 0.5)
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .balcony, point: CGPoint(x: 0.5, y: 0.8)),
            FloorPlanRoomMarker(type: .bathroom, point: CGPoint(x: 0.54, y: 0.78))
        ]

        let primary = NaqiAnalyzer.analyzeNaqiPoint(
            type: .balcony,
            name: "阳台",
            angle: 172.5,
            yun: .jiu
        )
        let palaces = [
            [makePalace(score: 55), makePalace(score: 55), makePalace(score: 55)],
            [makePalace(score: 55), makePalace(score: 62), makePalace(score: 55)],
            [makePalace(score: 55), makePalace(score: 55), makePalace(score: 55)]
        ]

        let assessments = viewModel.buildRoomAssessments(
            palaces: palaces,
            primaryNaqiPoint: primary
        )

        let bathroom = try XCTUnwrap(assessments.first(where: { $0.type == .bathroom }))
        XCTAssertEqual(bathroom.suitabilityScore, 66)
        XCTAssertEqual(bathroom.naqiAdjustment, -12)
        XCTAssertTrue(bathroom.isNearPrimaryNaqi)
        XCTAssertTrue(bathroom.naqiRelationshipSummary.contains("靠近阳台"))
        XCTAssertTrue(bathroom.naqiRelationshipSummary.contains("消耗当前旺气"))
    }

    func testCurrentNaqiResultPrefersBestOpeningAcrossDoorBalconyAndWindow() {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.centerPoint = CGPoint(x: 0.5, y: 0.5)
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .mainDoor, point: CGPoint(x: 0.5, y: 0.2)),
            FloorPlanRoomMarker(type: .balcony, point: CGPoint(x: 0.5, y: 0.8)),
            FloorPlanRoomMarker(type: .window, point: CGPoint(x: 0.2, y: 0.5))
        ]

        let result = viewModel.currentNaqiResult(yun: .jiu)

        XCTAssertEqual(result?.points.count, 3)
        XCTAssertEqual(result?.mainPoint?.name, "大门")
        XCTAssertEqual(result?.bestPoint?.name, "阳台")
        XCTAssertEqual(result?.bestPoint?.direction, .ding)
    }

    func testHeatLevelAndRecordDetails() {
        let viewModel = FloorPlanAnalysisViewModel()
        viewModel.centerPoint = CGPoint(x: 0.48, y: 0.52)
        viewModel.facingDirection = .wu
        viewModel.roomMarkers = [
            FloorPlanRoomMarker(type: .livingRoom, point: CGPoint(x: 0.3, y: 0.3)),
            FloorPlanRoomMarker(type: .study, point: CGPoint(x: 0.6, y: 0.6))
        ]

        let analysis = FloorPlanAnalysis(
            palaces: [
                [makePalace(score: 88), makePalace(score: 75), makePalace(score: 55)],
                [makePalace(score: 36), makePalace(score: 62), makePalace(score: 28)],
                [makePalace(score: 82), makePalace(score: 47), makePalace(score: 39)]
            ],
            auspiciousPositions: [(0, 0), (2, 0)],
            inauspiciousPositions: [(1, 0), (2, 2)],
            recommendation: "建议将主要活动区域布置在东南、东北。",
            mainDoorNaqi: NaqiAnalyzer.analyzeNaqiPoint(type: .mainDoor, angle: 180, yun: .jiu),
            naqiResult: NaqiAnalyzer.analyzeMultiplePoints(
                points: [
                    (type: .mainDoor, name: "大门", angle: 180),
                    (type: .balcony, name: "阳台", angle: 172.5)
                ],
                yun: .jiu
            ),
            primaryNaqiPoint: NaqiAnalyzer.analyzeNaqiPoint(type: .balcony, name: "阳台", angle: 172.5, yun: .jiu),
            analysisBasis: "已按大门纳气口起向盘：丁方 · 旺气 · 向星9",
            roomAssessments: [
                FloorPlanRoomAssessment(
                    id: UUID(),
                    label: "客厅",
                    type: .livingRoom,
                    palace: (0, 0),
                    palaceName: "东南",
                    palaceScore: 88,
                    suitabilityScore: 94,
                    heatLevel: .excellent,
                    suitability: .favorable,
                    naqiRelationshipSummary: "靠近阳台，较易承接当前旺气。",
                    naqiAdjustment: 12,
                    distanceToPrimaryNaqi: 0.14,
                    isNearPrimaryNaqi: true,
                    advice: "客厅落在东南宫，适合做主要活动与会客区。"
                )
            ]
        )

        XCTAssertEqual(viewModel.heatLevel(for: analysis.palaces[0][0]), .excellent)
        XCTAssertEqual(viewModel.heatLevel(for: analysis.palaces[0][1]), .supportive)
        XCTAssertEqual(viewModel.heatLevel(for: analysis.palaces[0][2]), .balanced)
        XCTAssertEqual(viewModel.heatLevel(for: analysis.palaces[1][0]), .caution)

        let details = viewModel.buildRecordDetails(analysis: analysis)
        XCTAssertTrue(details.contains("立极点：x 0.48 / y 0.52"))
        XCTAssertTrue(details.contains("朝向：午"))
        XCTAssertTrue(details.contains("向盘依据：已按大门纳气口起向盘：丁方 · 旺气 · 向星9"))
        XCTAssertTrue(details.contains("吉位：东南、东北"))
        XCTAssertTrue(details.contains("注意位：东、西北"))
        XCTAssertTrue(details.contains("房间标记：客厅、书房"))
        XCTAssertTrue(details.contains(where: { $0.contains("主要纳气口：阳台") }))
        XCTAssertTrue(details.contains(where: { $0.contains("纳气口评估：阳台") }))
        XCTAssertTrue(details.contains(where: { $0.contains("房间评估：客厅：东南宫 · 适合 · 94分") }))
        XCTAssertTrue(details.contains(where: { $0.contains("纳气联动：+12分") }))
    }

    private func makeStudyFriendlyPalace() -> PalaceInfo {
        PalaceInfo(
            position: (0, 0),
            yunStar: 4,
            shanStar: 1,
            xiangStar: 9,
            liunianStar: 9,
            yunStatus: .sheng,
            shanStatus: .sheng,
            xiangStatus: .wang
        )
    }

    private func makePalace(score: Int) -> PalaceInfo {
        switch score {
        case 80...100:
            return PalaceInfo(
                position: (0, 0),
                yunStar: 9,
                shanStar: 9,
                xiangStar: 9,
                liunianStar: 9,
                yunStatus: .wang,
                shanStatus: .wang,
                xiangStatus: .wang
            )
        case 60..<80:
            return PalaceInfo(
                position: (0, 0),
                yunStar: 9,
                shanStar: 8,
                xiangStar: 8,
                liunianStar: 9,
                yunStatus: .wang,
                shanStatus: .tui,
                xiangStatus: .tui
            )
        case 40..<60:
            return PalaceInfo(
                position: (0, 0),
                yunStar: 8,
                shanStar: 8,
                xiangStar: 8,
                liunianStar: 9,
                yunStatus: .tui,
                shanStatus: .tui,
                xiangStatus: .tui
            )
        default:
            return PalaceInfo(
                position: (0, 0),
                yunStar: 2,
                shanStar: 2,
                xiangStar: 2,
                liunianStar: 9,
                yunStatus: .sha,
                shanStatus: .sha,
                xiangStatus: .sha
            )
        }
    }
}

final class AnnualFortuneViewModelTests: XCTestCase {

    func testAnnualFortuneUsesUpdatedCenterStarAndSummary() {
        let viewModel = AnnualFortuneViewModel()
        viewModel.selectYear(2024)

        XCTAssertEqual(viewModel.annualChart?.stars[1][1], 3)
        XCTAssertEqual(viewModel.analysis?.centerStar, 3)
        XCTAssertTrue(viewModel.analysis?.summary.contains("2024 年三碧禄存入中") == true)
    }

    func testAnnualFortuneIncludesTaiSuiAndSuiPo() {
        let viewModel = AnnualFortuneViewModel()
        viewModel.selectYear(2026)

        XCTAssertEqual(viewModel.analysis?.taiSuiDirection, .wu)
        XCTAssertEqual(viewModel.analysis?.suiPoDirection, .zi)
        XCTAssertTrue(viewModel.analysis?.yearTheme.contains("太岁在午方") == true)
        XCTAssertTrue(viewModel.analysis?.yearTheme.contains("岁破在子方") == true)
    }

    func testAnnualFortuneCanLinkHouseFacingAndNaqiBasis() {
        let viewModel = AnnualFortuneViewModel()
        viewModel.useHouseFacingReference = true
        viewModel.selectedSittingDirection = .zi
        viewModel.useNaqiBasis = true
        viewModel.rawNaqiAngle = 172.5
        viewModel.naqiPointName = "主阳台"
        viewModel.selectYear(2026)

        XCTAssertTrue(viewModel.analysis?.annualChartBasis.contains("已带入子山午向") == true)
        XCTAssertTrue(viewModel.analysis?.annualChartBasis.contains("主阳台") == true)
        XCTAssertTrue(viewModel.analysis?.houseAdvice.contains("主阳台") == true)
        XCTAssertTrue(viewModel.analysis?.summary.contains("房屋按子山午向参考") == true)
    }

    func testAnnualFortuneRecordDetailsIncludeHouseLinkage() {
        let viewModel = AnnualFortuneViewModel()
        viewModel.useHouseFacingReference = true
        viewModel.selectedSittingDirection = .mao
        viewModel.useNaqiBasis = true
        viewModel.rawNaqiAngle = 90
        viewModel.naqiPointName = "大门"
        viewModel.selectYear(2025)

        let details = viewModel.recordDetails()
        XCTAssertTrue(details.contains(where: { $0.contains("太岁方：巳") }))
        XCTAssertTrue(details.contains(where: { $0.contains("岁破方：亥") }))
        XCTAssertTrue(details.contains(where: { $0.contains("排盘依据：已带入卯山酉向") }))
        XCTAssertTrue(details.contains(where: { $0.contains("房屋联动：房屋按卯山酉向参考") }))
        XCTAssertTrue(details.contains(where: { $0.contains("方位细评：") }))
    }
}

final class RecordReportComposerTests: XCTestCase {

    func testShareTextIncludesNotesWhenPresent() {
        let record = AnalysisRecord(
            category: .orientation,
            title: "大门纳气",
            subtitle: "午方 · 旺气",
            details: ["地盘角度：180.0°", "纳气角度：187.5°"],
            createdAt: Date(timeIntervalSince1970: 0),
            notes: ""
        )

        let text = RecordReportComposer.shareText(for: record, notes: "靠近电梯厅，现场磁场偏强")

        XCTAssertTrue(text.contains("探觅·堪舆"))
        XCTAssertTrue(text.contains("大门纳气"))
        XCTAssertTrue(text.contains("备注："))
        XCTAssertTrue(text.contains("靠近电梯厅"))
        XCTAssertTrue(text.contains("民俗文化参考"))
    }

    func testShareTextOmitsNotesBlockWhenEmpty() {
        let record = AnalysisRecord(
            category: .floorPlan,
            title: "户型图分析",
            subtitle: "朝向 午 · 标记 2 项",
            details: ["吉位：东南、东北"],
            createdAt: Date(timeIntervalSince1970: 0),
            notes: ""
        )

        let text = RecordReportComposer.shareText(for: record, notes: "   ")

        XCTAssertTrue(text.contains("户型图分析"))
        XCTAssertFalse(text.contains("备注："))
        XCTAssertTrue(text.contains("吉位：东南、东北"))
    }

    func testMakeImageProducesOpaqueImageWithExpectedMinimumSize() {
        let record = AnalysisRecord(
            category: .flyingStar,
            title: "飞星排盘",
            subtitle: "九运 · 午向",
            details: [
                "运盘：九紫火入中",
                "向盘：纳气盘起盘",
                "注意位：西、东北"
            ],
            createdAt: Date(timeIntervalSince1970: 0),
            notes: ""
        )

        let image = RecordReportComposer.makeImage(for: record, notes: "现场采光较强，适合结合户型热力图一起判断。")

        XCTAssertNotNil(image)
        XCTAssertEqual(try XCTUnwrap(image).size.width, 1080, accuracy: 0.1)
        XCTAssertTrue((image?.size.height ?? 0) > 900)
    }

    func testMakeImageUsesLightHeaderBranding() {
        let record = AnalysisRecord(
            category: .orientation,
            title: "大门纳气",
            subtitle: "午方 · 旺气",
            details: ["地盘角度：180.0°", "纳气角度：187.5°"],
            createdAt: Date(timeIntervalSince1970: 0),
            notes: ""
        )

        let image = RecordReportComposer.makeImage(for: record, notes: "")
        XCTAssertNotNil(image)

        guard let image,
              let cgImage = image.cgImage,
              let data = cgImage.dataProvider?.data,
              let bytes = CFDataGetBytePtr(data) else {
            XCTFail("无法读取导出图片像素")
            return
        }

        let bytesPerRow = cgImage.bytesPerRow
        let bytesPerPixel = cgImage.bitsPerPixel / 8
        let sampleX = min(90, cgImage.width - 1)
        let sampleY = min(90, cgImage.height - 1)
        let offset = sampleY * bytesPerRow + sampleX * bytesPerPixel

        let red = CGFloat(bytes[offset]) / 255
        let green = CGFloat(bytes[offset + 1]) / 255
        let blue = CGFloat(bytes[offset + 2]) / 255
        let brightness = (red + green + blue) / 3

        XCTAssertGreaterThan(brightness, 0.85)
    }

    func testMakeShareItemsReturnsImageAndSummary() {
        let record = AnalysisRecord(
            category: .orientation,
            title: "主阳台纳气",
            subtitle: "巽方 · 平气",
            details: ["地盘角度：150.0°"],
            createdAt: Date(timeIntervalSince1970: 0),
            notes: ""
        )

        let items = RecordReportComposer.makeShareItems(for: record, notes: "")

        XCTAssertEqual(items.count, 2)
        XCTAssertTrue(items.contains { $0 is UIImage })
        XCTAssertTrue(items.contains { ($0 as? String)?.contains("探觅·堪舆") == true })
    }

    func testSharePreviewRecordContainsExportReadyContent() {
        let record = RecordsView.sharePreviewRecord(createdAt: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(record.category, .floorPlan)
        XCTAssertFalse(record.title.isEmpty)
        XCTAssertTrue(record.details.contains { $0.contains("TAME·Geomancy") || $0.contains("报告图") })
        XCTAssertFalse(record.notes.isEmpty)
    }
}

final class HistoryBackupTests: XCTestCase {

    func testBackupRoundTripPreservesRecords() throws {
        let records = [
            AnalysisRecord(
                id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
                category: .orientation,
                title: "大门纳气",
                subtitle: "午方 · 旺气",
                details: ["地盘角度：180.0°"],
                createdAt: Date(timeIntervalSince1970: 1_700_000_000),
                notes: "首测"
            ),
            AnalysisRecord(
                id: UUID(uuidString: "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB")!,
                category: .annual,
                title: "2026 流年",
                subtitle: "中宫一白",
                details: ["太岁方：午", "岁破方：子"],
                createdAt: Date(timeIntervalSince1970: 1_710_000_000),
                notes: ""
            )
        ]

        let data = try HistoryStore.makeBackupData(for: records, exportedAt: Date(timeIntervalSince1970: 1_720_000_000))
        let envelope = try HistoryStore.decodeBackupData(data)

        XCTAssertEqual(envelope.schemaVersion, 1)
        XCTAssertEqual(envelope.recordCount, 2)
        XCTAssertEqual(envelope.records, records.sorted { $0.createdAt > $1.createdAt })
        XCTAssertEqual(envelope.appName, "TAME·Geomancy / 探觅·堪舆")
    }

    func testMergeRecordsImportsNewAndSkipsDuplicates() {
        let existing = [
            AnalysisRecord(
                id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
                category: .orientation,
                title: "大门纳气",
                subtitle: "午方 · 旺气",
                details: ["地盘角度：180.0°"],
                createdAt: Date(timeIntervalSince1970: 100),
                notes: ""
            )
        ]

        let incoming = [
            AnalysisRecord(
                id: UUID(uuidString: "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA")!,
                category: .orientation,
                title: "大门纳气",
                subtitle: "午方 · 旺气",
                details: ["地盘角度：180.0°"],
                createdAt: Date(timeIntervalSince1970: 100),
                notes: ""
            ),
            AnalysisRecord(
                id: UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC")!,
                category: .floorPlan,
                title: "户型分析",
                subtitle: "朝向 午",
                details: ["吉位：东南"],
                createdAt: Date(timeIntervalSince1970: 200),
                notes: "补录"
            )
        ]

        let result = HistoryStore.mergeRecords(existing: existing, incoming: incoming)

        XCTAssertEqual(result.records.count, 2)
        XCTAssertEqual(result.summary.importedCount, 1)
        XCTAssertEqual(result.summary.skippedDuplicates, 1)
        XCTAssertEqual(result.summary.totalCount, 2)
        XCTAssertEqual(result.records.first?.id, UUID(uuidString: "CCCCCCCC-CCCC-CCCC-CCCC-CCCCCCCCCCCC"))
    }

    func testDecodeRejectsMismatchedRecordCount() throws {
        let json = """
        {
          "appName" : "TAME·Geomancy",
          "exportedAt" : "2026-05-05T10:00:00Z",
          "recordCount" : 2,
          "records" : [
            {
              "category" : "坐向纳气",
              "createdAt" : "2026-05-05T10:00:00Z",
              "details" : ["地盘角度：180.0°"],
              "id" : "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA",
              "notes" : "",
              "subtitle" : "午方 · 旺气",
              "title" : "大门纳气"
            }
          ],
          "schemaVersion" : 1
        }
        """

        XCTAssertThrowsError(try HistoryStore.decodeBackupData(Data(json.utf8))) { error in
            XCTAssertEqual(error as? HistoryBackupError, .recordCountMismatch)
        }
    }
}

final class RecordPhotoAlbumSaverTests: XCTestCase {

    func testPhotoSaveFailureResultPreservesMessage() {
        let result = RecordPhotoSaveResult.failure("请允许访问相册")

        XCTAssertEqual(result, .failure("请允许访问相册"))
    }

    func testPhotoSaveSuccessResultIsEquatable() {
        XCTAssertEqual(RecordPhotoSaveResult.success, .success)
    }
}

final class DeepLinkRouteTests: XCTestCase {

    func testTabDeepLinkParsing() {
        let route = AppDeepLinkRoute(url: URL(string: "tamegeomancy://tab/settings")!)

        XCTAssertEqual(route, .tab(.settings))
    }

    func testDirectTabHostDeepLinkParsing() {
        let route = AppDeepLinkRoute(url: URL(string: "tamegeomancy://compass")!)

        XCTAssertEqual(route, .tab(.compass))
    }

    func testAnalysisDeepLinkParsing() {
        let route = AppDeepLinkRoute(url: URL(string: "tamegeomancy://analysis/floor-plan-demo")!)

        XCTAssertEqual(route, .analysis(.floorPlanDemo))
    }

    func testRecordsDeepLinkParsing() {
        let route = AppDeepLinkRoute(url: URL(string: "tamegeomancy://records/share-preview")!)

        XCTAssertEqual(route, .records(.sharePreview))
    }

    func testSettingsDeepLinkParsing() {
        let route = AppDeepLinkRoute(url: URL(string: "tamegeomancy://settings/permissions")!)

        XCTAssertEqual(route, .settings(.permissions))
    }

    func testLaunchRouteResolverFallsBackToEnvironment() {
        let route = AppLaunchRouteResolver.resolve(
            arguments: ["TAMEGeomancy"],
            environment: ["TAME_LAUNCH_ROUTE": "tamegeomancy://tab/settings"]
        )

        XCTAssertEqual(route, .tab(.settings))
    }

    func testLaunchRouteResolverPrefersExplicitArgumentOverEnvironment() {
        let route = AppLaunchRouteResolver.resolve(
            arguments: ["TAMEGeomancy", "-TAMELaunchRoute", "tamegeomancy://records/share-preview"],
            environment: ["TAME_LAUNCH_ROUTE": "tamegeomancy://analysis/floor-plan-demo"]
        )

        XCTAssertEqual(route, .records(.sharePreview))
    }

    func testLaunchRouteResolverSupportsNamedArgument() {
        let route = AppLaunchRouteResolver.resolve(
            arguments: ["TAMEGeomancy", "-TAMELaunchRoute", "tamegeomancy://analysis/floor-plan-demo"],
            environment: [:]
        )

        XCTAssertEqual(route, .analysis(.floorPlanDemo))
    }

    func testLaunchRouteResolverSupportsInlineArgument() {
        let route = AppLaunchRouteResolver.resolve(
            arguments: ["TAMEGeomancy", "--tame-launch-route=tamegeomancy://records/share-preview"],
            environment: [:]
        )

        XCTAssertEqual(route, .records(.sharePreview))
    }

    func testLaunchRouteResolverSupportsAnalysisDemoArgument() {
        let route = AppLaunchRouteResolver.resolve(
            arguments: ["TAMEGeomancy", "-TAMELaunchRoute", "tamegeomancy://analysis/orientation-demo"],
            environment: [:]
        )

        XCTAssertEqual(route, .analysis(.orientationDemo))
    }

    func testLaunchRouteResolverSupportsSettingsDocumentArgument() {
        let route = AppLaunchRouteResolver.resolve(
            arguments: ["TAMEGeomancy", "-TAMELaunchRoute", "tamegeomancy://settings/support"],
            environment: [:]
        )

        XCTAssertEqual(route, .settings(.support))
    }

    func testCompassSimulationResolverSupportsNamedArgument() throws {
        let reading = CompassSimulationResolver.resolve(
            arguments: ["TAMEGeomancy", "-TAMEMockHeading", "205.5"],
            environment: [:]
        )

        let unwrappedReading = try XCTUnwrap(reading)
        XCTAssertEqual(unwrappedReading.magneticHeading, 205.5, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(unwrappedReading.trueNorthHeading), 207.2, accuracy: 0.001)
    }

    func testCompassSimulationResolverReadsEnvironmentOverrides() throws {
        let reading = CompassSimulationResolver.resolve(
            arguments: ["TAMEGeomancy"],
            environment: [
                "TAME_MOCK_HEADING": "91.5",
                "TAME_MOCK_TRUE_HEADING": "93.0",
                "TAME_MOCK_PITCH": "2.4",
                "TAME_MOCK_ROLL": "1.1",
                "TAME_MOCK_FIELD": "88"
            ]
        )

        let unwrappedReading = try XCTUnwrap(reading)
        XCTAssertEqual(unwrappedReading.magneticHeading, 91.5, accuracy: 0.001)
        XCTAssertEqual(try XCTUnwrap(unwrappedReading.trueNorthHeading), 93.0, accuracy: 0.001)
        XCTAssertEqual(unwrappedReading.pitch, 2.4, accuracy: 0.001)
        XCTAssertEqual(unwrappedReading.roll, 1.1, accuracy: 0.001)
        XCTAssertEqual(unwrappedReading.magneticFieldStrength, 88, accuracy: 0.001)
    }
}
