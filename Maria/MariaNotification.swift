//
//  Aria2Notification.swift
//  Aria2
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

public class MariaNotification {
    static public func notification(title title: String, details: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = details
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    static public func actionNotification(identifier identifier: String, title: String, details: String, userInfo: [String: AnyObject]?) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = details
        notification.identifier = identifier
        notification.userInfo = userInfo
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
}