//
//  AppDelegate.swift
//  JonnySearch
//
//  Created by Jonny on 3/29/17.
//  Copyright © 2017 Junyu Kuang <lightscreen.app@gmail.com>. All rights reserved.
//

import Cocoa
import MASShortcut

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    private var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        registerShortcuts()
        
        let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.title = "S"
        statusItem.button?.target = self
        statusItem.button?.action = #selector(statusItemButtonDidTap)
        self.statusItem = statusItem
		
        let panel = NSApp.windows.first as! NSPanel
        configurePanel(panel)
		panel.makeKeyAndOrderFront(self)
		
		self.window = panel
		
		NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey), name: NSWindow.didResignKeyNotification, object: nil)
	}
    
	func toggleWindowVisibleState() {
		if window.isVisible {
			window.resignKey()
		} else {
			window.makeKeyAndOrderFront(self)
		}
	}
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        print(#function)
        window?.makeKeyAndOrderFront(self)
        return false
    }
}

@objc private extension AppDelegate {
    
    func windowDidResignKey() {
        window.orderOut(self)
    }
    
    func statusItemButtonDidTap(_ sender: Any?) {
        print(#function)
        toggleWindowVisibleState()
    }
}

private extension AppDelegate {
    
    func configurePanel(_ panel: NSPanel) {
        panel.isReleasedWhenClosed = true
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.styleMask = NSWindow.StyleMask.nonactivatingPanel
        panel.level = NSWindow.Level(rawValue: NSWindow.Level.mainMenu.rawValue - 1)
        panel.collectionBehavior = [NSWindow.CollectionBehavior.canJoinAllSpaces, NSWindow.CollectionBehavior.fullScreenAuxiliary]
        panel.center()
        
        panel.titlebarAppearsTransparent = true
        panel.isMovableByWindowBackground = true
    }
    
    // MARK: - Customizable
    func registerShortcuts() {
        let monitor = MASShortcutMonitor.shared()!
        
        // command + space: show search bar
        if let shortcut = MASShortcut(keyCode: UInt(kVK_Space), modifierFlags: NSEvent.ModifierFlags.control.rawValue),
            !monitor.isShortcutRegistered(shortcut) {
            monitor.register(shortcut) {
                self.toggleWindowVisibleState()
            }
        }
        
        // shift + command + v: show search bar and paste clipboard text
        if let shortcut = MASShortcut(event: PasteShortcutEvent()),
            !monitor.isShortcutRegistered(shortcut) {
            monitor.register(shortcut) {
                if self.window.isVisible {
                    self.window.resignKey()
                } else {
                    let clipboardText = NSPasteboard.general.string ?? ""
                    let textField = (self.window!.contentViewController as! ViewController).textField
                    textField?.stringValue = clipboardText
                    textField?.currentEditor()?.selectedRange = NSMakeRange((clipboardText as NSString).length, 0)
                    
                    self.window.makeKeyAndOrderFront(self)
                }
            }
        }
        
        // shift + command + R: Open AirDrop
//        if let shortcut = MASShortcut(event: AirDropShortcutEvent()),
//            !monitor.isShortcutRegistered(shortcut) {
//            monitor.register(shortcut) {
//                NSWorkspace.shared.activateFileViewerSelecting([])
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                    self.performAirDropShortcut()
//                }
//            }
//        }
        
        // shift + command + x: kill SourceKitService
//        if let shortcut = MASShortcut(event: KillSourceKitServiceEvent()),
//            !monitor.isShortcutRegistered(shortcut) {
//            monitor.register(shortcut) {
//                Process.launchedProcess(launchPath: "/usr/bin/killall", arguments: ["SourceKitService"])
//            }
//        }
    }
    
    func performAirDropShortcut() {
        
        func keyEvents(forPressAndReleaseVirtualKey virtualKey: Int) -> [CGEvent] {
            let eventSource = CGEventSource(stateID: .hidSystemState)
            return [
                CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: true)!,
                CGEvent(keyboardEventSource: eventSource, virtualKey: CGKeyCode(virtualKey), keyDown: false)!,
            ]
        }
        
        let tapLocation = CGEventTapLocation.cghidEventTap
        let events = keyEvents(forPressAndReleaseVirtualKey: kVK_ANSI_R)
        
        events.forEach {
            $0.flags = [.maskShift, .maskCommand, .maskControl]
            $0.post(tap: tapLocation)
        }
    }
}

extension NSPasteboard {
    
    var string: String? {
        return readObjects(forClasses: [NSString.self], options: nil)?.first as? String
    }
}
