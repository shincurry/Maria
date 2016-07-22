//
//  TaskListViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/5/10.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2
import SwiftyJSON

class TaskListViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let nib = NSNib(nibNamed: "TaskCellView", bundle: Bundle.main)
        taskListTableView.register(nib!, forIdentifier: "TaskCell")
        taskListTableView.rowHeight = 64
        
        aria2Config()
    }
    
    override func viewWillAppear() {
        runTimer()
    }
    override func viewWillDisappear() {
        closeTimer()
    }
    
    var timer: Timer!
    var aria2 = Aria2.shared

    var currentStatus: ConnectionStatus = .disconnected

    typealias NumberOfTask = (active: Int,waiting: Int,stopped: Int)
    var numberOfTask: NumberOfTask = (0, 0, 0)
    
    typealias TaskData = (active: [Aria2Task], waiting: [Aria2Task], stopped: [Aria2Task])
    var taskData: [Aria2Task] = []
    var newTaskData: TaskData = ([], [], [])
    
    @IBOutlet weak var alertLabel: NSTextField!
    @IBOutlet weak var taskListTableView: NSTableView!
    
    @IBOutlet weak var globalSpeedLabel: NSTextField!
    
    @IBOutlet weak var globalTaskNumberLabel: NSTextField!
    
    override func keyDown(_ theEvent: NSEvent) {
        // esc key pressed
        if theEvent.keyCode == 53 {
            taskListTableView.deselectRow(taskListTableView.selectedRow)
        }
    }
}


extension TaskListViewController {
    func updateListStatus() {
        if aria2.status == .connected {
            aria2.tellActive()
            aria2.tellWaiting()
            aria2.tellStopped()
            
            aria2.getGlobalStatus()
            aria2.onGlobalStatus = { status in
                let activeNumber = status.numberOfActiveTask!
                let totalNumber = status.numberOfActiveTask! + status.numberOfWaitingTask!
                self.globalTaskNumberLabel.stringValue = "\(activeNumber) of \(totalNumber) download(s)"
                self.globalSpeedLabel.stringValue = "⬇︎ " + status.speed!.downloadString + " ⬆︎ " + status.speed!.uploadString
            }
        }
    }
    
    func aria2Config() {
        aria2.onActives = { self.newTaskData.active = $0 }
        aria2.onWaitings = { self.newTaskData.waiting = $0 }
        aria2.onStoppeds = {
            self.newTaskData.stopped = $0.filter({ return !($0.title!.range(of: "[METADATA]") != nil && $0.status! == "complete") })
            self.updateListView()
        }
        
        aria2.onStatusChanged = {
            if self.aria2.status == .connecting || self.aria2.status == .disconnected {
                self.taskData = []
                self.numberOfTask.active = 0
                self.numberOfTask.waiting = 0
                self.numberOfTask.stopped = 0
                self.taskListTableView.reloadData()
            }
            switch self.aria2.status {
            case .connecting:
                self.alertLabel.isHidden = false
                self.alertLabel.stringValue = "Connecting to aria2..."
            case .connected:
                self.alertLabel.isHidden = true
            case .unauthorized:
                self.alertLabel.isHidden = false
                self.alertLabel.stringValue = "Connection unauthorized."
            case .disconnected:
                self.alertLabel.isHidden = false
                self.alertLabel.stringValue = "Disconnected to aria2."
            }
        }
    }
}

// MARK: - Timer Config
extension TaskListViewController {
    private func runTimer() {
        updateListStatus()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateListStatus), userInfo: nil, repeats: true)
    }
    private func closeTimer() {
        timer.invalidate()
        timer = nil
    }
}

// MARK: - TableView Config
extension TaskListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func updateListView() {
        let flag = (numberOfTask.active != newTaskData.active.count) ||
                    (numberOfTask.waiting != newTaskData.waiting.count) ||
                    (numberOfTask.stopped != newTaskData.stopped.count)
        
        numberOfTask.active = newTaskData.active.count
        numberOfTask.waiting = newTaskData.waiting.count
        numberOfTask.stopped = newTaskData.stopped.count
        
        taskData = newTaskData.active + newTaskData.waiting + newTaskData.stopped
        if flag {
            taskListTableView.reloadData()
            if let controller = self.view.window?.windowController as? MainWindowController {
                controller.taskCleanButton.isEnabled = (numberOfTask.stopped != 0)
            }
        } else {
            for index in 0..<taskData.count {
                if let cell = taskListTableView.view(atColumn: 0, row: index, makeIfNecessary: true) as?TaskCellView {
                    cell.update(taskData[index])
                }
            }
        }
//        NSApplication.shared().dockTile.badgeLabel = (numberOfTask.active == 0 ? nil : "\(numberOfTask.active)")
    }
    
    func updateTasksStatus(_ status: String) {
        for index in 0..<taskData.count {
            if let cell = taskListTableView.view(atColumn: 0, row: index, makeIfNecessary: true) as? TaskCellView {
                cell.status = status
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return taskData.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "TaskCell", owner: self) as! TaskCellView
        cell.update(taskData[row])
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let controller = self.view.window?.windowController as? MainWindowController {
            controller.taskRemoveButton.isEnabled = (taskListTableView.selectedRowIndexes.count > 0)
        }
    }
    
}
