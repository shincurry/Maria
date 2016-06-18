//
//  Aria2Task.swift
//  Aria2
//
//  Created by ShinCurry on 16/5/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct Aria2Task {
    public var gid: String?
    public var status: String?
    public var isBtTask: Bool?
    public var title: String?
    
    public var completedLength: Int?
    public var totalLength: Int?
    
    public var filePath: String?
    public var dirPath: String? {
        get {
            if let file = filePath {
                if !file.isEmpty {
                    var path = file.components(separatedBy: "/").filter({ return !$0.isEmpty })
                    path.removeLast()
                    return path.reduce("", combine: { sum, next in return sum + "/" + next }) + "/"
                }
            }
            return nil
        }
    }
    public var torrentDirectoryPath: String?
    public var fileName: String?
    
    public var uris: [[String]]?
    
    public var remaining: Int {
        get {
            
            var download = 0
            if let value = speed {
                download = value.download
            }
            if download == 0 {
                return -1
            }
            
            let remainingLength = totalLength! - completedLength!
            
            return remainingLength / download
        }
    }
    public var speed: Aria2Speed?
    
    public var progress: Double {
        get {
            if totalLength == 0 {
                return -1
            } else if completedLength == totalLength {
                return 100.0
            } else {
                return Double(completedLength!) / Double(totalLength!) * 100
            }
        }
    }
    public var progressString: String {
        get {
            if progress == -1 {
                return "Unknown"
            } else {
                return String(format: "%.2f", progress) + " %"
            }
        }
    }
    public var fileSize: Int?
    public var fileSizeString: String {
        get {
            if fileSize == 0 {
                return "Unknown"
            }
            
            var size = 0.0
            if let value = fileSize {
                size = Double(value) / 1024.0
            }
            return getStringByFileSize(size)
        }
    }
    public var remainingString: String {
        get {
            if remaining == -1 {
                return " ∞ remaining"
            }
            
            let hou = remaining / (60 * 60)
            let min = remaining / 60 % 60
            let sec = remaining % 60
            
            return String(format: "%02d:%02d:%02d remaining", hou, min, sec)
            
        }
    }
        
    private func getStringByFileSize(_ value: Double) -> String {
        if value > 1024 * 1024 {
            return String(format: "%.2f GB", value / 1024.0 / 1024.0)
        } else if value > 1024 {
            return String(format: "%.2f MB", value / 1024.0)
        } else {
            return String(format: "%.2f KB", value)
        }
    }
}
