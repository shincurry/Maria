//
//  ACDownloadHandler.m
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/16.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import "ACDownloadHandle.h"
#include "aria2.h"
#import "ACModel.h"
#import "ACUriData.h"
#import "ACFileData.h"
#import "ACBtMetaInfoData.h"
#import "ACTool.h"

typedef std::vector<std::string> Uris;
typedef uint64_t Gid;
typedef std::vector<uint64_t> Gids;
typedef aria2::KeyVals KeyVals;
typedef aria2::OffsetMode OffsetMode;

@implementation ACDownloadHandle {
    aria2::DownloadHandle * handle;
}

- (instancetype)initWithSession: (struct aria2::Session *)session
                         andGid: (ACGid *)gid {
    self = [super init];
    if (self) {
        handle = aria2::getDownloadHandle(session, [gid unsignedLongLongValue]);
    }
    return self;
}

- (void)dealloc {
    aria2::deleteDownloadHandle(handle);
}

- (aria2::DownloadHandle *)getDownloadHandle {
    return handle;
}

- (ACDownloadStatus)getSatus {
    aria2::DownloadStatus status = handle->getStatus();
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

- (ACLength *)getTotalLength {
    return [NSNumber numberWithUnsignedLongLong:handle->getTotalLength()];
}

- (ACLength *)getCompletedLength {
    return [NSNumber numberWithUnsignedLongLong:handle->getCompletedLength()];
}

- (ACLength *)getUploadLength {
    return [NSNumber numberWithUnsignedLongLong:handle->getUploadLength()];
}

- (NSString *)getBitfield {
    return [NSString stringWithCString:handle->getBitfield().c_str() encoding:NSUTF8StringEncoding];
}

- (int)getDownloadSpeed {
    return handle->getDownloadSpeed();
}

- (int)getUploadSpeed {
    return handle->getUploadSpeed();
}

- (NSString *)getInfoHash {
    return [NSString stringWithCString:handle->getInfoHash().c_str() encoding:NSUTF8StringEncoding];
}

- (size_t)getPieceLength {
    return handle->getPieceLength();
}

- (int)getNumPieces {
    return handle->getNumPieces();
}

- (int)getConnections {
    return handle->getConnections();
}

- (int)getErrorCode {
    return handle->getErrorCode();
}

- (ACGids *)getFollowedBy {
    return GidsToAC(handle->getFollowedBy());
}
- (ACGid *)getFollowing {
    return [NSNumber numberWithUnsignedLongLong:handle->getFollowing()];
}
- (ACGid *)getBelongsTo {
    return [NSNumber numberWithUnsignedLongLong:handle->getBelongsTo()];
}
- (NSArray<ACFileData *> *)getFiles {
    std::vector<aria2::FileData> files = handle->getFiles();
    NSMutableArray<ACFileData *> * _files;
    for (auto it = files.begin(); it != files.end(); ++it) {
        ACFileData * file;
        [file setIndex:it->index];
        [file setPath:[NSString stringWithCString:(it->path).c_str() encoding:NSUTF8StringEncoding]];
        [file setLength:[NSNumber numberWithUnsignedLongLong:it->length]];
        [file setCompletedLength:[NSNumber numberWithUnsignedLongLong:it->completedLength]];
        [file setSelected:it->selected];
        
        NSMutableArray<ACUriData *> * _uris;
        for (auto it2 = (it->uris).begin(); it2 != (it->uris).end(); ++it2) {
            ACUriData * uri;
            [uri setUri:[NSString stringWithCString:it2->uri.c_str() encoding:NSUTF8StringEncoding]];
            [uri setStatus:UriStatusToAC(it2->status)];
            [_uris addObject:uri];
        }
        
        [file setUris:_uris];
        [_files addObject: file];
    }
    NSArray<ACFileData *> * result = [_files copy];
    return result;
}
- (int)getNumFiles {
    return handle->getNumFiles();
}

- (ACFileData *)getFileByIndex: (int)index {
    aria2::FileData file = handle->getFile(index);
    ACFileData * _file;
    [_file setIndex:file.index];
    [_file setPath:[NSString stringWithCString:(file.path).c_str() encoding:NSUTF8StringEncoding]];
    [_file setLength:[NSNumber numberWithUnsignedLongLong:file.length]];
    [_file setCompletedLength:[NSNumber numberWithUnsignedLongLong:file.completedLength]];
    [_file setSelected:file.selected];
    
    NSMutableArray<ACUriData *> * _uris;
    for (auto it2 = (file.uris).begin(); it2 != (file.uris).end(); ++it2) {
        ACUriData * uri;
        [uri setUri:[NSString stringWithCString:it2->uri.c_str() encoding:NSUTF8StringEncoding]];
        [uri setStatus:UriStatusToAC(it2->status)];
        [_uris addObject:uri];
    }
    [_file setUris:_uris];
    
    return _file;
}
- (ACBtMetaInfoData *)getBtMetaInfo {
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
    
    ACBtFileMode _mode;
    switch (data.mode) {
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
    [_data setMode:_mode];
    [_data setName:[NSString stringWithCString:data.name.c_str() encoding:NSUTF8StringEncoding]];
    
    return _data;
}
- (NSString *)getOptionByName: (NSString *) name {
    return [NSString stringWithCString:handle->getOption([name cStringUsingEncoding:NSUTF8StringEncoding]).c_str() encoding:NSUTF8StringEncoding];
}

- (ACKeyVals *)getOptions {
    return KeyValsToAC(handle->getOptions());
}

@end
