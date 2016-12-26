//
//  YouGet.swift
//  YouGet
//
//  Created by ShinCurry on 2016/12/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum ProcessMode {
    case single
    case multiply
}

public class YouGet {
    
    public init?() {
        if let bin = sh(command: ["you-get"], exec: "/usr/bin/which"), !bin.isEmpty {
            self.bin = bin.replacingOccurrences(of: "\n", with: "")
        } else {
            return nil
        }
    }
    
    
    public var processMode = ProcessMode.single
    
    private var bin = ""
    
    private var task: Process?
    
    /**
     Add uris to download task
     
     - parameter uris:	download task links
     */
    public func fetchData(fromLink link: String) -> YGResult? {
        guard let jsonString = sh(command: ["--json", link], exec: bin), !jsonString.isEmpty else {
            print("you-get fetch data failed.")
            return nil
        }
        guard let data = revise(JSONString: jsonString).data(using: .utf8, allowLossyConversion: false) else {
            return nil
        }
        
        let json = JSON(data: data)
        return YGResult(json: json)
    }
    
    /**
     extracted information.
     
     - parameter uris:	download task links
     */
    public func fetchInfo(fromLink link: String) -> String? {
        return sh(command: ["--info", link], exec: bin)
    }
    
    /**
     extracted information with URLs.
     
     - parameter link:	target link url
     */
    public func fetchUrl(fromLink link: String) -> String? {
        return sh(command: ["--url", link], exec: bin)?.components(separatedBy: "\n").dropLast().last
    }
    
    
    private func sh(command: [String], exec binary: String = "/bin/sh") -> String? {
        var task: Process
        switch processMode {
        case .single:
            self.task = Process()
            task = self.task!
        case .multiply:
            task = Process()
        }

        task.launchPath = binary
        if binary != "/bin/sh" {
            task.arguments = command
        } else {
            task.arguments = ["-c"]
            task.arguments?.append(contentsOf: command)
        }
        task.environment = ["PATH": String(cString: getenv("PATH")) + ":/usr/local/bin",
                            "LC_CTYPE": "en_US.UTF-8"]

        let pip = Pipe()
        task.standardOutput = pip
        
        let outHandle = pip.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()
        
        var output = "";
        var progressObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) { notification -> Void in
            let data = outHandle.availableData
            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) as String? {
                    output += str
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }
        
        var terminationObserver = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: task, queue: nil) { notification -> Void in
            NotificationCenter.default.removeObserver(self)
        }
        
        task.launch()
        task.waitUntilExit()
        return output
    }
    
    // revise wrong json from you-get
    private func revise(JSONString str: String) -> String {
        if str.contains("163.com") {
            return str.components(separatedBy: "\n").dropLast(2).reduce("", { $0 + $1 + "\n" })
        }
        return str
    }
}
