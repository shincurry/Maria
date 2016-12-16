//
//  AppDelegate.swift
//  Maria
//
//  Created by ShinCurry on 16/4/13.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2RPC
import SwiftyJSON

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    var maria = Maria.shared
    let defaults = MariaUserDefault.auto
    
    var statusItem: NSStatusItem?
    
    var speedStatusTimer: Timer?
    var dockTileTimer: Timer?
    
    override init() {
        if !MariaUserDefault.main[.isNotFirstLaunch] {
            MariaUserDefault.initMain()
            MariaUserDefault.initExternal()
            MariaUserDefault.initBuiltIn()
        }
        
        if !MariaUserDefault.main[.useEmbeddedAria2] {
            if defaults[.enableAria2AutoLaunch] {
                let task = Process()
                let confPath = defaults[.aria2ConfPath]!
                let shFilePath = Bundle.main
                    .path(forResource: "runAria2c", ofType: "sh")
                task.launchPath = shFilePath
                task.arguments = [confPath]
                task.launch()
                task.waitUntilExit()
            }
        }
        
        super.init()
        
        if defaults[.enableAutoConnectAria2] {
            maria.rpc?.connect()
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        NSUserNotificationCenter.default.delegate = self

        if defaults[.enableStatusBarMode] {
            statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
            statusItem?.button?.action = #selector(AppDelegate.menuClicked)
            statusItem?.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        
        if defaults[.enableStatusBarMode] && defaults[.enableSpeedStatusBar] {
            enableSpeedStatusBar()
        } else {
            disableSpeedStatusBar()
        }

        for window in NSApp.windows {
            window.canHide = false
        }
        
        if defaults[.enableStatusBarMode] {
            disableDockIcon()
        } else {
            enableDockIcon()
        }
        
        NSApp.dockTile.contentView = dockTileView
        dockTileTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateDockTile), userInfo: nil, repeats: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        aria2close()
        if !MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
            if defaults[.enableAria2AutoLaunch] {
                let task = Process()
                let pipe = Pipe()
                let shFilePath = Bundle.main.path(forResource: "shutdownAria2c", ofType: "sh")
                task.launchPath = shFilePath
                task.standardOutput = pipe
                task.launch()
                task.waitUntilExit()
                print("EnableAria2AutoLaunch")
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                print(String(data: data, encoding: .utf8)!)
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
        if let button = statusItem?.button {
            button.image = nil
        }
    }
    
    func disableSpeedStatusBar() {
        speedStatusTimer?.invalidate()
        if let button = statusItem?.button {
            button.image = NSImage(named: "Arrow")
            button.title = ""
        }
        
    }
    
    func menuClicked(sender: NSStatusBarButton) {
        if NSApp.currentEvent!.type == NSEventType.rightMouseUp {
            statusItem?.popUpMenu(statusMenu)
        } else {
            if NSApp.isActive {
               statusItem?.popUpMenu(statusMenu)
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
    
    func updateDockTile() {
        maria.rpc?.onGlobalStatus = { status in
            if !MariaUserDefault.auto[.enableStatusBarMode] {
                if status.speed!.download == 0 {
                    self.dockTileView.badgeBox.isHidden = true
                } else {
                    self.dockTileView.badgeBox.isHidden = false
                    self.dockTileView.badgeTitle.stringValue = status.speed!.downloadIntString
                }
                NSApp.dockTile.display()
            }
        }
        maria.rpc?.getGlobalStatus()
    }
    
    func updateSpeedStatus() {
        if maria.rpc?.status == .connected {
            maria.rpc?.getGlobalStatus()
        }
        
        maria.rpc?.onGlobalStatus = { status in
            if let button = self.statusItem?.button {
                button.title = "⬇︎ " + status.speed!.downloadString + " ⬆︎ " + status.speed!.uploadString
            }
        }
    }
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var RPCServerStatus: NSMenuItem!
    @IBOutlet weak var lowSpeedMode: NSMenuItem!
    
    @IBOutlet weak var dockTileView: DockTileView!
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
            defaults[.enableLowSpeedMode] = false
        } else {
            lowSpeedModeOn()
            defaults[.enableLowSpeedMode] = true
        }
        defaults.synchronize()
    }
    
    func lowSpeedModeOff() {
        let limitDownloadSpeed = defaults[.globalDownloadRate]
        let limitUploadSpeed = defaults[.globalUploadRate]
        maria.rpc?.globalSpeedLimit(download: limitDownloadSpeed, upload: limitUploadSpeed)
    }
    func lowSpeedModeOn() {
        let limitDownloadSpeed = defaults[.limitModeDownloadRate]
        let limitUploadSpeed = defaults[.limitModeUploadRate]
        maria.rpc?.lowSpeedLimit(download: limitDownloadSpeed, upload: limitUploadSpeed)
    }

    @IBAction func openWebUIApp(_ sender: NSMenuItem) {
        if let path = defaults[.webAppPath], !path.isEmpty {
            NSWorkspace.shared().open(URL(fileURLWithPath: path))
        }
    }
}

// MARK: - Aria2 Config
extension AppDelegate: NSUserNotificationCenterDelegate {
    func aria2open() {
        aria2configure()
        maria.rpc?.connect()
        RPCServerStatus.state = 1
    }
    
    func aria2close() {
        maria.rpc?.disconnect()
    }
    
    func aria2configure() {
        maria.rpc?.onConnect = {
            self.RPCServerStatus.state = 1
            if self.defaults[.enableLowSpeedMode] {
                self.lowSpeedModeOn()
            } else {
                self.lowSpeedModeOff()
            }
            if self.defaults[.enableNotificationWhenConnected] {
                MariaNotification.notification(title: "Aria2 Connected", details: "Aria2 server connected at \(MariaUserDefault.RPCUrl)")
            }
        }
        maria.rpc?.onDisconnect = {
            self.RPCServerStatus.state = 0
            if self.defaults[.enableNotificationWhenDisconnected] {
                MariaNotification.notification(title: "Aria2 Disconnected", details: "Aria2 server disconnected")
            }
        }
        
        maria.rpc?.downloadStarted = { name in
            if self.defaults[.enableNotificationWhenStarted] {
                MariaNotification.notification(title: "Download Started", details: "\(name) started.")
            }
        }
        maria.rpc?.downloadPaused = { name in
            if self.defaults[.enableNotificationWhenPaused] {
                MariaNotification.notification(title: "Download Paused", details: "\(name) paused.")
            }
        }
        maria.rpc?.downloadStopped = { name in
            if self.defaults[.enableNotificationWhenStopped] {
                MariaNotification.notification(title: "Download Stopoped", details: "\(name) stopped.")
            }
        }
        maria.rpc?.downloadCompleted = { (name, path) in
            if self.defaults[.enableNotificationWhenCompleted] {
                MariaNotification.actionNotification(identifier: "complete", title: "Download Completed", details: "\(name) completed.", userInfo: ["path": path as AnyObject])
            }
        }
        maria.rpc?.downloadError = { name in
            if self.defaults[.enableNotificationWhenError] {
                MariaNotification.notification(title: "Download Error", details: "Download task \(name) have an error.")
            }
        }
        
        
        maria.rpc?.onGlobalSpeedLimitOK = { flag in
            if flag {
                self.lowSpeedMode.state = 0
                if let controller = NSApp.mainWindow?.windowController as? MainWindowController {
                    controller.lowSpeedModeButton.state = 0
                    if let button = controller.touchBarLowSpeedButton {
                        button.state = 0
                    }
                }
            }
        }
        maria.rpc?.onLowSpeedLimitOK = { flag in
            if flag {
                self.lowSpeedMode.state = 1
                if let controller = NSApp.mainWindow?.windowController as? MainWindowController {
                    controller.lowSpeedModeButton.state = 1
                    if let button = controller.touchBarLowSpeedButton {
                        button.state = 1
                    }
                }
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
