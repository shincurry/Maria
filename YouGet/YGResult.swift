//
//  YouGetResult.swift
//  YouGet
//
//  Created by ShinCurry on 2016/12/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Cocoa
import SwiftyJSON

public struct YGResult: CustomStringConvertible {
    public var site: String
    public var title: String
    public var url: String
    public var streams: [YGStream]
    
    init(json: JSON) {
        let jsonStreams = json["streams"]

        self.title = json["title"].stringValue
        self.site = json["site"].stringValue
        
        self.streams = []
        for (key, json) in jsonStreams {
            if let stream = YGStream(key: key, json: json) {
                self.streams.append(stream)
            }
        }
        self.streams.sort { $0.size > $1.size }
        
        self.url = json["url"].string ?? ""
    }
    
    public var description: String {
        var message = "● \(LocalizedString("site")): \(site)\n"
        message += "● \(LocalizedString("title")): \(title)\n"
        message += "● Streams:\n"
        streams.forEach { stream in
            message += "    ● \(stream.name)\n"
            message += "        ○ \(LocalizedString("size")): \(getStringByFileSize(stream.size))\n"
            message += "        ○ \(LocalizedString("realUrls")): \(stream.sources.first!)\n"
        }
        return message
    }
    
    private func getStringByFileSize(_ value: Int) -> String {
        let kbps = Double(value) / 1024.0
        if kbps > 1024 {
            return String(format: "%.2f MB", kbps / 1024.0)
        } else if kbps > 1 {
            return String(format: "%.2f KB", kbps)
        } else if kbps > 0{
            return String(format: "%d B", value)
        } else {
            return LocalizedString("unknown")
        }
    }
}
