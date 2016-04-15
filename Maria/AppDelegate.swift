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
            button.image = NSImage(named: "Arrow")
        }
        statusItem.menu = appMenu
        
        aria2configure()
        aria2.connect()
        
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        
    }
    
    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var RPCServerStatus: NSMenuItem!
}

extension AppDelegate {
    @IBAction func switchRPCServerStatus(sender: NSMenuItem) {
        let status = sender.state == 0 ? false : true
        if status {
            aria2.disconnect()
        } else {
            aria2.connect()
        }
    }
    
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

extension AppDelegate: NSUserNotificationCenterDelegate {
    func aria2configure() {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        aria2.downloadStarted = { name in
            Aria2Notification.notification(title: "Download Started", details: "Download task \(name) started.")
        }
        aria2.downloadPaused = { name in
            Aria2Notification.notification(title: "Download Paused", details: "Download task \(name) has been paused.")
        }
        aria2.downloadStopped = { name in
            Aria2Notification.notification(title: "Download Stopoped", details: "Download task \(name) has been stopped.")
        }
        aria2.downloadCompleted = { (name, path) in
            Aria2Notification.actionNotification(identifier: "complete", title: "Download Completed", details: "Download task \(name) has completed.", userInfo: ["path": path])
        }
        aria2.downloadError = { name in
            Aria2Notification.notification(title: "Download Error", details: "Download task \(name) have an error.")
        }
        
        aria2.connected = {
            self.RPCServerStatus.state = 1
        }
        aria2.disconnected = {
            self.RPCServerStatus.state = 0
        }
    }
    
    func userNotificationCenter(center: NSUserNotificationCenter, didActivateNotification notification: NSUserNotification) {
        if let id = notification.identifier {
            switch id {
            case "complete":
                let path = notification.userInfo!["path"] as! String
                NSWorkspace.sharedWorkspace().openURL(NSURL(string: "file://\(path)")!)
            default:
                break
                
            }
        }
    }
}
