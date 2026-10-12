@testable import AppBundle
import Common
import XCTest

@MainActor
final class ClosedWindowsCacheTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testReappearedWindowRestoresCacheWhenVisibleWorkspacesAreUnchanged() async throws {
        let window = TestWindow.new(id: 1, parent: Workspace.get(byName: "a").rootTilingContainer)
        assertTrue(Workspace.get(byName: "a").focusWorkspace())
        cacheClosedWindowIfNeeded()

        assertEquals(try await restoreClosedWindowsCacheIfNeeded(newlyDetectedWindow: window), true)
    }

    func testWorkspaceSwitchInvalidatesClosedWindowsCache() async throws {
        let window = TestWindow.new(id: 1, parent: Workspace.get(byName: "a").rootTilingContainer)
        TestWindow.new(id: 2, parent: Workspace.get(byName: "b").rootTilingContainer)
        assertTrue(Workspace.get(byName: "a").focusWorkspace())
        cacheClosedWindowIfNeeded()

        assertTrue(Workspace.get(byName: "b").focusWorkspace())

        assertEquals(try await restoreClosedWindowsCacheIfNeeded(newlyDetectedWindow: window), false)
        assertEquals(focus.workspace.name, "b")
    }
}
