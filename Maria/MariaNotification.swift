//
//  Aria2Notification.swift
//  Aria2
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

open class MariaNotification {
    static open func notification(title: String, details: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = details
        NSUserNotificationCenter.default.deliver(notification)
    }
    static public func actionNotification(identifier: String, title: String, details: String, userInfo: [String: AnyObject]?) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = details
        notification.identifier = identifier
        notification.userInfo = userInfo
        NSUserNotificationCenter.default.deliver(notification)
    }
}
