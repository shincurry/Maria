//
//  TaskListViewController.swift
//  Maria
//
//  Created by ShinCurry on 16/5/10.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2RPC
import SwiftyJSON

class TaskListViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        let nib = NSNib(nibNamed: NSNib.Name("TaskCellView"), bundle: Bundle.main)
        taskListTableView.register(nib!, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TaskCell"))
        taskListTableView.rowHeight = 64
        taskListTableView.selectionHighlightStyle = .none
        
        aria2Config()
        alertConnectButton.attributedTitle = NSAttributedString(string: NSLocalizedString("aria2.status.disconnected.tryNow", comment: ""), attributes: [NSAttributedStringKey.foregroundColor: NSColor(calibratedRed: 0.000, green: 0.502, blue: 0.753, alpha: 1.00), NSAttributedStringKey.font: NSFont.systemFont(ofSize: 14)])
    }
    
    override func viewWillAppear() {
        runTimer()
    }
    override func viewWillDisappear() {
        closeTimer()
    }
    override func viewDidAppear() {
        MariaNotification.removeAllNotification()
    }
    
    var timer: Timer!
    
    var timeToConnectAria = 4
    var countdownTimeToConnectAria = 4
    let maria = Maria.shared

    
    var currentStatus: ConnectionStatus = .disconnected

    typealias NumberOfTask = (active: Int,waiting: Int,stopped: Int)
    var numberOfTask: NumberOfTask = (0, 0, 0)
    
    typealias TaskData = (active: [Aria2Task], waiting: [Aria2Task], stopped: [Aria2Task])
    var taskData: [Aria2Task] = []
    var newTaskData: TaskData = ([], [], [])
    
    let selectedColor = NSColor(calibratedRed: 211.0/255.0, green: 231.0/255.0, blue: 250.0/255.0, alpha: 1.0).cgColor
    
    @IBOutlet weak var alertLabel: NSTextField!
    @IBOutlet weak var alertConnectButton: NSButton!
    @IBOutlet weak var taskListTableView: NSTableView!
    
    @IBOutlet weak var globalSpeedLabel: NSTextField!
    
    @IBOutlet weak var globalTaskNumberLabel: NSTextField!
    
    override func keyDown(with theEvent: NSEvent) {
        // esc key pressed
        if theEvent.keyCode == 53 {
            taskListTableView.deselectRow(taskListTableView.selectedRow)
        }
    }
    @IBAction func connectToAria(_ sender: NSButton) {
        maria.rpc?.connect()
    }
}


extension TaskListViewController {
    @objc func updateListStatus() {
//        if let core = maria.core {
//            print("---core---")
//            if let tasks = core.getActiveDownload() {
//                print(tasks)
//            } else {
//                print("nil")
//            }
//        }
        
        switch maria.rpc!.status {
        case .disconnected:
            countdownTimeToConnectAria -= 1
            if countdownTimeToConnectAria == 0 {
                maria.rpc?.connect()
                timeToConnectAria *= 2
                countdownTimeToConnectAria = timeToConnectAria
            } else {
                let localized = NSLocalizedString("aria2.status.disconnected", comment: "")
                alertLabel.stringValue = String(format: localized, countdownTimeToConnectAria)
            }
        case .connected:
            timeToConnectAria = 4
            countdownTimeToConnectAria = 4
            
            maria.rpc?.tellActive()
            maria.rpc?.tellWaiting()
            maria.rpc?.tellStopped()
            
            maria.rpc?.getGlobalStatus()
            maria.rpc?.onGlobalStatus = { status in
                let activeNumber = status.numberOfActiveTask!
                let totalNumber = status.numberOfActiveTask! + status.numberOfWaitingTask!
                self.globalTaskNumberLabel.stringValue = "\(activeNumber) of \(totalNumber) download(s)"
                self.globalSpeedLabel.stringValue = "⬇︎ " + status.speed!.downloadString + " ⬆︎ " + status.speed!.uploadString
            }
        default:
            break
        }
    }
    
    func aria2Config() {
        maria.rpc?.onActives = {
            guard let tasks = $0 else {
                return
            }
            self.newTaskData.active = tasks
        }
        maria.rpc?.onWaitings = {
            guard let tasks = $0 else {
                return
            }
            self.newTaskData.waiting = tasks
        }
        maria.rpc?.onStoppeds = {
            guard let tasks = $0 else {
                return
            }
            self.newTaskData.stopped = tasks.filter({ return !($0.title!.range(of: "[METADATA]") != nil && $0.status! == "complete") })
            self.updateListView()
        }
        
        maria.rpc?.onStatusChanged = {
            if self.maria.rpc?.status == .connecting || self.maria.rpc?.status == .disconnected {
                self.taskData = []
                self.numberOfTask = (0, 0, 0)
                self.taskListTableView.reloadData()
            }
            switch self.maria.rpc!.status {
            case .connecting:
                self.alertLabel.isHidden = false
                self.alertLabel.stringValue = NSLocalizedString("aria2.status.connecting", comment: "")
                self.alertConnectButton.isHidden = true
            case .connected:
                self.alertLabel.isHidden = true
                self.alertLabel.isHidden = true
            case .unauthorized:
                self.alertLabel.isHidden = false
                self.alertLabel.stringValue = NSLocalizedString("aria2.status.unauthorized", comment: "")
                self.alertConnectButton.isHidden = true
            case .disconnected:
                self.alertLabel.isHidden = false
                self.alertConnectButton.isHidden = false
            }
        }
    }
}

// MARK: - Timer Config
extension TaskListViewController {
    fileprivate func runTimer() {
        updateListStatus()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateListStatus), userInfo: nil, repeats: true)
    }
    fileprivate func closeTimer() {
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
    
    func updateTasks(status: String) {
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
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TaskCell"), owner: self) as? TaskCellView else {
            fatalError("Unexpected cell type at \(row)")
        }
        cell.update(taskData[row])
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let controller = self.view.window?.windowController as? MainWindowController {
            controller.taskRemoveButton.isEnabled = (taskListTableView.selectedRowIndexes.count > 0)
        }
        
        for row in 0..<taskListTableView.numberOfRows {
            let cell = taskListTableView.view(atColumn: 0, row: row, makeIfNecessary: true) as! TaskCellView
            cell.wantsLayer = true
            if taskListTableView.selectedRowIndexes.contains(row) {
                cell.layer?.backgroundColor = selectedColor
            } else {
                cell.layer?.backgroundColor = NSColor.clear.cgColor
            }
        }
    }
    
}
