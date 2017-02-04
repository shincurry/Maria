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
        _ = initRPC()
        _ = initYouGet()
        
        if MariaUserDefault.main[.useEmbeddedAria2] {
            _ = initCore()
        }
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
//            let resourcePath = Bundle.main.resourcePath!
//            let conf = resourcePath + "/aria2.conf"
//            let session = resourcePath + "/aria2.session"
//            
//            if !FileManager.default.fileExists(atPath: conf) {
//                do {
//                    let defaults = MariaUserDefault.auto    
//                    let defaultConfPath = Bundle.main.path(forResource: "aria2.Maria", ofType: "conf")!
//                    try FileManager.default.copyItem(atPath: defaultConfPath, toPath: conf)
//                    if !FileManager.default.fileExists(atPath: session) {
//                        FileManager.default.createFile(atPath: session, contents: nil, attributes: nil)
//                    }
//                    MariaUserDefault.initBuiltIn()
//                    defaults[.aria2ConfPath] = conf
//                } catch {
//                    print(error)
//                }
//            }
//            
//            if Bundle.main.load() {
//                let config = AriaConfig(filePath: conf)
//                config.load()
//                if config.dict["dir"] == nil {
//                    config.data.append(("dir", "\(NSHomeDirectory())/Downloads"))
//                }
//                config.data.append(("input-file", "\(Bundle.main.resourcePath!)/aria2.session"))
//                config.data.append(("save-session", "\(Bundle.main.resourcePath!)/aria2.session"))
//                core = Aria2Core(options: config.dict)
//                return true
//            }
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
