//
//  SettingsMariaViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2
import SwiftyUserDefaults

class SettingsBandwidthViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        userDefaultsInit()
    }
    
    let defaults = MariaUserDefault.auto
    let maria = Maria.shared
    
    
    @IBOutlet weak var globalDownloadRate: NSTextField!
    @IBOutlet weak var globalUploadRate: NSTextField!

    @IBOutlet weak var limitModeDownloadRate: NSTextField!
    @IBOutlet weak var limitModeUploadRate: NSTextField!
    
}

extension SettingsBandwidthViewController {
    
    @IBAction func finishEditing(_ sender: NSTextField) {
        var key = DefaultsKeys.globalDownloadRate
        switch sender {
        case globalDownloadRate:
            key = .globalDownloadRate
        case globalUploadRate:
            key = .globalUploadRate
        case limitModeDownloadRate:
            key = .limitModeDownloadRate
        case limitModeUploadRate:
            key = .limitModeUploadRate
        default:
            break
        }
        
        if let intValue = Int(sender.stringValue) {
            defaults[key] = intValue
            defaults.synchronize()
        } else {
            sender.stringValue = "\(defaults[key])"
        }
        
        if defaults[.enableLowSpeedMode] {
            if sender == limitModeDownloadRate || sender == limitModeUploadRate {
                let downloadSpeed = defaults[.limitModeDownloadRate]
                let uploadSpeed = defaults[.limitModeUploadRate]
                maria.rpc!.lowSpeedLimit(download: downloadSpeed, upload: uploadSpeed)
            }
        }
    }
}

extension SettingsBandwidthViewController {
    func userDefaultsInit() {
        globalDownloadRate.stringValue = "\(defaults[.globalDownloadRate])"
        globalUploadRate.stringValue = "\(defaults[.globalUploadRate])"
        limitModeDownloadRate.stringValue = "\(defaults[.limitModeDownloadRate])"
        limitModeUploadRate.stringValue = "\(defaults[.limitModeUploadRate])"
    }
}
