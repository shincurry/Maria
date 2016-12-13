//
//  YGStream.swift
//  YouGet
//
//  Created by ShinCurry on 2016/12/13.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct YGStream {
    public var container: String
    public var size: Int
    public var sources: [String]
    public var key: String
    public var name: String
    
    init?(key: String, json: JSON) {
        self.key = key
        self.container = json["container"].string ?? "__unknown__"
        self.size = json["size"].int ?? 0
        self.name = json["video_profile"].string ?? "__unknown__"
        
        if let sources = json["src"].array?.map({ $0.stringValue }), !sources.isEmpty {
            self.sources = sources
        } else {
            return nil
        }
        
        localize()
    }
    
    private mutating func localize() {
        if self.name == "__default__" {
            self.name = LocalizedString("default")
        }
        if self.container == "__unknown__" {
            self.name = LocalizedString("unknown")
        }
        if self.name == "__unknown__" {
            self.name = LocalizedString("unknown")
        }
    }
}
