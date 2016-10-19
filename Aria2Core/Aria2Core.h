//
//  Aria2Core.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/9/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACModel.h"
#import "ACDownloadHandle.h"
#import "ACGlobalStatus.h"

FOUNDATION_EXPORT NSString * const EmbeddedAria2Version;


@interface Aria2Core : NSObject {
    dispatch_queue_t aria2Queue;
}

- (instancetype)init;
- (instancetype)initWithOptions: (NSDictionary *)options;

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

- (ACDownloadHandle *)getDownloadHandleByGid: (ACGid *)gid;

- (int)deleteACDownloadHandleByGid: (ACGid *)gid;

@end
