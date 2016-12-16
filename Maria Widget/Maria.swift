//
//  AriaWidget.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2RPC

class Maria {
    var rpc: Aria2RPC!
    
    static let shared = Maria()
    
    private init() {
        rpc = Aria2RPC(url: MariaUserDefault.RPCUrl, secret: MariaUserDefault.auto.object(forKey: "RPCServerSecret") as? String)
    }
}
