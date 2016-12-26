//
//  ACGlobalStatus.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACGlobalStatus : NSObject

@property (nonatomic) int downloadSpeed;
@property (nonatomic) int uploadSpeed;
@property (nonatomic) int numberOfActive;
@property (nonatomic) int numberOfStopped;
@property (nonatomic) int numberOfWaiting;

@end
