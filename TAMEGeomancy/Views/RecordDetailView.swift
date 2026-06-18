import SwiftUI

struct RecordDetailView: View {
    let recordID: UUID
    @EnvironmentObject private var premiumAccessStore: PremiumAccessStore
    @StateObject private var historyStore = HistoryStore.shared
    @State private var notesDraft: String = ""
    @State private var sharePayload: RecordSharePayload?
    @State private var saveStatusMessage: String?
    @State private var saveErrorMessage: String?
    @State private var isSavingToPhotos = false
    @State private var albumSaver = RecordPhotoAlbumSaver()
    @State private var showPremiumSheet = false

    private var record: AnalysisRecord? {
        historyStore.record(for: recordID)
    }

    var body: some View {
        ScrollView {
            if let record {
                VStack(alignment: .leading, spacing: 20) {
                    if let saveStatusMessage {
                        TAMEStatusBanner(message: saveStatusMessage)
                    }

                    headerCard(record)
                    detailCard(record)
                    notesCard(record)
                    shareCard(record)
                }
                .padding()
                .onAppear {
                    notesDraft = record.notes
                }
            } else {
                Text(TAMEL10n.text("记录不存在", "Record Not Found"))
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .padding()
            }
        }
        .tameBrandPageBackground()
        .navigationTitle(TAMEL10n.text("记录详情", "Record Details"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if let record {
                    Button(action: { prepareShare(record) }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .accessibilityLabel(TAMEL10n.text("分享记录", "Share Record"))
                }
            }
        }
        .sheet(item: $sharePayload) { payload in
            ActivityShareSheet(activityItems: payload.items)
        }
        .sheet(isPresented: $showPremiumSheet) {
            NavigationView {
                PremiumUnlockView()
            }
        }
        .alert(TAMEL10n.text("保存失败", "Save Failed"), isPresented: Binding(
            get: { saveErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    saveErrorMessage = nil
                }
            }
        )) {
            Button(TAMEL10n.text("知道了", "OK"), role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            Text(saveErrorMessage ?? TAMEL10n.text("发生未知错误", "An unknown error occurred."))
        }
    }

    private func headerCard(_ record: AnalysisRecord) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("记录摘要", "Record Summary"), accent: "01")

            HStack(alignment: .top, spacing: 14) {
                TAMEDashboardBadge(style: record.category.badgeStyle, size: 58)

                VStack(alignment: .leading, spacing: 10) {
                    Text(record.category.localizedTitle)
                        .font(.caption.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    Text(record.title)
                        .font(.system(size: 26, weight: .medium, design: .rounded))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(record.subtitle)
                        .font(.callout)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundColor(TAMETheme.brandTextMuted)
                }
            }

            LazyVGrid(columns: detailColumns, spacing: 10) {
                detailPill(
                    title: TAMEL10n.text("记录分类", "Category"),
                    value: record.category.localizedTitle,
                    tint: TAMETheme.stardustGold
                )
                detailPill(
                    title: TAMEL10n.text("时间状态", "Timeline"),
                    value: TAMEL10n.text("已归档", "Archived"),
                    tint: TAMETheme.techGray
                )
                detailPill(
                    title: TAMEL10n.text("报告权限", "Report Access"),
                    value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已解锁", "Unlocked") : TAMEL10n.text("需高级解锁", "Locked"),
                    tint: premiumAccessStore.hasPremiumAccess ? TAMETheme.stardustGold : TAMETheme.techGray
                )
            }

            VStack(spacing: 10) {
                metricLine(index: "01.1", title: TAMEL10n.text("分析条目", "Detail Rows"), value: "\(record.details.count)")
                metricLine(index: "01.2", title: TAMEL10n.text("备注状态", "Notes Status"), value: record.notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? TAMEL10n.text("未填写", "Empty") : TAMEL10n.text("已填写", "Saved"))
                metricLine(index: "01.3", title: TAMEL10n.text("导出准备", "Export Ready"), value: TAMEL10n.text("可分享 / 可存图", "Share / Save"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 24)
    }

    private func detailCard(_ record: AnalysisRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("分析内容", "Analysis Details"), accent: "02")

            ForEach(Array(record.details.enumerated()), id: \.offset) { index, detail in
                HStack(alignment: .top, spacing: 12) {
                    Text(String(format: "02.%d", index + 1))
                        .font(.caption2.weight(.medium))
                        .foregroundColor(TAMETheme.stardustGold)
                        .frame(width: 38, alignment: .leading)

                    Text(detail)
                        .font(.footnote)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, emphasized: true, shadow: true)
    }

    private func notesCard(_ record: AnalysisRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeading(title: TAMEL10n.text("备注", "Notes"), accent: "03")

            Text(TAMEL10n.text("可记录小区名、房号、现场观察、复测原因或方案比对结论，方便后续回看。", "Use notes for residence name, unit number, field observations, retest reasons, or comparison conclusions."))
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)

            VStack(alignment: .leading, spacing: 10) {
                TextEditor(text: $notesDraft)
                    .frame(minHeight: 140)
                    .padding(8)
                    .background(TAMETheme.fieldBackground)
                    .cornerRadius(16)

                if notesDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text(TAMEL10n.text("例如：南向采光较好，主阳台作为主要纳气口，建议再复测一次大门。", "For example: south-facing daylight looks strong, the main balcony is treated as the primary opening, and the main door is worth retesting."))
                        .font(.footnote)
                        .foregroundColor(TAMETheme.brandTextMuted)
                }
            }

            quickNoteSection

            Button(TAMEL10n.text("保存备注", "Save Notes")) {
                let normalized = notesDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                historyStore.updateNotes(for: record.id, notes: normalized)
                notesDraft = normalized
                saveStatusMessage = TAMEL10n.text("备注已保存。", "Notes saved.")
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(TAMESecondaryActionButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func shareCard(_ record: AnalysisRecord) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeading(title: TAMEL10n.text("报告导出", "Report Export"), accent: "04")

            HStack(spacing: 12) {
                exportActionCard(
                    title: isSavingToPhotos ? TAMEL10n.text("保存中…", "Saving...") : TAMEL10n.text("保存到相册", "Save to Photos"),
                    subtitle: premiumAccessStore.hasPremiumAccess
                    ? TAMEL10n.text("生成报告图片并写入系统相册", "Generate a report image and write it to Photos.")
                    : TAMEL10n.text("高级解锁可用，支持保存品牌化报告图片", "Available with premium access and saves the branded report image."),
                    symbol: "photo.on.rectangle.angled"
                ) {
                    saveToPhotos(record)
                }
                .disabled(isSavingToPhotos)

                exportActionCard(
                    title: TAMEL10n.text("分享报告", "Share Report"),
                    subtitle: premiumAccessStore.hasPremiumAccess
                    ? TAMEL10n.text("调起系统分享面板发送图文", "Open the system share sheet for image and text export.")
                    : TAMEL10n.text("高级解锁可用，支持导出完整图文报告", "Available with premium access and exports the full report."),
                    symbol: "square.and.arrow.up"
                ) {
                    prepareShare(record)
                }
            }

            Text(
                premiumAccessStore.hasPremiumAccess
                ? TAMEL10n.text("会生成一张 TAME Space Compass 风格的报告图片，可通过系统分享并保存到相册。", "Generates a TAME Space Compass report image that can be shared through the system sheet or saved to Photos.")
                : TAMEL10n.text("报告分享与保存到相册已归入高级解锁，用来承接更完整的专业输出能力。", "Report sharing and save-to-Photos are part of Premium Access and support the app's richer professional output.")
            )
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)

            if let saveStatusMessage {
                Text(saveStatusMessage)
                    .font(.footnote)
                    .foregroundColor(TAMETheme.brandTextSecondary)
            }

            VStack(spacing: 10) {
                metricLine(index: "04.1", title: TAMEL10n.text("分享权限", "Share Access"), value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("已开启", "Enabled") : TAMEL10n.text("需高级解锁", "Locked"))
                metricLine(index: "04.2", title: TAMEL10n.text("图片输出", "Image Output"), value: premiumAccessStore.hasPremiumAccess ? TAMEL10n.text("保存到相册", "Save to Photos") : TAMEL10n.text("解锁后可用", "Available after unlock"))
                metricLine(index: "04.3", title: TAMEL10n.text("备注同步", "Notes Sync"), value: notesDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? TAMEL10n.text("无备注", "No Notes") : TAMEL10n.text("将随报告导出", "Included in Export"))
            }

            if !premiumAccessStore.hasPremiumAccess {
                PremiumAccessInlineCard(
                    title: TAMEL10n.text("解锁报告能力", "Unlock Report Tools"),
                    summary: TAMEL10n.text("解锁后可分享完整图文报告，并把报告图片直接保存到相册。", "Unlock to share the full report and save branded report images directly to Photos."),
                    actionTitle: TAMEL10n.text("查看高级解锁", "Open Premium Access")
                )
            }

            RecordShareCard(record: record, notes: notesDraft)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .tameBrandPanel(cornerRadius: 24, shadow: true)
    }

    private func sectionHeading(title: String, accent: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(accent)
                .font(.caption2.weight(.medium))
                .foregroundColor(TAMETheme.stardustGold)

            HStack(spacing: 12) {
                Text(title)
                    .font(.title3.weight(.medium))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Rectangle()
                    .fill(TAMETheme.stardustGold.opacity(0.14))
                    .frame(height: 1)
            }
        }
    }

    private func prepareShare(_ record: AnalysisRecord) {
        guard premiumAccessStore.hasPremiumAccess else {
            saveStatusMessage = nil
            saveErrorMessage = TAMEL10n.text("报告分享属于高级解锁能力。解锁后可导出完整图文报告。", "Report sharing is part of Premium Access. Unlock to export the full report.")
            showPremiumSheet = true
            return
        }

        let normalizedNotes = notesDraft.trimmingCharacters(in: .whitespacesAndNewlines)

        if normalizedNotes != record.notes {
            historyStore.updateNotes(for: record.id, notes: normalizedNotes)
            notesDraft = normalizedNotes
        }

        saveStatusMessage = nil

        sharePayload = RecordSharePayload(
            items: RecordReportComposer.makeShareItems(for: record, notes: normalizedNotes)
        )
    }

    private func saveToPhotos(_ record: AnalysisRecord) {
        guard premiumAccessStore.hasPremiumAccess else {
            saveStatusMessage = nil
            saveErrorMessage = TAMEL10n.text("保存到相册属于高级解锁能力。解锁后可直接保存品牌化报告图片。", "Save to Photos is part of Premium Access. Unlock to save branded report images directly.")
            showPremiumSheet = true
            return
        }

        let normalizedNotes = notesDraft.trimmingCharacters(in: .whitespacesAndNewlines)

        if normalizedNotes != record.notes {
            historyStore.updateNotes(for: record.id, notes: normalizedNotes)
            notesDraft = normalizedNotes
        }

        guard let image = RecordReportComposer.makeImage(for: record, notes: normalizedNotes) else {
            saveErrorMessage = TAMEL10n.text("报告图片生成失败，请稍后重试。", "Unable to create the report image. Please try again.")
            return
        }

        isSavingToPhotos = true
        saveStatusMessage = nil
        saveErrorMessage = nil

        albumSaver.save(image) { result in
            isSavingToPhotos = false
            switch result {
            case .success:
                saveStatusMessage = TAMEL10n.text("报告图片已保存到系统相册。", "The report image was saved to Photos.")
            case .failure(let message):
                saveErrorMessage = message
            }
        }
    }

    private var quickNoteSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(TAMEL10n.text("快捷短语", "Quick Notes"))
                .font(.caption.weight(.medium))
                .foregroundColor(TAMETheme.brandTextSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickNotePhrases, id: \.self) { phrase in
                        Button(action: { appendNotePhrase(phrase) }) {
                            Text(phrase)
                                .font(.caption.weight(.medium))
                                .foregroundColor(TAMETheme.brandTextPrimary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(TAMETheme.fieldBackground)
                                .overlay {
                                    Capsule()
                                        .stroke(TAMETheme.brandHairline, lineWidth: 1)
                                }
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var quickNotePhrases: [String] {
        [
            TAMEL10n.text("现场复测", "Retest on Site"),
            TAMEL10n.text("主大门纳气", "Main Door Opening"),
            TAMEL10n.text("主阳台纳气", "Balcony Opening"),
            TAMEL10n.text("仅供方案比对", "For Plan Comparison"),
            TAMEL10n.text("建议结合采光通风", "Review with Daylight & Airflow")
        ]
    }

    private func appendNotePhrase(_ phrase: String) {
        let trimmed = notesDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            notesDraft = phrase
        } else if !trimmed.contains(phrase) {
            notesDraft = "\(trimmed)\n\(phrase)"
        }
    }

    private func metricLine(index: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Text(index)
                .font(.caption2.weight(.medium))
                .foregroundColor(TAMETheme.stardustGold)
                .frame(width: 34, alignment: .leading)

            Text(title)
                .font(.callout)
                .foregroundColor(TAMETheme.brandTextSecondary)

            Rectangle()
                .fill(TAMETheme.stardustGold.opacity(0.16))
                .frame(height: 1)

            Text(value)
                .font(.callout.weight(.medium))
                .foregroundColor(TAMETheme.brandTextPrimary)
        }
    }

    private func detailPill(title: String, value: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.medium))
                .foregroundColor(TAMETheme.brandTextMuted)
            Text(value)
                .font(.callout.weight(.medium))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .lineLimit(2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(alignment: .bottomLeading) {
            Capsule()
                .fill(tint.opacity(0.18))
                .frame(width: 22, height: 4)
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
        }
        .tameInstrumentCard(cornerRadius: 14, shadow: false)
    }

    private var detailColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
    }

    private func exportActionCard(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: symbol)
                    .font(.callout.weight(.medium))
                    .foregroundColor(TAMETheme.stardustGold)

                Text(title)
                    .font(.headline.weight(.medium))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundColor(TAMETheme.brandTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
            .padding(16)
            .tameInstrumentCard(cornerRadius: 16, shadow: false)
        }
        .buttonStyle(.plain)
    }
}

struct RecordDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RecordDetailView(recordID: UUID())
        }
    }
}
