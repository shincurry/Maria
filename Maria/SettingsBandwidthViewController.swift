//
//  SettingsMariaViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class SettingsBandwidthViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
    }
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
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
        } else {
            sender.stringValue = "\(defaults.integerForKey(key))"
        }
        

    }
}
