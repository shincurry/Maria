//
//  DownloadTaskWidgetView.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2

class TodayTaskCellView: NSTableCellView {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    @IBOutlet weak var taskTitle: NSTextField!
    @IBOutlet weak var taskProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var taskProgressLabel: NSTextField!
    @IBOutlet weak var taskImageView: NSImageView!
    @IBOutlet weak var separatorLine: NSBox!
    var isBtTask = false {
        didSet {
            if isBtTask {
                taskImageView.image = NSImage(named: "TodayTorrentIcon")
            }
        }
    }
    
    func update(data: Aria2Task, isLast: Bool) {
        self.taskTitle.stringValue = data.title!
        self.taskProgressIndicator.doubleValue = data.progress
        self.taskProgressLabel.stringValue = data.progressString
        self.isBtTask = data.isBtTask!
        self.separatorLine.hidden = isLast
    }
}

