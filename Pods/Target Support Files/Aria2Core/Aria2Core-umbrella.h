#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "ACBtMetaInfoData.h"
#import "ACFileData.h"
#import "ACGlobalStatus.h"
#import "ACUriData.h"
#import "Aria2Core.h"

FOUNDATION_EXPORT double Aria2CoreVersionNumber;
FOUNDATION_EXPORT const unsigned char Aria2CoreVersionString[];

