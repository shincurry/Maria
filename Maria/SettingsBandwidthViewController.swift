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
    
    let defaults = MariaUserDefault.auto
    let aria2 = Aria2.shared
    
    
    @IBOutlet weak var globalDownloadRate: NSTextField!
    @IBOutlet weak var globalUploadRate: NSTextField!

    @IBOutlet weak var limitModeDownloadRate: NSTextField!
    @IBOutlet weak var limitModeUploadRate: NSTextField!
    
}

extension SettingsBandwidthViewController {
    
    @IBAction func finishEditing(_ sender: NSTextField) {
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
            defaults.set(intValue, forKey: key)
            defaults.synchronize()
        } else {
            sender.stringValue = "\(defaults.integer(forKey: key))"
        }
        
        
        
        if defaults.bool(forKey: "EnableLowSpeedMode") {
            if sender == limitModeDownloadRate || sender == limitModeUploadRate {
                let downloadSpeed = defaults.integer(forKey: "LimitModeDownloadRate")
                let uploadSpeed = defaults.integer(forKey: "LimitModeUploadRate")
                aria2.lowSpeedLimit(download: downloadSpeed, upload: uploadSpeed)
            }
        }
        

    }
}

extension SettingsBandwidthViewController {
    func userDefaultsInit() {
        globalDownloadRate.stringValue = "\(defaults.integer(forKey: "GlobalDownloadRate"))"
        globalUploadRate.stringValue = "\(defaults.integer(forKey: "GlobalUploadRate"))"
        limitModeDownloadRate.stringValue = "\(defaults.integer(forKey: "LimitModeDownloadRate"))"
        limitModeUploadRate.stringValue = "\(defaults.integer(forKey: "LimitModeUploadRate"))"
    }
}
