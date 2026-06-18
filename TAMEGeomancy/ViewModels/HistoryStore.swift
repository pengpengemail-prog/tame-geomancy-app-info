import Foundation
import Combine

enum AnalysisRecordCategory: String, Codable, CaseIterable {
    case orientation = "坐向纳气"
    case yangGongFenjin = "杨公分金"
    case jiuyun = "三元九运"
    case flyingStar = "飞星排盘"
    case annual = "年度布局"
    case floorPlan = "户型分析"
    case bazhai = "八区建议"
    case reference = "形煞参考"

    var localizedTitle: String {
        switch self {
        case .orientation:
            return TAMEL10n.text("坐向纳气", "Orientation & Openings")
        case .yangGongFenjin:
            return TAMEL10n.text("杨公分金", "Yang Gong Lines")
        case .jiuyun:
            return TAMEL10n.text("三元九运", "Period Guide")
        case .flyingStar:
            return TAMEL10n.text("飞星排盘", "Flying Star Chart")
        case .annual:
            return TAMEL10n.text("年度布局", "Annual Review")
        case .floorPlan:
            return TAMEL10n.text("户型分析", "Floor Plan")
        case .bazhai:
            return TAMEL10n.text("八区建议", "Eight-Sector Planner")
        case .reference:
            return TAMEL10n.text("形煞参考", "Reference Notes")
        }
    }

    var searchKeywords: [String] {
        switch self {
        case .orientation:
            return ["坐向纳气", "orientation", "naqi", "opening", "facing"]
        case .yangGongFenjin:
            return ["杨公分金", "分金立向", "二十四山", "yang gong", "fenjin", "luopan", "orientation"]
        case .jiuyun:
            return ["三元九运", "period", "cycles", "jiuyun"]
        case .flyingStar:
            return ["飞星排盘", "flying star", "chart", "stars"]
        case .annual:
            return ["年度布局", "annual", "layout", "review", "yearly"]
        case .floorPlan:
            return ["户型分析", "floor plan", "layout", "heatmap"]
        case .bazhai:
            return ["八区建议", "bazhai", "house", "profile"]
        case .reference:
            return ["形煞参考", "reference", "notes", "knowledge"]
        }
    }
}

extension AnalysisRecordCategory {
    var badgeStyle: TAMEDashboardBadgeStyle {
        switch self {
        case .orientation:
            return .naqi
        case .yangGongFenjin:
            return .yangGong
        case .jiuyun:
            return .period
        case .flyingStar:
            return .stars
        case .annual:
            return .annual
        case .floorPlan:
            return .layout
        case .bazhai:
            return .bazhai
        case .reference:
            return .reference
        }
    }
}

struct AnalysisRecord: Identifiable, Codable, Equatable {
    let id: UUID
    let category: AnalysisRecordCategory
    let title: String
    let subtitle: String
    let details: [String]
    let createdAt: Date
    var notes: String

    init(
        id: UUID = UUID(),
        category: AnalysisRecordCategory,
        title: String,
        subtitle: String,
        details: [String],
        createdAt: Date = Date(),
        notes: String = ""
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.subtitle = subtitle
        self.details = details
        self.createdAt = createdAt
        self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case id
        case category
        case title
        case subtitle
        case details
        case createdAt
        case notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        category = try container.decode(AnalysisRecordCategory.self, forKey: .category)
        title = try container.decode(String.self, forKey: .title)
        subtitle = try container.decode(String.self, forKey: .subtitle)
        details = try container.decode([String].self, forKey: .details)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
}

final class HistoryStore: ObservableObject {
    static let shared = HistoryStore()

    @Published private(set) var records: [AnalysisRecord] = []

    private let storageKey = "tame_geomancy_records"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private static let backupSchemaVersion = 1

    private init() {
        load()
    }

    @discardableResult
    func save(
        category: AnalysisRecordCategory,
        title: String,
        subtitle: String,
        details: [String],
        notes: String = ""
    ) -> AnalysisRecord {
        let record = AnalysisRecord(
            category: category,
            title: title,
            subtitle: subtitle,
            details: details,
            notes: notes
        )

        return save(record)
    }

    @discardableResult
    func save(_ record: AnalysisRecord) -> AnalysisRecord {
        records.insert(record, at: 0)
        persist()
        return record
    }

    func delete(at offsets: IndexSet) {
        records.remove(atOffsets: offsets)
        persist()
    }

    func clear() {
        records.removeAll()
        persist()
    }

    func record(for id: UUID) -> AnalysisRecord? {
        records.first(where: { $0.id == id })
    }

    func updateNotes(for id: UUID, notes: String) {
        guard let index = records.firstIndex(where: { $0.id == id }) else { return }
        records[index].notes = notes
        persist()
    }

    func makeBackupData(exportedAt: Date = Date()) throws -> Data {
        try Self.makeBackupData(for: records, exportedAt: exportedAt)
    }

    @discardableResult
    func importBackup(data: Data) throws -> HistoryBackupImportResult {
        let envelope = try Self.decodeBackupData(data)
        let mergeResult = Self.mergeRecords(existing: records, incoming: envelope.records)
        records = mergeResult.records
        persist()
        return mergeResult.summary
    }

    private func persist() {
        guard let data = try? encoder.encode(records) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? decoder.decode([AnalysisRecord].self, from: data) else {
            records = []
            return
        }
        records = decoded.sorted { $0.createdAt > $1.createdAt }
    }
}

extension HistoryStore {
    static func makeBackupData(for records: [AnalysisRecord], exportedAt: Date = Date()) throws -> Data {
        let backupEncoder = JSONEncoder()
        backupEncoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        backupEncoder.dateEncodingStrategy = .iso8601

        let envelope = HistoryBackupEnvelope(
            schemaVersion: backupSchemaVersion,
            exportedAt: exportedAt,
            appName: "TAME Space Compass / 探觅·空间罗盘",
            recordCount: records.count,
            records: records.sorted { $0.createdAt > $1.createdAt }
        )

        return try backupEncoder.encode(envelope)
    }

    static func decodeBackupData(_ data: Data) throws -> HistoryBackupEnvelope {
        let backupDecoder = JSONDecoder()
        backupDecoder.dateDecodingStrategy = .iso8601

        let envelope = try backupDecoder.decode(HistoryBackupEnvelope.self, from: data)

        guard envelope.schemaVersion == backupSchemaVersion else {
            throw HistoryBackupError.unsupportedSchema
        }

        guard envelope.recordCount == envelope.records.count else {
            throw HistoryBackupError.recordCountMismatch
        }

        return envelope
    }

    static func mergeRecords(existing: [AnalysisRecord], incoming: [AnalysisRecord]) -> HistoryBackupMergeResult {
        var merged = existing
        var knownIDs = Set(existing.map(\.id))
        var importedCount = 0
        var skippedDuplicates = 0

        for record in incoming {
            if knownIDs.insert(record.id).inserted {
                merged.append(record)
                importedCount += 1
            } else {
                skippedDuplicates += 1
            }
        }

        merged.sort { $0.createdAt > $1.createdAt }

        return HistoryBackupMergeResult(
            records: merged,
            summary: HistoryBackupImportResult(
                importedCount: importedCount,
                skippedDuplicates: skippedDuplicates,
                totalCount: merged.count
            )
        )
    }
}

struct HistoryBackupEnvelope: Codable, Equatable {
    let schemaVersion: Int
    let exportedAt: Date
    let appName: String
    let recordCount: Int
    let records: [AnalysisRecord]
}

struct HistoryBackupImportResult: Equatable {
    let importedCount: Int
    let skippedDuplicates: Int
    let totalCount: Int

    var summaryText: String {
        if importedCount == 0 {
            return TAMEL10n.text(
                "备份已读取，但没有新增记录。当前共 \(totalCount) 条记录。",
                "The backup was read successfully, but no new records were added. Total records: \(totalCount)."
            )
        }

        return TAMEL10n.text(
            "已导入 \(importedCount) 条记录，跳过重复 \(skippedDuplicates) 条，当前共 \(totalCount) 条记录。",
            "Imported \(importedCount) records, skipped \(skippedDuplicates) duplicates, total records: \(totalCount)."
        )
    }
}

struct HistoryBackupMergeResult: Equatable {
    let records: [AnalysisRecord]
    let summary: HistoryBackupImportResult
}

enum HistoryBackupError: LocalizedError, Equatable {
    case unsupportedSchema
    case recordCountMismatch

    var errorDescription: String? {
        switch self {
        case .unsupportedSchema:
            return TAMEL10n.text(
                "备份文件版本暂不支持，请确认是否为当前版本导出的备份。",
                "This backup schema is not supported yet. Please confirm it was exported from the current app version."
            )
        case .recordCountMismatch:
            return TAMEL10n.text(
                "备份文件内容不完整，记录数量校验未通过。",
                "The backup file appears incomplete because the record count validation failed."
            )
        }
    }
}
