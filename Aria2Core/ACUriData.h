//
//  ACUriData.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACModel.h"

@interface ACUriData : NSObject

@property (nonatomic, copy) NSString * uri;
@property (nonatomic) ACUriStatus status;

@end
