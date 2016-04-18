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
        
        aria2.getGlobalStatus = { results in
            self.authorized = true
            if results["error"] != nil {
                if results["error"]["message"] != nil {
                    self.authorized = false
                }
                return
            }
            
            let result = results["result"]
            let downloadSpeed = Double(result["downloadSpeed"].stringValue)! / 1024.0
            let uploadSpeed = Double(result["uploadSpeed"].stringValue)! / 1024.0
            self.downloadSpeedLabel.stringValue = self.getStringBy(value: downloadSpeed)
            self.uploadSpeedLabel.stringValue = self.getStringBy(value: uploadSpeed)
        }
        aria2.getActives = { results in
            let sortedResult = results.array!.sort() { (last, next) in
                return Int(last["downloadSpeed"].stringValue) > Int(next["downloadSpeed"].stringValue)
            }
            
            let subViews = self.taskView.subviews as! [TaskCellView]
            subViews.enumerate().forEach() { (index, view) in
                if index >= sortedResult.count {
                    view.hidden = true
                } else {
                    view.hidden = false
                    
                    let result = sortedResult[index]
                    var downloadName = ""
                    if let btName = result["bittorrent"]["info"]["name"].string {
                        downloadName = btName
                    } else {
                        downloadName = result["files"][0]["path"].stringValue.componentsSeparatedByString("/").last!
                    }
                    let downloadProgress = Double(result["completedLength"].stringValue)! / Double(result["totalLength"].stringValue)! * 100
                    view.updateView(name: downloadName, progress: downloadProgress)
                }
            }
            
        }
        aria2.connect()
    }
    
    func getStatus() {
        let isConnected = aria2.isConnected
        let boolValue = (isConnected && authorized)
        speedView.hidden = !boolValue
        alertLabel.hidden = boolValue
        
        if isConnected {
            aria2.request(method: .getGlobalStat, params: "[]")
            aria2.request(method: .tellActive, params: "[]")
        } else {
            if authorized {
                alertLabel.stringValue = "Please run aria2 first"
            } else {
                alertLabel.stringValue = "Unauthorized"
            }
            
        }
    }
    
    private func getStringBy(value value: Double) -> String {
        if value > 1024 {
            return String(format: "%.2f MB/s", value / 1024.0)
        } else {
            return String(format: "%.2f KB/s", value)
        }
    }
}
