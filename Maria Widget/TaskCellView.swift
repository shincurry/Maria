//
//  DownloadTaskWidgetView.swift
//  Maria
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class TaskCellView: NSView {
    
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
    
    @IBOutlet weak var name: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    
    func initSubView() {
        NSBundle.mainBundle().loadNibNamed("TaskCellView", owner: self, topLevelObjects: nil)
    }
}

