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
    var aria2Core: Aria2Core?

    let defaults = MariaUserDefault.auto
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var speedStatusTimer: Timer?
    
    override init() {
        if !MariaUserDefault.main.bool(forKey: "IsNotFirstLaunch") {
            MariaUserDefault.initMain()
            MariaUserDefault.initExternal()
            MariaUserDefault.initBuildIn()
        }
        
        if MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
            let resourcePath = Bundle.main.resourcePath!
            let conf = resourcePath + "/aria2.conf"
            let session = resourcePath + "/aria2.session"
            
            if !FileManager.default.fileExists(atPath: conf) {
                do {
                    let defaultConfPath = Bundle.main.path(forResource: "aria2.Maria", ofType: "conf")!
                    try FileManager.default.copyItem(atPath: defaultConfPath, toPath: conf)
                    let config = AriaConfig(filePath: conf)
                    config.load()
                    config.data.append(("dir", "\(NSHomeDirectory())/Downloads"))
                    config.data.append(("input-file", "\(Bundle.main.resourcePath!)/aria2.session"))
                    config.data.append(("save-session", "\(Bundle.main.resourcePath!)/aria2.session"))
                    config.save()
                    if !FileManager.default.fileExists(atPath: session) {
                        FileManager.default.createFile(atPath: session, contents: nil, attributes: nil)
                    }
                    defaults.set("6789", forKey: "RPCServerPort")
                    defaults.set("maria.rpc.2016", forKey: "RPCServerSecret")
                    defaults.set(conf, forKey: "Aria2ConfPath")
                } catch {
                    print(error)
                }
            }
            
            if let path = Bundle.main.path(forResource: "aria2.Maria", ofType: "conf") {
                let config = AriaConfig(filePath: path)
                config.load()
                aria2Core = Aria2Core(options: config.dict)
            }
        } else {
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
        
        if let value = defaults.object(forKey: "RPCServerHost") as? String {
            aria2.host = value
        }
        if let value = defaults.object(forKey: "RPCServerPort") as? String {
            aria2.port = value
        }
        if let value = defaults.object(forKey: "RPCServerPath") as? String {
            aria2.path = value
        }
        if let value = defaults.object(forKey: "RPCServerSecret") as? String {
            aria2.secret = value
        }
        aria2.baseHost = "http" + (defaults.bool(forKey: "SSLEnabled") ? "s" : "") + "://"
        aria2.initSocket()
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
        if defaults.bool(forKey: "EnableAria2AutoLaunch") {
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
        if aria2.status == .connected {
            aria2.getGlobalStatus()
        }
        aria2.onGlobalStatus = { status in
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
        aria2.globalSpeedLimit(download: limitDownloadSpeed, upload: limitUploadSpeed)
    }

    func lowSpeedModeOn() {
        let limitDownloadSpeed = defaults.integer(forKey: "LimitModeDownloadRate")
        let limitUploadSpeed = defaults.integer(forKey: "LimitModeUploadRate")
        if let controller = NSApp.mainWindow?.windowController as? MainWindowController {
            controller.lowSpeedModeOn()
        }
        aria2.lowSpeedLimit(download: limitDownloadSpeed, upload: limitUploadSpeed)
    }
}

// MARK: - Aria2 Config
extension AppDelegate: NSUserNotificationCenterDelegate {
    func aria2open() {
        aria2configure()
        aria2.connect()
        RPCServerStatus.state = 1
    }
    
    func aria2close() {
        aria2.disconnect()
    }
    
    func aria2configure() {
        aria2.onConnect = {
            self.RPCServerStatus.state = 1
            if self.defaults.bool(forKey: "EnableLowSpeedMode") {
                self.lowSpeedModeOn()
            } else {
                self.lowSpeedModeOff()
            }
            if self.defaults.bool(forKey: "EnableNotificationWhenConnected") {
                MariaNotification.notification(title: "Aria2 Connected", details: "Aria2 server connected at \(self.aria2.url)")
            }
        }
        aria2.onDisconnect = {
            self.RPCServerStatus.state = 0
            if self.defaults.bool(forKey: "EnableNotificationWhenDisconnected") {
                MariaNotification.notification(title: "Aria2 Disconnected", details: "Aria2 server disconnected")
            }
        }
        
        aria2.downloadStarted = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenStarted") {
                MariaNotification.notification(title: "Download Started", details: "\(name) started.")
            }
        }
        aria2.downloadPaused = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenPaused") {
                MariaNotification.notification(title: "Download Paused", details: "\(name) paused.")
            }
        }
        aria2.downloadStopped = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenStopped") {
                MariaNotification.notification(title: "Download Stopoped", details: "\(name) stopped.")
            }
        }
        aria2.downloadCompleted = { (name, path) in
            if self.defaults.bool(forKey: "EnableNotificationWhenCompleted") {
                MariaNotification.actionNotification(identifier: "complete", title: "Download Completed", details: "\(name) completed.", userInfo: ["path": path as AnyObject])
            }
        }
        aria2.downloadError = { name in
            if self.defaults.bool(forKey: "EnableNotificationWhenError") {
                MariaNotification.notification(title: "Download Error", details: "Download task \(name) have an error.")
            }
        }
        
        
        aria2.globalSpeedLimitOK = { result in
            if result["result"].stringValue == "OK" {
                self.lowSpeedMode.state = 0
            }
        }
        aria2.lowSpeedLimitOK = { result in
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
