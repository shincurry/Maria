//
//  Aria2Speed.swift
//  Aria2
//
//  Created by ShinCurry on 16/5/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

public struct Aria2Speed {
    init(download: Int, upload: Int) {
        self.download = download
        self.upload = upload
    }
    
    public var download: Int
    public var upload: Int
    
    public var downloadString: String {
        get {
            return self.getStringBySpeed(download)
        }
    }
    public var uploadString: String {
        get {
            return self.getStringBySpeed(upload)
        }
    }
    private func getStringBySpeed(_ value: Int) -> String {
        let kbps = Double(value) / 1024.0
        if kbps > 1024 {
            return String(format: "%.2f MB/s", kbps / 1024.0)
        } else if value > 1 {
            return String(format: "%.2f KB/s", kbps)
        } else {
            return String(format: "%d B/s", value)
        }
    }
    
    public var downloadIntString: String {
        get {
            return self.getIntStringBySpeed(download)
        }
    }
    public var uploadIntString: String {
        get {
            return self.getIntStringBySpeed(upload)
        }
    }
    
    private func getIntStringBySpeed(_ value: Int) -> String {
        let kbps = value / 1024
        if kbps > 1024 {
            return String(format: "%d MB/s", kbps / 1024)
        } else if value > 1 {
            return String(format: "%d KB/s", kbps)
        } else {
            return String(format: "%d B/s", value)
        }
    }
    
}
