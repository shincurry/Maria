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
    }
    
    @IBOutlet weak var notificationWhenStarted: NSButton!
    @IBOutlet weak var notificationWhenStopped: NSButton!
    @IBOutlet weak var notificationWhenPaused: NSButton!
    @IBOutlet weak var notificationWhenCompleted: NSButton!
    @IBOutlet weak var notificationWhenError: NSButton!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBAction func switchNotification(sender: NSButton) {
        print(sender.state)
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
        default:
            break
        }
        defaults.setBool(boolValue, forKey: key)
    }
}
