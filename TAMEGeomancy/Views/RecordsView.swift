import SwiftUI

struct RecordsView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var historyStore = HistoryStore.shared
    @State private var selectedCategory: AnalysisRecordCategory?
    @State private var searchText = ""
    @State private var showClearConfirmation = false
    @State private var navigationPath: [UUID] = []
    @State private var legacyPreviewRoute: RecordPreviewRoute?
    @State private var pendingInitialDestination: RecordsDeepLinkDestination?

    init(initialDestination: RecordsDeepLinkDestination? = nil) {
        _pendingInitialDestination = State(initialValue: initialDestination)
    }

    private var latestRecord: AnalysisRecord? {
        historyStore.records.first
    }

    private var activeCategoryTitle: String {
        selectedCategory?.localizedTitle ?? TAMEL10n.text("全部", "All")
    }

    private var filteredRecords: [AnalysisRecord] {
        historyStore.records.filter { record in
            let matchesCategory = selectedCategory == nil || record.category == selectedCategory
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            guard matchesCategory else { return false }
            guard !query.isEmpty else { return true }

            let haystack = [
                record.title,
                record.subtitle,
                record.notes,
                record.category.localizedTitle
            ] + record.category.searchKeywords + record.details

            return haystack.joined(separator: "\n").localizedCaseInsensitiveContains(query)
        }
    }

    var body: some View {
        Group {
            if #available(iOS 16.0, *) {
                NavigationStack(path: $navigationPath) {
                    recordsContent
                        .navigationDestination(for: UUID.self) { recordID in
                            RecordDetailView(recordID: recordID)
                        }
                }
            } else {
                NavigationView {
                    recordsContent
                        .sheet(item: $legacyPreviewRoute) { route in
                            NavigationView {
                                RecordDetailView(recordID: route.id)
                            }
                        }
                }
            }
        }
    }

    private var recordsContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                if historyStore.records.isEmpty {
                    emptyState
                } else if filteredRecords.isEmpty {
                    filteredEmptyState
                } else {
                    dashboardHeader
                    filterBar

                    VStack(spacing: 12) {
                        ForEach(Array(filteredRecords.enumerated()), id: \.element.id) { index, record in
                            recordLink(record, index: index + 1)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, TAMETheme.bottomContentInset)
        }
        .tameBrandPageBackground()
        .safeAreaInset(edge: .bottom) {
            Color.clear
                .frame(height: 24)
        }
        .navigationTitle(TAMEL10n.text("历史记录", "Records"))
        .searchable(text: $searchText, prompt: TAMEL10n.text("搜索标题、摘要、备注", "Search title, summary, notes"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(TAMEL10n.text("清空", "Clear")) {
                    showClearConfirmation = true
                }
                .font(.caption.weight(.medium))
                .disabled(historyStore.records.isEmpty)
                .opacity(historyStore.records.isEmpty ? 0.35 : 1)
            }
        }
        .confirmationDialog(
            TAMEL10n.text("确认清空全部历史记录？", "Clear all saved records?"),
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button(TAMEL10n.text("清空全部记录", "Delete All Records"), role: .destructive) {
                historyStore.clear()
            }
            Button(TAMEL10n.text("取消", "Cancel"), role: .cancel) {}
        } message: {
            Text(TAMEL10n.text("此操作会删除当前设备上的全部历史记录。若需要保留，请先到设置页导出本地备份。", "This deletes all records stored on this device. Export a local backup in Settings first if you want to keep them."))
        }
        .onReceive(NotificationCenter.default.publisher(for: .tameOpenRecordsDestination)) { output in
            guard let rawValue = output.object as? String,
                  let destination = RecordsDeepLinkDestination(rawValue: rawValue) else { return }
            handleRecordsDeepLink(destination)
        }
        .onAppear {
            guard let destination = pendingInitialDestination else { return }
            handleRecordsDeepLink(destination)
            pendingInitialDestination = nil
        }
    }

    private var dashboardHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("记录摘要", "Records Summary"), accent: "00")

            Text(TAMEL10n.text("这里汇总当前设备上的测量与分析记录，方便快速筛选、回看与导出。", "This area gathers saved measurements and analysis records on the current device so you can quickly filter, revisit, and export them."))
                .font(.system(size: 14.5, weight: .regular, design: .rounded))
                .foregroundColor(TAMETheme.brandTextSecondary)

            LazyVGrid(columns: dashboardColumns, spacing: 10) {
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("当前记录数", "Total Records"),
                    value: "\(historyStore.records.count)",
                    symbol: "tray.full.fill",
                    note: TAMEL10n.text("本地档案", "Local archive"),
                    tint: TAMETheme.stardustGold
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("当前筛选", "Active Filter"),
                    value: activeCategoryTitle,
                    symbol: "line.3.horizontal.decrease.circle",
                    note: TAMEL10n.text("当前视图", "Current view"),
                    tint: TAMETheme.techGray
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("最近更新", "Latest Update"),
                    value: latestRecord?.createdAt.formatted(date: .abbreviated, time: .shortened) ?? TAMEL10n.text("暂无", "None"),
                    symbol: "clock.arrow.circlepath",
                    note: TAMEL10n.text("最后修改", "Latest edit"),
                    tint: TAMETheme.stardustGold
                )
                TAMEGlyphMetricCard(
                    title: TAMEL10n.text("记录状态", "Record State"),
                    value: historyStore.records.isEmpty ? TAMEL10n.text("待建立", "Starting Fresh") : TAMEL10n.text("已归档", "Archived"),
                    symbol: historyStore.records.isEmpty ? "tray" : "bookmark.fill",
                    note: TAMEL10n.text("归档准备", "Archive status"),
                    tint: historyStore.records.isEmpty ? TAMETheme.techGray : TAMETheme.stardustGold
                )
            }

            HStack(spacing: 12) {
                dashboardShortcut(
                    title: TAMEL10n.text("飞星排盘", "Flying Star Chart"),
                    subtitle: TAMEL10n.text("前往保存一条新的分析记录", "Open the chart and save a new record"),
                    symbol: "sparkles",
                    action: openFlyingStarChart
                )

                dashboardShortcut(
                    title: TAMEL10n.text("八宅记录", "Eight-Mansion Records"),
                    subtitle: TAMEL10n.text("只看命宅相关", "Focus on house-person matching"),
                    symbol: "house.fill",
                    action: {
                        selectedCategory = .bazhai
                        searchText = ""
                    }
                )
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }

    @ViewBuilder
    private func recordLink(_ record: AnalysisRecord, index: Int) -> some View {
        if #available(iOS 16.0, *) {
            NavigationLink(value: record.id) {
                recordRow(record, index: index)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(destination: RecordDetailView(recordID: record.id)) {
                recordRow(record, index: index)
            }
            .buttonStyle(.plain)
        }
    }

    private func recordRow(_ record: AnalysisRecord, index: Int) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                TAMEDashboardBadge(style: record.category.badgeStyle, size: 48)

                Text(String(format: "%02d", index))
                    .font(.caption2.weight(.medium))
                    .foregroundColor(TAMETheme.stardustGold)

                Text(record.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(TAMETheme.brandTextMuted)
                    .lineLimit(2)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(record.category.localizedTitle)
                        .font(.caption.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextSecondary)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.16))
                        .frame(width: 20, height: 1)

                    Text(TAMEL10n.text("已保存", "Saved"))
                        .font(.caption2.weight(.medium))
                        .foregroundColor(TAMETheme.stardustGold)
                }

                Text(record.title)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(TAMETheme.brandTextPrimary)

                Text(record.subtitle)
                    .font(.callout)
                    .foregroundColor(TAMETheme.brandTextSecondary)

                ForEach(record.details.prefix(2), id: \.self) { detail in
                    Text(detail)
                        .font(.footnote)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .lineLimit(2)
                }

                if !record.notes.isEmpty {
                    Text(TAMEL10n.text("备注：\(record.notes)", "Notes: \(record.notes)"))
                        .font(.footnote)
                        .foregroundColor(TAMETheme.brandTextPrimary)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "arrow.right")
                .font(.caption.weight(.medium))
                .foregroundColor(TAMETheme.brandTextPrimary)
                .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .tameInstrumentCard(cornerRadius: 16, shadow: false)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                sectionHeading(title: TAMEL10n.text("记录筛选", "Filter Records"), accent: "01")

                HStack(spacing: 10) {
                    filterChip(title: TAMEL10n.text("全部", "All"), isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }

                    ForEach(AnalysisRecordCategory.allCases, id: \.self) { category in
                        filterChip(title: category.localizedTitle, isSelected: selectedCategory == category) {
                            selectedCategory = category
                        }
                    }
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(isSelected ? TAMETheme.deepBlueBlack : TAMETheme.brandTextPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isSelected ? TAMETheme.stardustGold.opacity(0.12) : TAMETheme.fieldBackground)
                .overlay {
                    Capsule()
                        .stroke(isSelected ? TAMETheme.stardustGold.opacity(0.22) : TAMETheme.brandHairline, lineWidth: 1)
                }
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }

    private func dashboardShortcut(title: String, subtitle: String, symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Label {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.headline.weight(.medium))
                            .foregroundColor(TAMETheme.brandTextPrimary)

                        Text(subtitle)
                            .font(.footnote)
                            .foregroundColor(TAMETheme.brandTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(TAMEL10n.text("立即打开", "Open Now"))
                            .font(.caption.weight(.medium))
                            .foregroundColor(TAMETheme.stardustGold)
                    }
                } icon: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(TAMETheme.stardustGold.opacity(0.10))

                        Image(systemName: symbol)
                            .font(.callout.weight(.medium))
                            .foregroundColor(TAMETheme.stardustGold)
                    }
                    .frame(width: 34, height: 34)
                }
                .labelStyle(.titleAndIcon)

                Spacer(minLength: 0)

                Image(systemName: "arrow.right")
                    .font(.caption.weight(.medium))
                    .foregroundColor(TAMETheme.brandTextPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .tameInstrumentCard(cornerRadius: 16, shadow: false)
        }
        .buttonStyle(.plain)
    }

    private var dashboardColumns: [GridItem] {
        if horizontalSizeClass == .compact {
            return [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]
        }

        return Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionHeading(title: TAMEL10n.text("暂无记录", "No Records Yet"), accent: "01")

            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "tray")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundColor(TAMETheme.stardustGold)

                VStack(alignment: .leading, spacing: 8) {
                    Text(TAMEL10n.text("还没有保存的分析记录", "No Saved Records Yet"))
                        .font(.title3.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Text(TAMEL10n.text("在纳气、飞星或三元九运页面点击“保存记录”后，会出现在这里。", "Saved results from Naqi, Flying Star, or Period pages will appear here."))
                        .font(.callout)
                        .foregroundColor(TAMETheme.brandTextSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Button(action: openFlyingStarChart) {
                HStack(spacing: 10) {
                    Text("01")
                        .font(.caption2.weight(.medium))
                        .foregroundColor(TAMETheme.stardustGold)

                    Rectangle()
                        .fill(TAMETheme.stardustGold.opacity(0.24))
                        .frame(width: 18, height: 1)

                    Text(TAMEL10n.text("前往飞星排盘", "Open Flying Star Chart"))
                        .font(.callout.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextPrimary)

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.caption.weight(.medium))
                        .foregroundColor(TAMETheme.brandTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .tameInstrumentCard(cornerRadius: 16, shadow: false)
            }
            .buttonStyle(.plain)

            Text(TAMEL10n.text("先在罗盘、纳气、飞星、流年或户型页面保存一次分析结果，之后就可以在这里继续查看、备注、分享与保存图片。", "Save one result from the compass, openings, Flying Star, annual, or floor-plan pages first, then return here to review, annotate, share, and save images."))
                .font(.footnote)
                .foregroundColor(TAMETheme.brandTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
    }

    private var filteredEmptyState: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionHeading(title: TAMEL10n.text("没有匹配结果", "No Matches"), accent: "02")

            Text(TAMEL10n.text("没有匹配的历史记录", "No Matching Records"))
                .font(.title3.weight(.medium))
                .foregroundColor(TAMETheme.brandTextPrimary)

            Text(TAMEL10n.text("可以试试切换分类，或清空搜索关键词。", "Try switching categories or clearing the search text."))
                .font(.callout)
                .foregroundColor(TAMETheme.brandTextSecondary)

            HStack(spacing: 12) {
                Button(TAMEL10n.text("清空筛选", "Reset Filters")) {
                    selectedCategory = nil
                    searchText = ""
                }
                .font(.callout.weight(.medium))

                Button(TAMEL10n.text("前往专题分析", "Open Analysis")) {
                    guard let url = URL(string: "tamegeomancy://tab/analysis") else { return }
                    openURL(url)
                }
                .font(.callout.weight(.medium))
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 4)
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

    private func handleRecordsDeepLink(_ destination: RecordsDeepLinkDestination) {
        switch destination {
        case .list:
            selectedCategory = nil
            searchText = ""
            navigationPath = []
            legacyPreviewRoute = nil
        case .bazhaiList:
            selectedCategory = .bazhai
            searchText = ""
            navigationPath = []
            legacyPreviewRoute = nil
        case .sharePreview:
            let record = historyStore.save(RecordsView.sharePreviewRecord())
            openRecord(record.id)
        }
    }

    private func openRecord(_ recordID: UUID) {
        if #available(iOS 16.0, *) {
            navigationPath = [recordID]
        } else {
            legacyPreviewRoute = RecordPreviewRoute(id: recordID)
        }
    }

    private func openFlyingStarChart() {
        guard let url = URL(string: "tamegeomancy://analysis/flying-star") else { return }
        openURL(url)
    }

    static func sharePreviewRecord(createdAt: Date = Date()) -> AnalysisRecord {
        AnalysisRecord(
            category: .floorPlan,
            title: TAMEL10n.text("参考报告预览", "Report Preview"),
            subtitle: TAMEL10n.text("户型热力图 · 纳气联动", "Floor-plan heatmap · intake linkage"),
            details: [
                TAMEL10n.text("朝向参考：午方 · 九运", "Facing basis: Wu sector · Period 9"),
                TAMEL10n.text("主要纳气口：南向阳台 · 旺气 · 100分", "Primary intake opening: South Balcony · Excellent · score 100"),
                TAMEL10n.text("热力图：客厅与书房落在较稳区域，厨房与卫浴建议保持通风整洁。", "Heatmap: living room and study sit in steadier sectors; keep kitchen and bath ventilated and tidy."),
                TAMEL10n.text("导出说明：可生成 TAME Space Compass 风格报告图，并通过系统分享。", "Export note: creates a TAME Space Compass report image that can be shared through the system sheet.")
            ],
            createdAt: createdAt,
            notes: TAMEL10n.text("用于快速预览报告分享与保存到相册流程。", "Used to preview report sharing and save-to-Photos flow quickly.")
        )
    }
}

private struct RecordPreviewRoute: Identifiable {
    let id: UUID
}

struct RecordsView_Previews: PreviewProvider {
    static var previews: some View {
        RecordsView()
    }
}
