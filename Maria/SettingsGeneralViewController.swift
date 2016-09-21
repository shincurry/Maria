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
    
    @IBOutlet weak var enableDockIcon: NSButton!
    
    @IBOutlet weak var webAppPathButton: NSPopUpButton!
    
    @IBAction func switchOptions(_ sender: NSButton) {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let boolValue = sender.state == 1 ? true : false
        switch sender {
        case enableSpeedStatusBar:
            defaults.set(boolValue, forKey: "EnableSpeedStatusBar")
            if boolValue {
                appDelegate.enableSpeedStatusBar()
            } else {
                appDelegate.disableSpeedStatusBar()
            }
        case enableDockIcon:
            defaults.set(boolValue, forKey: "EnableDockIcon")
            if boolValue {
                appDelegate.enableDockIcon()
            } else {
                appDelegate.disableDockIcon()
            }
        default:
            break
        }
    }
    
    @IBAction func finishEditing(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: "WebAppPath")
        defaults.synchronize()
    }
    
    @IBAction func selectFilePath(_ sender: NSMenuItem) {
        webAppPathButton.selectItem(at: 0)
        let openPanel = NSOpenPanel()
        openPanel.title = NSLocalizedString("selectWebUIPath.openPanel.title", comment: "")
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.showsHiddenFiles = true
        openPanel.beginSheetModal(for: self.view.window!, completionHandler: { key in
            if key == 1, let url = openPanel.url?.relativePath {
                self.defaults.set(url, forKey: "WebAppPath")
                self.webAppPathButton.item(at: 0)!.title = url
            }
        })
    }
}

extension SettingsGeneralViewController {
    func userDefaultsInit() {
        if let value = defaults.object(forKey: "WebAppPath") as? String {
            webAppPathButton.item(at: 0)!.title = value
        }
        enableSpeedStatusBar.state = defaults.bool(forKey: "EnableSpeedStatusBar") ? 1 : 0
    }
}


