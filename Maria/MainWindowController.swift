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
        let onRemove: Bool -> Void = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.taskListTableView.reloadData()
                    self.taskRemoveButton.enabled = false
                }
            }
        }
        aria2.onRemoveActive = onRemove
        aria2.onRemoveOther = onRemove
        
        aria2.onCleanCompletedErrorRemoved = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.taskListTableView.reloadData()
                }
            }
        }
    }
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    let aria2 = Aria2.shared
    
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet weak var taskRemoveButton: NSToolbarItem!
    @IBOutlet weak var taskCleanButton: NSToolbarItem!
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
    @IBAction func removeSelectedTasks(sender: NSToolbarItem) {
        
        if let controller = contentViewController as? TaskListViewController {
            let tableView = controller.taskListTableView
            let indexes = controller.taskListTableView.selectedRowIndexes.enumerate()
            let tasks: [(Int, Aria2Task)] = indexes.map() { (_, index) in
                let cell = tableView.viewAtColumn(0, row: index, makeIfNecessary: true) as! TaskCellView
                return (index, cell.data!)
            }
            
            let alert = NSAlert()
            alert.messageText = "Remove Task"
            if tasks.count == 1 {
                alert.informativeText = "Are you sure to remove \"\(tasks[0].1.title!)\" from the download list?"
            } else {
                alert.informativeText = "Are you sure to remove \(tasks.count) tasks from the download list?"
            }
            
            alert.addButtonWithTitle("Remove")
            alert.addButtonWithTitle("Cancel")
            alert.beginSheetModalForWindow(self.window!, completionHandler: { response in
                if response == NSAlertFirstButtonReturn {
                    tasks.forEach() { (index, task) in
                        if task.status == "active" || task.status == "paused" {
                            self.aria2.removeActive(task.gid!)
                        } else {
                            self.aria2.removeOther(task.gid!)
                        }
                    }
                }
            
            })
        }
    }
    
    @IBAction func cleanCompletedErrorRemovedTasks(sender: NSToolbarItem) {
        let alert = NSAlert()
        alert.messageText = "Clean Task"
        alert.informativeText = "Are you sure to clean those completed/error/removed task(s) from the download list?"
        alert.addButtonWithTitle("Clean")
        alert.addButtonWithTitle("Cancel")
        alert.beginSheetModalForWindow(self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                self.aria2.cleanCompletedErrorRemoved()
            }
        })
        
    }
    
    

    
}
