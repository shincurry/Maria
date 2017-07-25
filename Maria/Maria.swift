//
//  maria.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2RPC
import Aria2Core
import YouGet

class Maria {
    var rpc: Aria2RPC?
    var core: Aria2Core?
    var youget: YouGet?
    
    static let shared = Maria()
    
    private init() {
        if MariaUserDefault.main[.useEmbeddedAria2] {
            _ = initCore()
        }
        
        _ = initRPC()
        _ = initYouGet()
    }
    
    func initRPC(forced: Bool = true) -> Bool  {
        if forced {
            rpc = nil
        } else {
            guard rpc == nil else {
                return false
            }
        }

        rpc = Aria2RPC(url: MariaUserDefault.RPCUrl, secret: MariaUserDefault.auto.object(forKey: "RPCServerSecret") as? String)
        return true
    }
    
    func initCore(forced: Bool = true) -> Bool {
        if forced {
            core?.stop()
            core = nil
        } else {
            guard core == nil else {
                return false
            }
        }

        if MariaUserDefault.main[.useEmbeddedAria2] {
            if let config = AriaConfig.builtIn {
                core = Aria2Core(options: config.dict)
            }
        }
        return false
    }
    
    func initYouGet(forced: Bool = true) -> Bool {
        if forced {
            youget = nil
        } else {
            guard youget == nil else {
                return false
            }
        }
        
        if MariaUserDefault.auto[.enableYouGet] && youget == nil {
            youget = YouGet()
        }
        return true
    }
}
