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

    var aria2: Aria2?
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        if defaults.boolForKey("IsNotFirstLaunch") {
            userDefaultsInit()
        }
        
        if let button = statusItem.button {
            button.image = NSImage(named: "Arrow")
        }
        statusItem.menu = appMenu
        
        if defaults.boolForKey("EnableAutoConnectAria2") {
            aria2open()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        if let _ = aria2 {
            aria2close()
        }
    }
    
    @IBOutlet weak var appMenu: NSMenu!
    @IBOutlet weak var RPCServerStatus: NSMenuItem!
}

extension AppDelegate {
    @IBAction func switchRPCServerStatus(sender: NSMenuItem) {
        let status = sender.state == 0 ? false : true
        if status {
            aria2close()
        } else {
            aria2open()
        }
    }
    
    @IBAction func quit(sender: NSMenuItem)  {
        NSApp.terminate(self)
    }
    
    @IBAction func speedLimitMode(sender: NSMenuItem) {
        sender.state = (sender.state == 0 ? 1 : 0)
    }

    @IBAction func openWebUIApp(sender: NSMenuItem) {
        let path = defaults.objectForKey("WebAppPath") as! String
        if !path.isEmpty {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: "file:///Users/shincurry/webui-aria2-master/index.html")!)
        }
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    func aria2open() {
        
        let baseHost = "http" + (defaults.boolForKey("SSLEnabled") ? "s" : "") + "://"
        let host = defaults.objectForKey("RPCServerHost") as! String
        let port = defaults.objectForKey("RPCServerPort") as! String
        let path = defaults.objectForKey("RPCServerPath") as! String
        
        aria2 = Aria2(url: baseHost + host + ":" + port + path)
        aria2configure()
        aria2!.connect()
        RPCServerStatus.state = 1
        
    }
    
    func aria2close() {
        aria2!.disconnect()
    }
    
    func aria2configure() {
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        aria2!.downloadStarted = { name in
            if self.defaults.boolForKey("EnableNotificationWhenStarted") {
                Aria2Notification.notification(title: "Download Started", details: "Download task \(name) started.")
            }
        }
        aria2!.downloadPaused = { name in
            if self.defaults.boolForKey("EnableNotificationWhenPaused") {
                Aria2Notification.notification(title: "Download Paused", details: "Download task \(name) has been paused.")
            }
        }
        aria2!.downloadStopped = { name in
            if self.defaults.boolForKey("EnableNotificationWhenStopped") {
                Aria2Notification.notification(title: "Download Stopoped", details: "Download task \(name) has been stopped.")
            }
        }
        aria2!.downloadCompleted = { (name, path) in
            if self.defaults.boolForKey("EnableNotificationWhenCompleted") {
                Aria2Notification.actionNotification(identifier: "complete", title: "Download Completed", details: "Download task \(name) has completed.", userInfo: ["path": path])
            }
        }
        aria2!.downloadError = { name in
            if self.defaults.boolForKey("EnableNotificationWhenError") {
                Aria2Notification.notification(title: "Download Error", details: "Download task \(name) have an error.")
            }
        }
        
        aria2!.connected = {
            self.RPCServerStatus.state = 1
        }
        aria2!.disconnected = {
            self.RPCServerStatus.state = 0
            self.aria2 = nil
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

extension AppDelegate {
    func userDefaultsInit() {
        // First Launch
        defaults.setBool(false, forKey: "IsNotFirstLaunch")
        
        
        // Notification Settings
        defaults.setBool(true, forKey: "EnableNotificationWhenStarted")
        defaults.setBool(false, forKey: "EnableNotificationWhenStopped")
        defaults.setBool(false, forKey: "EnableNotificationWhenPaused")
        defaults.setBool(true, forKey: "EnableNotificationWhenCompleted")
        defaults.setBool(false, forKey: "EnableNotificationWhenError")
        
        
        // Bandwidth Settings
        defaults.setInteger(0, forKey: "GlobalDownloadRate")
        defaults.setInteger(0, forKey: "GlobalUploadRate")
        defaults.setInteger(0, forKey: "LimitModeDownloadRate")
        defaults.setInteger(0, forKey: "LimitModeUploadRate")
        
        
        // General Settings
        defaults.setBool(false, forKey: "LaunchAtStartup")
        defaults.setObject("", forKey: "WebAppPath")

        
        // Aria2 Settings
        defaults.setBool(true, forKey: "EnableAutoConnectAria2")
        
        defaults.setObject("localhost", forKey: "RPCServerHost")
        defaults.setObject("6800", forKey: "RPCServerPort")
        defaults.setObject("/jsonrpc", forKey: "RPCServerPath")
        defaults.setObject("", forKey: "RPCServerSecret")
        defaults.setObject("", forKey: "RPCServerUsername")
        defaults.setObject("", forKey: "RPCServerPassword")
        defaults.setBool(false, forKey: "EnabledSSL")
        defaults.synchronize()

    }
}
