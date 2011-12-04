//
//  NSDictionary+AboundingNest.m
//  AboundingNest
//
//  Created by Samuel Grau on 04/12/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import "NSDictionary+AboundingNest.h"

@implementation NSDictionary (AboundingNest)

+ (id)vfk:(id)key wd:(NSDictionary *)aDict et:(Class)aClass dv:(id)defaultValue {
    
    if (nil == key) { 
        return defaultValue; 
    }
    
    id value = [aDict objectForKey:key];
    
    if (!value) {
        return defaultValue;
    }
    
    if (![value isKindOfClass:aClass]) {
        return defaultValue;   
    }
    
    return value;
}


@end
