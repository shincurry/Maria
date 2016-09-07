//
//  TodayViewController.swift
//  Maria Widget
//
//  Created by ShinCurry on 16/4/13.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import NotificationCenter
import Aria2
import SwiftyJSON

class TodayViewController: NSViewController, NCWidgetProviding {
    
    override var nibName: String? {
        return "TodayViewController"
    }
    
    @IBOutlet weak var downloadSpeedLabel: NSTextField!
    @IBOutlet weak var uploadSpeedLabel: NSTextField!
    @IBOutlet weak var alertLabel: NSTextField!
    @IBOutlet weak var speedView: NSView!

    @IBOutlet weak var separateLine: NSBox!
    
    @IBOutlet weak var taskListScrollViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var taskListScrollView: NSScrollView!
    @IBOutlet weak var taskListTableView: NSTableView!
    
    @IBOutlet weak var noTaskAlertLabel: NSTextField!
    
    let cellHeight: CGFloat = 42.0
    
    var numberOfActive: Int = -1

    var taskData: [Aria2Task] = []
    
    let defaults = UserDefaults(suiteName: "group.windisco.maria")!
    
    var aria2 = Aria2.shared
    var timer: Timer!
    var authorized: Bool = true
    
    func widgetPerformUpdate(_ completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(.newData)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = NSNib(nibNamed: "TodayTaskCellView", bundle: Bundle.main)
        taskListTableView.register(nib!, forIdentifier: "TodayTaskCell")
        taskListTableView.rowHeight = cellHeight
        aria2Config()
        
    }

    override func viewWillAppear() {
        aria2.connect()
        runTimer()
    }
    override func viewWillDisappear() {
        aria2.disconnect()
        closeTimer()
    }
    
    func updateListStatus() {
        if aria2.status == .connected {
            aria2.getGlobalStatus()
            aria2.tellActive()
        }
    }
    
    func aria2Config() {
        aria2.onGlobalStatus = { status in
            self.authorized = true
            self.downloadSpeedLabel.stringValue = status.speed!.downloadString
            self.uploadSpeedLabel.stringValue = status.speed!.uploadString
        }
        
        aria2.onActives = { tasks in
            var taskArray = tasks
            if taskArray.isEmpty {
                self.taskListTableView.gridStyleMask = .solidHorizontalGridLineMask
            } else {
                self.taskListTableView.gridStyleMask = NSTableViewGridLineStyle()
                if self.defaults.bool(forKey: "TodayEnableTasksSortedByProgress") {
                    taskArray = taskArray.sorted() { return $0.progress > $1.progress }
                }
                let number = self.defaults.integer(forKey: "TodayTasksNumber")
                if number < taskArray.count {
                    taskArray = taskArray.enumerated().filter({ (index, task) in return index > number-1 }).map({ return $1 })
                }
            }
            self.taskData = taskArray
            self.updateListView()
        }
        aria2.onStatusChanged = {
            let flag = (self.aria2.status == .connected)
            self.speedView.isHidden = !flag
            self.separateLine.isHidden = !flag
            self.taskListTableView.isHidden = !flag
            self.alertLabel.isHidden = flag

            switch self.aria2.status {
            case .connecting:
                self.alertLabel.stringValue = "Connecting to aria2..."
                self.taskListScrollViewHeightConstraint.constant = 0
                self.noTaskAlertLabel.isHidden = true
            case .connected:
                self.noTaskAlertLabel.isHidden = !(self.taskData.count == 0)
            case .unauthorized:
                self.noTaskAlertLabel.isHidden = true
                self.alertLabel.stringValue = "Connection unauthorized."
                self.taskListScrollViewHeightConstraint.constant = 0
            case .disconnected:
                self.noTaskAlertLabel.isHidden = true
                self.alertLabel.stringValue = "Disconnected to aria2."
                self.taskListScrollViewHeightConstraint.constant = 0
            }
        }
    }
}

// MARK: - Timer Config
extension TodayViewController {
    fileprivate func runTimer() {
        updateListStatus()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateListStatus), userInfo: nil, repeats: true)
    }
    fileprivate func closeTimer() {
        timer.invalidate()
        timer = nil
    }
}

// MARK: - TableView Delegate and DataSource
extension TodayViewController: NSTableViewDelegate, NSTableViewDataSource {
    func updateListView() {
        let tasksNone = taskData.isEmpty
        let tasksChanged = (numberOfActive != taskData.count)
        numberOfActive = taskData.count
        
        if tasksChanged {
            taskListTableView.reloadData()
            taskListScrollViewHeightConstraint.constant = tasksNone ? (cellHeight * 3.0) : (cellHeight * CGFloat(numberOfActive))
            noTaskAlertLabel.isHidden = !tasksNone
        } else {
            for index in 0..<taskData.count {
                let cell = taskListTableView.view(atColumn: 0, row: index, makeIfNecessary: true) as! TodayTaskCellView
                cell.update(taskData[index], isLast: index == taskData.count-1)
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return taskData.isEmpty ? 3 : taskData.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if taskData.isEmpty {
            return NSTableCellView()
        }
        let cell = tableView.make(withIdentifier: "TodayTaskCell", owner: self) as! TodayTaskCellView
        cell.update(taskData[row], isLast: row == taskData.count-1)
        return cell
    }
}
