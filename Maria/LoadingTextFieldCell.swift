//
//  LoadingTextField.swift
//  Maria
//
//  Created by ShinCurry on 2016/12/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

class LoadingTextFieldCell: NSTextFieldCell {
    
    let padding: CGFloat = 12.0
    
    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let insetRect = NSRect(x: rect.origin.x, y: rect.origin.y, width: rect.size.width - padding, height: rect.size.height)
        return super.drawingRect(forBounds: insetRect)
    }
    
}
