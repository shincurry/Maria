//
//  Aria.swift
//  Maria
//
//  Created by ShinCurry on 2016/10/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import Aria2

class Aria {
    var rpc: Aria2!
    var core: Aria2Core?
    
    static let shared = Aria()
    
    private init() {
        initRPC()
        initCore()
    }
    
    private func initRPC() {
        rpc = Aria2(url: MariaUserDefault.RPCUrl, secret: MariaUserDefault.auto.object(forKey: "RPCServerSecret") as? String)
    }
    
    private func initCore() {
        if MariaUserDefault.main.bool(forKey: "UseEmbeddedAria2") {
            let resourcePath = Bundle.main.resourcePath!
            let conf = resourcePath + "/aria2.conf"
            let session = resourcePath + "/aria2.session"
            
            if !FileManager.default.fileExists(atPath: conf) {
                do {
                    let defaults = MariaUserDefault.auto    
                    let defaultConfPath = Bundle.main.path(forResource: "aria2.Maria", ofType: "conf")!
                    try FileManager.default.copyItem(atPath: defaultConfPath, toPath: conf)
                    if !FileManager.default.fileExists(atPath: session) {
                        FileManager.default.createFile(atPath: session, contents: nil, attributes: nil)
                    }
                    defaults.set("6789", forKey: "RPCServerPort")
                    defaults.set("maria.rpc.2016", forKey: "RPCServerSecret")
                    defaults.set(conf, forKey: "Aria2ConfPath")
                } catch {
                    print(error)
                }
            }
            
            if let path = Bundle.main.path(forResource: "aria2", ofType: "conf") {
                let config = AriaConfig(filePath: path)
                config.load()
                config.data.append(("dir", "\(NSHomeDirectory())/Downloads"))
                config.data.append(("input-file", "\(Bundle.main.resourcePath!)/aria2.session"))
                config.data.append(("save-session", "\(Bundle.main.resourcePath!)/aria2.session"))
                core = Aria2Core(options: config.dict)
            }
        }
    }
}
