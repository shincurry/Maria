//
//  SettingsNotificationViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsNotificationViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    @IBOutlet weak var notificationWhenStarted: NSButton!
    @IBOutlet weak var notificationWhenStopped: NSButton!
    @IBOutlet weak var notificationWhenPaused: NSButton!
    @IBOutlet weak var notificationWhenCompleted: NSButton!
    @IBOutlet weak var notificationWhenError: NSButton!
    
    @IBOutlet weak var notificationWhenConnected: NSButton!
    @IBOutlet weak var notificationWhenDisconnected: NSButton!
    
    
    let defaults = UserDefaults(suiteName: "525R2U87NG.group.windisco.maria")!
    
    @IBAction func switchNotification(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        
        var key = ""
        switch sender {
        case notificationWhenStarted:
            key = "EnableNotificationWhenStarted"
        case notificationWhenStopped:
            key = "EnableNotificationWhenStopped"
        case notificationWhenPaused:
            key = "EnableNotificationWhenPaused"
        case notificationWhenCompleted:
            key = "EnableNotificationWhenCompleted"
        case notificationWhenError:
            key = "EnableNotificationWhenError"
        case notificationWhenConnected:
            key = "EnableNotificationWhenConnected"
        case notificationWhenDisconnected:
            key = "EnableNotificationWhenDisconnected"
        default:
            break
        }
        defaults.set(boolValue, forKey: key)
        defaults.synchronize()
    }
    
    func checkButtonState(by value: Bool) -> Int {
        return value ? 1 : 0
    }
}

extension SettingsNotificationViewController {
    func userDefaultsInit() {
        notificationWhenStarted.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenStarted"))
        notificationWhenPaused.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenStopped"))
        notificationWhenStopped.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenPaused"))
        notificationWhenCompleted.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenCompleted"))
        notificationWhenError.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenError"))
        
        notificationWhenConnected.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenConnected"))
        notificationWhenDisconnected.state = checkButtonState(by: defaults.bool(forKey: "EnableNotificationWhenDisconnected"))
    }
}
