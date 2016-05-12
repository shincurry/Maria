//
//  MainWindowController.swift
//  Maria
//
//  Created by ShinCurry on 16/5/1.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        NSApp.activateIgnoringOtherApps(true)
        window?.titleVisibility = .Hidden
        lowSpeedModeButton.state = defaults.boolForKey("EnableLowSpeedMode") ? 1 : 0
        
        aria2.onPauseAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasksStatus("paused")
                }
            }
        }
        aria2.onStartAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasksStatus("active")
                }
            }
        }
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    let aria2 = Aria2.shared
    
    @IBOutlet weak var toolbar: NSToolbar!
    @IBOutlet weak var lowSpeedModeButton: NSButton!
    @IBAction func toggleLowSpeedMode(sender: NSButton) {
        let appDelegate = NSApplication.sharedApplication().delegate as! AppDelegate
        if lowSpeedModeButton.state == 1 {
            lowSpeedModeOn()
            appDelegate.lowSpeedModeOn()
        } else {
            lowSpeedModeOff()
            appDelegate.lowSpeedModeOff()
        }
    }
    func lowSpeedModeOn() {
        lowSpeedModeButton.state = 1
        defaults.setBool(true, forKey: "EnableLowSpeedMode")
        lowSpeedModeButton.image = NSImage(named: "TortoiseColorful")
    }
    func lowSpeedModeOff() {
        lowSpeedModeButton.state = 0
        defaults.setBool(false, forKey: "EnableLowSpeedMode")
        lowSpeedModeButton.image = NSImage(named: "TortoiseGray")
    }
    @IBAction func pauseAllTasks(sender: NSToolbarItem) {
        aria2.pauseAll()
    }
    @IBAction func startAllTasks(sender: NSToolbarItem) {
        aria2.startAll()
    }
    
    @IBAction func openBtFile(sender: NSToolbarItem) {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose a .torrent file"
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = true
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["torrent"]
        openPanel.runModal()
        if let url = openPanel.URL {
            if let data = NSData(contentsOfURL: url) {
                aria2.addTorrent(data)
                self.dismissController(self)
            }
        }
    }
    
}
