//
//  DownloadTaskWidgetView.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class TodayTaskCellView: NSView {
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initSubView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubView()
    }

    
    @IBOutlet var view: NSView!
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    func initSubView() {
        var objects: NSArray?;
        NSBundle.mainBundle().loadNibNamed("TodayTaskCellView", owner: self, topLevelObjects: &objects)
        
        for obj in objects! {
            if (obj.isMemberOfClass(NSView)) {
                view = obj as! NSView
            }
        }
        addSubview(view)
    }
    
    func updateView(name name: String, progress: Double) {
        self.name.stringValue = name
        self.progressIndicator.doubleValue = progress
    }
    
}

