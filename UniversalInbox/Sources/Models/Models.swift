import CloudKit
import Foundation

/// Represents the processing state of a captured item.
enum ItemStatus: String, Codable {
    case inbox
    case processed
    case archived
}

/// A single captured item that can be routed into a bin.
struct Item: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var rawText: String
    var status: ItemStatus = .inbox
    var binId: UUID?
    var createdAt: Date = Date()

    // CloudKit Integration
    init(record: CKRecord) {
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.rawText = record["rawText"] as? String ?? ""
        if let statusString = record["status"] as? String,
            let status = ItemStatus(rawValue: statusString)
        {
            self.status = status
        } else {
            self.status = .inbox
        }
        if let binIdString = record["binId"] as? String {
            self.binId = UUID(uuidString: binIdString)
        }
        self.createdAt = record.creationDate ?? Date()
    }

    /// Default initializer for new items.
    init(
        id: UUID = UUID(), rawText: String, status: ItemStatus = .inbox, binId: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.rawText = rawText
        self.status = status
        self.binId = binId
        self.createdAt = createdAt
    }

    /// Converts the item into a CloudKit record for persistence.
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Item", recordID: CKRecord.ID(recordName: id.uuidString))
        record["rawText"] = rawText
        record["status"] = status.rawValue
        if let binId = binId {
            record["binId"] = binId.uuidString
        }
        return record
    }
}

/// A user-defined destination for routing items.
struct Bin: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var description: String

    /// Initializes a bin from a CloudKit record.
    init(record: CKRecord) {
        self.id = UUID(uuidString: record.recordID.recordName) ?? UUID()
        self.name = record["name"] as? String ?? ""
        self.description = record["description"] as? String ?? ""
    }

    /// Default initializer for new bins.
    init(id: UUID = UUID(), name: String, description: String) {
        self.id = id
        self.name = name
        self.description = description
    }

    /// Converts the bin into a CloudKit record for persistence.
    func toCKRecord() -> CKRecord {
        let record = CKRecord(recordType: "Bin", recordID: CKRecord.ID(recordName: id.uuidString))
        record["name"] = name
        record["description"] = description
        return record
    }
}
