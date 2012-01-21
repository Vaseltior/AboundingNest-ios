//
//  ANNSString.h
//  AboundingNest
//
//  Created by Samuel Grau on 1/21/12.
//  Copyright (c) 2012 Samuel Grau. All rights reserved.
//

static inline BOOL ANIsStringWithAnyText(id object) {
    return [object isKindOfClass:[NSString class]] && [(NSString*)object length] > 0;
}
