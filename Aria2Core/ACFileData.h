//
//  ACFileData.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACUriData.h"

typedef NSNumber ACLength;

@interface ACFileData : NSObject

@property (nonatomic) int index;
@property (nonatomic, copy) NSString * path;
@property (nonatomic, copy) ACLength * length;
@property (nonatomic, copy) ACLength * completedLength;
@property (nonatomic) bool selected;
@property (nonatomic, copy) NSArray<ACUriData *> * uris;

@end
