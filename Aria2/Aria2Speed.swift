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
            let dl = Double(download) / 1024.0
            return self.getStringBySpeed(dl)
        }
    }
    public var uploadString: String {
        get {
            let ul = Double(upload) / 1024.0
            return self.getStringBySpeed(ul)
        }
    }
    private func getStringBySpeed(_ value: Double) -> String {
        if value > 1024 {
            return String(format: "%.2f MB/s", value / 1024.0)
        } else {
            return String(format: "%.2f KB/s", value)
        }
    }
}
