//
//  ACModel.h
//  Aria2Core
//
//  Created by ShinCurry on 2016/10/18.
//  Copyright © 2016年 ShinCurry. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef ACModel_h
#define ACModel_h

typedef enum {
    ACOffsetModeBegin,
    ACOffsetModeCurrent,
    ACOffsetModeEnd
} ACOffsetMode;

typedef NSNumber ACLength;

typedef enum {
    ACUriStatusUsed,
    ACUriStatusWaiting
} ACUriStatus;

typedef enum {
    ACBtFileModeNone,
    ACBtFileModeSingle,
    ACBtFileModeMultiple
} ACBtFileMode;

typedef enum {
    ACDownloadStatusActive,
    ACDownloadStatusWaiting,
    ACDownloadStatusPaused,
    ACDownloadStatusComplete,
    ACDownloadStatusError,
    ACDownloadStatusRemoved
} ACDownloadStatus;

#endif /* ACModel_h */
