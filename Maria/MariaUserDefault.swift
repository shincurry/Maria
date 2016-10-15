//
//  MariaUserDefault.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

let TeamID = "525R2U87NG"

class MariaUserDefault {
    static var main = UserDefaults(suiteName: "\(TeamID).group.windisco.maria.main")!
    
    static var auto: UserDefaults {
        get {
            if MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
                return buildin
            } else {
                return external
            }
        }
    }
    static var external = UserDefaults(suiteName: "\(TeamID).group.windisco.maria.external")!
    static var buildin = UserDefaults(suiteName: "\(TeamID).group.windisco.maria.buildin")!

    
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
    static func initBuildIn() {
        MariaUserDefault.initShared(defaults: MariaUserDefault.buildin)
        
        let defaults = MariaUserDefault.buildin
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
        defaults.set(false, forKey: "EnabledSSL")
        
        defaults.set(false, forKey: "EnableAria2AutoLaunch")
        defaults.set("", forKey: "Aria2ConfPath")
        
        
        
        // Today Settings
        defaults.set(5, forKey: "TodayTasksNumber")
        defaults.set(false, forKey: "TodayEnableTasksSortedByProgress")
        
        defaults.synchronize()
    }
}
