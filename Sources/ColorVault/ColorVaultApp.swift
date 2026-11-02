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
            // Load unified fixed app icon
            var menuIcon: NSImage?
            if let path = Bundle.main.path(forResource: "MenuBarIcon", ofType: "png") {
                menuIcon = NSImage(contentsOfFile: path)
            } else if let path = Bundle.main.path(forResource: "MenuBarIcon@2x", ofType: "png") {
                menuIcon = NSImage(contentsOfFile: path)
            }

            if let img = menuIcon {
                img.isTemplate = true
                img.size = NSSize(width: 18, height: 18)
                button.image = img
            } else {
                let fallback = NSImage(systemSymbolName: "paintpalette.fill", accessibilityDescription: "ColorVault Pro")
                fallback?.isTemplate = true
                button.image = fallback
            }

            button.action = #selector(togglePopover(_:))
            button.target = self
        }

        // Setup the Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 520, height: 645)
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
            // Clear any default initial button focus so there's zero blue highlight
            popover.contentViewController?.view.window?.makeFirstResponder(nil)
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
