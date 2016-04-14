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

    let aria2 = Aria2()

    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if let button = statusItem.button {
            button.image = NSImage(named: "StatusBarItem")
        }
        statusItem.menu = appMenu
        aria2.connect()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    @IBOutlet weak var appMenu: NSMenu!
    
}

extension AppDelegate {
    
    @IBAction func quit(sender: NSMenuItem)  {
        NSApp.terminate(self)
    }
    
    @IBAction func speedLimitMode(sender: NSMenuItem) {
        sender.state = (sender.state == 0 ? 1 : 0)
    }

    @IBAction func openWebUIApp(sender: NSMenuItem) {
        
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: "file:///Users/shincurry/webui-aria2-master/index.html")!)
    }
}

