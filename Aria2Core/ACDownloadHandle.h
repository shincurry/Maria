//
//  ACDownloadHandler.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/16.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACModel.h"
#import "ACFileData.h"
#import "ACBtMetaInfoData.h"
#include "aria2.h"

typedef NSDictionary<NSString *, NSString *> ACKeyVals;
typedef NSString ACUri;
typedef NSArray<NSString *> ACUris;
typedef NSNumber ACGid;
typedef NSArray<NSNumber *> ACGids;

@interface ACDownloadHandle : NSObject


- (instancetype)initWithSession: (struct aria2::Session *)session
                         andGid: (ACGid *)gid;

- (void)dealloc;

- (aria2::DownloadHandle *)getDownloadHandle;


- (ACDownloadStatus)getSatus;

- (ACLength *)getTotalLength;

- (ACLength *)getCompletedLength;

- (ACLength *)getUploadLength;

- (NSString *)getBitfield;

- (int)getDownloadSpeed;

- (int)getUploadSpeed;

- (NSString *)getInfoHash;

- (size_t)getPieceLength;

- (int)getNumPieces;

- (int)getConnections;

- (int)getErrorCode;

- (ACGids *)getFollowedBy;

- (ACGid *)getFollowing;

- (ACGid *)getBelongsTo;

- (ACFileData *)getFiles;

- (int)getNumFiles;

- (ACFileData *)getFileByIndex: (int)index;

- (ACBtMetaInfoData *)getBtMetaInfo;

- (NSString *)getOptionByName: (NSString *) name;

- (ACKeyVals *)getOptions;

@end
