import Foundation

enum ItemStatus: String, Codable {
    case inbox
    case processed
    case archived
}

struct Item: Identifiable, Codable {
    var id: UUID = UUID()
    var rawText: String
    var status: ItemStatus = .inbox
    var binId: UUID?
    var createdAt: Date = Date()
}

struct Bin: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var description: String
}
