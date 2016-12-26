//
//  Extension.swift
//  YouGet
//
//  Created by ShinCurry on 2016/12/14.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

import Foundation

func LocalizedString(_ key: String) -> String {
    let bundle = Bundle(identifier: "com.windisco.YouGet")
    return NSLocalizedString(key, tableName: nil, bundle: bundle!, value: "", comment: "")
}
