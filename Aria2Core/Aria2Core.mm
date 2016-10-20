//
//  Aria2Core.m
//  Aria2Core
//
//  Created by ShinCurry on 2016/9/20.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <chrono>
#include <ratio>
#include <thread>
#import "Aria2Core.h"
#include "aria2.h"
#include <map>
#import "ACGlobalStatus.h"
#import "ACFileData.h"
#import "ACBtMetaInfoData.h"

NSString * const EmbeddedAria2Version = @"1.28.0";

typedef std::vector<std::string> Uris;
typedef uint64_t Gid;
typedef std::vector<uint64_t> Gids;
typedef aria2::KeyVals KeyVals;
typedef aria2::OffsetMode OffsetMode;
typedef aria2::BtFileMode BtFileMode;
typedef aria2::UriData UriData;
typedef std::vector<UriData> UriDatas;
typedef aria2::FileData FileData;

@implementation Aria2Core {
    aria2::Session * session;
    aria2::DownloadHandle * downloadHandle;
    std::map<std::string, aria2::DownloadHandle *> handles;
}

#pragma mark - Initial

-(instancetype)init {
    return [self initWithOptions: @{}];
}

- (instancetype)initWithOptions: (ACKeyVals *)options {
    self = [super init];
    if (self) {
        aria2Queue = dispatch_queue_create("com.windisco.Maria.gcd.aria2core", DISPATCH_QUEUE_SERIAL);
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
        std::this_thread::sleep_for(std::chrono::duration<double, std::milli>(100));
    }
    aria2::shutdown(session);
    dispatch_sync(aria2Queue, ^{
        aria2::sessionFinal(session);
    });
    aria2::libraryDeinit();
}

#pragma mark - Aria2 Objective-C API

- (ACGid *)addUri:(ACUris *)uris
      withOptions:(ACKeyVals *)options {
    Uris _uris = ACToUris(uris);
    aria2::KeyVals _options = ACToKeyVals(options);
    Gid gid;
    if (aria2::addUri(session, &gid, _uris, _options) != 0) {
        return nil;
    }
    if (aria2::isNull(gid)) {
        return nil;
    }
    return GidToAC(gid);
}

- (ACGids *)addMetalink:(NSString *)metalink
       withOptions:(ACKeyVals *)options {
    std::string _metalink = [metalink cStringUsingEncoding:NSUTF8StringEncoding];
    Gids * gids;
    aria2::KeyVals _options = ACToKeyVals(options);
    if (aria2::addMetalink(session, gids, _metalink, _options) != 0) {
        return nil;
    }
    if (gids == nil) {
        return nil;
    }
    return GidsToAC(*gids);
}

- (ACGid *)addTorrent: (NSString *)torrent
      withOptions: (ACKeyVals *)options {
    std::string _torrent = [torrent cStringUsingEncoding:NSUTF8StringEncoding];
    aria2::KeyVals _options = ACToKeyVals(options);
    Gid gid;
    if (aria2::addTorrent(session, &gid, _torrent, _options) != 0) {
        return nil;
    }
    if (aria2::isNull(gid)) {
        return nil;
    }
    return GidToAC(gid);
}

- (ACGid *)addTorrent: (NSString *)torrent
   andWebSeedUris: (ACUris *)uris
      withOptions: (ACKeyVals *)options {
    std::string _torrent = [torrent cStringUsingEncoding:NSUTF8StringEncoding];
    Uris _uris = ACToUris(uris);
    aria2::KeyVals _options = ACToKeyVals(options);
    Gid gid;
    if (aria2::addTorrent(session, &gid, _torrent, _uris, _options) != 0) {
        return nil;
    }
    if (aria2::isNull(gid)) {
        return nil;
    }
    return GidToAC(gid);
}

- (ACGids *)getActiveDownload {
    return GidsToAC(aria2::getActiveDownload(session));
}

- (int)removeTasksByGid:(ACGid *)gid
           byForce:(bool)force {
    return aria2::removeDownload(session, ACToGid(gid), force);
}

- (int)pauseTasksByGid:(ACGid *)gid
           byForce:(bool)force {
    return aria2::pauseDownload(session, ACToGid(gid), force);
}

- (int)unpauseTasksByGid:(ACGid *)gid {
    return aria2::unpauseDownload(session, ACToGid(gid));
}

- (int)changeOptionsByGid: (ACGid *)gid
           withNewOptions: (ACKeyVals *)options {
    KeyVals _options = ACToKeyVals(options);
    return aria2::changeOption(session, ACToGid(gid), _options);
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
    return aria2::changePosition(session, ACToGid(gid), position, ACToOffsetMode(mode));
}

- (int)shutdownByforce: (bool)force {
    return aria2::shutdown(session, force);
}

#pragma mark - DownloadHandle implementation

- (ACDownloadStatus)getSatusByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return DownloadStatusToAC(handle->getStatus());
}

- (ACLength)getTotalLengthByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getTotalLength();
}

- (ACLength)getCompletedLengthByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getCompletedLength();
}

- (ACLength)getUploadLengthByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getUploadLength();
}

- (NSString *)getBitfieldByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return [NSString stringWithCString:handle->getBitfield().c_str() encoding:NSUTF8StringEncoding];
}

- (int)getDownloadSpeedByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getDownloadSpeed();
}

- (int)getUploadSpeedByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getUploadSpeed();
}

- (NSString *)getInfoHashByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return [NSString stringWithCString:handle->getInfoHash().c_str() encoding:NSUTF8StringEncoding];
}

- (size_t)getPieceLengthByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getPieceLength();
}

- (int)getNumberOfPiecesByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getNumPieces();
}

- (int)getConnectionsByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getConnections();
}

- (int)getErrorCodeByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getErrorCode();
}

- (ACGids *)getFollowedByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return GidsToAC(handle->getFollowedBy());
}

- (ACGid *)getFollowingByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return GidToAC(handle->getFollowing());
}

- (ACGid *)getBelongsToGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return GidToAC(handle->getBelongsTo());
}

- (NSArray<ACFileData *> *)getFilesByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    std::vector<aria2::FileData> files = handle->getFiles();
    NSMutableArray<ACFileData *> * _files;
    for (auto it = files.begin(); it != files.end(); ++it) {
        [_files addObject: FileDataToAC(*it)];
    }
    NSArray<ACFileData *> * result = [_files copy];
    return result;
}

- (int)getNumberOfFilesByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return handle->getNumFiles();
}

- (ACFileData *)getFileByIndex: (int)index
                         andGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return FileDataToAC(handle->getFile(index));
}

- (ACBtMetaInfoData *)getBtMetaInfoByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    ACBtMetaInfoData * _data;
    aria2::BtMetaInfoData data = handle->getBtMetaInfo();
    NSMutableArray<NSArray<NSString *> *> * announceList;
    for (auto it = data.announceList.begin(); it != data.announceList.end(); ++it) {
        NSMutableArray<NSString *> * section;
        for (auto it2 = it->begin(); it2 != it->end(); ++it2) {
            [section addObject:[NSString stringWithCString:it2->c_str() encoding:NSUTF8StringEncoding]];
        }
        [announceList addObject:[section copy]];
    }
    NSArray<NSArray<NSString *> *> * _announceList = [announceList copy];
    [_data setAnnounceList:_announceList];
    [_data setComment:[NSString stringWithCString:data.name.c_str() encoding:NSUTF8StringEncoding]];
    [_data setCreationDate:[NSDate dateWithTimeIntervalSince1970:data.creationDate]];
    [_data setMode:BtFileModeToAC(data.mode)];
    [_data setName:[NSString stringWithCString:data.name.c_str() encoding:NSUTF8StringEncoding]];
    return _data;
}

- (NSString *)getOptionByName: (NSString *) name
                       andGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return [NSString stringWithCString:handle->getOption([name cStringUsingEncoding:NSUTF8StringEncoding]).c_str() encoding:NSUTF8StringEncoding];
}

- (ACKeyVals *)getOptionsByGid:(ACGid *)gid {
    aria2::DownloadHandle * handle = [self getDownloadHandleByGid:gid];
    return KeyValsToAC(handle->getOptions());
}

- (class aria2::DownloadHandle *)getDownloadHandleByGid: (ACGid *)gid {
    std::string key = [gid cStringUsingEncoding:NSUTF8StringEncoding];
    auto it = handles.find(key);
    aria2::DownloadHandle * handle;
    if(it == handles.end()) {
        handle = aria2::getDownloadHandle(session, ACToGid(gid));
        handles.insert(std::make_pair(key, handle));
    } else {
        handle = it->second;
    }
    return handle;
}

- (int)deleteDownloadHandleByGid: (ACGid *)gid {
    std::string key = [gid cStringUsingEncoding:NSUTF8StringEncoding];
    auto it = handles.find(key);
    if(it != handles.end()) {
        handles.erase(it);
        return 0;
    } else {
        return -1;
    }
}

#pragma mark - C Function Tool

// use c function to transform data
KeyVals ACToKeyVals(ACKeyVals * options) {
    KeyVals _options;
    for (NSString * key in [options allKeys]) {
        std::string first = [key cStringUsingEncoding:NSUTF8StringEncoding];
        std::string second = [options[key] cStringUsingEncoding:NSUTF8StringEncoding];
        _options.push_back(std::make_pair(first, second));
    }
    return _options;
}

ACKeyVals * KeyValsToAC(KeyVals options) {
    NSMutableDictionary<NSString *, NSString *> * _options;
    
    for (auto it = options.begin(); it != options.end(); ++it) {
        NSString * key = [NSString stringWithCString:(it->first).c_str() encoding:NSUTF8StringEncoding];
        NSString * value = [NSString stringWithCString:(it->first).c_str() encoding:NSUTF8StringEncoding];
        [_options setValue:value forKey:key];
    }
    ACKeyVals * result = [_options copy];
    return result;
}

Uris ACToUris(ACUris * uris) {
    Uris _uris;
    
    for (ACUri * uri in uris) {
        _uris.push_back(uri.UTF8String);
    }
    return _uris;
}

Gids ACToGids(ACGids * gids) {
    Gids _gids;
    for (ACGid * gid in gids) {
        _gids.push_back(ACToGid(gid));
    }
    return _gids;
}

ACGids * GidsToAC(Gids gids) {
    NSMutableArray<NSString *> * _gids;
    for (auto it = gids.begin(); it != gids.end(); ++it) {
        [_gids addObject:GidToAC(*it)];
    }
    ACGids * result = [_gids copy];
    return result;
}

Gid ACToGid(ACGid * gid) {
    
    return aria2::hexToGid([gid cStringUsingEncoding:NSUTF8StringEncoding]);
}

ACGid * GidToAC(Gid gid) {
    return [NSString stringWithCString:aria2::gidToHex(gid).c_str() encoding:NSUTF8StringEncoding];
}

ACUriStatus UriStatusToAC(aria2::UriStatus status) {
    ACUriStatus _status;
    switch (status) {
        case aria2::URI_USED:
            _status = ACUriStatusUsed;
            break;
        case aria2::URI_WAITING:
            _status = ACUriStatusWaiting;
            break;
        default:
            _status = ACUriStatusWaiting;
            break;
    }
    return _status;
}

ACDownloadStatus DownloadStatusToAC(aria2::DownloadStatus status) {
    ACDownloadStatus _status;
    switch (status) {
        case aria2::DOWNLOAD_ACTIVE:
            _status = ACDownloadStatusActive;
            break;
        case aria2::DOWNLOAD_WAITING:
            _status = ACDownloadStatusWaiting;
            break;
        case aria2::DOWNLOAD_PAUSED:
            _status = ACDownloadStatusPaused;
            break;
        case aria2::DOWNLOAD_COMPLETE:
            _status = ACDownloadStatusComplete;
            break;
        case aria2::DOWNLOAD_ERROR:
            _status = ACDownloadStatusError;
            break;
        case aria2::DOWNLOAD_REMOVED:
            _status = ACDownloadStatusRemoved;
            break;
        default:
            _status = ACDownloadStatusRemoved;
            break;
    }
    return _status;
}

OffsetMode ACToOffsetMode(ACOffsetMode mode) {
    OffsetMode _mode;
    switch (mode) {
        case ACOffsetModeBegin:
            _mode = aria2::OFFSET_MODE_SET;
            break;
        case ACOffsetModeCurrent:
            _mode = aria2::OFFSET_MODE_CUR;
            break;
        case ACOffsetModeEnd:
            _mode = aria2::OFFSET_MODE_END;
            break;
        default:
            _mode = aria2::OFFSET_MODE_SET;
            break;
    }
    return _mode;
}

ACBtFileMode BtFileModeToAC(BtFileMode mode) {
    ACBtFileMode _mode;
    switch (mode) {
        case aria2::BT_FILE_MODE_NONE:
            _mode = ACBtFileModeNone;
            break;
        case aria2::BT_FILE_MODE_SINGLE:
            _mode = ACBtFileModeSingle;
            break;
        case aria2::BT_FILE_MODE_MULTI:
            _mode = ACBtFileModeMultiple;
            break;
        default:
            _mode = ACBtFileModeNone;
            break;
    }
    return _mode;
}

ACUriDatas * UriDatasToAC(UriDatas datas) {
    NSMutableArray<ACUriData *> * _uris;
    for (auto it2 = datas.begin(); it2 != datas.end(); ++it2) {
        ACUriData * uri;
        [uri setUri:[NSString stringWithCString:it2->uri.c_str() encoding:NSUTF8StringEncoding]];
        [uri setStatus:UriStatusToAC(it2->status)];
        [_uris addObject:uri];
    }
    return [_uris copy];
}

ACFileData * FileDataToAC(FileData data) {
    ACFileData * _file;
    [_file setIndex:data.index];
    [_file setPath:[NSString stringWithCString:(data.path).c_str() encoding:NSUTF8StringEncoding]];
    [_file setLength:data.length];
    [_file setCompletedLength:data.completedLength];
    [_file setSelected:data.selected];
    [_file setUris:UriDatasToAC(data.uris)];
    return _file;
}

int downloadEventCallback(aria2::Session* session, aria2::DownloadEvent event, aria2::A2Gid gid, void* userData) {
    printf("event is %d\n", event);
    return 0;
}

@end
