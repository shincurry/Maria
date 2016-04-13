//
//  AppDelegate.swift
//  Maria
//
//  Created by ShinCurry on 16/4/13.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2
import SwiftyJSON

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let aria2 = Aria2.shared

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarItem")
        }
        
//        let menu = NSMenu()
//        menu.addItem(NSMenuItem(title: "Settings", action: #selector(settings), keyEquivalent: ""))
//        menu.addItem(NSMenuItem(title: "About", action: #selector(about), keyEquivalent: ""))
//        menu.addItem(NSMenuItem.separatorItem())
//        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: ""))
        statusItem.menu = appMenu
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    @IBOutlet weak var appMenu: NSMenu!
    
}

extension AppDelegate {
    func settings() {
    }
    func about() {
        
    }
    
    @IBAction func quit(sender: NSMenuItem) {
        NSApp.terminate(self)
    }
}

