//
//  NSDictionary+Merge.m
//  AboundingNest
//
//  Created by Samuel Grau on 1/3/12.
//  Copyright (c) 2012 Samuel Grau. All rights reserved.
//

#import "NSDictionary+Merge.h"

@implementation NSDictionary (Merge)

+ (NSDictionary *)dictionaryByMerging:(NSDictionary *)dictionary1 
                                 with:(NSDictionary *)dictionary2 {
    
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    [dictionary2 enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		// If object is a dictionary and dict1 contains key with a value, set the object 
        if ([obj isKindOfClass: [NSDictionary class]] && [dictionary1 containsSomethingForKey:key]) {
            NSDictionary * newVal = [[dictionary1 objectForKey: key] dictionaryByMergingWith:(NSDictionary *)obj];
            [result setObject:newVal forKey:key];
        } else if (![dictionary1 containsSomethingForKey:key]) {
            [result setObject:obj forKey:key];
        } else {
            [result setObject:[dictionary1 objectForKey:key] forKey:key];
        }
    }];
    
    return (NSDictionary *) [[result mutableCopy] autorelease];
}

- (NSDictionary *) dictionaryByMergingWith: (NSDictionary *) dict {
    return [[self class] dictionaryByMerging: self with: dict];
}

- (BOOL)containsSomethingForKey:(id)key {
    return ([self objectForKey:key] != nil);
}


@end
