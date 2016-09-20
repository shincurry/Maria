//
//  Aria2Core.m
//  Aria2Core
//
//  Created by ShinCurry on 2016/9/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Aria2Core.h"
#include "aria2.h"

@implementation Aria2Core {
    aria2::Session * session;
}

- (void)initial {
    NSLog(@"init");
    aria2::libraryInit();
    aria2::SessionConfig config;
    config.keepRunning = true;
    session = aria2::sessionNew(aria2::KeyVals(), config);
}

@end
