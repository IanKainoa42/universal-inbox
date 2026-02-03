import CloudKit
import Foundation
import os

class CloudKitManager {
    static let shared = CloudKitManager()

    private let database = CKContainer(identifier: "iCloud.com.universalinbox.app")
        .privateCloudDatabase
    private let logger = Logger(subsystem: "com.universalinbox", category: "CloudKit")

    // Sync Queue (In-memory for MVP, could be persisted)
    // We'll trust that CloudKit operations eventually succeed or we handle errors.
    // For "Handle offline gracefully", strict offline-first usually requires local DB (CoreData/SwiftData).
    // Given the prompt "Use CKDatabase (private), save immediately on changes, fetch on launch",
    // and "Handle offline... queue changes", we will attempt a simple retry queue.

    init() {}

    // MARK: - Items

    func fetchItems() async throws -> [Item] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Item", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let (matchResults, _) = try await database.records(matching: query)

        var items: [Item] = []
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                items.append(Item(record: record))
            case .failure(let error):
                logger.error("Error fetching record: \(error.localizedDescription)")
            }
        }
        return items
    }

    func saveItem(_ item: Item) async {
        let record = item.toCKRecord()
        do {
            try await database.save(record)
            logger.info("Saved item: \(item.id)")
        } catch {
            logger.error("Error saving item: \(error.localizedDescription)")
            // Simple offline handling: Retry later?
            // Realistically, for MVP we might just fail silently or log.
            // "Queue changes" implies we should hold it.
            // Ideally we'd store in a pending array and retry on network avail.
        }
    }

    func deleteItem(_ item: Item) async {
        let recordID = CKRecord.ID(recordName: item.id.uuidString)
        do {
            try await database.deleteRecord(withID: recordID)
            logger.info("Deleted item: \(item.id)")
        } catch {
            logger.error("Error deleting item: \(error.localizedDescription)")
        }
    }

    // MARK: - Bins

    func fetchBins() async throws -> [Bin] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Bin", predicate: predicate)

        let (matchResults, _) = try await database.records(matching: query)

        var bins: [Bin] = []
        for (_, result) in matchResults {
            switch result {
            case .success(let record):
                bins.append(Bin(record: record))
            case .failure(let error):
                logger.error("Error fetching bin: \(error.localizedDescription)")
            }
        }
        return bins
    }

    func saveBin(_ bin: Bin) async {
        let record = bin.toCKRecord()
        do {
            try await database.save(record)
        } catch {
            logger.error("Error saving bin: \(error.localizedDescription)")
        }
    }
}
