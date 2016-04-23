//
//  SettingsMariaViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2

class SettingsBandwidthViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    let aria2 = Aria2.shared
    
    
    @IBOutlet weak var globalDownloadRate: NSTextField!
    @IBOutlet weak var globalUploadRate: NSTextField!

    @IBOutlet weak var limitModeDownloadRate: NSTextField!
    @IBOutlet weak var limitModeUploadRate: NSTextField!
    
}

extension SettingsBandwidthViewController {
    
    @IBAction func finishEditing(sender: NSTextField) {
        var key = ""
        switch sender {
        case globalDownloadRate:
            key = "GlobalDownloadRate"
        case globalUploadRate:
            key = "GlobalUploadRate"
        case limitModeDownloadRate:
            key = "LimitModeDownloadRate"
        case limitModeUploadRate:
            key = "LimitModeUploadRate"
        default:
            break
        }
        
        if let intValue = Int(sender.stringValue) {
            defaults.setInteger(intValue, forKey: key)
            defaults.synchronize()
        } else {
            sender.stringValue = "\(defaults.integerForKey(key))"
        }
        
        
        
        if defaults.boolForKey("EnableLowSpeedMode") {
            if sender == limitModeDownloadRate || sender == limitModeUploadRate {
                let downloadSpeed = defaults.integerForKey("LimitModeDownloadRate")
                let uploadSpeed = defaults.integerForKey("LimitModeUploadRate")
                aria2.lowSpeedLimit(downloadSpeed: downloadSpeed, uploadSpeed: uploadSpeed)
            }
        }
        

    }
}

extension SettingsBandwidthViewController {
    func userDefaultsInit() {
        globalDownloadRate.stringValue = "\(defaults.integerForKey("GlobalDownloadRate"))"
        globalUploadRate.stringValue = "\(defaults.integerForKey("GlobalUploadRate"))"
        limitModeDownloadRate.stringValue = "\(defaults.integerForKey("LimitModeDownloadRate"))"
        limitModeUploadRate.stringValue = "\(defaults.integerForKey("LimitModeUploadRate"))"
    }
}
