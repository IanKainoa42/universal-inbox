import XCTest
@testable import UniversalInbox

final class AppStateTests: XCTestCase {
    var defaults: UserDefaults!
    var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "Tests_\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        super.tearDown()
    }

    func testInitialState() {
        let appState = AppState(defaults: defaults, loadCloud: false)
        XCTAssertTrue(appState.items.isEmpty)
        // Bins should be seeded if empty
        XCTAssertFalse(appState.bins.isEmpty)
        XCTAssertEqual(appState.bins.count, 3)
    }

    func testItemsAreNotPersistedLocally() {
        let appState = AppState(defaults: defaults, loadCloud: false)
        let item = Item(rawText: "Test Note")
        appState.items.append(item)
        appState.save()

        // Create new AppState with same defaults
        let newAppState = AppState(defaults: defaults, loadCloud: false)
        XCTAssertTrue(newAppState.items.isEmpty)
    }

    func testDraftTextPersistence() {
        let appState = AppState(defaults: defaults, loadCloud: false)
        appState.draftText = "Drafting..."
        appState.save()

        let newAppState = AppState(defaults: defaults, loadCloud: false)
        XCTAssertEqual(newAppState.draftText, "Drafting...")
    }
}
