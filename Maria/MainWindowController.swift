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
        NSApp.activate(ignoringOtherApps: true)
        window?.titleVisibility = .hidden
        lowSpeedModeButton.state = defaults.bool(forKey: "EnableLowSpeedMode") ? 1 : 0
        
        aria.rpc!.onPauseAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasksStatus("paused")
                }
            }
        }
        aria.rpc!.onUnpauseAll = { flag in
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
        aria.rpc!.onRemoveActive = onRemove
        aria.rpc!.onRemoveOther = onRemove
        
        aria.rpc!.onClearCompletedErrorRemoved = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.taskListTableView.reloadData()
                }
            }
        }
    }
    
    let defaults = MariaUserDefault.auto
    let aria = Aria.shared
    
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
        aria.rpc!.pauseAll()
    }
    @IBAction func startAllTasks(_ sender: NSToolbarItem) {
        aria.rpc!.unpauseAll()
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
            
            if tasks.count == 1 {
                alert.messageText = NSLocalizedString("removeTasks.alert.messageText", comment: "")
                alert.informativeText = String.init(format: NSLocalizedString("removeTasks.alert.informativeText", comment: ""), tasks[0].1.title!)
            } else {
                alert.messageText = NSLocalizedString("removeTasks.alert.messageText(s)", comment: "")
                alert.informativeText = String.init(format: NSLocalizedString("removeTasks.alert.informativeText(s)", comment: ""), tasks.count)
            }
            
            alert.addButton(withTitle: NSLocalizedString("button.remove", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
            alert.beginSheetModal(for: self.window!, completionHandler: { response in
                if response == NSAlertFirstButtonReturn {
                    tasks.forEach() { (index, task) in
                        if task.status == "active" || task.status == "paused" {
                            self.aria.rpc!.removeActive(task.gid!)
                        } else {
                            self.aria.rpc!.removeOther(task.gid!)
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func clearCompletedErrorRemovedTasks(_ sender: NSToolbarItem) {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("clearTasks.alert.messageText(s)", comment: "")
        alert.informativeText = NSLocalizedString("clearTasks.alert.informativeText(s)", comment: "")
        alert.addButton(withTitle: NSLocalizedString("button.clean", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
        alert.beginSheetModal(for: self.window!, completionHandler: { response in
            if response == NSAlertFirstButtonReturn {
                self.aria.rpc!.clearCompletedErrorRemoved()
            }
        })
    }
}
