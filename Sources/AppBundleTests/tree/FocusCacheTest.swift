@testable import AppBundle
import Common
import XCTest

@MainActor
final class FocusCacheTest: XCTestCase {
    override func setUp() async throws {
        setUpWorkspacesForTests()
        for popup in macosPopupWindowsContainer.children { popup.unbindFromParent() }
    }

    override func tearDown() async throws {
        for popup in macosPopupWindowsContainer.children { popup.unbindFromParent() }
    }

    func testClickInsidePopupOfTheAppIsPopupClick() async throws {
        TestWindow.new(id: 1, parent: macosPopupWindowsContainer, rect: Rect(topLeftX: 2600, topLeftY: 100, width: 400, height: 200))

        assertEquals(try await isClickOnPopup(of: TestApp.shared, at: CGPoint(x: 2700, y: 150)), true)
    }

    func testClickOutsidePopupsIsNotPopupClick() async throws {
        TestWindow.new(id: 1, parent: macosPopupWindowsContainer, rect: Rect(topLeftX: 2600, topLeftY: 100, width: 400, height: 200))
        TestWindow.new(id: 2, parent: Workspace.get(byName: "a").rootTilingContainer, rect: Rect(topLeftX: 0, topLeftY: 0, width: 1000, height: 1000))

        assertEquals(try await isClickOnPopup(of: TestApp.shared, at: CGPoint(x: 100, y: 150)), false)
    }

    func testNoRecentClickIsNotPopupClick() async throws {
        TestWindow.new(id: 1, parent: macosPopupWindowsContainer, rect: Rect(topLeftX: 2600, topLeftY: 100, width: 400, height: 200))

        assertEquals(try await isClickOnPopup(of: TestApp.shared, at: nil), false)
    }
}
