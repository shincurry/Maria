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
    
    var aria = Aria.shared
    let defaults = MariaUserDefault.auto
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var speedStatusTimer: Timer?
    
    override init() {
        if !MariaUserDefault.main.bool(forKey: "IsNotFirstLaunch") {
            MariaUserDefault.initMain()
            MariaUserDefault.initExternal()
            MariaUserDefault.initBuildIn()
        }
        
        if !MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
            if defaults.bool(forKey: "EnableAria2AutoLaunch") {
                let task = Process()
                let confPath = defaults.object(forKey: "Aria2ConfPath") as! String
                let shFilePath = Bundle.main
                    .path(forResource: "runAria2c", ofType: "sh")
                task.launchPath = shFilePath
                task.arguments = [confPath]
                task.launch()
                task.waitUntilExit()
            }
        }
        
        super.init()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSUserNotificationCenter.default.delegate = self
        
        if defaults.bool(forKey: "EnableAutoConnectAria2") {
            aria2open()
        }

        statusItem.button?.action = #selector(AppDelegate.menuClicked)
        statusItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        
        if defaults.bool(forKey: "EnableSpeedStatusBar") {
            enableSpeedStatusBar()
        } else {
            disableSpeedStatusBar()
        }

        for window in NSApp.windows {
            window.canHide = false
        }
        
        if defaults.bool(forKey: "EnableDockIcon") {
            enableDockIcon()
        } else {
            disableDockIcon()
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        aria2close()
        if !MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
            if defaults.bool(forKey: "EnableAria2AutoLaunch") {
                let task = Process()
                let pipe = Pipe()
                let shFilePath = Bundle.main.path(forResource: "shutdownAria2c", ofType: "sh")
                task.launchPath = shFilePath
                task.standardOutput = pipe
                task.launch()
                task.waitUntilExit()
                print("EnableAria2AutoLaunch")
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                print(String(data: data, encoding: .utf8))
            }
        }
        
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(self)
            }
        }
        return true
    }
    
    // MARK: SpeedBar
    func enableSpeedStatusBar() {
        speedStatusTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateSpeedStatus), userInfo: nil, repeats: true)
        if let button = statusItem.button {
            button.image = nil
        }
    }
    
    func disableSpeedStatusBar() {
        speedStatusTimer?.invalidate()
        if let button = statusItem.button {
            button.image = NSImage(named: "Arrow")
            button.title = ""
        }
        
    }
    
    func menuClicked(sender: NSStatusBarButton) {
        if NSApp.currentEvent!.type == NSEventType.rightMouseUp {
            statusItem.popUpMenu(statusMenu)
        } else {
            if NSApp.isActive {
               statusItem.popUpMenu(statusMenu)
                return
            }
            for window in NSApp.windows {
                window.makeKeyAndOrderFront(self)
            }
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    
    // MARK: Dock Icon
    func enableDockIcon() {
        NSApp.setActivationPolicy(.regular)
    }
    
    func disableDockIcon() {
        NSApp.setActivationPolicy(.accessory)
    }
    
    func updateSpeedStatus() {
        if aria.rpc!.status == .connected {
            aria.rpc!.getGlobalStatus()
        }
        aria.rpc!.onGlobalStatus = { status in
            if let button = self.statusItem.button {
                button.title = "⬇︎ " + status.speed!.downloadString + " ⬆︎ " + status.speed!.uploadString
            }
        }
    }
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var RPCServerStatus: NSMenuItem!
    @IBOutlet weak var lowSpeedMode: NSMenuItem!
    
}

extension AppDelegate {
    @IBAction func switchRPCServerStatus(_ sender: NSMenuItem) {
        let status = sender.state == 0 ? false : true
        if status {
            aria2close()
        } else {
            aria2open()
        }
    }
    
    @IBAction func quit(_ sender: NSMenuItem)  {
        NSApp.terminate(self)
    }
    
    @IBAction func speedLimitMode(_ sender: NSMenuItem) {
        let status = sender.state == 0 ? false : true
        if status {
            lowSpeedModeOff()
            defaults.set(false, forKey: "EnableLowSpeedMode")
        } else {
            lowSpeedModeOn()
            defaults.set(true, forKey: "EnableLowSpeedMode")
        }
        defaults.synchronize()
        
    }

    @IBAction func openWebUIApp(_ sender: NSMenuItem) {
        let path = defaults.object(forKey: "WebAppPath") as! String
        if !path.isEmpty {
            NSWorkspace.shared().open(URL(fileURLWithPath: path))
        }
    }
    
    func lowSpeedModeOff() {
        let limitDownloadSpeed = defaults.integer(forKey: "GlobalDownloadRate")
        let limitUploadSpeed = defaults.integer(forKey: "GlobalUploadRate")
        if let controller = NSApp.mainWindow?.windowController as? MainWindowController {
            controller.lowSpeedModeOff()
        }
        aria.rpc!.globalSpeedLimit(download: limitDownloadSpeed, upload: limitUploadSpeed)
    }

    func lowSpeedModeOn() {
        let limitDownloadSpeed = defaults.integer(forKey: "LimitModeDownloadRate")
        let limitUploadSpeed = defaults.integer(forKey: "LimitModeUploadRate")
        if let controller = NSApp.mainWindow?.windowController as? MainWindowController {
            controller.lowSpeedModeOn()
        }
        aria.rpc!.lowSpeedLimit(download: limitDownloadSpeed, upload: limitUploadSpeed)
    }
}

// MARK: - Aria2 Config
extension AppDelegate: NSUserNotificationCenterDelegate {
    func aria2open() {
        aria2configure()
        aria.rpc!.connect()
        RPCServerStatus.state = 1
    }
    
    func aria2close() {
        aria.rpc!.disconnect()
    }
    
    func aria2configure() {
        aria.rpc!.onConnect = {
            self.RPCServerStatus.state = 1
            if self.defaults.bool(forKey: "EnableLowSpeedMode") {
                self.lowSpeedModeOn()
            } else {
                self.lowSpeedModeOff()
            }
            if self.defaults.bool(forKey: "EnableNotificationWhenConnected") {
                MariaNotification.notification(title: "Aria2 Connected", details: "Aria2 server connected at \(MariaUserDefault.RPCUrl)")
            }
        }
        aria.rpc!.onDisconnect = {
            self.RPCServerStatus.state = 0
            if self.defaults.bool(forKey: "EnableNotificationWhenDisconnected") {
                MariaNotification.notification(title: "Aria2 Disconnected", details: "Aria2 server disconnected")
            }
        }
        
        aria.rpc!.downloadStarted = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenStarted") {
                MariaNotification.notification(title: "Download Started", details: "\(name) started.")
            }
        }
        aria.rpc!.downloadPaused = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenPaused") {
                MariaNotification.notification(title: "Download Paused", details: "\(name) paused.")
            }
        }
        aria.rpc!.downloadStopped = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenStopped") {
                MariaNotification.notification(title: "Download Stopoped", details: "\(name) stopped.")
            }
        }
        aria.rpc!.downloadCompleted = { (name, path) in
            if self.defaults.bool(forKey: "EnableNotificationWhenCompleted") {
                MariaNotification.actionNotification(identifier: "complete", title: "Download Completed", details: "\(name) completed.", userInfo: ["path": path as AnyObject])
            }
        }
        aria.rpc!.downloadError = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenError") {
                MariaNotification.notification(title: "Download Error", details: "Download task \(name) have an error.")
            }
        }
        
        
        aria.rpc!.globalSpeedLimitOK = { result in
            if result["result"].stringValue == "OK" {
                self.lowSpeedMode.state = 0
            }
        }
        aria.rpc!.lowSpeedLimitOK = { result in
            if result["result"].stringValue == "OK" {
                self.lowSpeedMode.state = 1
            }
        }
        
    }
    
    fileprivate func getStringBy(_ value: Double) -> String {
        if value > 1024 {
            return String(format: "%.2f MB/s", value / 1024.0)
        } else {
            return String(format: "%.2f KB/s", value)
        }
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        if let id = notification.identifier {
            switch id {
            case "complete":
                let path = notification.userInfo!["path"] as! String
                NSWorkspace.shared().open(URL(string: "file://\(path)")!)
            default:
                break
                
            }
        }
    }
}
