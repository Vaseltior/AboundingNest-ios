//
//  NSDictionary+Merge.h
//  AboundingNest
//
//  Created by Samuel Grau on 1/3/12.
//  Copyright (c) 2012 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Merge)

+ (NSDictionary *)dictionaryByMerging:(NSDictionary *)dictionary1 with:(NSDictionary *)dictionary2;
- (NSDictionary *)dictionaryByMergingWith:(NSDictionary *)dict;
- (BOOL)containsSomethingForKey:(id)key;

@end
