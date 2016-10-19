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
#import "ACModel.h"
#import "ACGlobalStatus.h"
#import "ACDownloadHandle.h"
#import "ACTool.h"

//typedef std::vector<std::string> Uris;
//typedef uint64_t Gid;
//typedef std::vector<uint64_t> Gids;
//typedef aria2::KeyVals KeyVals;
//typedef aria2::OffsetMode OffsetMode;

NSString * const EmbeddedAria2Version = @"1.28.0";

@implementation Aria2Core {
    aria2::Session * session;
    aria2::DownloadHandle * downloadHandle;
    NSDictionary<NSString *, ACDownloadHandle *> * handles;
}


#pragma mark - Initial

-(instancetype)init {
    return [self initWithOptions: @{}];
}

- (instancetype)initWithOptions: (ACKeyVals *)options {
    self = [super init];
    if (self) {
        aria2Queue = dispatch_queue_create("aria2core.queue", DISPATCH_QUEUE_SERIAL);
        aria2::libraryInit();
        aria2::KeyVals _options = ACToKeyVals(options);
        aria2::SessionConfig config;
        config.keepRunning = true;
        config.downloadEventCallback = downloadEventCallback;
        session = aria2::sessionNew(_options, config);
        dispatch_async(aria2Queue, ^{
            // BUG 如果 aria2c 运行有问题，整个 Maria 都会崩溃，待解决
            try {
                aria2::run(session, aria2::RUN_DEFAULT);
            } catch(const char * msg) {
                printf("%s", msg);
            }
        });
    }
    return self;
}

- (void)dealloc {
    Gids tasks = aria2::getActiveDownload(session);
    for (auto it = tasks.begin(); it != tasks.end(); ++it) {
        aria2::pauseDownload(session, *it);
    }
    while (aria2::getGlobalStat(session).numActive > 0) {
        system("sleep 0.1");
    }
    aria2::shutdown(session);
    dispatch_sync(aria2Queue, ^{
        aria2::sessionFinal(session);
    });
    aria2::libraryDeinit();
}


#pragma mark - Aria2 Objective-C API

- (int)addUri:(ACUris *)uris
        toGid:(ACGid *)gid
  withOptions:(ACKeyVals *)options {
    
    Uris _uris = ACToUris(uris);
    Gid _gid = gid.unsignedLongLongValue;
    aria2::KeyVals _options = ACToKeyVals(options);
    return aria2::addUri(session, &_gid, _uris, _options);
}

- (int)addMetalink:(NSString *)metalink
            toGids:(ACGids *)gids
       withOptions:(ACKeyVals *)options {
    
    std::string _metalink = [metalink cStringUsingEncoding:NSUTF8StringEncoding];
    Gids _gids = ACToGids(gids);
    aria2::KeyVals _options = ACToKeyVals(options);
    return aria2::addMetalink(session, &_gids, _metalink, _options);
}

- (int)addTorrent: (NSString *)torrent
            toGid: (ACGid *)gid
      withOptions: (ACKeyVals *)options {
    
    std::string _torrent = [torrent cStringUsingEncoding:NSUTF8StringEncoding];
    Gid _gid = gid.unsignedLongLongValue;
    aria2::KeyVals _options = ACToKeyVals(options);
    return aria2::addTorrent(session, &_gid, _torrent, _options);
}

- (int)addTorrent: (NSString *)torrent
   andWebSeedUris: (ACUris *)uris
            toGid: (ACGid *)gid
      withOptions: (ACKeyVals *)options {
    
    std::string _torrent = [torrent cStringUsingEncoding:NSUTF8StringEncoding];
    Gid _gid = gid.unsignedLongLongValue;
    Uris _uris = ACToUris(uris);
    aria2::KeyVals _options = ACToKeyVals(options);
    return aria2::addTorrent(session, &_gid, _torrent, _uris, _options);
}

- (ACGids *)getActiveDownload {
    auto tasks = aria2::getActiveDownload(session);
    NSMutableArray<NSNumber *> * _tasks;
    for(auto const& task: tasks) {
        [_tasks addObject:[NSNumber numberWithUnsignedLongLong:task]];
    }
    NSArray * result = [_tasks copy];
    return result;
}

- (int)removeTasks:(ACGid *)gid
           byForce:(bool)force {
    
    Gid _gid = gid.unsignedLongLongValue;
    return aria2::removeDownload(session, _gid, force);
}

- (int)pauseTasks:(ACGid *)gid
           byForce:(bool)force {
    
    Gid _gid = gid.unsignedLongLongValue;
    return aria2::pauseDownload(session, _gid, force);
}

- (int)unpauseTasks:(ACGid *)gid {
    Gid _gid = gid.unsignedLongLongValue;
    return aria2::unpauseDownload(session, _gid);
}

- (int)changeOptions: (ACGid *)gid
      withNewOptions: (ACKeyVals *)options {
    
    Gid _gid = gid.unsignedLongLongValue;
    KeyVals _options = ACToKeyVals(options);
    return aria2::changeOption(session, _gid, _options);
}

- (NSString *)getGlobalOptionByName: (NSString *)name {
    std::string _name = [name cStringUsingEncoding:NSUTF8StringEncoding];
    std::string result = aria2::getGlobalOption(session, _name);
    return [NSString stringWithCString:result.c_str() encoding:NSUTF8StringEncoding];
}

- (ACKeyVals *)getGlobalOptions {
    return KeyValsToAC(aria2::getGlobalOptions(session));
}

- (int)changeGlobalOptionWithNewOptions: (ACKeyVals *)options {
    KeyVals _options = ACToKeyVals(options);
    return aria2::changeGlobalOption(session, _options);
}


- (ACGlobalStatus *)getGlobalStatus {
    aria2::GlobalStat status = aria2::getGlobalStat(session);
    ACGlobalStatus * _status;
    [_status setDownloadSpeed: status.downloadSpeed];
    [_status setUploadSpeed: status.uploadSpeed];
    [_status setNumberOfActive: status.numActive];
    [_status setNumberOfStopped: status.numStopped];
    [_status setNumberOfWaiting: status.numWaiting];
    return _status;
}

- (int)changePosition:(ACGid *)gid
                   to: (int) position
             withMode: (ACOffsetMode) mode {
    
    Gid _gid = gid.unsignedLongLongValue;
    return aria2::changePosition(session, _gid, position, ACToOffsetMode(mode));
}

- (int)shutdownByforce: (bool)force {
    return aria2::shutdown(session, force);
}

- (ACDownloadHandle *)getACDownloadHandleByGid: (ACGid *)gid {
    
    
    ACDownloadHandle * handle = [handles valueForKey:[gid stringValue]];
    if (handle == nil) {
        handle = [[ACDownloadHandle alloc] initWithSession:session andGid:gid];
        [handles setValue:handle forKey:[gid stringValue]];
    }
    return handle;
}

- (int)deleteACDownloadHandleByGid: (ACGid *)gid {
    ACDownloadHandle * handle = [handles valueForKey:[gid stringValue]];
    if (handle != nil) {
        aria2::deleteDownloadHandle(handle.getDownloadHandle);
        return 1;
    } else {
        return 0;
    }
}


#pragma mark - C Function Tool

int downloadEventCallback(aria2::Session* session, aria2::DownloadEvent event, aria2::A2Gid gid, void* userData) {
    printf("event is %d\n", event);
    return 0;
}

@end
