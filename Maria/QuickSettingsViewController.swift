//
//  QuickSettingsViewController.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/6.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2

class QuickSettingsViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = MariaUserDefault.auto
    let aria = Aria.shared
    
    @IBOutlet weak var limitModeDownloadRate: NSTextField!
    @IBOutlet weak var limitModeUploadRate: NSTextField!
}

extension QuickSettingsViewController {
    
    @IBAction func finishEditing(_ sender: NSTextField) {
        var key = ""
        switch sender {
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
                aria.rpc!.lowSpeedLimit(download: downloadSpeed, upload: uploadSpeed)
            }
        }
    }
}

extension QuickSettingsViewController {
    func userDefaultsInit() {
        limitModeDownloadRate.stringValue = "\(defaults.integer(forKey: "LimitModeDownloadRate"))"
        limitModeUploadRate.stringValue = "\(defaults.integer(forKey: "LimitModeUploadRate"))"
    }
}
