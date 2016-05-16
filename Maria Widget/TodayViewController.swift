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
    @IBOutlet weak var taskView: NSStackView!
    

    @IBOutlet weak var separateLine: NSBox!
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    var aria2 = Aria2.shared
    var timer: NSTimer!
    var authorized: Bool = true
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(.NewData)
        
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskView.subviews.forEach() { view in
            view.hidden = true
        }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(getStatus), userInfo: nil, repeats: true)
        
        aria2.onGlobalStatus = { status in
            self.authorized = true

            self.downloadSpeedLabel.stringValue = status.speed!.downloadString
            self.uploadSpeedLabel.stringValue = status.speed!.uploadString
        }
        
        aria2.onActives = { tasks in
            let sortedTasks = tasks.sort() { (last, next) in
                return last.speed!.download > next.speed!.download
            }
            let subViews = self.taskView.subviews as! [TodayTaskCellView]
            subViews.enumerate().forEach() { (index, view) in
                if index >= sortedTasks.count {
                    view.hidden = true
                } else {
                    view.hidden = false
                    let task = sortedTasks[index]
                    view.updateView(name: task.title!, progress: task.progress)
                }
            }
        }
        aria2.connect()
    }
    
    func getStatus() {
        let isConnected = aria2.isConnected
        let boolValue = (isConnected && authorized)
        speedView.hidden = !boolValue
        separateLine.hidden = !boolValue
        taskView.hidden = !boolValue
        
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
