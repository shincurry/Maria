//
//  SettingsWindowController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static var isWindowShown = false
    
    func windowWillClose(_ aNotification: Notification) {
        SettingsWindowController.isWindowShown = false
    }
    
    override func showWindow(_ sender: Any?) {
        if !SettingsWindowController.isWindowShown {
            super.showWindow(sender)
            SettingsWindowController.isWindowShown = true
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        NSApp.activate(ignoringOtherApps: true)
        self.window?.canHide = false
        self.window?.delegate = self
    }
}
