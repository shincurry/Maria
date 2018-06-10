//
//  StatusItemView.swift
//  Maria
//
//  Created by ShinCurry on 2017/2/13.
//  Copyright © 2017年 ShinCurry. All rights reserved.
//

import Cocoa

class StatusItemView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
    @IBOutlet weak var uploadSpeedLabel: NSTextField!
    @IBOutlet weak var downloadSpeedLabel: NSTextField!
    @IBOutlet weak var menuButton: NSStatusBarButton!
    @IBOutlet weak var menuButtonWidthConstraint: NSLayoutConstraint!
    
    
    
    var isShowSpeed: Bool = false {
        didSet {
            if isShowSpeed {
                menuButton.image = nil
                uploadSpeedLabel.isHidden = false
                downloadSpeedLabel.isHidden = false
                menuButtonWidthConstraint.constant = 60
            } else {
                menuButton.image = NSImage(named: "Arrow")
                uploadSpeedLabel.isHidden = true
                downloadSpeedLabel.isHidden = true
                menuButtonWidthConstraint.constant = 22
            }
        }
    }
    
}
