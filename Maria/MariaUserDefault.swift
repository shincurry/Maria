//
//  MariaUserDefault.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

class MariaUserDefault {
    static var main = UserDefaults(suiteName: "group.windisco.maria.main")!
    static var external = UserDefaults(suiteName: "group.windisco.maria.external")!
    static var builtIn = UserDefaults(suiteName: "group.windisco.maria.builtin")!
    
    static var auto: UserDefaults {
        get {
            if MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
                return builtIn
            } else {
                return external
            }
        }
    }
    
    static func initMain() {
        let defaults = main
        defaults.set(true, forKey: "IsNotFirstLaunch")
        defaults.set(false, forKey: "UseEmbeddedAria2")
    }
    
    static func initExternal() {
        MariaUserDefault.initShared(defaults: MariaUserDefault.external)
        
        let defaults = MariaUserDefault.external
        defaults.set("6800", forKey: "RPCServerPort")
        defaults.set("/jsonrpc", forKey: "RPCServerPath")
        defaults.set("", forKey: "RPCServerSecret")
    }
    static func initBuiltIn() {
        MariaUserDefault.initShared(defaults: MariaUserDefault.builtIn)
        
        let defaults = MariaUserDefault.builtIn
        defaults.set("6789", forKey: "RPCServerPort")
        defaults.set("/jsonrpc", forKey: "RPCServerPath")
        defaults.set("maria.rpc.2016", forKey: "RPCServerSecret")
    }
    
    private static func initShared(defaults: UserDefaults) {
        
        // Notification Settings
        defaults.set(true, forKey: "EnableNotificationWhenStarted")
        defaults.set(false, forKey: "EnableNotificationWhenStopped")
        defaults.set(false, forKey: "EnableNotificationWhenPaused")
        defaults.set(true, forKey: "EnableNotificationWhenCompleted")
        defaults.set(false, forKey: "EnableNotificationWhenError")
        
        defaults.set(false, forKey: "EnableNotificationWhenConnected")
        defaults.set(true, forKey: "EnableNotificationWhenDisconnected")
        
        // Bandwidth Settings
        defaults.set(false, forKey: "EnableLowSpeedMode")
        
        defaults.set(0, forKey: "GlobalDownloadRate")
        defaults.set(0, forKey: "GlobalUploadRate")
        defaults.set(0, forKey: "LimitModeDownloadRate")
        defaults.set(0, forKey: "LimitModeUploadRate")
        
        
        // General Settings
        defaults.set(false, forKey: "LaunchAtStartup")
        defaults.set("", forKey: "WebAppPath")
        defaults.set(false, forKey: "EnableSpeedStatusBar")
        defaults.set(true, forKey: "EnableDockIcon")
        
        
        // Aria2 Settings
        defaults.set(true, forKey: "EnableAutoConnectAria2")
        
        defaults.set("localhost", forKey: "RPCServerHost")
        defaults.set("", forKey: "RPCServerUsername")
        defaults.set("", forKey: "RPCServerPassword")
        defaults.set(false, forKey: "RPCServerEnabledSSL")
        
        defaults.set(false, forKey: "EnableAria2AutoLaunch")
        defaults.set("", forKey: "Aria2ConfPath")
        
        
        
        // Today Settings
        defaults.set(5, forKey: "TodayTasksNumber")
        defaults.set(false, forKey: "TodayEnableTasksSortedByProgress")
        
        defaults.synchronize()
    }
    
    static var RPCUrl: String {
        get {
            let defaults = MariaUserDefault.auto
            var url = "http\(defaults.bool(forKey: "RPCServerEnabledSSL") ? "s" : "")://"
            if let value = defaults.object(forKey: "RPCServerHost") as? String {
                url += value
            }
            url += ":"
            if let value = defaults.object(forKey: "RPCServerPort") as? String {
                url += value
            }
            if let value = defaults.object(forKey: "RPCServerPath") as? String {
                url += value
            }
            return url
        }
    }

}
