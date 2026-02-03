import XCTest
@testable import UniversalInbox

final class ModelTests: XCTestCase {
    func testItemInitialization() {
        let text = "Buy milk"
        let item = Item(rawText: text)

        XCTAssertEqual(item.rawText, text)
        XCTAssertEqual(item.status, .inbox)
        XCTAssertNil(item.binId)
    }

    func testItemCoding() throws {
        let item = Item(rawText: "Test Item", status: .processed)
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(Item.self, from: data)

        XCTAssertEqual(item.id, decoded.id)
        XCTAssertEqual(item.rawText, decoded.rawText)
        XCTAssertEqual(item.status, decoded.status)
    }

    func testBinInitialization() {
        let name = "Work"
        let description = "Work related stuff"
        let bin = Bin(name: name, description: description)

        XCTAssertEqual(bin.name, name)
        XCTAssertEqual(bin.description, description)
    }

    func testEdgeCases() {
        // Special Characters
        let specialText = "Hello 🌍! This contains emojis & special chars: @#%^&*()"
        let item = Item(rawText: specialText)
        XCTAssertEqual(item.rawText, specialText)

        // Long Text
        let longText = String(repeating: "A", count: 10000)
        let longItem = Item(rawText: longText)
        XCTAssertEqual(longItem.rawText, longText)
    }
}
