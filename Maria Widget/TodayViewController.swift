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
    @IBOutlet weak var speedView: NSStackView!
    
    let aria2 = Aria2.shared
    var timer: NSTimer!
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(.NewData)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(getStatus), userInfo: nil, repeats: true)
        aria2.didReceiveMessage = { (socket, text) in
            let results = JSON(data: text.dataUsingEncoding(NSUTF8StringEncoding)!)
            let speed = results["result"].array!.reduce((0.0, 0.0)) { (sum, result) in
                let downloadSpeed = Double(result["downloadSpeed"].stringValue)! / 1024.0
                let uploadSpeed = Double(result["uploadSpeed"].stringValue)! / 1024.0
                return (downloadSpeed, uploadSpeed)
            }
            self.downloadSpeedLabel.stringValue = self.getStringBy(value: speed.0)
            self.uploadSpeedLabel.stringValue = self.getStringBy(value: speed.1)
        }
        
        aria2.connect()
        

        
        
    }
    
    func getStatus() {
        aria2.tellActive()
    }
    
    private func getStringBy(value value: Double) -> String {
        if value > 1024 {
            return String(format: "%.2f MB/s", value / 1024.0)
        } else {
            return String(format: "%.2f KB/s", value)
        }
    }
}
