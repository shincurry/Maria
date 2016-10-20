//
//  Aria2Core.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/9/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACFileData.h"
#import "ACBtMetaInfoData.h"
#import "ACGlobalStatus.h"

FOUNDATION_EXPORT NSString * const EmbeddedAria2Version;

typedef NSDictionary<NSString *, NSString *> ACKeyVals;
typedef NSString ACUri;
typedef NSArray<NSString *> ACUris;
typedef NSNumber ACGid;
typedef NSArray<NSNumber *> ACGids;
typedef NSArray<ACUriData *> ACUriDatas;

typedef enum {
    ACOffsetModeBegin,
    ACOffsetModeCurrent,
    ACOffsetModeEnd
} ACOffsetMode;

typedef enum {
    ACDownloadStatusActive,
    ACDownloadStatusWaiting,
    ACDownloadStatusPaused,
    ACDownloadStatusComplete,
    ACDownloadStatusError,
    ACDownloadStatusRemoved
} ACDownloadStatus;

@interface Aria2Core : NSObject {
    dispatch_queue_t aria2Queue;
}

#pragma mark - initial

- (instancetype)init;
- (instancetype)initWithOptions: (NSDictionary *)options;


#pragma mark - Aria2Core Interface

- (int)addUri: (ACUris *)uris
        toGid: (ACGid *)gid
  withOptions: (ACKeyVals *)options;

- (int)addMetalink: (NSString *)metalink
            toGids: (ACGids *)gids
       withOptions: (ACKeyVals *) options;

- (int)addTorrent: (NSString *)torrent
            toGid: (ACGid *)gid
      withOptions: (ACKeyVals *)options;

- (int)addTorrent: (NSString *)torrent
   andWebSeedUris: (ACUris *)uris
            toGid: (ACGid *)gid
      withOptions: (ACKeyVals *)options;

- (ACGids *)getActiveDownload;

- (int)removeTasks: (ACGid *)gid
           byForce: (bool)force;

- (int)pauseTasks: (ACGid *)gid
          byForce: (bool)force;

- (int)unpauseTasks: (ACGid *)gid;

- (int)changeOptions: (ACGid *)gid
      withNewOptions: (ACKeyVals *)options;

- (NSString *)getGlobalOptionByName: (NSString *)name;

- (ACKeyVals *)getGlobalOptions;

- (int)changeGlobalOptionWithNewOptions: (ACKeyVals *)options;

- (ACGlobalStatus *)getGlobalStatus;

- (int)changePosition:(ACGid *)gid
                   to: (int) position
             withMode: (ACOffsetMode) mode;

- (int)shutdownByforce: (bool)force;

#pragma mark - DownloadHandle Interface

- (ACDownloadStatus)getSatusByGid: (ACGid *)gid;

- (ACLength *)getTotalLengthByGid: (ACGid *)gid;

- (ACLength *)getCompletedLengthByGid: (ACGid *)gid;

- (ACLength *)getUploadLengthByGid: (ACGid *)gid;

- (NSString *)getBitfieldByGid: (ACGid *)gid;

- (int)getDownloadSpeedByGid: (ACGid *)gid;

- (int)getUploadSpeedByGid: (ACGid *)gid;

- (NSString *)getInfoHashByGid: (ACGid *)gid;

- (size_t)getPieceLengthByGid: (ACGid *)gid;

- (int)getNumPiecesByGid: (ACGid *)gid;

- (int)getConnectionsByGid: (ACGid *)gid;

- (int)getErrorCodeByGid: (ACGid *)gid;

- (ACGids *)getFollowedByGid: (ACGid *)gid;

- (ACGid *)getFollowingByGid: (ACGid *)gid;

- (ACGid *)getBelongsToGid: (ACGid *)gid;

- (ACFileData *)getFilesByGid: (ACGid *)gid;

- (int)getNumFilesByGid: (ACGid *)gid;

- (ACFileData *)getFileByIndex: (int)index
                        andGid: (ACGid *)gid;

- (ACBtMetaInfoData *)getBtMetaInfoByGid: (ACGid *)gid;

- (NSString *)getOptionByName: (NSString *)name
                       andGid: (ACGid *)gid;

- (ACKeyVals *)getOptionsByGid: (ACGid *)gid;

@end
