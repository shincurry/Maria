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
        let nib = NSNib(nibNamed: "TaskCellView", bundle: NSBundle.mainBundle())
        taskListTableView.registerNib(nib!, forIdentifier: "TaskCell")
        taskListTableView.rowHeight = 64
        
        aria2Config()
    }
    
    override func viewWillAppear() {
        runTimer()
    }
    override func viewWillDisappear() {
        closeTimer()
    }
    
    var timer: NSTimer!
    var aria2 = Aria2.shared

    var aria2isConnected: Bool = true
    
    var numberOfActive: Int = 0
    var numberOfWaiting: Int = 0
    var numberOfStopped: Int = 0
    
    var taskData: [Aria2Task] = []
    var newActiveTaskData: [Aria2Task] = []
    var newWaitingTaskData: [Aria2Task] = []
    var newStoppedTaskData: [Aria2Task] = []
    
    @IBOutlet weak var alertLabel: NSTextField!
    @IBOutlet weak var taskListTableView: NSTableView!
    
    @IBOutlet weak var globalSpeedLabel: NSTextField!
    
    @IBOutlet weak var globalTaskNumberLabel: NSTextField!
    
    override func keyDown(theEvent: NSEvent) {
        // esc key pressed
        if theEvent.keyCode == 53 {
            taskListTableView.deselectRow(taskListTableView.selectedRow)
        }
    }
}


extension TaskListViewController {
    func updateListStatus() {
        if aria2.isConnected != aria2isConnected {
            aria2isConnected = aria2.isConnected
            if aria2.isConnected == false {
                taskData = []
                numberOfActive = 0
                numberOfWaiting = 0
                numberOfStopped = 0
                taskListTableView.reloadData()
            } else {
                updateListStatus()
            }
            return
        }
        if !aria2.isConnected {
            alertLabel.hidden = false
            return
        } else {
            alertLabel.hidden = true
        }
        
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
    
    func aria2Config() {
        aria2.onActives = { tasks in
            self.newActiveTaskData = tasks
        }
        
        aria2.onWaitings = { tasks in
            self.newWaitingTaskData = tasks
        }
        aria2.onStoppeds = { tasks in
            self.newStoppedTaskData = tasks
            self.updateListView()
        }
        
        
    }
}

// MARK: - Timer Config
extension TaskListViewController {
    private func runTimer() {
        updateListStatus()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateListStatus), userInfo: nil, repeats: true)
    }
    private func closeTimer() {
        timer.invalidate()
        timer = nil
    }
}

// MARK: - TableView Config
extension TaskListViewController: NSTableViewDelegate, NSTableViewDataSource {
    func updateListView() {
        let flag = (numberOfActive != newActiveTaskData.count) ||
                    (numberOfWaiting != newWaitingTaskData.count) ||
                    (numberOfStopped != newStoppedTaskData.count)
        
        numberOfActive = newActiveTaskData.count
        numberOfWaiting = newWaitingTaskData.count
        numberOfStopped = newStoppedTaskData.count
        
        taskData = newActiveTaskData + newWaitingTaskData + newStoppedTaskData
        if flag {
            taskListTableView.reloadData()
            if let controller = self.view.window?.windowController as? MainWindowController {
                controller.taskCleanButton.enabled = (numberOfStopped != 0)
            }
        } else {
            for index in 0..<taskData.count {
                let cell = taskListTableView.viewAtColumn(0, row: index, makeIfNecessary: false) as! TaskCellView
                cell.updateView(taskData[index])
            }
        }
    }
    
    func updateTasksStatus(status: String) {
        for index in 0..<taskData.count {
            let cell = taskListTableView.viewAtColumn(0, row: index, makeIfNecessary: false) as! TaskCellView
            cell.status = status
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return taskData.count
    }


    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeViewWithIdentifier("TaskCell", owner: self) as! TaskCellView
        cell.data = taskData[row]
        return cell
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let controller = self.view.window?.windowController as? MainWindowController {
            controller.taskRemoveButton.enabled = (taskListTableView.selectedRowIndexes.count > 0)
        }
    }
    
}
