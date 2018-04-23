//
//  AriaConf.swift
//  Maria
//
//  Created by ShinCurry on 2016/9/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation


class AriaConfig {
    static var builtIn: AriaConfig? {
        get {
            
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
                    MariaUserDefault.initBuiltIn()
                    defaults[.aria2ConfPath] = conf
                    guard Bundle.main.load() else {
                        return nil
                    }
                    
                    let config = AriaConfig(filePath: conf)
                    config.load()
                    config.data.append(("dir", "\(NSHomeDirectory())/Downloads"))
                    
                    config.data.append(("input-file", "\(Bundle.main.resourcePath!)/aria2.session"))
                    config.data.append(("save-session", "\(Bundle.main.resourcePath!)/aria2.session"))
                    config.save()
                    return config
                } catch {
                    print(error)
                    return nil
                }
            } else {
                let config = AriaConfig(filePath: conf)
                config.load()
                return config
            }
        }
    }
    
    init(filePath: String) {
        self.filePath = filePath
    }

    var filePath: String
    typealias AriaConf = [(key: String, value: String)]
    var data = AriaConf()
    var array: AriaConf {
        get {
            return data
        }
    }
    var dict: Dictionary<String, String> {
        get {
            var dict = Dictionary<String, String>()
            data.forEach { dict[$0.key] = $0.value }
            return dict
        }
    }
    

    func load() {
        do {
            let conf = try String(contentsOfFile: filePath)
            data = parseConfig(from: conf)
        } catch {
            print(error)
        }
    }
    func reload() {
        data.removeAll()
        load()
    }
    
    func reset() {
        do {
            let resource = MariaUserDefault.main[.useEmbeddedAria2] ? "aria2.Maria" : "aria2.default"
            
            let path = Bundle.main.path(forResource: resource, ofType: ".conf")!
            let conf = try String(contentsOfFile: path)
            data = parseConfig(from: conf)
            
            data.append(("dir", "\(NSHomeDirectory())/Downloads"))
            data.append(("input-file", "\(NSHomeDirectory())/.aria2/aria2.session"))
            data.append(("save-session", "\(NSHomeDirectory())/.aria2/aria2.session"))
            save()
        } catch {
            print(error)
        }
    }
    
    func save() {
        do {
            let confString = data.filter({ return !($0.key.isEmpty || $0.value.isEmpty) }).reduce("", { prev, next in
                return "\(prev)\(next.key)=\(next.value)\n"
            })
            try confString.write(toFile: filePath, atomically: false, encoding: .utf8)
        } catch {
            print(error)
        }
    }
}

extension AriaConfig {
    func parseConfig(from conf: String) -> AriaConf {
        var dat = AriaConf()
        conf.components(separatedBy: "\n").filter({ item in
            if item.isEmpty {
                return false
            }
            let pattern = " *#"
            let regex: NSRegularExpression
            do {
                try regex = NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let matches = regex.matches(in: item, options: [], range: NSMakeRange(0, item.count))
                return matches.count == 0 ? true : false
            } catch {
                print(error)
            }
            return false
        }).forEach({ item in
            let array = item.components(separatedBy: "=")
            if array.count == 2 {
                dat.append((array[0], array[1]))
            }
        })
        return dat
    }
}
