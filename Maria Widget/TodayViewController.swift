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
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    var aria2 = Aria2.shared
    var timer: NSTimer!
    var authorized: Bool = true
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(.NewData)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = NSNib(nibNamed: "TodayTaskCellView", bundle: NSBundle.mainBundle())
        taskListTableView.registerNib(nib!, forIdentifier: "TodayTaskCell")
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
        if aria2.status == .Connected {
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
                self.taskListTableView.gridStyleMask = .SolidHorizontalGridLineMask
            } else {
                self.taskListTableView.gridStyleMask = .GridNone
                if self.defaults.boolForKey("TodayEnableTasksSortedByProgress") {
                    taskArray = taskArray.sort() { return $0.progress > $1.progress }
                }
                let number = self.defaults.integerForKey("TodayTasksNumber")
                if number < taskArray.count {
                    taskArray = taskArray.enumerate().filter({ (index, task) in return index > number-1 }).map({ return $1 })
                }
            }
            self.taskData = taskArray
            self.updateListView()
        }
        aria2.onStatusChanged = {
            let flag = (self.aria2.status == .Connected)
            self.speedView.hidden = !flag
            self.separateLine.hidden = !flag
            self.taskListTableView.hidden = !flag
            self.alertLabel.hidden = flag

            switch self.aria2.status {
            case .Connecting:
                self.alertLabel.stringValue = "Connecting to aria2..."
                self.taskListScrollViewHeightConstraint.constant = 0
            case .Connected:
                self.updateListStatus()
                self.noTaskAlertLabel.hidden = !(self.taskData.count == 0)
            case .Disconnected:
                self.noTaskAlertLabel.hidden = true
                self.alertLabel.stringValue = "Disconnected to aria2."
                self.taskListScrollViewHeightConstraint.constant = 0
            }
        }
    }
}

// MARK: - Timer Config
extension TodayViewController {
    private func runTimer() {
        updateListStatus()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateListStatus), userInfo: nil, repeats: true)
    }
    private func closeTimer() {
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
            noTaskAlertLabel.hidden = !tasksNone
        } else {
            for index in 0..<taskData.count {
                let cell = taskListTableView.viewAtColumn(0, row: index, makeIfNecessary: true) as! TodayTaskCellView
                cell.update(taskData[index], isLast: index == taskData.count-1)
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return taskData.isEmpty ? 3 : taskData.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if taskData.isEmpty {
            return NSTableCellView()
        }
        let cell = tableView.makeViewWithIdentifier("TodayTaskCell", owner: self) as! TodayTaskCellView
        cell.update(taskData[row], isLast: row == taskData.count-1)
        return cell
    }
}
