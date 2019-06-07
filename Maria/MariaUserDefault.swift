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
    static let enableNotificationWhenStarted = DefaultsKey<Bool>("EnableNotificationWhenStarted", defaultValue: false)
    static let enableNotificationWhenStopped = DefaultsKey<Bool>("EnableNotificationWhenStopped", defaultValue: false)
    static let enableNotificationWhenPaused = DefaultsKey<Bool>("EnableNotificationWhenPaused", defaultValue: false)
    static let enableNotificationWhenCompleted = DefaultsKey<Bool>("EnableNotificationWhenCompleted", defaultValue: false)
    static let enableNotificationWhenError = DefaultsKey<Bool>("EnableNotificationWhenError", defaultValue: false)
    static let enableNotificationWhenConnected = DefaultsKey<Bool>("EnableNotificationWhenConnected", defaultValue: false)
    static let enableNotificationWhenDisconnected = DefaultsKey<Bool>("EnableNotificationWhenDisconnected", defaultValue: false)
    
    // Bandwidth Settings
    static let enableLowSpeedMode = DefaultsKey<Bool>("EnableLowSpeedMode", defaultValue: false)
    static let globalDownloadRate = DefaultsKey<Int>("GlobalDownloadRate", defaultValue: 0)
    static let globalUploadRate = DefaultsKey<Int>("GlobalUploadRate", defaultValue: 0)
    static let limitModeDownloadRate = DefaultsKey<Int>("LimitModeDownloadRate", defaultValue: 0)
    static let limitModeUploadRate = DefaultsKey<Int>("LimitModeUploadRate", defaultValue: 0)
    
    // General Settings
    static let launchAtStartup = DefaultsKey<Bool>("LaunchAtStartup", defaultValue: false)
    static let webAppPath = DefaultsKey<String?>("WebAppPath")
    static let enableSpeedStatusBar = DefaultsKey<Bool>("EnableSpeedStatusBar", defaultValue: false)
    static let enableStatusBarMode = DefaultsKey<Bool>("EnableStatusBarMode", defaultValue: false)

    // Aria2 Settings
    static let enableAutoConnectAria2 = DefaultsKey<Bool>("EnableAutoConnectAria2", defaultValue: false)
    static let rpcServerHost = DefaultsKey<String?>("RPCServerHost")
    static let rpcServerUsername = DefaultsKey<String?>("RPCServerUsername")
    static let rpcServerPassword = DefaultsKey<String?>("RPCServerPassword")
    static let rpcServerPort = DefaultsKey<String?>("RPCServerPort")
    static let rpcServerPath = DefaultsKey<String?>("RPCServerPath")
    static let rpcServerSecret = DefaultsKey<String?>("RPCServerSecret")
    static let rpcServerEnabledSSL = DefaultsKey<Bool>("RPCServerEnabledSSL", defaultValue: false)
    static let enableAria2AutoLaunch = DefaultsKey<Bool>("EnableAria2AutoLaunch", defaultValue: false)
    static let aria2ConfPath = DefaultsKey<String?>("Aria2ConfPath")
    
    // Today Settings
    static let todayTasksNumber = DefaultsKey<Int>("TodayTasksNumber", defaultValue: 0)
    static let todayEnableTasksSortedByProgress = DefaultsKey<Bool>("TodayEnableTasksSortedByProgress", defaultValue: false)
    
    // Main settings
    static let isNotFirstLaunch = DefaultsKey<Bool>("IsNotFirstLaunch", defaultValue: false)
    static let useEmbeddedAria2 = DefaultsKey<Bool>("UseEmbeddedAria2", defaultValue: true)
    
    static let enableYouGet = DefaultsKey<Bool>("EnableYouGet", defaultValue: false)
}

class MariaUserDefault {
    static var main = UserDefaults(suiteName: "group.windisco.maria.main")!
    static var external = UserDefaults(suiteName: "group.windisco.maria.external")!
    static var builtIn = UserDefaults(suiteName: "group.windisco.maria.builtin")!
    
    static var auto: UserDefaults {
        get {
            if MariaUserDefault.main[.useEmbeddedAria2] {
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
    
    fileprivate static func initShared(defaults: UserDefaults) {
        
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
        defaults[.enableStatusBarMode] = false
        
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
