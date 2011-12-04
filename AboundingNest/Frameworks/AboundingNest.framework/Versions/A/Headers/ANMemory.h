//
//  ANMemory.h
//  AboundingNest
//
//  Created by Samuel Grau on 04/12/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>

static inline void ANReleaseSafely(NSObject **object){
    if (!*object) return;
    [*object release];
    *object = nil;
}

static inline void ANInvalidateTimer(NSObject **object) {
    if (!*object) return;
    NSTimer *t = (NSTimer *)object;
    [t invalidate];
    ANReleaseSafely(&t);
}

/**
 * Release a CoreFoundation object safely.
 */
static inline void ANReleaseCFSafely(NSObject **object) {
    if (nil != (*object)) { 
        CFRelease(*object); 
        *object = nil;
    }
}

/**
 * Shorthand for getting localized strings, 
 * used in formats
 */
static inline NSString *ANLocStr(NSString *key) {
    return [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil];
}
