//
//  AriaWidget.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2

class Aria {
    var rpc: Aria2!
    
    static let shared = Aria()
    
    private init() {
        rpc = Aria2(url: MariaUserDefault.RPCUrl, secret: MariaUserDefault.auto.object(forKey: "RPCServerSecret") as? String)
    }
}
