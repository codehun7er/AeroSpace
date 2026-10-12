import AppKit

@MainActor private var lastKnownNativeFocusedWindowId: UInt32? = nil

/// The data should flow (from nativeFocused to focused) and
///                      (from nativeFocused to lastKnownNativeFocusedWindowId)
/// Alternative names: takeFocusFromMacOs, syncFocusFromMacOs
@MainActor func updateFocusCache(_ nativeFocused: Window?) async throws {
    if nativeFocused?.parent is MacosPopupWindowsContainer {
        return
    }
    if nativeFocused?.windowId != lastKnownNativeFocusedWindowId {
        if try await !isActivatedByPopupClick(nativeFocused) {
            _ = nativeFocused?.focusWindow()
        }
        lastKnownNativeFocusedWindowId = nativeFocused?.windowId
    }
    nativeFocused?.macAppUnsafe.lastNativeFocusedWindowId = nativeFocused?.windowId
}

@MainActor private func isActivatedByPopupClick(_ nativeFocused: Window?) async throws -> Bool {
    guard let nativeFocused else { return false }
    return try await isClickOnPopup(of: nativeFocused.app, at: recentLeftMouseDownLocation)
}

/// Arc keeps reporting its main window as focused when the user clicks its picture-in-picture panel.
/// Following such focus change would switch the monitor to the workspace of the main window.
@MainActor func isClickOnPopup(of app: any AbstractApp, at click: CGPoint?) async throws -> Bool {
    guard let click else { return false }
    for popup in macosPopupWindowsContainer.children.filterIsInstance(of: Window.self) where popup.app.pid == app.pid {
        if try await popup.getAxRect(.cancellable)?.contains(click) == true { return true }
    }
    return false
}
