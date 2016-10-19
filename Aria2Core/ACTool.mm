//
//  ACTool.m
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACTool.h"
#import "aria2.h"


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
    for (NSNumber * gid in gids) {
        _gids.push_back(gid.unsignedLongLongValue);
    }
    return _gids;
}

ACGids * GidsToAC(Gids gids) {
    NSMutableArray<NSNumber *> * _gids;
    for (auto it = gids.begin(); it != gids.end(); ++it) {
        [_gids addObject:[NSNumber numberWithUnsignedLongLong:*it]];
    }
    ACGids * result = [_gids copy];
    return result;
}

Gid ACToGid(ACGid * gid) {
    return [gid unsignedLongLongValue];
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
