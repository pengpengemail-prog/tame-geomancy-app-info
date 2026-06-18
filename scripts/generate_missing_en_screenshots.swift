#!/usr/bin/env swift

import AppKit

private let canvasSize = CGSize(width: 1284, height: 2778)
private let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("AppStoreAssets/en-US")

private struct Palette {
    static let paper = NSColor(calibratedRed: 0.972, green: 0.956, blue: 0.918, alpha: 1)
    static let card = NSColor(calibratedRed: 1.0, green: 0.992, blue: 0.964, alpha: 1)
    static let ink = NSColor(calibratedRed: 0.105, green: 0.094, blue: 0.078, alpha: 1)
    static let muted = NSColor(calibratedRed: 0.394, green: 0.361, blue: 0.302, alpha: 1)
    static let gold = NSColor(calibratedRed: 0.733, green: 0.560, blue: 0.278, alpha: 1)
    static let goldSoft = NSColor(calibratedRed: 0.870, green: 0.768, blue: 0.548, alpha: 1)
    static let red = NSColor(calibratedRed: 0.690, green: 0.262, blue: 0.196, alpha: 1)
    static let green = NSColor(calibratedRed: 0.212, green: 0.455, blue: 0.345, alpha: 1)
    static let gray = NSColor(calibratedRed: 0.760, green: 0.733, blue: 0.662, alpha: 1)
    static let line = NSColor(calibratedRed: 0.812, green: 0.753, blue: 0.616, alpha: 1)
}

private enum ShotKind {
    case dualCompass
    case opening
    case flyingStar
    case floorPlan
    case bazhai
    case recordShare

    var fileName: String {
        switch self {
        case .dualCompass: return "01-dual-compass.png"
        case .opening: return "02-opening-reference.png"
        case .flyingStar: return "03-flying-star.png"
        case .floorPlan: return "04-floor-plan-heatmap.png"
        case .bazhai: return "05-bazhai.png"
        case .recordShare: return "06-record-share.png"
        }
    }

    var title: String {
        switch self {
        case .dualCompass: return "Dual Compass, Clear Orientation"
        case .opening: return "Review Door and Window Directions"
        case .flyingStar: return "Year and Period Views Made Clear"
        case .floorPlan: return "Import Plans, Add a 3x3 Heatmap"
        case .bazhai: return "Room Groups and Layout Notes"
        case .recordShare: return "Save Records, Share Report Cards"
        }
    }

    var subtitle: String {
        switch self {
        case .dualCompass: return "Earth plate and space plate in one view"
        case .opening: return "Check openings for key spaces"
        case .flyingStar: return "Nine-grid and annual layout charts"
        case .floorPlan: return "Place the center point and mark rooms"
        case .bazhai: return "Use direction-based room suggestions"
        case .recordShare: return "Private local history with exportable summaries"
        }
    }
}

private func topRect(_ rect: CGRect) -> CGRect {
    CGRect(x: rect.minX, y: canvasSize.height - rect.minY - rect.height, width: rect.width, height: rect.height)
}

private func topPoint(_ point: CGPoint) -> CGPoint {
    CGPoint(x: point.x, y: canvasSize.height - point.y)
}

private func fillRect(_ rect: CGRect, color: NSColor) {
    color.setFill()
    topRect(rect).fill()
}

private func paragraphStyle(alignment: NSTextAlignment = .left, lineHeight: CGFloat? = nil) -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = alignment
    if let lineHeight {
        style.minimumLineHeight = lineHeight
        style.maximumLineHeight = lineHeight
    }
    return style
}

private func attributes(
    size: CGFloat,
    weight: NSFont.Weight,
    color: NSColor,
    alignment: NSTextAlignment = .left,
    lineHeight: CGFloat? = nil
) -> [NSAttributedString.Key: Any] {
    [
        .font: NSFont.systemFont(ofSize: size, weight: weight),
        .foregroundColor: color,
        .paragraphStyle: paragraphStyle(alignment: alignment, lineHeight: lineHeight)
    ]
}

private func drawText(
    _ text: String,
    in rect: CGRect,
    size: CGFloat,
    weight: NSFont.Weight,
    color: NSColor = Palette.ink,
    alignment: NSTextAlignment = .left,
    lineHeight: CGFloat? = nil
) {
    NSString(string: text).draw(
        in: topRect(rect),
        withAttributes: attributes(size: size, weight: weight, color: color, alignment: alignment, lineHeight: lineHeight)
    )
}

private func roundedRect(_ rect: CGRect, radius: CGFloat, fill: NSColor, stroke: NSColor? = nil, lineWidth: CGFloat = 2) {
    let path = NSBezierPath(roundedRect: topRect(rect), xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}

private func line(from start: CGPoint, to end: CGPoint, color: NSColor = Palette.line, width: CGFloat = 2) {
    let path = NSBezierPath()
    path.move(to: topPoint(start))
    path.line(to: topPoint(end))
    color.setStroke()
    path.lineWidth = width
    path.stroke()
}

private func pill(_ text: String, rect: CGRect, fill: NSColor = Palette.card, stroke: NSColor = Palette.line) {
    roundedRect(rect, radius: rect.height / 2, fill: fill, stroke: stroke, lineWidth: 2)
    drawText(text, in: rect.insetBy(dx: 28, dy: 14), size: 26, weight: .semibold, color: Palette.ink, alignment: .center)
}

private func drawChrome(for kind: ShotKind) {
    fillRect(CGRect(origin: .zero, size: canvasSize), color: Palette.paper)

    drawText(
        "TAME Space Compass / 探觅·空间罗盘",
        in: CGRect(x: 78, y: 92, width: 900, height: 44),
        size: 28,
        weight: .semibold,
        color: Palette.gold
    )

    drawText(
        kind.title,
        in: CGRect(x: 78, y: 170, width: 1020, height: 210),
        size: 74,
        weight: .bold,
        color: Palette.ink,
        lineHeight: 84
    )

    drawText(
        kind.subtitle,
        in: CGRect(x: 82, y: 385, width: 980, height: 74),
        size: 34,
        weight: .medium,
        color: Palette.muted
    )

    roundedRect(CGRect(x: 118, y: 545, width: 970, height: 1840), radius: 86, fill: NSColor.white, stroke: Palette.ink, lineWidth: 6)
    roundedRect(CGRect(x: 154, y: 595, width: 898, height: 1740), radius: 54, fill: Palette.paper, stroke: Palette.line, lineWidth: 2)
    roundedRect(CGRect(x: 476, y: 620, width: 252, height: 18), radius: 9, fill: Palette.gray)
}

private func drawDualCompassShot() {
    drawChrome(for: .dualCompass)

    drawText("Compass Reading", in: CGRect(x: 202, y: 685, width: 560, height: 48), size: 38, weight: .bold)
    pill("Earth + Space", rect: CGRect(x: 760, y: 676, width: 240, height: 54), fill: NSColor.white)

    drawMetric("00.1", "Earth Plate", "180°", x: 202, y: 770)
    drawMetric("00.2", "Space Plate", "187.5°", x: 612, y: 770)
    drawMetric("00.3", "Facing", "South", x: 202, y: 904)
    drawMetric("00.4", "Mode", "Live reading", x: 612, y: 904)

    drawSectionTitle("Dual-Ring View", y: 1070)
    let board = CGRect(x: 202, y: 1135, width: 808, height: 808)
    roundedRect(board, radius: 34, fill: Palette.card, stroke: Palette.line)
    let center = CGPoint(x: board.midX, y: board.midY)
    let rings: [(CGFloat, CGFloat, NSColor)] = [
        (330, 4, Palette.ink.withAlphaComponent(0.18)),
        (290, 2, Palette.line),
        (250, 4, Palette.goldSoft),
        (208, 2, Palette.line)
    ]
    for (radius, width, color) in rings {
        let path = NSBezierPath(ovalIn: topRect(CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)))
        color.setStroke()
        path.lineWidth = width
        path.stroke()
    }
    for degree in stride(from: 0, to: 360, by: 15) {
        let radians = CGFloat(Double(degree) * .pi / 180)
        let outer = CGPoint(x: center.x + cos(radians) * 330, y: center.y + sin(radians) * 330)
        let inner = CGPoint(x: center.x + cos(radians) * (degree % 45 == 0 ? 270 : 302), y: center.y + sin(radians) * (degree % 45 == 0 ? 270 : 302))
        line(from: outer, to: inner, color: degree % 45 == 0 ? Palette.ink.withAlphaComponent(0.55) : Palette.line, width: degree % 45 == 0 ? 4 : 2)
    }
    let needle = NSBezierPath()
    needle.move(to: topPoint(CGPoint(x: center.x, y: center.y + 255)))
    needle.line(to: topPoint(CGPoint(x: center.x - 18, y: center.y - 8)))
    needle.line(to: topPoint(CGPoint(x: center.x, y: center.y - 122)))
    needle.line(to: topPoint(CGPoint(x: center.x + 18, y: center.y - 8)))
    needle.close()
    Palette.ink.setFill()
    needle.fill()
    roundedRect(CGRect(x: center.x - 24, y: center.y - 24, width: 48, height: 48), radius: 24, fill: NSColor.white, stroke: Palette.ink, lineWidth: 5)
    roundedRect(CGRect(x: center.x - 9, y: center.y - 9, width: 18, height: 18), radius: 9, fill: Palette.ink)

    drawSectionTitle("Why it helps", y: 2000)
    roundedRect(CGRect(x: 202, y: 2068, width: 808, height: 184), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText("Keep the Earth plate and space plate together so orientation checks stay fast and consistent on site.", in: CGRect(x: 248, y: 2118, width: 710, height: 80), size: 27, weight: .medium, color: Palette.muted, lineHeight: 36)
}

private func drawOpeningShot() {
    drawChrome(for: .opening)

    drawText("Opening Reference", in: CGRect(x: 202, y: 685, width: 640, height: 48), size: 38, weight: .bold)
    pill("Stage 9", rect: CGRect(x: 780, y: 676, width: 190, height: 54), fill: NSColor.white)

    drawMetric("00.1", "Facing", "South", x: 202, y: 770)
    drawMetric("00.2", "Openings", "Door / Balcony / Window", x: 612, y: 770)

    drawSectionTitle("Key Openings", y: 950)
    roundedRect(CGRect(x: 202, y: 1018, width: 808, height: 352), radius: 34, fill: Palette.card, stroke: Palette.line)
    drawText("South-Facing Home", in: CGRect(x: 250, y: 1070, width: 440, height: 38), size: 32, weight: .bold)
    drawText("Main Door · Balcony · Main Window", in: CGRect(x: 250, y: 1122, width: 580, height: 34), size: 25, weight: .medium, color: Palette.muted)
    pill("Load Demo", rect: CGRect(x: 250, y: 1200, width: 210, height: 56), fill: NSColor.white)
    pill("Grid Link", rect: CGRect(x: 488, y: 1200, width: 230, height: 56), fill: NSColor.white)
    pill("Save Record", rect: CGRect(x: 748, y: 1200, width: 210, height: 56), fill: NSColor.white)

    drawSectionTitle("Opening Result", y: 1442)
    roundedRect(CGRect(x: 202, y: 1510, width: 808, height: 440), radius: 34, fill: NSColor.white, stroke: Palette.ink, lineWidth: 3)
    drawMetric("01.1", "Primary Opening", "South Balcony", x: 250, y: 1570, width: 328)
    drawMetric("01.2", "Opening Status", "Good", x: 632, y: 1570, width: 328)
    drawMetric("01.3", "Score", "100", x: 250, y: 1710, width: 328)
    drawMetric("01.4", "Reference", "Door + window", x: 632, y: 1710, width: 328)
    drawText(
        "Each key opening is scored against the current stage, then summarized into a practical orientation reference.",
        in: CGRect(x: 250, y: 1858, width: 710, height: 72),
        size: 26,
        weight: .regular,
        color: Palette.muted,
        lineHeight: 34
    )

    drawSectionTitle("Suggested Notes", y: 2020)
    roundedRect(CGRect(x: 202, y: 2088, width: 808, height: 184), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText("Keep the balcony open and bright; use the record detail page to archive the full comparison.", in: CGRect(x: 250, y: 2138, width: 710, height: 78), size: 27, weight: .medium, color: Palette.ink, lineHeight: 36)
}

private func drawSectionTitle(_ title: String, y: CGFloat) {
    drawText(title, in: CGRect(x: 202, y: y, width: 808, height: 44), size: 30, weight: .bold, color: Palette.ink)
}

private func drawMetric(_ index: String, _ title: String, _ value: String, x: CGFloat, y: CGFloat, width: CGFloat = 390) {
    roundedRect(CGRect(x: x, y: y, width: width, height: 116), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText(index, in: CGRect(x: x + 24, y: y + 20, width: 80, height: 30), size: 19, weight: .semibold, color: Palette.gold)
    drawText(title, in: CGRect(x: x + 24, y: y + 51, width: width - 48, height: 26), size: 20, weight: .medium, color: Palette.muted)
    drawText(value, in: CGRect(x: x + 24, y: y + 78, width: width - 48, height: 28), size: 24, weight: .bold, color: Palette.ink)
}

private func drawFloorPlanShot() {
    drawChrome(for: .floorPlan)

    drawText("Floor Plan Analysis", in: CGRect(x: 202, y: 685, width: 680, height: 46), size: 36, weight: .bold)
    pill("Grid + Heatmap", rect: CGRect(x: 744, y: 676, width: 228, height: 54), fill: NSColor.white)

    drawMetric("00.1", "Import Status", "Reference Layout", x: 202, y: 770)
    drawMetric("00.2", "Center Point", "Placed", x: 612, y: 770)
    drawMetric("00.3", "Facing", "South", x: 202, y: 904)
    drawMetric("00.4", "Room Markers", "9", x: 612, y: 904)

    drawSectionTitle("9-Palace Overlay", y: 1070)
    let plan = CGRect(x: 202, y: 1135, width: 808, height: 642)
    roundedRect(plan, radius: 34, fill: NSColor(calibratedRed: 0.984, green: 0.972, blue: 0.929, alpha: 1), stroke: Palette.ink, lineWidth: 3)

    let cellW = plan.width / 3
    let cellH = plan.height / 3
    let heatColors: [NSColor] = [
        Palette.goldSoft, NSColor(calibratedRed: 0.955, green: 0.852, blue: 0.615, alpha: 1), Palette.red.withAlphaComponent(0.28),
        Palette.green.withAlphaComponent(0.35), Palette.gold.withAlphaComponent(0.42), Palette.gray.withAlphaComponent(0.40),
        Palette.gray.withAlphaComponent(0.30), Palette.green.withAlphaComponent(0.26), Palette.goldSoft.withAlphaComponent(0.55)
    ]
    for row in 0..<3 {
        for col in 0..<3 {
            let index = row * 3 + col
            let rect = CGRect(x: plan.minX + CGFloat(col) * cellW, y: plan.minY + CGFloat(row) * cellH, width: cellW, height: cellH)
            fillRect(rect, color: heatColors[index])
        }
    }
    for i in 1...2 {
        let x = plan.minX + CGFloat(i) * cellW
        let y = plan.minY + CGFloat(i) * cellH
        line(from: CGPoint(x: x, y: plan.minY), to: CGPoint(x: x, y: plan.maxY), color: Palette.ink.withAlphaComponent(0.35), width: 3)
        line(from: CGPoint(x: plan.minX, y: y), to: CGPoint(x: plan.maxX, y: y), color: Palette.ink.withAlphaComponent(0.35), width: 3)
    }

    let rooms: [(String, CGFloat, CGFloat, NSColor)] = [
        ("Door", 0.18, 0.17, Palette.red),
        ("Bath", 0.42, 0.20, Palette.gray),
        ("Kitchen", 0.78, 0.20, Palette.red),
        ("Study", 0.18, 0.40, Palette.green),
        ("Living", 0.54, 0.66, Palette.gold),
        ("Bed", 0.22, 0.64, Palette.green),
        ("Bed", 0.80, 0.67, Palette.gold),
        ("Window", 0.86, 0.32, Palette.gold),
        ("Balcony", 0.52, 0.90, Palette.green)
    ]
    for (label, px, py, color) in rooms {
        let center = CGPoint(x: plan.minX + px * plan.width, y: plan.minY + py * plan.height)
        roundedRect(CGRect(x: center.x - 53, y: center.y - 24, width: 106, height: 48), radius: 24, fill: NSColor.white, stroke: color, lineWidth: 3)
        drawText(label, in: CGRect(x: center.x - 48, y: center.y - 13, width: 96, height: 24), size: 17, weight: .bold, color: color, alignment: .center)
    }

    roundedRect(CGRect(x: plan.midX - 28, y: plan.midY - 28, width: 56, height: 56), radius: 28, fill: Palette.ink)
    drawText("C", in: CGRect(x: plan.midX - 16, y: plan.midY - 15, width: 32, height: 30), size: 22, weight: .bold, color: NSColor.white, alignment: .center)

    drawSectionTitle("Room Review", y: 1845)
    drawMetric("01.1", "Stable Areas", "Living / Study", x: 202, y: 1910)
    drawMetric("01.2", "Needs Care", "Kitchen / Bath", x: 612, y: 1910)
    drawText(
        "The reference layout combines a center point, room markers, and a direction-based heatmap so spatial notes stay organized.",
        in: CGRect(x: 202, y: 2055, width: 808, height: 110),
        size: 28,
        weight: .regular,
        color: Palette.muted,
        lineHeight: 38
    )
    pill("Save to local records", rect: CGRect(x: 304, y: 2200, width: 600, height: 74), fill: Palette.ink, stroke: Palette.ink)
    drawText("Save to local records", in: CGRect(x: 330, y: 2218, width: 548, height: 34), size: 27, weight: .bold, color: NSColor.white, alignment: .center)
}

private func drawFlyingStarShot() {
    drawChrome(for: .flyingStar)

    drawText("Nine-Grid Layout", in: CGRect(x: 202, y: 685, width: 560, height: 48), size: 38, weight: .bold)
    pill("Stage 9", rect: CGRect(x: 790, y: 676, width: 190, height: 54), fill: NSColor.white)

    drawMetric("00.1", "Layout", "9", x: 202, y: 770)
    drawMetric("00.2", "Mountain", "6", x: 612, y: 770)
    drawMetric("00.3", "Facing", "1", x: 202, y: 904)
    drawMetric("00.4", "Year", "4", x: 612, y: 904)

    drawSectionTitle("Nine-Grid Overview", y: 1070)
    let chart = CGRect(x: 250, y: 1135, width: 712, height: 712)
    roundedRect(chart, radius: 34, fill: Palette.card, stroke: Palette.ink, lineWidth: 3)
    let cellW = chart.width / 3
    let cellH = chart.height / 3
    let values = [
        ("4", "6", "1"), ("9", "5", "8"), ("2", "7", "3"),
        ("3", "1", "7"), ("5", "9", "6"), ("8", "2", "4"),
        ("7", "3", "9"), ("1", "8", "5"), ("6", "4", "2")
    ]
    for row in 0..<3 {
        for col in 0..<3 {
            let idx = row * 3 + col
            let rect = CGRect(x: chart.minX + CGFloat(col) * cellW, y: chart.minY + CGFloat(row) * cellH, width: cellW, height: cellH)
            fillRect(rect, color: (row + col).isMultiple(of: 2) ? Palette.paper : Palette.card)
            drawText(values[idx].0, in: CGRect(x: rect.minX + 26, y: rect.minY + 26, width: 50, height: 42), size: 32, weight: .bold, color: Palette.gold)
            drawText(values[idx].1, in: CGRect(x: rect.midX - 20, y: rect.midY - 18, width: 40, height: 36), size: 28, weight: .bold, color: Palette.ink, alignment: .center)
            drawText(values[idx].2, in: CGRect(x: rect.maxX - 74, y: rect.maxY - 66, width: 50, height: 42), size: 32, weight: .bold, color: Palette.green, alignment: .right)
        }
    }
    for i in 1...2 {
        let x = chart.minX + CGFloat(i) * cellW
        let y = chart.minY + CGFloat(i) * cellH
        line(from: CGPoint(x: x, y: chart.minY), to: CGPoint(x: x, y: chart.maxY), color: Palette.ink.withAlphaComponent(0.35), width: 3)
        line(from: CGPoint(x: chart.minX, y: y), to: CGPoint(x: chart.maxX, y: y), color: Palette.ink.withAlphaComponent(0.35), width: 3)
    }

    drawSectionTitle("Chart Summary", y: 1900)
    roundedRect(CGRect(x: 202, y: 1968, width: 808, height: 200), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText("Review yun, mountain, facing, and yearly layout together before moving into room-by-room layout notes.", in: CGRect(x: 248, y: 2024, width: 710, height: 80), size: 27, weight: .medium, color: Palette.muted, lineHeight: 36)
}

private func drawBazhaiShot() {
    drawChrome(for: .bazhai)

    drawText("Eight-Sector Notes", in: CGRect(x: 202, y: 685, width: 620, height: 48), size: 38, weight: .bold)
    pill("House + Profile", rect: CGRect(x: 700, y: 676, width: 280, height: 54), fill: NSColor.white)

    drawMetric("00.1", "House Profile", "Li", x: 202, y: 770)
    drawMetric("00.2", "Occupant Profile", "Xun", x: 612, y: 770)
    drawMetric("00.3", "Group", "East Group", x: 202, y: 904)
    drawMetric("00.4", "Match", "Aligned", x: 612, y: 904)

    drawSectionTitle("Room Suggestions", y: 1070)
    let map = CGRect(x: 202, y: 1138, width: 808, height: 610)
    roundedRect(map, radius: 34, fill: NSColor(calibratedRed: 0.984, green: 0.972, blue: 0.929, alpha: 1), stroke: Palette.ink, lineWidth: 3)
    let labels: [(String, String, NSColor)] = [
        ("SE", "Study", Palette.green), ("S", "Living", Palette.gold), ("SW", "Bath", Palette.gray),
        ("E", "Bedroom", Palette.green), ("C", "Balance", Palette.goldSoft), ("W", "Storage", Palette.gray),
        ("NE", "Desk", Palette.gold), ("N", "Quiet", Palette.green), ("NW", "Kitchen", Palette.red)
    ]
    let cellW = map.width / 3
    let cellH = map.height / 3
    for row in 0..<3 {
        for col in 0..<3 {
            let index = row * 3 + col
            let rect = CGRect(x: map.minX + CGFloat(col) * cellW, y: map.minY + CGFloat(row) * cellH, width: cellW, height: cellH)
            fillRect(rect, color: labels[index].2.withAlphaComponent(0.20))
            drawText(labels[index].0, in: CGRect(x: rect.minX + 22, y: rect.minY + 20, width: 70, height: 28), size: 22, weight: .bold, color: Palette.muted)
            drawText(labels[index].1, in: CGRect(x: rect.minX + 22, y: rect.minY + 76, width: cellW - 44, height: 34), size: 28, weight: .bold, color: labels[index].2)
        }
    }
    for i in 1...2 {
        let x = map.minX + CGFloat(i) * cellW
        let y = map.minY + CGFloat(i) * cellH
        line(from: CGPoint(x: x, y: map.minY), to: CGPoint(x: x, y: map.maxY), color: Palette.ink.withAlphaComponent(0.30), width: 3)
        line(from: CGPoint(x: map.minX, y: y), to: CGPoint(x: map.maxX, y: y), color: Palette.ink.withAlphaComponent(0.30), width: 3)
    }

    drawSectionTitle("Practical Reference", y: 1820)
    roundedRect(CGRect(x: 202, y: 1888, width: 808, height: 280), radius: 34, fill: Palette.card, stroke: Palette.line)
    drawText("Use suggested sectors for quiet work and rest, then keep caution sectors lighter and well ventilated.", in: CGRect(x: 250, y: 1940, width: 710, height: 84), size: 29, weight: .medium, color: Palette.ink, lineHeight: 38)
    pill("Save Eight-Sector Record", rect: CGRect(x: 304, y: 2070, width: 600, height: 70), fill: Palette.ink, stroke: Palette.ink)
    drawText("Save Eight-Sector Record", in: CGRect(x: 330, y: 2087, width: 548, height: 34), size: 26, weight: .bold, color: NSColor.white, alignment: .center)
}

private func drawRecordShareShot() {
    drawChrome(for: .recordShare)

    drawText("Records", in: CGRect(x: 202, y: 685, width: 360, height: 48), size: 38, weight: .bold)
    pill("Private on device", rect: CGRect(x: 704, y: 676, width: 282, height: 54), fill: NSColor.white)

    drawMetric("00.1", "Saved Items", "1", x: 202, y: 770)
    drawMetric("00.2", "Export", "Image + Text", x: 612, y: 770)

    roundedRect(CGRect(x: 202, y: 950, width: 808, height: 280), radius: 36, fill: Palette.card, stroke: Palette.line)
    drawText("Report Preview", in: CGRect(x: 248, y: 1002, width: 500, height: 42), size: 36, weight: .bold)
    drawText("Floor-plan heatmap · opening linkage", in: CGRect(x: 248, y: 1053, width: 650, height: 34), size: 25, weight: .medium, color: Palette.muted)
    drawText("Category: Floor Plan", in: CGRect(x: 248, y: 1120, width: 250, height: 34), size: 24, weight: .semibold, color: Palette.gold)
    drawText("Detail Rows 4 · Notes Saved", in: CGRect(x: 248, y: 1158, width: 560, height: 34), size: 24, weight: .medium, color: Palette.muted)

    drawSectionTitle("Report Card", y: 1300)
    let card = CGRect(x: 250, y: 1370, width: 708, height: 520)
    roundedRect(card, radius: 34, fill: NSColor.white, stroke: Palette.ink, lineWidth: 3)
    drawText("TAME Space Compass", in: CGRect(x: 292, y: 1412, width: 380, height: 34), size: 26, weight: .bold, color: Palette.gold)
    drawText("Report Preview", in: CGRect(x: 292, y: 1472, width: 450, height: 46), size: 39, weight: .bold)
    drawText("Facing basis: Wu sector · Stage 9", in: CGRect(x: 292, y: 1538, width: 570, height: 34), size: 24, weight: .medium, color: Palette.muted)

    let mini = CGRect(x: 292, y: 1605, width: 270, height: 210)
    roundedRect(mini, radius: 20, fill: Palette.paper, stroke: Palette.line)
    for i in 1...2 {
        line(from: CGPoint(x: mini.minX + CGFloat(i) * mini.width / 3, y: mini.minY), to: CGPoint(x: mini.minX + CGFloat(i) * mini.width / 3, y: mini.maxY), color: Palette.line, width: 2)
        line(from: CGPoint(x: mini.minX, y: mini.minY + CGFloat(i) * mini.height / 3), to: CGPoint(x: mini.maxX, y: mini.minY + CGFloat(i) * mini.height / 3), color: Palette.line, width: 2)
    }
    fillRect(CGRect(x: mini.minX + mini.width / 3, y: mini.minY + mini.height / 3, width: mini.width / 3, height: mini.height / 3), color: Palette.gold.withAlphaComponent(0.55))
    roundedRect(CGRect(x: mini.midX - 18, y: mini.midY - 18, width: 36, height: 36), radius: 18, fill: Palette.ink)

    drawText("Primary opening", in: CGRect(x: 594, y: 1608, width: 300, height: 30), size: 21, weight: .medium, color: Palette.muted)
    drawText("South Balcony", in: CGRect(x: 594, y: 1644, width: 300, height: 35), size: 28, weight: .bold)
    drawText("Good · score 100", in: CGRect(x: 594, y: 1688, width: 300, height: 30), size: 24, weight: .semibold, color: Palette.green)
    drawText("Export note: creates a branded report image for sharing.", in: CGRect(x: 594, y: 1744, width: 300, height: 70), size: 22, weight: .regular, color: Palette.muted, lineHeight: 29)

    drawSectionTitle("Export Options", y: 1970)
    roundedRect(CGRect(x: 202, y: 2038, width: 386, height: 150), radius: 32, fill: Palette.card, stroke: Palette.line)
    drawText("Save to Photos", in: CGRect(x: 244, y: 2085, width: 300, height: 34), size: 30, weight: .bold)
    drawText("Branded report image", in: CGRect(x: 244, y: 2126, width: 300, height: 28), size: 22, weight: .medium, color: Palette.muted)

    roundedRect(CGRect(x: 624, y: 2038, width: 386, height: 150), radius: 32, fill: Palette.ink, stroke: Palette.ink)
    drawText("Share Report", in: CGRect(x: 666, y: 2085, width: 300, height: 34), size: 30, weight: .bold, color: NSColor.white)
    drawText("Image and text summary", in: CGRect(x: 666, y: 2126, width: 300, height: 28), size: 22, weight: .medium, color: Palette.goldSoft)
}

private func makeBitmapContext() -> CGContext {
    let width = Int(canvasSize.width)
    let height = Int(canvasSize.height)
    let bytesPerRow = width * 4
    let data = UnsafeMutableRawPointer.allocate(byteCount: bytesPerRow * height, alignment: 16)
    data.initializeMemory(as: UInt8.self, repeating: 255, count: bytesPerRow * height)
    guard let context = CGContext(
        data: data,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
    ) else {
        fatalError("Unable to create RGB bitmap context")
    }
    context.interpolationQuality = .high
    return context
}

private func write(_ kind: ShotKind, draw: () -> Void) throws {
    NSGraphicsContext.saveGraphicsState()
    let context = makeBitmapContext()
    NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
    draw()
    NSGraphicsContext.restoreGraphicsState()

    guard let cgImage = context.makeImage() else {
        fatalError("Unable to create CGImage")
    }

    let bitmap = NSBitmapImageRep(cgImage: cgImage)
    guard let data = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Unable to encode PNG")
    }
    try FileManager.default.createDirectory(at: outputDir, withIntermediateDirectories: true)
    try data.write(to: outputDir.appendingPathComponent(kind.fileName), options: .atomic)
    print("Generated \(kind.fileName)")
}

try write(.dualCompass, draw: drawDualCompassShot)
try write(.opening, draw: drawOpeningShot)
try write(.flyingStar, draw: drawFlyingStarShot)
try write(.floorPlan, draw: drawFloorPlanShot)
try write(.bazhai, draw: drawBazhaiShot)
try write(.recordShare, draw: drawRecordShareShot)
