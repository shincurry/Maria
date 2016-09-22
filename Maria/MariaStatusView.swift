//
//  MariaStatusView.swift
//  Maria
//
//  Created by ShinCurry on 2016/9/22.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class MariaStatusView: NSControl {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        image.draw(in: NSRect(x: 0, y: 0, width: 22, height: 22), from: NSZeroRect, operation: NSCompositeSourceOver, fraction: 1)
        // Drawing code here.
    }
    
    let image = NSImage(named: "Arrow")!
    
    
    
}
