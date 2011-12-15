//
//  SGHyphenator.h
//  AboundingNest
//
//  Created by Samuel Grau on 24/05/10.
//  Copyright 2010 Samuel GRAU. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ANTextManipulationHyphenator : NSObject 
{
	NSString				*sep;
	NSMutableDictionary		*patmap, *excmap;
}

@property (nonatomic, retain)	NSString				*sep;
@property (nonatomic, retain)	NSMutableDictionary		*patmap, *excmap;


/**
 * Creates a TexHyphenator without exceptions
 * 
 * @param pathToPatternFile Path to file with patterns, separated line by
 * line
 */
- (void)initWithPatternFile:(NSString *)pathToPatternFile;

/**
 * Method to hyphenate word
 * 
 * @param word Word to hyphenate
 * 
 * @return Collection Collection of strings representing the hyphens
 */
- (NSArray *)hyphenate:(NSString *)word;

/**
 * Method to set the file containing the patterns line by line, separated by
 * 
 * @param path Path to file containing pattern.
 */
- (void)setPatternFile:(NSString *)path;
- (void)setExceptionFile:(NSString *)path;

/**
 * A pattern consists of letters, numbers and dots, e.g.: .mis2s1 Even
 * numbers indicate an unacceptable location for a hyphen, odd numbers
 * indicate an acceptable location. Higher numbers are superior over lower
 * numbers.
 */
- (Boolean)addPattern:(NSString *)aPattern;
- (Boolean)addException:(NSString *)aPattern;

#pragma mark -
#pragma mark Singleton object methods

+ (ANTextManipulationHyphenator *)sharedHyphenator;

@end
