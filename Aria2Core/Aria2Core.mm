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

-(instancetype)init {
    return [self initWithOptions: @{}];
}

- (instancetype)initWithOptions: (NSDictionary *) optionsDict {
    self = [super init];
    if (self) {
        NSLog(@"init");
        aria2Queue = dispatch_queue_create("aria2core.queue", DISPATCH_QUEUE_SERIAL);
        aria2::libraryInit();
        aria2::KeyVals options = dictToKeyVals(optionsDict);
        aria2::SessionConfig config;
        config.keepRunning = true;
        config.downloadEventCallback = downloadEventCallback;
        session = aria2::sessionNew(options, config);
        dispatch_async(aria2Queue, ^{
            // BUG 如果已经有 aria2c 在运行，此处会 Crash ，待修复
            aria2::run(session, aria2::RUN_DEFAULT);
        });
    }
    return self;
}

- (void)dealloc {
    std::vector<aria2::A2Gid> taskDownloading = aria2::getActiveDownload(session);
    for (auto i = taskDownloading.begin(); i != taskDownloading.end(); ++i) {
        aria2::pauseDownload(session, *i);
    }
    while (aria2::getGlobalStat(session).numActive > 0) {
        system("sleep 0.1"); // +1s
    }
    printf("all task paused\n");
    aria2::shutdown(session);
    dispatch_sync(aria2Queue, ^{
        aria2::sessionFinal(session);
        printf("sessionFinal\n");
    });
    aria2::libraryDeinit();
    printf("dealloc\n");
}

aria2::KeyVals dictToKeyVals(NSDictionary* ns_dict) {
    aria2::KeyVals keyvals;
    for (NSString* key in [ns_dict allKeys]) {
        std::string key_str([key cStringUsingEncoding:NSUTF8StringEncoding]);
        std::string value_str([ns_dict[key] cStringUsingEncoding:NSUTF8StringEncoding]);
        keyvals.push_back(std::make_pair(key_str, value_str));
    }
    return keyvals;
}

int downloadEventCallback(aria2::Session* session, aria2::DownloadEvent event,
                          aria2::A2Gid gid, void* userData) {
    printf("event is %d\n", event);
    return 0;
}


@end
