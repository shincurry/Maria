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
    case tellWaiting
    case tellStopped
    case shutdown
    case forceShutdown
    
    case addUri
    case addTorrent
    
    case getUris
    
    case changeGlobalOption
    
    case remove
    case removeDownloadResult
    case purgeDownloadResult
    
    case pause
    case pauseAll
    case unpause
    case unpauseAll

    // Aria2 Notification Method
    case onDownloadStart
    case onDownloadPause
    case onDownloadStop
    case onDownloadComplete
    case onBtDownloadComplete
    case onDownloadError
    
}
