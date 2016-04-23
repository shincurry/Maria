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
    
    let aria2: Aria2
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    
    var speedStatusTimer: NSTimer?
    
    override init() {
        if !defaults.boolForKey("IsNotFirstLaunch") {
            AppDelegate.userDefaultsInit()
        }

        if defaults.boolForKey("EnableAria2AutoLaunch") {
            let task = NSTask()
            let pipe = NSPipe()
            //            task.launchPath = "/bin/sh"
            let confPath = defaults.objectForKey("Aria2ConfPath") as! String
            let shFilePath = NSBundle.mainBundle().pathForResource("runAria2c", ofType: "sh")
            task.launchPath = shFilePath
            task.arguments = [confPath]
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()
            print("EnableAria2AutoLaunch")
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            print(String(data: data, encoding: NSUTF8StringEncoding))
        }
        aria2 = Aria2.shared
        super.init()
        
        
    }
    
    func applicationDidFinishLaunching(aNotification: NSNotification) {

        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        if defaults.boolForKey("EnableAutoConnectAria2") {
            aria2open()
        }
        
        statusItem.menu = statusMenu
        if defaults.boolForKey("EnableSpeedStatusBar") {
            enableSpeedStatusBar()
        } else {
            disableSpeedStatusBar()
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        aria2close()
        
        if defaults.boolForKey("EnableAria2AutoLaunch") {
            let task = NSTask()
            let pipe = NSPipe()
            let shFilePath = NSBundle.mainBundle().pathForResource("shutdownAria2c", ofType: "sh")
            task.launchPath = shFilePath
            task.standardOutput = pipe
            task.launch()
            task.waitUntilExit()
            print("EnableAria2AutoLaunch")
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            print(String(data: data, encoding: NSUTF8StringEncoding))

        }
    }
    
    // MARK: SpeedBar
    func enableSpeedStatusBar() {
        speedStatusTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(AppDelegate.updateSpeedStatus), userInfo: nil, repeats: true)
        if let button = statusItem.button {
            button.image = nil
        }
    }
    
    // Bug 取消状态栏速度显示 Unauthorized 态栏显示有问题
    func disableSpeedStatusBar() {
        speedStatusTimer?.invalidate()
        if let button = statusItem.button {
            button.image = NSImage(named: "Arrow")
            button.title = ""
        }
        
    }
    func updateSpeedStatus() {
        if aria2.isConnected {
            aria2.request(method: .getGlobalStat, params: "[]")
        }
    }
    
    
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var RPCServerStatus: NSMenuItem!
    @IBOutlet weak var lowSpeedMode: NSMenuItem!
    
    var quickDownloadLink = ""
    let pasteboard = NSPasteboard.generalPasteboard()
    @IBOutlet weak var quickDownloadMenuItem: NSMenuItem!
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
        let status = sender.state == 0 ? false : true
        if status {
            lowSpeedModeOff()
            defaults.setBool(false, forKey: "EnableLowSpeedMode")
        } else {
            lowSpeedModeOn()
            defaults.setBool(true, forKey: "EnableLowSpeedMode")
        }
        defaults.synchronize()
        
    }

    @IBAction func openWebUIApp(sender: NSMenuItem) {
        let path = defaults.objectForKey("WebAppPath") as! String
        if !path.isEmpty {
            NSWorkspace.sharedWorkspace().openURL(NSURL(string: path)!)
        }
    }
    
    
    func lowSpeedModeOff() {
        let limitDownloadSpeed = defaults.integerForKey("GlobalDownloadRate")
        let limitUploadSpeed = defaults.integerForKey("GlobalUploadRate")
        aria2.globalSpeedLimit(downloadSpeed: limitDownloadSpeed, uploadSpeed: limitUploadSpeed)
    }

    func lowSpeedModeOn() {
        let limitDownloadSpeed = defaults.integerForKey("LimitModeDownloadRate")
        let limitUploadSpeed = defaults.integerForKey("LimitModeUploadRate")
        aria2.lowSpeedLimit(downloadSpeed: limitDownloadSpeed, uploadSpeed: limitUploadSpeed)
    }
}

// MARK: - Aria2 configuration
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
            if self.defaults.boolForKey("EnableLowSpeedMode") {
                self.lowSpeedModeOn()
            } else {
                self.lowSpeedModeOff()
            }
            if self.defaults.boolForKey("EnableNotificationWhenConnected") {
                let baseHost = "http" + (self.defaults.boolForKey("SSLEnabled") ? "s" : "") + "://"
                let host = self.defaults.objectForKey("RPCServerHost") as! String
                let port = self.defaults.objectForKey("RPCServerPort") as! String
                let path = self.defaults.objectForKey("RPCServerPath") as! String
                let url = baseHost + host + ":" + port + path
                Aria2Notification.notification(title: "Aria2 Connected", details: "Aria2 server connected at \(url)")
            }
        }
        aria2.onDisconnect = {
            self.RPCServerStatus.state = 0
            if self.defaults.boolForKey("EnableNotificationWhenDisconnected") {
                Aria2Notification.notification(title: "Aria2 Disconnected", details: "Aria2 server disconnected")
            }
        }
        
        aria2.downloadStarted = { name in
            if self.defaults.boolForKey("EnableNotificationWhenStarted") {
                Aria2Notification.notification(title: "Download Started", details: "\(name) started.")
            }
        }
        aria2.downloadPaused = { name in
            if self.defaults.boolForKey("EnableNotificationWhenPaused") {
                Aria2Notification.notification(title: "Download Paused", details: "\(name) paused.")
            }
        }
        aria2.downloadStopped = { name in
            if self.defaults.boolForKey("EnableNotificationWhenStopped") {
                Aria2Notification.notification(title: "Download Stopoped", details: "\(name) stopped.")
            }
        }
        aria2.downloadCompleted = { (name, path) in
            if self.defaults.boolForKey("EnableNotificationWhenCompleted") {
                Aria2Notification.actionNotification(identifier: "complete", title: "Download Completed", details: "\(name) completed.", userInfo: ["path": path])
            }
        }
        aria2.downloadError = { name in
            if self.defaults.boolForKey("EnableNotificationWhenError") {
                Aria2Notification.notification(title: "Download Error", details: "Download task \(name) have an error.")
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
        
        
        aria2.getGlobalStatus = { results in
            if results["error"] != nil {
                if let button = self.statusItem.button {
                    button.title = "Unauthorized"
                }
                return
            }
            
            let result = results["result"]
            
            let downloadSpeed = Double(result["downloadSpeed"].stringValue)! / 1024.0
            let uploadSpeed = Double(result["uploadSpeed"].stringValue)! / 1024.0
            if let button = self.statusItem.button {
                button.title = "⬇︎ " + self.getStringBy(value: downloadSpeed) + " ⬆︎ " + self.getStringBy(value: uploadSpeed)
            }
        }
        
    }
    
    private func getStringBy(value value: Double) -> String {
        if value > 1024 {
            return String(format: "%.2f MB/s", value / 1024.0)
        } else {
            return String(format: "%.2f KB/s", value)
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

// MARK: - UserDefaults Init
extension AppDelegate {
    static func userDefaultsInit() {
        let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
        
        // First Launch
        defaults.setBool(true, forKey: "IsNotFirstLaunch")
        
        
        // Notification Settings
        defaults.setBool(true, forKey: "EnableNotificationWhenStarted")
        defaults.setBool(false, forKey: "EnableNotificationWhenStopped")
        defaults.setBool(false, forKey: "EnableNotificationWhenPaused")
        defaults.setBool(true, forKey: "EnableNotificationWhenCompleted")
        defaults.setBool(false, forKey: "EnableNotificationWhenError")
        
        defaults.setBool(false, forKey: "EnableNotificationWhenConnected")
        defaults.setBool(true, forKey: "EnableNotificationWhenDisconnected")
        
        // Bandwidth Settings
        defaults.setBool(false, forKey: "EnableLowSpeedMode")
        
        defaults.setInteger(0, forKey: "GlobalDownloadRate")
        defaults.setInteger(0, forKey: "GlobalUploadRate")
        defaults.setInteger(0, forKey: "LimitModeDownloadRate")
        defaults.setInteger(0, forKey: "LimitModeUploadRate")
        
        
        // General Settings
        defaults.setBool(false, forKey: "LaunchAtStartup")
        defaults.setObject("", forKey: "WebAppPath")
        defaults.setBool(false, forKey: "EnableSpeedStatusBar")
        
        
        // Aria2 Settings
        defaults.setBool(true, forKey: "EnableAutoConnectAria2")
        
        defaults.setObject("localhost", forKey: "RPCServerHost")
        defaults.setObject("6800", forKey: "RPCServerPort")
        defaults.setObject("/jsonrpc", forKey: "RPCServerPath")
        defaults.setObject("", forKey: "RPCServerSecret")
        defaults.setObject("", forKey: "RPCServerUsername")
        defaults.setObject("", forKey: "RPCServerPassword")
        defaults.setBool(false, forKey: "EnabledSSL")
        
        defaults.setBool(false, forKey: "EnableAria2AutoLaunch")
        defaults.setObject("", forKey: "Aria2ConfPath")
        
        defaults.synchronize()

    }
}

// MARK: - Download from pasteboard
extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(menu: NSMenu) {
        if let paste = pasteboard.stringForType(NSPasteboardTypeString) {
            let pattern = "^(https?://)([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([/\\w \\.-]*)*/?$"
            let matcher: RegexHelper
            do {
                matcher = try RegexHelper(pattern)
                if matcher.match(paste) {
                    quickDownloadMenuItem.hidden = false
                    quickDownloadLink = paste
                } else {
                    quickDownloadMenuItem.hidden = true
                }
            } catch {
                print(error)
            }
        }
    }
    @IBAction func downloadFromPasteboard(sender: NSMenuItem) {
        self.aria2.request(method: .addUri, params: "[\"\(quickDownloadLink)\"]")
    }
    
}


/**
 *	Copy by http://swifter.tips/regex/
 *  Author: @Onevcat
 */
struct RegexHelper {
    let regex: NSRegularExpression
    init(_ pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: .CaseInsensitive)
    }
    func match(input: String) -> Bool {
        let matches = regex.matchesInString(input, options: [], range: NSMakeRange(0, input.characters.count))
        return matches.count > 0
    }
}