//
//  Aria2Method.swift
//  Aria2
//
//  Created by ShinCurry on 16/4/15.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

public enum Aria2Method: String {
    // Aria2 Request Method
    case getGlobalStat

    case tellStatus
    case tellActive
    case shutdown
    
    case addUri
    case addTorrent
    
    case changeGlobalOption
    

    // Aria2 Notification Method
    case onDownloadStart
    case onDownloadPause
    case onDownloadStop
    case onDownloadComplete
    case onBtDownloadComplete
    case onDownloadError
    
}