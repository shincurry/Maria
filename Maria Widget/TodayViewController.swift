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
    
    let cellHeight: CGFloat = 36.0
    
    var numberOfActive: Int = 0

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
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(getStatus), userInfo: nil, repeats: true)

        aria2.onGlobalStatus = { status in
            self.authorized = true

            self.downloadSpeedLabel.stringValue = status.speed!.downloadString
            self.uploadSpeedLabel.stringValue = status.speed!.uploadString
        }
        
        aria2.onActives = { tasks in
            self.taskData = tasks
            self.updateListView()
        }
        aria2.connect()
    }
    
    func getStatus() {
        let isConnected = aria2.isConnected
        let boolValue = (isConnected && authorized)
        speedView.hidden = !boolValue
        separateLine.hidden = !boolValue
        taskListTableView.hidden = !boolValue
        
        alertLabel.hidden = boolValue
        
        if isConnected {
            aria2.getGlobalStatus()
            aria2.tellActive()
        } else {
            if authorized {
                alertLabel.stringValue = "Please run aria2 first"
            } else {
                alertLabel.stringValue = "Unauthorized"
            }
        }
    }
}

// MARK: - TableView Delegate and DataSource
extension TodayViewController: NSTableViewDelegate, NSTableViewDataSource {
    func updateListView() {
        let flag = (numberOfActive != taskData.count)
        numberOfActive = taskData.count
        
        if flag {
            taskListTableView.reloadData()
            taskListScrollViewHeightConstraint.constant = (cellHeight + 1) * CGFloat(numberOfActive)
        } else {
            for index in 0..<taskData.count {
                let cell = taskListTableView.viewAtColumn(0, row: index, makeIfNecessary: true) as! TodayTaskCellView
                cell.data = taskData[index]
            }
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return taskData.isEmpty ? 3 : taskData.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if taskData.isEmpty {
            let cell = NSTableCellView()
            return cell
        }
        let cell = tableView.makeViewWithIdentifier("TodayTaskCell", owner: self) as! TodayTaskCellView
        cell.data = taskData[row]
        return cell
    }
}
