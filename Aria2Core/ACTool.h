//
//  ACTool.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACModel.h"
#import "aria2.h"

typedef NSDictionary<NSString *, NSString *> ACKeyVals;
typedef NSString ACUri;
typedef NSArray<NSString *> ACUris;
typedef NSNumber ACGid;
typedef NSArray<NSNumber *> ACGids;

#ifndef ACTool_h
#define ACTool_h

typedef std::vector<std::string> Uris;
typedef uint64_t Gid;
typedef std::vector<uint64_t> Gids;
typedef aria2::KeyVals KeyVals;
typedef aria2::OffsetMode OffsetMode;

KeyVals ACToKeyVals(ACKeyVals * options);

ACKeyVals * KeyValsToAC(KeyVals options);

Uris ACToUris(ACUris * uris);

Gids ACToGids(ACGids * gids);

ACGids * GidsToAC(Gids gids);

Gid ACToGid(ACGid * gid);

ACUriStatus UriStatusToAC(aria2::UriStatus status);

OffsetMode ACToOffsetMode(ACOffsetMode mode);

#endif /* ACTool_h */
