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
    @IBOutlet weak var appCloseAlertLabel: NSTextField!
    @IBOutlet weak var taskView: NSStackView!
    @IBOutlet weak var speedView: NSView!
    
    let defaults = NSUserDefaults(suiteName: "group.windisco.maria")!
    
    var aria2: Aria2!
    var timer: NSTimer!
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(.NewData)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let baseHost = "http" + (defaults.boolForKey("SSLEnabled") ? "s" : "") + "://"
        let host = defaults.objectForKey("RPCServerHost") as! String
        let port = defaults.objectForKey("RPCServerPort") as! String
        let path = defaults.objectForKey("RPCServerPath") as! String
        
        aria2 = Aria2(url: baseHost + host + ":" + port + path)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(getStatus), userInfo: nil, repeats: true)
        aria2.getGlobalStatus = { results in
            let result = results["result"]
            let downloadSpeed = Double(result["downloadSpeed"].stringValue)! / 1024.0
            let uploadSpeed = Double(result["uploadSpeed"].stringValue)! / 1024.0
            self.downloadSpeedLabel.stringValue = self.getStringBy(value: downloadSpeed)
            self.uploadSpeedLabel.stringValue = self.getStringBy(value: uploadSpeed)
        }
        
        aria2.connect()
    }
    
    func getStatus() {
        let isConnected = aria2.isConnected
        
        taskView.hidden = !isConnected
        speedView.hidden = !isConnected
        appCloseAlertLabel.hidden = isConnected
        
        if isConnected {
            aria2.request(method: .getGlobalStat, params: "")
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
