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
        
        let boolValue = sender.state == .off ? false : true
        
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
}

extension SettingsNotificationViewController {
    func userDefaultsInit() {
        notificationWhenStarted.state = defaults[.enableNotificationWhenStarted] ? .on : .off
        notificationWhenPaused.state = defaults[.enableNotificationWhenPaused] ? .on : .off
        notificationWhenStopped.state = defaults[.enableNotificationWhenStopped] ? .on : .off
        notificationWhenCompleted.state = defaults[.enableNotificationWhenCompleted] ? .on : .off
        notificationWhenError.state = defaults[.enableNotificationWhenError] ? .on : .off
        notificationWhenConnected.state = defaults[.enableNotificationWhenConnected] ? .on : .off
        notificationWhenDisconnected.state = defaults[.enableNotificationWhenDisconnected] ? .on : .off
    }
}
