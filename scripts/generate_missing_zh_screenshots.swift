#!/usr/bin/env swift

import AppKit

private let canvasSize = CGSize(width: 1284, height: 2778)
private let outputDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    .appendingPathComponent("AppStoreAssets/zh-Hans")

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
        case .dualCompass: return "双盘罗盘 一眼定坐向"
        case .opening: return "门窗方向 直接查看"
        case .flyingStar: return "年份与阶段 一屏掌握"
        case .floorPlan: return "导入户型图 叠加九宫热力图"
        case .bazhai: return "房间分组 辅助空间布置"
        case .recordShare: return "保存记录 生成参考报告卡"
        }
    }

    var subtitle: String {
        switch self {
        case .dualCompass: return "地盘正针与空间盘同屏显示"
        case .opening: return "大门 阳台 主窗都能参考"
        case .flyingStar: return "九宫布局与年度盘清晰查看"
        case .floorPlan: return "立极点 标记房间 一目了然"
        case .bazhai: return "卧室 书房 客厅布局更有依据"
        case .recordShare: return "本地整理 分析结果可直接分享"
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
    drawText("TAME Space Compass / 探觅·空间罗盘", in: CGRect(x: 76, y: 92, width: 980, height: 44), size: 28, weight: .semibold, color: Palette.gold)
    drawText(kind.title, in: CGRect(x: 76, y: 166, width: 1100, height: 210), size: 72, weight: .bold, color: Palette.ink, lineHeight: 82)
    drawText(kind.subtitle, in: CGRect(x: 82, y: 388, width: 980, height: 74), size: 34, weight: .medium, color: Palette.muted)
    roundedRect(CGRect(x: 118, y: 545, width: 1048, height: 1940), radius: 86, fill: NSColor.white, stroke: Palette.ink, lineWidth: 6)
    roundedRect(CGRect(x: 154, y: 595, width: 976, height: 1842), radius: 54, fill: Palette.paper, stroke: Palette.line, lineWidth: 2)
    roundedRect(CGRect(x: 516, y: 620, width: 252, height: 18), radius: 9, fill: Palette.gray)
}

private func drawSectionTitle(_ title: String, y: CGFloat) {
    drawText(title, in: CGRect(x: 202, y: y, width: 860, height: 44), size: 30, weight: .bold, color: Palette.ink)
}

private func drawDualCompassShot() {
    drawChrome(for: .dualCompass)
    drawText("双盘罗盘", in: CGRect(x: 202, y: 685, width: 420, height: 48), size: 38, weight: .bold)
    pill("地盘 + 空间盘", rect: CGRect(x: 730, y: 676, width: 280, height: 54), fill: NSColor.white)
    drawMetric("00.1", "地盘", "180°", x: 202, y: 770)
    drawMetric("00.2", "空间盘", "187.5°", x: 654, y: 770)
    drawMetric("00.3", "坐向", "坐北朝南", x: 202, y: 904)
    drawMetric("00.4", "模式", "实时测向", x: 654, y: 904)

    drawSectionTitle("双盘测向", y: 1070)
    let board = CGRect(x: 202, y: 1135, width: 860, height: 860)
    roundedRect(board, radius: 34, fill: Palette.card, stroke: Palette.line)
    let center = CGPoint(x: board.midX, y: board.midY)
    let rings: [(CGFloat, CGFloat, NSColor)] = [
        (360, 4, Palette.ink.withAlphaComponent(0.18)),
        (318, 2, Palette.line),
        (276, 4, Palette.goldSoft),
        (228, 2, Palette.line)
    ]
    for (radius, width, color) in rings {
        let path = NSBezierPath(ovalIn: topRect(CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)))
        color.setStroke()
        path.lineWidth = width
        path.stroke()
    }
    for degree in stride(from: 0, to: 360, by: 15) {
        let radians = CGFloat(Double(degree) * .pi / 180)
        let outer = CGPoint(x: center.x + cos(radians) * 360, y: center.y + sin(radians) * 360)
        let inner = CGPoint(x: center.x + cos(radians) * (degree % 45 == 0 ? 292 : 330), y: center.y + sin(radians) * (degree % 45 == 0 ? 292 : 330))
        line(from: outer, to: inner, color: degree % 45 == 0 ? Palette.ink.withAlphaComponent(0.55) : Palette.line, width: degree % 45 == 0 ? 4 : 2)
    }
    let needle = NSBezierPath()
    needle.move(to: topPoint(CGPoint(x: center.x, y: center.y + 278)))
    needle.line(to: topPoint(CGPoint(x: center.x - 18, y: center.y - 8)))
    needle.line(to: topPoint(CGPoint(x: center.x, y: center.y - 130)))
    needle.line(to: topPoint(CGPoint(x: center.x + 18, y: center.y - 8)))
    needle.close()
    Palette.ink.setFill()
    needle.fill()
    roundedRect(CGRect(x: center.x - 24, y: center.y - 24, width: 48, height: 48), radius: 24, fill: NSColor.white, stroke: Palette.ink, lineWidth: 5)
    roundedRect(CGRect(x: center.x - 9, y: center.y - 9, width: 18, height: 18), radius: 9, fill: Palette.ink)

    drawSectionTitle("使用场景", y: 2045)
    roundedRect(CGRect(x: 202, y: 2110, width: 860, height: 168), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText("先确认房屋坐向，再进入开口、九宫和户型分析页面，现场查看会更顺手。", in: CGRect(x: 248, y: 2160, width: 760, height: 80), size: 28, weight: .medium, color: Palette.muted, lineHeight: 38)
}

private func drawOpeningShot() {
    drawChrome(for: .opening)
    drawText("开口参考", in: CGRect(x: 202, y: 685, width: 420, height: 48), size: 38, weight: .bold)
    pill("大门 / 阳台 / 主窗", rect: CGRect(x: 700, y: 676, width: 320, height: 54), fill: NSColor.white)
    drawMetric("00.1", "朝向", "正南", x: 202, y: 770)
    drawMetric("00.2", "开口数量", "3", x: 654, y: 770)

    drawSectionTitle("主要开口", y: 950)
    roundedRect(CGRect(x: 202, y: 1018, width: 860, height: 352), radius: 34, fill: Palette.card, stroke: Palette.line)
    drawText("南向住宅", in: CGRect(x: 250, y: 1070, width: 440, height: 38), size: 32, weight: .bold)
    drawText("大门 · 阳台 · 主窗", in: CGRect(x: 250, y: 1122, width: 580, height: 34), size: 25, weight: .medium, color: Palette.muted)
    pill("加载示例", rect: CGRect(x: 250, y: 1200, width: 210, height: 56), fill: NSColor.white)
    pill("联动九宫", rect: CGRect(x: 488, y: 1200, width: 230, height: 56), fill: NSColor.white)
    pill("保存记录", rect: CGRect(x: 748, y: 1200, width: 210, height: 56), fill: NSColor.white)

    drawSectionTitle("开口结论", y: 1442)
    roundedRect(CGRect(x: 202, y: 1510, width: 860, height: 440), radius: 34, fill: NSColor.white, stroke: Palette.ink, lineWidth: 3)
    drawMetric("01.1", "主要开口", "南向阳台", x: 250, y: 1570, width: 350)
    drawMetric("01.2", "开口状态", "良好", x: 650, y: 1570, width: 350)
    drawMetric("01.3", "评分", "100", x: 250, y: 1710, width: 350)
    drawMetric("01.4", "参考依据", "大门 + 主窗", x: 650, y: 1710, width: 350)
    drawText("每个主要开口会结合当前阶段整理成一条更容易理解的开口参考。", in: CGRect(x: 250, y: 1858, width: 750, height: 72), size: 26, weight: .regular, color: Palette.muted, lineHeight: 34)
}

private func drawFlyingStarShot() {
    drawChrome(for: .flyingStar)
    drawText("九宫布局", in: CGRect(x: 202, y: 685, width: 420, height: 48), size: 38, weight: .bold)
    pill("九运", rect: CGRect(x: 850, y: 676, width: 140, height: 54), fill: NSColor.white)
    drawMetric("00.1", "运盘", "9", x: 202, y: 770)
    drawMetric("00.2", "山盘", "6", x: 654, y: 770)
    drawMetric("00.3", "向盘", "1", x: 202, y: 904)
    drawMetric("00.4", "年度", "4", x: 654, y: 904)

    drawSectionTitle("九宫总盘", y: 1070)
    let chart = CGRect(x: 250, y: 1135, width: 764, height: 764)
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

    drawSectionTitle("排盘摘要", y: 1960)
    roundedRect(CGRect(x: 202, y: 2028, width: 860, height: 200), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText("运盘、山盘、向盘与年度盘可以同屏查看，方便先看总盘，再进入逐宫参考。", in: CGRect(x: 248, y: 2084, width: 760, height: 84), size: 28, weight: .medium, color: Palette.muted, lineHeight: 38)
}

private func drawMetric(_ index: String, _ title: String, _ value: String, x: CGFloat, y: CGFloat, width: CGFloat = 410) {
    roundedRect(CGRect(x: x, y: y, width: width, height: 116), radius: 30, fill: Palette.card, stroke: Palette.line)
    drawText(index, in: CGRect(x: x + 24, y: y + 20, width: 80, height: 30), size: 19, weight: .semibold, color: Palette.gold)
    drawText(title, in: CGRect(x: x + 24, y: y + 51, width: width - 48, height: 26), size: 20, weight: .medium, color: Palette.muted)
    drawText(value, in: CGRect(x: x + 24, y: y + 78, width: width - 48, height: 28), size: 24, weight: .bold, color: Palette.ink)
}

private func drawFloorPlanShot() {
    drawChrome(for: .floorPlan)
    drawText("户型分析", in: CGRect(x: 202, y: 685, width: 420, height: 48), size: 38, weight: .bold)
    pill("九宫 + 热力图", rect: CGRect(x: 780, y: 676, width: 240, height: 54), fill: NSColor.white)
    drawMetric("00.1", "导入状态", "参考户型", x: 202, y: 770)
    drawMetric("00.2", "立极点", "已设置", x: 654, y: 770)
    drawMetric("00.3", "朝向", "坐北朝南", x: 202, y: 904)
    drawMetric("00.4", "房间标记", "9", x: 654, y: 904)

    drawSectionTitle("九宫热力图", y: 1070)
    let plan = CGRect(x: 202, y: 1135, width: 860, height: 692)
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
        ("大门", 0.18, 0.17, Palette.red), ("卫浴", 0.42, 0.20, Palette.gray), ("厨房", 0.78, 0.20, Palette.red),
        ("书房", 0.18, 0.40, Palette.green), ("客厅", 0.54, 0.66, Palette.gold), ("卧室", 0.22, 0.64, Palette.green),
        ("卧室", 0.80, 0.67, Palette.gold), ("窗户", 0.86, 0.32, Palette.gold), ("阳台", 0.52, 0.90, Palette.green)
    ]
    for (label, px, py, color) in rooms {
        let center = CGPoint(x: plan.minX + px * plan.width, y: plan.minY + py * plan.height)
        roundedRect(CGRect(x: center.x - 60, y: center.y - 24, width: 120, height: 48), radius: 24, fill: NSColor.white, stroke: color, lineWidth: 3)
        drawText(label, in: CGRect(x: center.x - 52, y: center.y - 13, width: 104, height: 24), size: 17, weight: .bold, color: color, alignment: .center)
    }
    roundedRect(CGRect(x: plan.midX - 28, y: plan.midY - 28, width: 56, height: 56), radius: 28, fill: Palette.ink)
    drawText("中", in: CGRect(x: plan.midX - 16, y: plan.midY - 15, width: 32, height: 30), size: 20, weight: .bold, color: NSColor.white, alignment: .center)

    drawSectionTitle("空间结论", y: 1880)
    drawMetric("01.1", "较稳区域", "客厅 / 书房", x: 202, y: 1948)
    drawMetric("01.2", "需要留意", "厨房 / 卫浴", x: 654, y: 1948)
    drawText("导入户型图后，可统一查看立极点、房间标记和九宫热力图，让布局参考更清楚。", in: CGRect(x: 202, y: 2090, width: 860, height: 110), size: 28, weight: .regular, color: Palette.muted, lineHeight: 38)
    pill("保存户型分析记录", rect: CGRect(x: 330, y: 2235, width: 610, height: 74), fill: Palette.ink, stroke: Palette.ink)
    drawText("保存户型分析记录", in: CGRect(x: 356, y: 2254, width: 558, height: 34), size: 27, weight: .bold, color: NSColor.white, alignment: .center)
}

private func drawBazhaiShot() {
    drawChrome(for: .bazhai)
    drawText("八区建议", in: CGRect(x: 202, y: 685, width: 420, height: 48), size: 38, weight: .bold)
    pill("房屋 + 资料", rect: CGRect(x: 760, y: 676, width: 260, height: 54), fill: NSColor.white)
    drawMetric("00.1", "房屋分组", "离宅", x: 202, y: 770)
    drawMetric("00.2", "资料", "巽命", x: 654, y: 770)
    drawMetric("00.3", "分组", "东区", x: 202, y: 904)
    drawMetric("00.4", "匹配度", "较合", x: 654, y: 904)

    drawSectionTitle("空间建议", y: 1070)
    let map = CGRect(x: 202, y: 1138, width: 860, height: 650)
    roundedRect(map, radius: 34, fill: NSColor(calibratedRed: 0.984, green: 0.972, blue: 0.929, alpha: 1), stroke: Palette.ink, lineWidth: 3)
    let labels: [(String, String, NSColor)] = [
        ("东南", "书房", Palette.green), ("正南", "客厅", Palette.gold), ("西南", "卫浴", Palette.gray),
        ("正东", "卧室", Palette.green), ("中宫", "平衡", Palette.goldSoft), ("正西", "储物", Palette.gray),
        ("东北", "书桌", Palette.gold), ("正北", "安静", Palette.green), ("西北", "厨房", Palette.red)
    ]
    let cellW = map.width / 3
    let cellH = map.height / 3
    for row in 0..<3 {
        for col in 0..<3 {
            let index = row * 3 + col
            let rect = CGRect(x: map.minX + CGFloat(col) * cellW, y: map.minY + CGFloat(row) * cellH, width: cellW, height: cellH)
            fillRect(rect, color: labels[index].2.withAlphaComponent(0.20))
            drawText(labels[index].0, in: CGRect(x: rect.minX + 22, y: rect.minY + 20, width: 90, height: 28), size: 22, weight: .bold, color: Palette.muted)
            drawText(labels[index].1, in: CGRect(x: rect.minX + 22, y: rect.minY + 76, width: cellW - 44, height: 34), size: 28, weight: .bold, color: labels[index].2)
        }
    }
    for i in 1...2 {
        let x = map.minX + CGFloat(i) * cellW
        let y = map.minY + CGFloat(i) * cellH
        line(from: CGPoint(x: x, y: map.minY), to: CGPoint(x: x, y: map.maxY), color: Palette.ink.withAlphaComponent(0.30), width: 3)
        line(from: CGPoint(x: map.minX, y: y), to: CGPoint(x: map.maxX, y: y), color: Palette.ink.withAlphaComponent(0.30), width: 3)
    }

    drawSectionTitle("应用方式", y: 1860)
    roundedRect(CGRect(x: 202, y: 1928, width: 860, height: 286), radius: 34, fill: Palette.card, stroke: Palette.line)
    drawText("把卧室、书房和客厅优先放在较稳方向，再把需要留意的区域保持整洁、通风和明亮。", in: CGRect(x: 250, y: 1982, width: 760, height: 82), size: 29, weight: .medium, color: Palette.ink, lineHeight: 38)
    pill("保存八区建议记录", rect: CGRect(x: 330, y: 2105, width: 610, height: 72), fill: Palette.ink, stroke: Palette.ink)
    drawText("保存八区建议记录", in: CGRect(x: 356, y: 2123, width: 558, height: 34), size: 27, weight: .bold, color: NSColor.white, alignment: .center)
}

private func drawRecordShareShot() {
    drawChrome(for: .recordShare)
    drawText("记录与分享", in: CGRect(x: 202, y: 685, width: 460, height: 48), size: 38, weight: .bold)
    pill("本地保存", rect: CGRect(x: 790, y: 676, width: 220, height: 54), fill: NSColor.white)
    drawMetric("00.1", "保存条数", "1", x: 202, y: 770)
    drawMetric("00.2", "导出方式", "图片 + 文本", x: 654, y: 770)

    roundedRect(CGRect(x: 202, y: 950, width: 860, height: 280), radius: 36, fill: Palette.card, stroke: Palette.line)
    drawText("报告预览", in: CGRect(x: 248, y: 1002, width: 500, height: 42), size: 36, weight: .bold)
    drawText("户型热力图 · 开口联动", in: CGRect(x: 248, y: 1053, width: 650, height: 34), size: 25, weight: .medium, color: Palette.muted)
    drawText("分类：户型分析", in: CGRect(x: 248, y: 1120, width: 260, height: 34), size: 24, weight: .semibold, color: Palette.gold)
    drawText("详情 4 条 · 已保存备注", in: CGRect(x: 248, y: 1158, width: 560, height: 34), size: 24, weight: .medium, color: Palette.muted)

    drawSectionTitle("参考报告卡", y: 1300)
    let card = CGRect(x: 250, y: 1370, width: 760, height: 560)
    roundedRect(card, radius: 34, fill: NSColor.white, stroke: Palette.ink, lineWidth: 3)
    drawText("TAME Space Compass", in: CGRect(x: 292, y: 1412, width: 380, height: 34), size: 26, weight: .bold, color: Palette.gold)
    drawText("报告预览", in: CGRect(x: 292, y: 1472, width: 450, height: 46), size: 39, weight: .bold)
    drawText("向盘依据：午位 · 九运", in: CGRect(x: 292, y: 1538, width: 570, height: 34), size: 24, weight: .medium, color: Palette.muted)

    let mini = CGRect(x: 292, y: 1605, width: 290, height: 230)
    roundedRect(mini, radius: 20, fill: Palette.paper, stroke: Palette.line)
    for i in 1...2 {
        line(from: CGPoint(x: mini.minX + CGFloat(i) * mini.width / 3, y: mini.minY), to: CGPoint(x: mini.minX + CGFloat(i) * mini.width / 3, y: mini.maxY), color: Palette.line, width: 2)
        line(from: CGPoint(x: mini.minX, y: mini.minY + CGFloat(i) * mini.height / 3), to: CGPoint(x: mini.maxX, y: mini.minY + CGFloat(i) * mini.height / 3), color: Palette.line, width: 2)
    }
    fillRect(CGRect(x: mini.minX + mini.width / 3, y: mini.minY + mini.height / 3, width: mini.width / 3, height: mini.height / 3), color: Palette.gold.withAlphaComponent(0.55))
    roundedRect(CGRect(x: mini.midX - 18, y: mini.midY - 18, width: 36, height: 36), radius: 18, fill: Palette.ink)

    drawText("主要开口", in: CGRect(x: 620, y: 1608, width: 300, height: 30), size: 21, weight: .medium, color: Palette.muted)
    drawText("南向阳台", in: CGRect(x: 620, y: 1644, width: 300, height: 35), size: 28, weight: .bold)
    drawText("良好 · 评分 100", in: CGRect(x: 620, y: 1688, width: 300, height: 30), size: 24, weight: .semibold, color: Palette.green)
    drawText("导出后会生成一张带品牌样式的参考报告卡，便于保存与系统分享。", in: CGRect(x: 620, y: 1744, width: 320, height: 90), size: 22, weight: .regular, color: Palette.muted, lineHeight: 29)

    drawSectionTitle("导出选项", y: 1980)
    roundedRect(CGRect(x: 202, y: 2048, width: 410, height: 162), radius: 32, fill: Palette.card, stroke: Palette.line)
    drawText("保存到相册", in: CGRect(x: 246, y: 2098, width: 300, height: 34), size: 30, weight: .bold)
    drawText("品牌化报告图片", in: CGRect(x: 246, y: 2139, width: 300, height: 28), size: 22, weight: .medium, color: Palette.muted)

    roundedRect(CGRect(x: 652, y: 2048, width: 410, height: 162), radius: 32, fill: Palette.ink, stroke: Palette.ink)
    drawText("分享报告", in: CGRect(x: 696, y: 2098, width: 300, height: 34), size: 30, weight: .bold, color: NSColor.white)
    drawText("图片与摘要文字", in: CGRect(x: 696, y: 2139, width: 300, height: 28), size: 22, weight: .medium, color: Palette.goldSoft)
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
