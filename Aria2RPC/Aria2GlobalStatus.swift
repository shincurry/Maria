//
//  Aria2GlobalStatus.swift
//  Aria2
//
//  Created by ShinCurry on 16/5/12.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

public struct Aria2GlobalStatus {
    public var speed: Aria2Speed?
    public var numberOfActiveTask: Int?
    public var numberOfWaitingTask: Int?
    public var numberOfStoppedTask: Int?
    public var numberOfTotalStoppedTask: Int?
}