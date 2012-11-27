//
//  ANMemory.m
//  AboundingNest
//
//  Created by Samuel Grau on 04/12/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANMemory.h"

inline void ANReleaseSafely(NSObject **object){
    if (!*object) return;
    [*object release];
    *object = nil;
}

inline void ANInvalidateTimer(NSObject **object) {
    if (!*object) return;
    NSTimer *t = (NSTimer *)object;
    [t invalidate];
    ANReleaseSafely(&t);
}

/**
 * Release a CoreFoundation object safely.
 */
inline void ANReleaseCFSafely(NSObject **object) {
    if (nil != (*object)) {
        CFRelease(*object);
        *object = nil;
    }
}

/**
 * Shorthand for getting localized strings,
 * used in formats
 */
inline NSString *ANLocStr(NSString *key) {
    return [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil];
}
