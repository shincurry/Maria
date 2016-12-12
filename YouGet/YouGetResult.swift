//
//  YouGetResult.swift
//  YouGet
//
//  Created by ShinCurry on 2016/12/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import SwiftyJSON

public struct YouGetResult: CustomStringConvertible {
    public var site: String
    public var title: String
    public var url: String?
    public var container: String
    public var size: Int?
    public var sources: [String]
    
    init?(json: JSON) {
        let jsonStreams = json["streams"]["__default__"]
        
        guard let title = json["title"].string, let site = json["site"].string, let container = jsonStreams["container"].string, let sources = jsonStreams["src"].array?.map({ $0.stringValue }) else {
            print("JSON parse failed.")
            return nil
        }
        self.title = title
        self.site = site
        self.container = container
        self.sources = sources
        
        self.size = jsonStreams["size"].int
        self.url = json["url"].string
    }
    
    public var description: String {
        var message = "● Site: \(site)\n"
        message += "● Title: \(title)\n"
        if let size = size {
            message += "● Size: \(getStringByFileSize(size))\n"
        }
        message += "● Type: \(container)\n"
        message += "● Real Urls: \n"
        sources.forEach { message += "  ○ \($0)\n" }
        return message
    }
    
    private func getStringByFileSize(_ value: Int) -> String {
        let kbps = Double(value) / 1024.0
        if kbps > 1024 {
            return String(format: "%.2f MB", kbps / 1024.0)
        } else if value > 1 {
            return String(format: "%.2f KB", kbps)
        } else {
            return String(format: "%d B", value)
        }
    }
}
