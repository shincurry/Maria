//
//  RegexHelper.swift
//  Maria
//
//  Created by ShinCurry on 2016/12/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa

// Author: @onevcat
// Url: http://swifter.tips/regex/
struct RegexHelper {
    let regex: NSRegularExpression
    
    init(pattern: String) throws {
        try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    }
    
    func match(input: String) -> Bool {
        let matches = regex.matches(in: input, options: [], range: NSMakeRange(0, input.utf16.count))
        return matches.count > 0
    }
}
