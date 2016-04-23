//
//  SettingsAria2ViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/23.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsAria2ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    @IBOutlet weak var enableAria2AutoLaunch: NSButton!
    @IBOutlet weak var aria2ConfPath: NSTextField!
    
    @IBAction func switchOptions(sender: NSButton) {
        let boolValue = sender.state == 1 ? true : false
        print(boolValue)
        switch sender {
        case enableAria2AutoLaunch:
            defaults.setBool(boolValue, forKey: "EnableAria2AutoLaunch")
        default:
            break
        }
    }
    
    @IBAction func finishEditing(sender: NSTextField) {
        defaults.setObject(sender.stringValue, forKey: "Aria2ConfPath")
        defaults.synchronize()
    }
    
}


extension SettingsAria2ViewController {
    func userDefaultsInit() {
        enableAria2AutoLaunch.state = defaults.boolForKey("EnableAria2AutoLaunch") ? 1 : 0
        if let value = defaults.objectForKey("Aria2ConfPath") as? String {
            aria2ConfPath.stringValue = value
        }
    }
}
