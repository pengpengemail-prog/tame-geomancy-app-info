import Foundation

struct YangGongAngleRange: Equatable {
    let start: Double
    let end: Double

    var wrapsZero: Bool {
        start > end
    }

    var formattedLabel: String {
        "\(Self.format(start))°-\(Self.format(end))°"
    }

    func contains(_ angle: Double) -> Bool {
        let value = YangGongCompassCalculator.normalized(angle)
        if wrapsZero {
            return value >= start || value < end
        }
        return value >= start && value < end
    }

    private static func format(_ value: Double) -> String {
        if value.rounded() == value {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }
}

struct YangGongFenjinLine: Equatable, Identifiable {
    let mountain: Direction
    let indexInMountain: Int
    let globalIndex: Int
    let range: YangGongAngleRange
    let centerAngle: Double

    var id: String {
        "\(mountain.rawValue)-fenjin-\(indexInMountain)"
    }

    var title: String {
        "\(mountain.chinese)山第\(indexInMountain)分金"
    }
}

struct YangGongDragonLine: Equatable, Identifiable {
    let mountain: Direction
    let indexInMountain: Int
    let globalIndex: Int
    let range: YangGongAngleRange
    let centerAngle: Double

    var id: String {
        "\(mountain.rawValue)-dragon-\(indexInMountain)"
    }

    var title: String {
        "\(mountain.chinese)山第\(indexInMountain)龙"
    }
}

enum YangGongBoundaryStatus: Equatable {
    case stable
    case nearFenjinBoundary(distance: Double)
    case nearMountainBoundary(distance: Double)

    var localizedTitle: String {
        switch self {
        case .stable:
            return TAMEL10n.text("线位稳定", "Stable line")
        case .nearFenjinBoundary:
            return TAMEL10n.text("接近分金边界", "Near line boundary")
        case .nearMountainBoundary:
            return TAMEL10n.text("接近二十四山边界", "Near mountain boundary")
        }
    }
}

struct YangGongOrientationReading: Equatable {
    let rawAngle: Double
    let normalizedAngle: Double
    let facingMountain: Direction
    let sittingMountain: Direction
    let fenjin: YangGongFenjinLine
    let dragon: YangGongDragonLine
    let distanceToMountainBoundary: Double
    let distanceToFenjinBoundary: Double
    let boundaryStatus: YangGongBoundaryStatus

    var orientationTitle: String {
        "坐\(sittingMountain.chinese)向\(facingMountain.chinese)"
    }

    var summary: String {
        "\(orientationTitle) · \(fenjin.title) · \(String(format: "%.1f", normalizedAngle))°"
    }
}

enum YangGongCompassCalculator {
    static let mountainWidth: Double = 15
    static let fenjinWidth: Double = 3
    static let dragonWidth: Double = 5
    static let defaultBoundaryThreshold: Double = 0.5

    static func reading(
        for angle: Double,
        boundaryThreshold: Double = defaultBoundaryThreshold
    ) -> YangGongOrientationReading {
        let normalizedAngle = normalized(angle)
        let facingMountain = Direction.from(angle: normalizedAngle)
        let sittingMountain = facingMountain.opposite
        let mountainOffset = offsetInMountain(angle: normalizedAngle, mountain: facingMountain)
        let fenjin = fenjinLine(for: normalizedAngle, mountain: facingMountain, mountainOffset: mountainOffset)
        let dragon = dragonLine(for: normalizedAngle, mountain: facingMountain, mountainOffset: mountainOffset)
        let distanceToMountainBoundary = min(mountainOffset, mountainWidth - mountainOffset)
        let fenjinLocalOffset = mountainOffset.truncatingRemainder(dividingBy: fenjinWidth)
        let distanceToFenjinBoundary = min(fenjinLocalOffset, fenjinWidth - fenjinLocalOffset)
        let boundaryStatus = boundaryStatus(
            distanceToMountainBoundary: distanceToMountainBoundary,
            distanceToFenjinBoundary: distanceToFenjinBoundary,
            threshold: boundaryThreshold
        )

        return YangGongOrientationReading(
            rawAngle: angle,
            normalizedAngle: normalizedAngle,
            facingMountain: facingMountain,
            sittingMountain: sittingMountain,
            fenjin: fenjin,
            dragon: dragon,
            distanceToMountainBoundary: distanceToMountainBoundary,
            distanceToFenjinBoundary: distanceToFenjinBoundary,
            boundaryStatus: boundaryStatus
        )
    }

    static func fenjinLine(for angle: Double) -> YangGongFenjinLine {
        let normalizedAngle = normalized(angle)
        let mountain = Direction.from(angle: normalizedAngle)
        return fenjinLine(
            for: normalizedAngle,
            mountain: mountain,
            mountainOffset: offsetInMountain(angle: normalizedAngle, mountain: mountain)
        )
    }

    static func dragonLine(for angle: Double) -> YangGongDragonLine {
        let normalizedAngle = normalized(angle)
        let mountain = Direction.from(angle: normalizedAngle)
        return dragonLine(
            for: normalizedAngle,
            mountain: mountain,
            mountainOffset: offsetInMountain(angle: normalizedAngle, mountain: mountain)
        )
    }

    static func normalized(_ angle: Double) -> Double {
        let value = angle.truncatingRemainder(dividingBy: 360)
        return value >= 0 ? value : value + 360
    }

    private static func fenjinLine(
        for angle: Double,
        mountain: Direction,
        mountainOffset: Double
    ) -> YangGongFenjinLine {
        let indexInMountain = min(Int(mountainOffset / fenjinWidth), 4) + 1
        let mountainIndex = Direction.compassOrder.firstIndex(of: mountain) ?? 0
        let globalIndex = mountainIndex * 5 + indexInMountain
        let start = normalized(mountainStartAngle(for: mountain) + Double(indexInMountain - 1) * fenjinWidth)
        let end = normalized(start + fenjinWidth)
        let center = normalized(start + fenjinWidth / 2)

        return YangGongFenjinLine(
            mountain: mountain,
            indexInMountain: indexInMountain,
            globalIndex: globalIndex,
            range: YangGongAngleRange(start: start, end: end),
            centerAngle: center
        )
    }

    private static func dragonLine(
        for angle: Double,
        mountain: Direction,
        mountainOffset: Double
    ) -> YangGongDragonLine {
        let indexInMountain = min(Int(mountainOffset / dragonWidth), 2) + 1
        let mountainIndex = Direction.compassOrder.firstIndex(of: mountain) ?? 0
        let globalIndex = mountainIndex * 3 + indexInMountain
        let start = normalized(mountainStartAngle(for: mountain) + Double(indexInMountain - 1) * dragonWidth)
        let end = normalized(start + dragonWidth)
        let center = normalized(start + dragonWidth / 2)

        return YangGongDragonLine(
            mountain: mountain,
            indexInMountain: indexInMountain,
            globalIndex: globalIndex,
            range: YangGongAngleRange(start: start, end: end),
            centerAngle: center
        )
    }

    private static func mountainStartAngle(for mountain: Direction) -> Double {
        normalized(mountain.angle - mountainWidth / 2)
    }

    private static func offsetInMountain(angle: Double, mountain: Direction) -> Double {
        let start = mountainStartAngle(for: mountain)
        return normalized(angle - start)
    }

    private static func boundaryStatus(
        distanceToMountainBoundary: Double,
        distanceToFenjinBoundary: Double,
        threshold: Double
    ) -> YangGongBoundaryStatus {
        if distanceToMountainBoundary <= threshold {
            return .nearMountainBoundary(distance: distanceToMountainBoundary)
        }

        if distanceToFenjinBoundary <= threshold {
            return .nearFenjinBoundary(distance: distanceToFenjinBoundary)
        }

        return .stable
    }
}
