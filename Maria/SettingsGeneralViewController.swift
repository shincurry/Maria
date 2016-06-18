//
//  SettingsGeneralViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/16.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsGeneralViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = UserDefaults(suiteName: "group.windisco.maria")!
    
    // little bug -- use a new thread?
    @IBOutlet weak var enableSpeedStatusBar: NSButton!
    
    @IBOutlet weak var webAppPath: NSTextField!
    
    
    @IBAction func switchOptions(_ sender: NSButton) {
        let boolValue = sender.state == 1 ? true : false
        switch sender {
        case enableSpeedStatusBar:
            defaults.set(boolValue, forKey: "EnableSpeedStatusBar")
        default:
            break
        }
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        
        if boolValue {
            appDelegate.enableSpeedStatusBar()
        } else {
            appDelegate.disableSpeedStatusBar()
        }
    }
    
    @IBAction func finishEditing(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: "WebAppPath")
        defaults.synchronize()
    }
}

extension SettingsGeneralViewController {
    func userDefaultsInit() {
        if let value = defaults.object(forKey: "WebAppPath") as? String {
            webAppPath.stringValue = value
        }
        enableSpeedStatusBar.state = defaults.bool(forKey: "EnableSpeedStatusBar") ? 1 : 0
    }
}


