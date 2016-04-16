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
        webAppPath.stringValue = defaults.objectForKey("WebAppPath") as! String
        enableSpeedStatusBar.state = defaults.boolForKey("EnableSpeedStatusBar") ? 1 : 0
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    // little bug -- use a new thread?
    @IBOutlet weak var enableSpeedStatusBar: NSButton!
    
    @IBOutlet weak var webAppPath: NSTextField!
    
    
    @IBAction func switchOptions(sender: NSButton) {
        let boolValue = sender.state == 1 ? true : false
        print(boolValue)
        switch sender {
        case enableSpeedStatusBar:
            defaults.setBool(boolValue, forKey: "EnableSpeedStatusBar")
        default:
            break
        }
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        
        dispatch_async(dispatch_get_main_queue()) {
            if boolValue {
                appDelegate.enableSpeedStatusBar()
            } else {
                appDelegate.disableSpeedStatusBar()
            }
        }
    }
    
    @IBAction func finishEditing(sender: NSTextField) {
        defaults.setObject(sender.stringValue, forKey: "WebAppPath")
        defaults.synchronize()
    }
}


