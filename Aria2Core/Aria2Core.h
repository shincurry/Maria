//
//  Aria2Core.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/9/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSString * const EmbeddedAria2Version;

@interface Aria2Core : NSObject {
    dispatch_queue_t aria2Queue;
}

- (instancetype)init;
- (instancetype)initWithOptions: (NSDictionary *) optionsDict;

@end
