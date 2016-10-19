//
//  ACBtMetaInfoData.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACModel.h"

@interface ACBtMetaInfoData : NSObject

@property (nonatomic, copy) NSArray<NSArray<NSString *> *> * announceList;
@property (nonatomic, copy) NSString * comment;
@property (nonatomic, copy) NSDate * creationDate;
@property (nonatomic) ACBtFileMode mode;
@property (nonatomic, copy) NSString * name;

@end
