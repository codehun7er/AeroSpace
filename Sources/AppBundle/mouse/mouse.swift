import AppKit

@MainActor var currentlyManipulatedWithMouseWindowId: UInt32? = nil
var isLeftMouseButtonDown: Bool { NSEvent.pressedMouseButtons == 1 }

/// Resize handles reach slightly outside of the window frame
private let resizeHandleReachOutsideWindow: CGFloat = 15

@MainActor
func isManipulatedWithMouse(_ window: Window) async throws -> Bool {
    let mightBeManipulated = !window.isHiddenInCorner && // Don't allow to resize/move windows of hidden workspaces
        isLeftMouseButtonDown &&
        (currentlyManipulatedWithMouseWindowId == nil || window.windowId == currentlyManipulatedWithMouseWindowId)
    return try await mightBeManipulated
        .andAsync { @Sendable @MainActor in try await getNativeFocusedWindow(.cancellable) == window }
        .andAsync { @Sendable @MainActor in try await isGrabbedByMouse(window) }
}

/// The native focused window isn't necessarily the one under the mouse.
/// Arc keeps reporting its main window as focused while the user clicks or drags its picture-in-picture panel.
/// If the main window moves at that moment (e.g. AeroSpace reveals its workspace), it must not be
/// mistaken for a drag, otherwise it gets moved to the monitor under the mouse.
@MainActor
private func isGrabbedByMouse(_ window: Window) async throws -> Bool {
    if window.windowId == currentlyManipulatedWithMouseWindowId { return true }
    guard let rect = try await window.getAxRect(.cancellable) else { return false }
    let reach = resizeHandleReachOutsideWindow
    return Rect(topLeftX: rect.minX - reach, topLeftY: rect.minY - reach, width: rect.width + 2 * reach, height: rect.height + 2 * reach)
        .contains(mouseLocation)
}

/// Same motivation as in monitorFrameNormalized
var mouseLocation: CGPoint { NSEvent.mouseLocation.withYAxisFlipped }
