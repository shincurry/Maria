//
//  ACFileData.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACUriData.h"

typedef int64_t ACLength;

@interface ACFileData : NSObject

@property (nonatomic) int index;
@property (nonatomic, copy) NSString * path;
@property (nonatomic) ACLength length;
@property (nonatomic) ACLength completedLength;
@property (nonatomic) bool selected;
@property (nonatomic, copy) NSArray<ACUriData *> * uris;

@end
