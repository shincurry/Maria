//
//  MainWindowController.swift
//  Maria
//
//  Created by ShinCurry on 16/5/1.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2RPC

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        NSApp.activate(ignoringOtherApps: true)
        window?.titleVisibility = .hidden
        lowSpeedModeButton.state = defaults[.enableLowSpeedMode] ? .on : .off
        
        maria.rpc?.onPauseAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasks(status: "paused")
                }
            }
        }
        maria.rpc?.onUnpauseAll = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.updateTasks(status: "active")
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
        maria.rpc?.onRemoveActive = onRemove
        maria.rpc?.onRemoveOther = onRemove
        
        maria.rpc?.onClearCompletedErrorRemoved = { flag in
            if flag {
                if let controller = self.contentViewController as? TaskListViewController {
                    controller.taskListTableView.reloadData()
                }
            }
        }
    }
    
    let defaults = MariaUserDefault.auto
    let maria = Maria.shared
    
    @IBOutlet weak var toolbar: NSToolbar!
    
    @IBOutlet weak var taskRemoveButton: NSToolbarItem!
    @IBOutlet weak var taskCleanButton: NSToolbarItem!
    @IBOutlet weak var lowSpeedModeButton: NSButton!
    
    var touchBarLowSpeedButton: NSButton?
    
    @IBAction func toggleLowSpeedMode(_ sender: NSButton) {
        let appDelegate = NSApplication.shared.delegate as! AppDelegate
        if sender.state == .on {
            defaults[.enableLowSpeedMode] = true
            appDelegate.lowSpeedModeOn()
        } else {
            defaults[.enableLowSpeedMode] = false
            appDelegate.lowSpeedModeOff()
        }
    }

    @IBAction func pauseAllTasks(_ sender: NSToolbarItem) {
        maria.rpc?.pauseAll()
    }
    @IBAction func resumeAllTasks(_ sender: NSToolbarItem) {
        maria.rpc?.unpauseAll()
    }
    @IBAction func removeSelectedTasks(_ sender: NSToolbarItem) {
        if let controller = contentViewController as? TaskListViewController {
            let tableView = controller.taskListTableView
            let indexes = controller.taskListTableView.selectedRowIndexes.enumerated()
            let tasks: [(Int, Aria2Task)] = indexes.map() { (arg) in
                let (_, index) = arg
                
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
            alert.addButton(withTitle: NSLocalizedString("button.delete", comment: ""))
            alert.addButton(withTitle: NSLocalizedString("button.cancel", comment: ""))
            alert.beginSheetModal(for: self.window!, completionHandler: { response in
                func remove(_ tasks: [(Int, Aria2Task)]) {
                    tasks.forEach() { (arg) in
                        let (_, task) = arg
                        
                        if task.status == "active" || task.status == "paused" {
                            self.maria.rpc?.removeActive(task.gid!)
                        } else {
                            self.maria.rpc?.removeOther(task.gid!)
                        }
                    }
                }
                func delete(_ tasks: [(Int, Aria2Task)]) {
                    let fileManager = FileManager.default
                    
                    tasks.forEach() { (arg) in
                        let (_, task) = arg
                        
                        guard let filePath = task.filePath else { return }
                        let aria2FilePath = "\(filePath).aria2"
                        do {
                            if (fileManager.fileExists(atPath: aria2FilePath)) {
                                try fileManager.removeItem(atPath: aria2FilePath)
                            }
                            if (fileManager.fileExists(atPath: filePath)) {
                                try fileManager.removeItem(atPath: filePath)
                            }
                        } catch (let error) {
                            print(error)
                        }
                    }
                }
                
                switch response {
                case .alertFirstButtonReturn:
                    remove(tasks)
                case .alertSecondButtonReturn:
                    remove(tasks)
                    delete(tasks)
                default: break
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
            if response == .alertFirstButtonReturn {
                self.maria.rpc?.clearCompletedErrorRemoved()
            }
        })
    }
}

// MARK: - NSTouchBar
@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let controlBar = NSTouchBar.CustomizationIdentifier("com.windisco.Maria.controlBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let resumeAll = NSTouchBarItem.Identifier("com.windisco.Maria.resumeAll")
    static let pauseAll = NSTouchBarItem.Identifier("com.windisco.Maria.pauseAll")
    static let lowSpeedMode = NSTouchBarItem.Identifier("com.windisco.Maria.lowSpeedMode")
}

extension MainWindowController: NSTouchBarDelegate {
    @available(OSX 10.12.2, *)
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        touchBar.customizationIdentifier = .controlBar
        touchBar.defaultItemIdentifiers = [.resumeAll, .pauseAll, .lowSpeedMode]
        touchBar.customizationAllowedItemIdentifiers = [.resumeAll, .pauseAll, .lowSpeedMode]
        return touchBar
    }
    
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let touchBarItem = NSCustomTouchBarItem(identifier: identifier)
        
        switch identifier {
        case NSTouchBarItem.Identifier.resumeAll:
            let button = NSButton(title: "", image: NSImage(named: "Resume")!, target: self, action: #selector(MainWindowController.resumeAllTasks(_:)))
            touchBarItem.view = button
        case NSTouchBarItem.Identifier.pauseAll:
            let button = NSButton(title: "", image: NSImage(named: "Pause")!, target: self, action: #selector(MainWindowController.pauseAllTasks(_:)))
            touchBarItem.view = button
        case NSTouchBarItem.Identifier.lowSpeedMode:
            touchBarLowSpeedButton = NSButton(title: "", target: self, action: #selector(MainWindowController.toggleLowSpeedMode(_:)))
            touchBarLowSpeedButton!.setButtonType(NSButton.ButtonType.toggle)
            touchBarLowSpeedButton!.image = NSImage(named: "TortoiseGray")
            touchBarLowSpeedButton!.alternateImage = NSImage(named: "TortoiseColorful")
            touchBarItem.view = touchBarLowSpeedButton!
        default:
            touchBarItem.view = NSButton(title: "", target: self, action: nil)
        }
        
        return touchBarItem;
    }
}
