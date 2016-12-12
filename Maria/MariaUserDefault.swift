//
//  MariaUserDefault.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKeys {
    // Notification Settings
    static let enableNotificationWhenStarted = DefaultsKey<Bool>("EnableNotificationWhenStarted")
    static let enableNotificationWhenStopped = DefaultsKey<Bool>("EnableNotificationWhenStopped")
    static let enableNotificationWhenPaused = DefaultsKey<Bool>("EnableNotificationWhenPaused")
    static let enableNotificationWhenCompleted = DefaultsKey<Bool>("EnableNotificationWhenCompleted")
    static let enableNotificationWhenError = DefaultsKey<Bool>("EnableNotificationWhenError")
    static let enableNotificationWhenConnected = DefaultsKey<Bool>("EnableNotificationWhenConnected")
    static let enableNotificationWhenDisconnected = DefaultsKey<Bool>("EnableNotificationWhenDisconnected")
    
    // Bandwidth Settings
    static let enableLowSpeedMode = DefaultsKey<Bool>("EnableLowSpeedMode")
    static let globalDownloadRate = DefaultsKey<Int>("GlobalDownloadRate")
    static let globalUploadRate = DefaultsKey<Int>("GlobalUploadRate")
    static let limitModeDownloadRate = DefaultsKey<Int>("LimitModeDownloadRate")
    static let limitModeUploadRate = DefaultsKey<Int>("LimitModeUploadRate")
    
    // General Settings
    static let launchAtStartup = DefaultsKey<Bool>("LaunchAtStartup")
    static let webAppPath = DefaultsKey<String?>("WebAppPath")
    static let enableSpeedStatusBar = DefaultsKey<Bool>("EnableSpeedStatusBar")
    static let enableDockIcon = DefaultsKey<Bool>("EnableDockIcon")

    // Aria2 Settings
    static let enableAutoConnectAria2 = DefaultsKey<Bool>("EnableAutoConnectAria2")
    static let rpcServerHost = DefaultsKey<String?>("RPCServerHost")
    static let rpcServerUsername = DefaultsKey<String?>("RPCServerUsername")
    static let rpcServerPassword = DefaultsKey<String?>("RPCServerPassword")
    static let rpcServerPort = DefaultsKey<String?>("RPCServerPort")
    static let rpcServerPath = DefaultsKey<String?>("RPCServerPath")
    static let rpcServerSecret = DefaultsKey<String?>("RPCServerSecret")
    static let rpcServerEnabledSSL = DefaultsKey<Bool>("RPCServerEnabledSSL")
    static let enableAria2AutoLaunch = DefaultsKey<Bool>("EnableAria2AutoLaunch")
    static let aria2ConfPath = DefaultsKey<String?>("Aria2ConfPath")
    
    // Today Settings
    static let todayTasksNumber = DefaultsKey<Int>("TodayTasksNumber")
    static let todayEnableTasksSortedByProgress = DefaultsKey<Bool>("TodayEnableTasksSortedByProgress")
    
    // Main settings
    static let isNotFirstLaunch = DefaultsKey<Bool>("IsNotFirstLaunch")
    static let useEmbeddedAria2 = DefaultsKey<Bool>("UseEmbeddedAria2")
    
    static let enableYouGet = DefaultsKey<Bool>("EnableYouGet")
}

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
        defaults[.isNotFirstLaunch] = true
        defaults[.useEmbeddedAria2] = false
    }
    
    static func initExternal() {
        MariaUserDefault.initShared(defaults: MariaUserDefault.external)
        
        let defaults = MariaUserDefault.external
        defaults[.rpcServerPort] = "6800"
        defaults[.rpcServerPath] = "/jsonrpc"
        defaults[.rpcServerSecret] = ""
    }
    static func initBuiltIn() {
        MariaUserDefault.initShared(defaults: MariaUserDefault.builtIn)
        
        let defaults = MariaUserDefault.builtIn
        defaults[.rpcServerPort] = "6789"
        defaults[.rpcServerPath] = "/jsonrpc"
        defaults[.rpcServerSecret] = "maria.rpc.2016"
    }
    
    private static func initShared(defaults: UserDefaults) {
        
        // Notification Settings
        defaults[.enableNotificationWhenStarted] = true
        defaults[.enableNotificationWhenStopped] = false
        defaults[.enableNotificationWhenPaused] = false
        defaults[.enableNotificationWhenCompleted] = true
        defaults[.enableNotificationWhenError] = false
        defaults[.enableNotificationWhenConnected] = false
        defaults[.enableNotificationWhenDisconnected] = true
        
        // Bandwidth Settings
        defaults[.enableLowSpeedMode] = false
        defaults[.globalDownloadRate] = 0
        defaults[.globalUploadRate] = 0
        defaults[.limitModeDownloadRate] = 0
        defaults[.limitModeUploadRate] = 0
        
        // General Settings
        defaults[.launchAtStartup] = false
        defaults[.webAppPath] = ""
        defaults[.enableSpeedStatusBar] = false
        defaults[.enableDockIcon] = true
        
        // Aria2 Settings
        defaults[.enableAutoConnectAria2] = true
        defaults[.rpcServerHost] = "localhost"
        defaults[.rpcServerUsername] = ""
        defaults[.rpcServerPassword] = ""
        defaults[.rpcServerEnabledSSL] = false
        defaults[.enableAria2AutoLaunch] = false
        defaults[.aria2ConfPath] = ""
        
        // Today Settings
        defaults[.todayTasksNumber] = 5
        defaults[.todayEnableTasksSortedByProgress] = false
        
        defaults[.enableYouGet] = false
        
        defaults.synchronize()
    }
    
    static var RPCUrl: String {
        get {
            
            let defaults = MariaUserDefault.auto
            var url = "http\(defaults[.rpcServerEnabledSSL] ? "s" : "")://"
            if let value = defaults[.rpcServerHost] {
                url += value
            }
            url += ":"
            if let value = defaults[.rpcServerPort] {
                url += value
            }
            if let value = defaults[.rpcServerPath] {
                url += value
            }
            return url
        }
    }

}
