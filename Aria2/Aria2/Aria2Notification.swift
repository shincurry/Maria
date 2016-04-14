//
//  Aria2Notification.swift
//  Aria2
//
//  Created by ShinCurry on 16/4/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

public class Aria2Notification {
    static public func downloadCompleted(name: String) {
        let notifyTitle = "Download Completed"
        let notifyDetails = "\(name) downloaded."
        notification(notifyTitle, details: notifyDetails)
    }
    
    static private func notification(title: String, details: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = details
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
}