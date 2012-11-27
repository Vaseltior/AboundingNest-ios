//
//  ANMemory.h
//  AboundingNest
//
//  Created by Samuel Grau on 04/12/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>

extern inline void ANReleaseSafely(NSObject **object);
extern inline void ANInvalidateTimer(NSObject **object);

/**
 * Release a CoreFoundation object safely.
 */
extern inline void ANReleaseCFSafely(NSObject **object);

/**
 * Shorthand for getting localized strings, 
 * used in formats
 */
extern inline NSString *ANLocStr(NSString *key);
