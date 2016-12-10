//
//  DockTitleView.swift
//  Maria
//
//  Created by ShinCurry on 2016/12/10.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class DockTileView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if let view = badgeBox.contentView {
            badgeBox.cornerRadius = view.frame.size.height / 2.0 - 2.0
        }
    }
    
    @IBOutlet weak var badgeBox: NSBox!
    @IBOutlet weak var badgeTitle: NSTextField!
}
