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
        window?.titleVisibility = .hidden
        lowSpeedModeButton.state = defaults.bool(forKey: "EnableLowSpeedMode") ? 1 : 0
        
        aria2.onPauseAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasksStatus("paused")
                }
            }
        }
        aria2.onUnpauseAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasksStatus("active")
                }
            }
        }
        let onRemove: (Bool) -> Void = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.taskListTableView.reloadData()
                    self.taskRemoveButton.isEnabled = false
                }
            }
        }
        aria2.onRemoveActive = onRemove
        aria2.onRemoveOther = onRemove
        
        aria2.onClearCompletedErrorRemoved = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.taskListTableView.reloadData()
                }
            }
        }
    }
    
    let defaults = UserDefaults(suiteName: "group.windisco.maria")!
    let aria2 = Aria2.shared
    
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet weak var taskRemoveButton: NSToolbarItem!
    @IBOutlet weak var taskCleanButton: NSToolbarItem!
    @IBOutlet weak var lowSpeedModeButton: NSButton!
    @IBAction func toggleLowSpeedMode(_ sender: NSButton) {
        let appDelegate = NSApplication.shared().delegate as! AppDelegate
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
        defaults.set(true, forKey: "EnableLowSpeedMode")
        lowSpeedModeButton.image = NSImage(named: "TortoiseColorful")
    }
    func lowSpeedModeOff() {
        lowSpeedModeButton.state = 0
        defaults.set(false, forKey: "EnableLowSpeedMode")
        lowSpeedModeButton.image = NSImage(named: "TortoiseGray")
    }
    @IBAction func pauseAllTasks(_ sender: NSToolbarItem) {
        aria2.pauseAll()
    }
    @IBAction func startAllTasks(_ sender: NSToolbarItem) {
        aria2.unpauseAll()
    }
    @IBAction func removeSelectedTasks(_ sender: NSToolbarItem) {
        if let controller = contentViewController as? TaskListViewController {
            let tableView = controller.taskListTableView
            let indexes = controller.taskListTableView.selectedRowIndexes.enumerated()
            let tasks: [(Int, Aria2Task)] = indexes.map() { (_, index) in
                let cell = tableView?.view(atColumn: 0, row: index, makeIfNecessary: true) as! TaskCellView
                return (index, cell.data!)
            }
            
            let alert = NSAlert()
            alert.messageText = "Remove Task" + (tasks.count > 0 ? "s" : "")
            if tasks.count == 1 {
                alert.informativeText = "Are you sure to remove \"\(tasks[0].1.title!)\" from the download list?"
            } else {
                alert.informativeText = "Are you sure to remove \(tasks.count) tasks from the download list?"
            }
            
            alert.addButton(withTitle: "Remove")
            alert.addButton(withTitle: "Cancel")
            alert.beginSheetModal(for: self.window!, completionHandler: { response in
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
    
    @IBAction func clearCompletedErrorRemovedTasks(_ sender: NSToolbarItem) {
        let alert = NSAlert()
        alert.messageText = "Clear Tasks"
        alert.informativeText = "Are you sure to clear those completed/error/removed task(s) from the download list?"
        alert.addButton(withTitle: "Clean")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                self.aria2.clearCompletedErrorRemoved()
            }
        })
    }
}
