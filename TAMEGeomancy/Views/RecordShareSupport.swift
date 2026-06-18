import SwiftUI
import UIKit
import Photos

struct RecordSharePayload: Identifiable {
    let id = UUID()
    let items: [Any]
}

struct ActivityShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

enum RecordPhotoSaveResult: Equatable {
    case success
    case failure(String)
}

final class RecordPhotoAlbumSaver: NSObject {
    private var completion: ((RecordPhotoSaveResult) -> Void)?

    func save(_ image: UIImage, completion: @escaping (RecordPhotoSaveResult) -> Void) {
        self.completion = completion

        PHPhotoLibrary.requestAuthorization(for: .addOnly) { [weak self] status in
            DispatchQueue.main.async {
                guard let self else { return }

                switch status {
                case .authorized, .limited:
                    UIImageWriteToSavedPhotosAlbum(
                        image,
                        self,
                        #selector(self.image(_:didFinishSavingWithError:contextInfo:)),
                        nil
                    )
                case .denied, .restricted:
                    completion(.failure(TAMEL10n.text("请在系统设置中允许“添加到照片”，才能直接保存报告图片。", "Allow Add to Photos in Settings to save the report image directly.")))
                    self.completion = nil
                case .notDetermined:
                    completion(.failure(TAMEL10n.text("系统尚未完成相册权限确认，请重试一次。", "The Photos permission flow is not finished yet. Please try again.")))
                    self.completion = nil
                @unknown default:
                    completion(.failure(TAMEL10n.text("无法确认相册权限状态，请稍后重试。", "Unable to confirm Photos permission status. Please try again.")))
                    self.completion = nil
                }
            }
        }
    }

    @objc
    private func image(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeMutableRawPointer?
    ) {
        if let error {
            completion?(.failure(error.localizedDescription))
        } else {
            completion?(.success)
        }
        completion = nil
    }
}

struct RecordShareCard: View {
    let record: AnalysisRecord
    let notes: String

    private var normalizedNotes: String {
        notes.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private let cardBackground = Color.white
    private let panelBackground = Color(red: 249 / 255, green: 247 / 255, blue: 242 / 255)
    private let panelStroke = Color(red: 14 / 255, green: 22 / 255, blue: 33 / 255).opacity(0.08)
    private let mutedText = Color(red: 14 / 255, green: 22 / 255, blue: 33 / 255).opacity(0.62)
    private let pillBackground = Color(red: 184 / 255, green: 154 / 255, blue: 99 / 255).opacity(0.14)
    private let accent = Color(red: 184 / 255, green: 154 / 255, blue: 99 / 255)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        TAMEBrandLockup(
                            wordmarkColor: .black,
                            primaryColor: .black,
                            secondaryColor: mutedText,
                            wordmarkHeight: 24,
                            spacing: 6
                        )
                        Text(TAMEL10n.text("分析记录导出", "Analysis Record Export"))
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(mutedText)
                    }

                    Spacer()

                    Text(record.category.localizedTitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(pillBackground)
                        .foregroundColor(accent)
                        .cornerRadius(999)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(record.title)
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                    Text(record.subtitle)
                        .font(.system(size: 14.5, weight: .regular, design: .rounded))
                        .foregroundColor(mutedText)
                    Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(mutedText.opacity(0.88))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            divider

            sectionPanel(title: TAMEL10n.text("分析内容", "Analysis Details")) {
                ForEach(record.details, id: \.self) { detail in
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(accent)
                            .frame(width: 6, height: 6)
                            .padding(.top, 6)

                        Text(detail)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(TAMETheme.brandTextPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if !normalizedNotes.isEmpty {
                sectionPanel(title: TAMEL10n.text("备注", "Notes")) {
                    Text(normalizedNotes)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            divider

            Text(TAMEL10n.text("本 APP 内容仅为民俗文化参考，非科学依据，不构成任何现实承诺。", "This app is for cultural reference only. It is not scientific guidance or a real-world guarantee."))
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white,
                            Color(red: 248 / 255, green: 246 / 255, blue: 240 / 255)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(panelStroke, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 18, y: 10)
    }

    private var divider: some View {
        Rectangle()
            .fill(panelStroke)
            .frame(height: 1)
    }

    private func sectionPanel<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 17, weight: .medium, design: .rounded))
                .foregroundColor(TAMETheme.brandTextPrimary)

            content()
        }
        .padding(16)
        .background(panelBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(panelStroke, lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

enum RecordReportComposer {
    static func makeShareItems(for record: AnalysisRecord, notes: String) -> [Any] {
        let summary = shareText(for: record, notes: notes)

        if let image = makeImage(for: record, notes: notes) {
            return [image, summary]
        }

        return [summary]
    }

    static func shareText(for record: AnalysisRecord, notes: String) -> String {
        let detailLines = record.details.map { "• \($0)" }.joined(separator: "\n")
        let normalizedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesBlock = normalizedNotes.isEmpty
        ? ""
        : "\n\(TAMEL10n.text("备注：", "Notes:"))\n\(normalizedNotes)\n"

        if TAMEL10n.isEnglish {
            return """
            TAME Space Compass · \(record.category.localizedTitle)
            Title: \(record.title)
            Summary: \(record.subtitle)
            Time: \(record.createdAt.formatted(date: .abbreviated, time: .shortened))

            Analysis Details:
            \(detailLines)\(notesBlock)
            This app is for cultural reference only and is not scientific guidance.
            """
        }

        return """
        TAME Space Compass · 探觅·空间罗盘 · \(record.category.localizedTitle)
        标题：\(record.title)
        摘要：\(record.subtitle)
        时间：\(record.createdAt.formatted(date: .abbreviated, time: .shortened))

        分析内容：
        \(detailLines)\(notesBlock)
        本 APP 内容仅为民俗文化参考，非科学依据。
        """
    }

    static func makeImage(for record: AnalysisRecord, notes: String) -> UIImage? {
        let width: CGFloat = 1080
        let outerPadding: CGFloat = 60
        let headerHeight: CGFloat = 180
        let cardPadding: CGFloat = 48
        let cardWidth = width - outerPadding * 2
        let contentWidth = cardWidth - cardPadding * 2
        let categoryPillHeight: CGFloat = 54
        let sectionInset: CGFloat = 20
        let sectionGap: CGFloat = 16
        let sectionInnerWidth = contentWidth - sectionInset * 2
        let accentColor = UIColor(red: 184 / 255, green: 154 / 255, blue: 99 / 255, alpha: 1)
        let textPrimary = UIColor(red: 14 / 255, green: 22 / 255, blue: 33 / 255, alpha: 0.96)
        let textSecondary = UIColor(red: 14 / 255, green: 22 / 255, blue: 33 / 255, alpha: 0.66)
        let cardColor = UIColor.white
        let panelColor = UIColor(red: 249 / 255, green: 247 / 255, blue: 242 / 255, alpha: 1)
        let panelStroke = UIColor(red: 14 / 255, green: 22 / 255, blue: 33 / 255, alpha: 0.08)

        let titleStyle = textStyle(font: .systemFont(ofSize: 42, weight: .medium), color: textPrimary, lineSpacing: 6)
        let subtitleStyle = textStyle(font: .systemFont(ofSize: 24, weight: .regular), color: textSecondary, lineSpacing: 4)
        let dateStyle = textStyle(font: .systemFont(ofSize: 20, weight: .regular), color: UIColor(red: 14 / 255, green: 22 / 255, blue: 33 / 255, alpha: 0.52), lineSpacing: 3)
        let sectionStyle = textStyle(font: .systemFont(ofSize: 26, weight: .medium), color: textPrimary, lineSpacing: 4)
        let bodyStyle = textStyle(font: .systemFont(ofSize: 22, weight: .regular), color: textPrimary, lineSpacing: 8)
        let noteStyle = textStyle(font: .systemFont(ofSize: 22, weight: .regular), color: textPrimary, lineSpacing: 8)
        let disclaimerStyle = textStyle(font: .systemFont(ofSize: 18, weight: .regular), color: UIColor(red: 14 / 255, green: 22 / 255, blue: 33 / 255, alpha: 0.54), lineSpacing: 6)
        let metadataStyle = textStyle(font: .systemFont(ofSize: 20, weight: .regular), color: textPrimary, lineSpacing: 6)

        let title = attributed(record.title, style: titleStyle)
        let subtitle = attributed(record.subtitle, style: subtitleStyle)
        let date = attributed(record.createdAt.formatted(date: .abbreviated, time: .shortened), style: dateStyle)
        let details = attributed(record.details.map { "• \($0)" }.joined(separator: "\n"), style: bodyStyle)
        let metadataLines = exportMetadataLines(for: record)
        let metadataText = metadataLines.isEmpty ? nil : attributed(metadataLines.joined(separator: "\n"), style: metadataStyle)
        let normalizedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesBlock = normalizedNotes.isEmpty ? nil : attributed(normalizedNotes, style: noteStyle)
        let disclaimer = attributed(
            TAMEL10n.text(
                "本 APP 内容仅为民俗文化参考，非科学依据，不构成任何现实承诺。",
                "This app is for cultural reference only. It is not scientific guidance or a real-world guarantee."
            ),
            style: disclaimerStyle
        )

        let titleHeight = measure(title, width: contentWidth)
        let subtitleHeight = measure(subtitle, width: contentWidth)
        let dateHeight = measure(date, width: contentWidth)
        let sectionHeight = measure(
            attributed(TAMEL10n.text("分析内容", "Analysis Details"), style: sectionStyle),
            width: sectionInnerWidth
        )
        let detailsHeight = measure(details, width: sectionInnerWidth - 18)
        let metadataHeaderHeight = metadataText == nil
        ? 0
        : measure(attributed(TAMEL10n.text("规则摘要", "Reference Basis"), style: sectionStyle), width: sectionInnerWidth)
        let metadataHeight = metadataText.map { measure($0, width: sectionInnerWidth) } ?? 0
        let notesHeaderHeight = notesBlock == nil
        ? 0
        : measure(attributed(TAMEL10n.text("备注", "Notes"), style: sectionStyle), width: sectionInnerWidth)
        let notesHeight = notesBlock.map { measure($0, width: sectionInnerWidth) } ?? 0
        let disclaimerHeight = measure(disclaimer, width: contentWidth)
        let detailsPanelHeight = sectionInset * 2 + sectionHeight + 12 + detailsHeight
        let metadataPanelHeight = metadataText == nil ? 0 : sectionInset * 2 + metadataHeaderHeight + 12 + metadataHeight
        let notesPanelHeight = notesBlock == nil ? 0 : sectionInset * 2 + notesHeaderHeight + 12 + notesHeight

        var cardHeight = cardPadding
        cardHeight += categoryPillHeight + 24
        cardHeight += titleHeight + 12 + subtitleHeight + 12 + dateHeight
        cardHeight += 24 + 1 + 24
        if metadataText != nil {
            cardHeight += metadataPanelHeight
            cardHeight += sectionGap
        }
        cardHeight += detailsPanelHeight

        if notesBlock != nil {
            cardHeight += sectionGap
            cardHeight += notesPanelHeight
        }

        cardHeight += 28 + 1 + 24
        cardHeight += disclaimerHeight + cardPadding

        let cardOriginY = headerHeight - 36
        let canvasHeight = cardOriginY + cardHeight + 60

        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        format.scale = max(UITraitCollection.current.displayScale, 1)

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: width, height: canvasHeight),
            format: format
        )

        return renderer.image { rendererContext in
            let context = rendererContext.cgContext
            let canvasRect = CGRect(origin: .zero, size: CGSize(width: width, height: canvasHeight))
            let backgroundGradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(red: 245 / 255, green: 245 / 255, blue: 242 / 255, alpha: 1).cgColor,
                    UIColor.white.cgColor,
                    UIColor(red: 248 / 255, green: 246 / 255, blue: 240 / 255, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 0.55, 1]
            )
            if let backgroundGradient {
                context.drawLinearGradient(
                    backgroundGradient,
                    start: CGPoint(x: 0, y: 0),
                    end: CGPoint(x: width, y: canvasHeight),
                    options: []
                )
            } else {
                UIColor(red: 245 / 255, green: 245 / 255, blue: 242 / 255, alpha: 1).setFill()
                context.fill(canvasRect)
            }

            context.saveGState()
            context.setFillColor(accentColor.withAlphaComponent(0.05).cgColor)
            for index in 0..<7 {
                let size = CGFloat(120 + index * 26)
                let rect = CGRect(x: CGFloat(index) * 124 - 40, y: 34 + CGFloat(index % 2) * 18, width: size, height: size)
                context.fillEllipse(in: rect)
            }
            context.restoreGState()

            let brandAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: accentColor
            ]
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 40, weight: .medium),
                .foregroundColor: textPrimary
            ]
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .regular),
                .foregroundColor: textSecondary
            ]

            ("01" as NSString).draw(
                at: CGPoint(x: outerPadding, y: 42),
                withAttributes: brandAttributes
            )
            context.saveGState()
            context.setStrokeColor(accentColor.withAlphaComponent(0.35).cgColor)
            context.setLineWidth(1)
            context.move(to: CGPoint(x: outerPadding + 40, y: 56))
            context.addLine(to: CGPoint(x: outerPadding + 92, y: 56))
            context.strokePath()
            context.restoreGState()

            (TAMEL10n.text("空间参考报告", "Spatial Reference Report") as NSString).draw(
                at: CGPoint(x: outerPadding, y: 86),
                withAttributes: titleAttributes
            )
            (TAMEL10n.text("TAME Space Compass · 探觅·空间罗盘", "TAME Space Compass · Spatial Reference") as NSString).draw(
                at: CGPoint(x: outerPadding, y: 138),
                withAttributes: subtitleAttributes
            )

            let cardRect = CGRect(x: outerPadding, y: cardOriginY, width: cardWidth, height: cardHeight)
            let shadowPath = UIBezierPath(roundedRect: cardRect, cornerRadius: 34)
            context.saveGState()
            context.setShadow(offset: CGSize(width: 0, height: 22), blur: 40, color: UIColor.black.withAlphaComponent(0.10).cgColor)
            cardColor.setFill()
            shadowPath.fill()
            context.restoreGState()

            cardColor.setFill()
            shadowPath.fill()
            context.setStrokeColor(panelStroke.cgColor)
            context.setLineWidth(1)
            context.addPath(shadowPath.cgPath)
            context.strokePath()

            var y = cardRect.minY + cardPadding
            let pillText = record.category.localizedTitle
            let pillAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .medium),
                .foregroundColor: accentColor
            ]
            let pillWidth = (pillText as NSString).size(withAttributes: pillAttributes).width + 32
            let pillRect = CGRect(x: cardRect.minX + cardPadding, y: y, width: pillWidth, height: categoryPillHeight)
            let pillPath = UIBezierPath(roundedRect: pillRect, cornerRadius: categoryPillHeight / 2)
            accentColor.withAlphaComponent(0.18).setFill()
            pillPath.fill()
            (pillText as NSString).draw(
                in: pillRect.insetBy(dx: 16, dy: 12),
                withAttributes: pillAttributes
            )
            y += categoryPillHeight + 24

            title.draw(in: CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: titleHeight))
            y += titleHeight + 12

            subtitle.draw(in: CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: subtitleHeight))
            y += subtitleHeight + 12

            date.draw(in: CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: dateHeight))
            y += dateHeight + 24

            drawDivider(
                in: context,
                from: CGPoint(x: cardRect.minX + cardPadding, y: y),
                width: contentWidth
            )
            y += 24

            if let metadataText {
                let metadataPanelRect = CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: metadataPanelHeight)
                drawPanel(
                    in: context,
                    rect: metadataPanelRect,
                    fillColor: panelColor,
                    strokeColor: panelStroke
                )
                let metadataHeader = attributed(
                    TAMEL10n.text("规则摘要", "Reference Basis"),
                    style: sectionStyle
                )
                metadataHeader.draw(in: CGRect(x: metadataPanelRect.minX + sectionInset, y: metadataPanelRect.minY + sectionInset, width: sectionInnerWidth, height: metadataHeaderHeight))
                metadataText.draw(in: CGRect(
                    x: metadataPanelRect.minX + sectionInset,
                    y: metadataPanelRect.minY + sectionInset + metadataHeaderHeight + 12,
                    width: sectionInnerWidth,
                    height: metadataHeight
                ))
                y += metadataPanelHeight + sectionGap
            }

            let detailsPanelRect = CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: detailsPanelHeight)
            drawPanel(
                in: context,
                rect: detailsPanelRect,
                fillColor: panelColor,
                strokeColor: panelStroke
            )
            let detailsHeader = attributed(
                TAMEL10n.text("分析内容", "Analysis Details"),
                style: sectionStyle
            )
            detailsHeader.draw(in: CGRect(x: detailsPanelRect.minX + sectionInset, y: detailsPanelRect.minY + sectionInset, width: sectionInnerWidth, height: sectionHeight))
            drawBulletText(
                details.string.components(separatedBy: "\n"),
                in: context,
                rect: CGRect(
                    x: detailsPanelRect.minX + sectionInset,
                    y: detailsPanelRect.minY + sectionInset + sectionHeight + 12,
                    width: sectionInnerWidth,
                    height: detailsHeight
                ),
                style: bodyStyle,
                accentColor: accentColor
            )
            y += detailsPanelHeight

            if let notesBlock {
                y += sectionGap
                let notesPanelRect = CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: notesPanelHeight)
                drawPanel(
                    in: context,
                    rect: notesPanelRect,
                    fillColor: panelColor,
                    strokeColor: panelStroke
                )
                let notesHeader = attributed(
                    TAMEL10n.text("备注", "Notes"),
                    style: sectionStyle
                )
                notesHeader.draw(in: CGRect(x: notesPanelRect.minX + sectionInset, y: notesPanelRect.minY + sectionInset, width: sectionInnerWidth, height: notesHeaderHeight))
                notesBlock.draw(in: CGRect(
                    x: notesPanelRect.minX + sectionInset,
                    y: notesPanelRect.minY + sectionInset + notesHeaderHeight + 12,
                    width: sectionInnerWidth,
                    height: notesHeight
                ))
                y += notesPanelHeight
            }

            y += 28
            drawDivider(
                in: context,
                from: CGPoint(x: cardRect.minX + cardPadding, y: y),
                width: contentWidth
            )
            y += 24

            disclaimer.draw(in: CGRect(x: cardRect.minX + cardPadding, y: y, width: contentWidth, height: disclaimerHeight))
        }
    }

    private static func textStyle(
        font: UIFont,
        color: UIColor,
        lineSpacing: CGFloat
    ) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = lineSpacing

        return [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph
        ]
    }

    private static func attributed(
        _ string: String,
        style: [NSAttributedString.Key: Any]
    ) -> NSAttributedString {
        NSAttributedString(string: string, attributes: style)
    }

    private static func measure(_ text: NSAttributedString, width: CGFloat) -> CGFloat {
        text.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).integral.height
    }

    private static func drawPanel(
        in context: CGContext,
        rect: CGRect,
        fillColor: UIColor,
        strokeColor: UIColor
    ) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 24)
        context.saveGState()
        fillColor.setFill()
        path.fill()
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(1)
        context.addPath(path.cgPath)
        context.strokePath()
        context.restoreGState()
    }

    private static func drawBulletText(
        _ lines: [String],
        in context: CGContext,
        rect: CGRect,
        style: [NSAttributedString.Key: Any],
        accentColor: UIColor
    ) {
        let paragraph = (style[.paragraphStyle] as? NSParagraphStyle)?.lineSpacing ?? 8
        let font = (style[.font] as? UIFont) ?? .systemFont(ofSize: 22)
        let lineHeight = font.lineHeight + paragraph
        let bulletSize: CGFloat = 7
        let bulletOffsetY: CGFloat = 9
        let textX = rect.minX + 18

        for (index, line) in lines.enumerated() {
            let y = rect.minY + CGFloat(index) * lineHeight
            let bulletRect = CGRect(x: rect.minX, y: y + bulletOffsetY, width: bulletSize, height: bulletSize)
            context.setFillColor(accentColor.cgColor)
            context.fillEllipse(in: bulletRect)

            let raw = line.hasPrefix("• ") ? String(line.dropFirst(2)) : line
            attributed(raw, style: style).draw(
                in: CGRect(x: textX, y: y, width: rect.width - 18, height: lineHeight + 8)
            )
        }
    }

    private static func drawDivider(
        in context: CGContext,
        from point: CGPoint,
        width: CGFloat
    ) {
        context.saveGState()
        context.setStrokeColor(UIColor(red: 14 / 255, green: 22 / 255, blue: 33 / 255, alpha: 0.08).cgColor)
        context.setLineWidth(1)
        context.move(to: point)
        context.addLine(to: CGPoint(x: point.x + width, y: point.y))
        context.strokePath()
        context.restoreGState()
    }

    private static func exportMetadataLines(for record: AnalysisRecord) -> [String] {
        let prefixes = [
            TAMEL10n.text("当前元运：", "Current period:"),
            TAMEL10n.text("元运：", "Period:"),
            TAMEL10n.text("纳气分区：", "Naqi zoning:"),
            TAMEL10n.text("向盘依据：", "Facing basis:")
        ]

        return record.details.filter { detail in
            prefixes.contains { detail.hasPrefix($0) }
        }
    }
}
