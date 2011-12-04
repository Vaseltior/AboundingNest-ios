//
//  ANMathShortcuts.h
//
//  Created by Samuel Grau on 7/18/11.
//  Copyright 2011 Samuel Grau. All rights reserved.
//

#ifndef AboundingNest_ANMathematics_h
#define AboundingNest_ANMathematics_h

#import <UIKit/UIKit.h>

#define ARC4RANDOM_MAX      0x100000000

/** High precision float comparison
 * \param[in] a The first float to compare
 * \param[in] b The second float to compare
 * \return true if equal within precision, false if not equal within defined precision.
 */
static inline int ANCompareFloat(const float a, const float b) {
    const float precision = 0.00001f;
    if((a - precision) < b && (a + precision) > b)
        return true;
    else
        return false;
}

/** High precision double comparison
 * \param[in] a The first double to compare
 * \param[in] b The second double to compare
 * \return true on equal within precison, false if not equal within defined precision.
 */
static inline int ANCompareDouble(const double a, const double b) {
    const double precision = 0.00001;
    if((a - precision) < b && (a + precision) > b)
        return true;
    else
        return false;
}

static inline CGFloat ANRandomNormalized(void) {
    return ((CGFloat)arc4random()/(CGFloat)ARC4RANDOM_MAX);
}

static inline NSUInteger ANRandomBounded(NSUInteger leftBound, NSUInteger rightBound) {
    return (arc4random() % (rightBound-leftBound)) + leftBound;
}

static inline BOOL ANRandomBoolean(void) {
    return (BOOL)(arc4random() % (2));
}

static inline CGFloat ANRandomBoundedf(CGFloat leftBound, CGFloat rightBound) {
    return (CGFloat)(arc4random() % (NSUInteger)(rightBound-leftBound)) + leftBound;
}


#endif
