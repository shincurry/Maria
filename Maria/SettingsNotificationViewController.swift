//
//  SettingsNotificationViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import SwiftyUserDefaults

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
    
    
    let defaults = MariaUserDefault.auto
    
    @IBAction func switchNotification(_ sender: NSButton) {
        let boolValue = sender.state == 0 ? false : true
        
        var key = DefaultsKeys.enableNotificationWhenError
        switch sender {
        case notificationWhenStarted:
            key = .enableNotificationWhenStarted
        case notificationWhenStopped:
            key = .enableNotificationWhenStopped
        case notificationWhenPaused:
            key = .enableNotificationWhenPaused
        case notificationWhenCompleted:
            key = .enableNotificationWhenCompleted
        case notificationWhenError:
            key = .enableNotificationWhenError
        case notificationWhenConnected:
            key = .enableNotificationWhenConnected
        case notificationWhenDisconnected:
            key = .enableNotificationWhenDisconnected
        default:
            break
        }
        defaults[key] = boolValue
        defaults.synchronize()
    }
    
    func checkButtonState(by value: Bool) -> Int {
        return value ? 1 : 0
    }
}

extension SettingsNotificationViewController {
    func userDefaultsInit() {
        notificationWhenStarted.state = checkButtonState(by: defaults[.enableNotificationWhenStarted])
        notificationWhenPaused.state = checkButtonState(by: defaults[.enableNotificationWhenStopped])
        notificationWhenStopped.state = checkButtonState(by: defaults[.enableNotificationWhenPaused])
        notificationWhenCompleted.state = checkButtonState(by: defaults[.enableNotificationWhenCompleted])
        notificationWhenError.state = checkButtonState(by: defaults[.enableNotificationWhenError])
        notificationWhenConnected.state = checkButtonState(by: defaults[.enableNotificationWhenConnected])
        notificationWhenDisconnected.state = checkButtonState(by: defaults[.enableNotificationWhenDisconnected])
    }
}
