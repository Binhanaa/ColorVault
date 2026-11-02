import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var eventMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize Rust SQLite Database
        _ = RustBridge.shared

        // Create the Status Item in the macOS Menu Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem.button {
            // Palette / Prism Status Icon
            let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .medium)
            if let image = NSImage(systemSymbolName: "paintpalette.fill", accessibilityDescription: "ColorVault")?.withSymbolConfiguration(config) {
                image.isTemplate = true
                button.image = image
            } else {
                button.title = "🎨"
            }
            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Setup the Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 480, height: 620)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: PopoverView())

        // Global click monitor to dismiss popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(event)
            }
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem.button else { return }

        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}

@main
struct ColorVaultApp {
    static func main() {
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // Menu bar only app (no dock clutter)
        app.run()
    }
}
