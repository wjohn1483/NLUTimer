//
//  AppDelegate.swift
//  NLUTimer
//
//  Created by Chia-Hung Wan on 2021/3/23.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    static var popoverWidth = 200
    static var popoverHeight = 100
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView()
        
        let viewController = NSHostingController(rootView: contentView)

        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: AppDelegate.popoverWidth, height: AppDelegate.popoverHeight)
        popover.behavior = .transient
        popover.contentViewController = viewController
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.action = #selector(togglePopover(_:))
        }
        
        // Show popover at start
        /*
        let button = self.statusBarItem.button
        self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        */

    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                NSApplication.shared.activate(ignoringOtherApps: true)
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

