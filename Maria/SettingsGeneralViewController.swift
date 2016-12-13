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
    
    let defaults = MariaUserDefault.auto
    
    // little bug -- use a new thread?
    @IBOutlet weak var enableSpeedStatusBar: NSButton!
    
    @IBOutlet weak var enableStatusBarMode: NSButton!
    
    @IBOutlet weak var webAppPathButton: NSPopUpButton!
    
    @IBAction func switchOptions(_ sender: NSButton) {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
        let boolValue = sender.state == 1 ? true : false
        switch sender {
        case enableSpeedStatusBar:
            defaults[.enableSpeedStatusBar] = boolValue
            if boolValue {
                appDelegate.enableSpeedStatusBar()
            } else {
                appDelegate.disableSpeedStatusBar()
            }
        case enableStatusBarMode:
            defaults[.enableStatusBarMode] = boolValue
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
        defaults[.webAppPath] = sender.stringValue
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
                self.defaults[.webAppPath] = url
                self.webAppPathButton.item(at: 0)!.title = url
            }
        })
    }
}

extension SettingsGeneralViewController {
    func userDefaultsInit() {
        if let value = defaults[.webAppPath] {
            webAppPathButton.item(at: 0)!.title = value
        }
        enableSpeedStatusBar.state = defaults[.enableSpeedStatusBar] ? 1 : 0
        enableStatusBarMode.state  = defaults[.enableStatusBarMode] ? 1 : 0
    }
}


