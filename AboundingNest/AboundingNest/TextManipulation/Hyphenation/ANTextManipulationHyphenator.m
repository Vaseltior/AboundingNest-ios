//
//  SGHyphenator.m
//  AboundingNest
//
//  Created by Samuel Grau on 24/05/10.
//  Copyright 2010 Samuel GRAU. All rights reserved.
//

/**
 * There is a proven algorithm for hyphenation, for TeX-documents by Liang,
 * called Liang's Algorithm.
 * 
 * The original algorithm is described here: http://www.tug.org/docs/liang/
 * 
 * A shorter explanation is given here:
 * http://xmlgraphics.apache.org/fop/0.95/hyphenation.html
 * 
 * Patterns can be generated with a Unix tool called patgen:
 * http://linux.die.net/man/1/patgen
 * 
 * But there are some patterns already created here:
 * http://www.ctan.org/tex-archive/language/hyphenation/
 * 
 * Nevertheless the german word "Ofen" is not hyphenated as "O-fen" because
 * it is considered to look "ugly".
 * 
 */

#import "ANTextManipulationHyphenator.h"
#import "ANCoreHeader.h"


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation ANTextManipulationHyphenator


@synthesize sep;
@synthesize patmap, excmap;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Singleton definition
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ANOBJECT_SINGLETON_BOILERPLATE( ANTextManipulationHyphenator, sharedHyphenator )


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (id)init {
	if (self = [super init]) {
		[self initWithPatternFile:@"hyphens"];
    }
    return self;
	
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)initWithPatternFile:(NSString *)pathToPatternFile {
	[self setSep:@"-"];
	
	NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
	[self setPatmap:d];
	[d release];
	
	d = [[NSMutableDictionary alloc] init];
	[self setExcmap:d];
	[d release];
	
	[self setPatternFile:pathToPatternFile];
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setPatternFile:(NSString *)path {
	NSError *error;
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:@"txt"];
	NSStringEncoding encoding = NSUTF8StringEncoding;
	NSString *s = [NSString stringWithContentsOfFile:fullPath usedEncoding:&encoding error:&error];
	
	NSArray *lines = [s componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	for (NSUInteger i=0; i<[lines count]; i++) {
		[self addPattern:[lines objectAtIndex:i]];
	}
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)setExceptionFile:(NSString *)path {
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (BOOL)addPattern:(NSString *)aPattern {
	NSString *pat = [aPattern stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
	NSArray *numbers = [aPattern componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
	
	NSMutableArray *points = [[NSMutableArray alloc] init];
	for(NSUInteger i=0; i<[numbers count]; i++) {
		if ( [(NSString *)[numbers objectAtIndex:i] compare:@""] == NSOrderedSame ) {
			[points addObject:[NSNumber numberWithInt:0]];
            
		} else {
			[points addObject:[NSNumber numberWithInt:[[numbers objectAtIndex:i] intValue]]];
		}
	}
	
	[patmap setObject:points forKey:pat];
	
	[points release];
	
	return YES;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (BOOL)addException:(NSString *)aPattern {
	return YES;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSArray *)hyphenate:(NSString *)word {
	// init return var
	NSMutableArray *retlist = [[NSMutableArray alloc] init];
	
	// very short words cannot be hyphenated
	if ( [word length] < 4) {	
		[retlist addObject:word];
		return [retlist autorelease];
	}
	
	NSString *workingword = [NSString stringWithFormat:@".%@.", [word lowercaseString]];
	NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:[workingword length]+1];
	for (NSUInteger k=0; k<[workingword length]+1; k++) {
		[points insertObject:[NSNumber numberWithInt:0] atIndex:0];
	}
    
	//points = new int[workingword.length() + 1];
	
	// label for a labeled continue
	NSString *tmpword;
	
	// for each char in the .word.
	for (NSUInteger i = 0; i < [workingword length]; i++)  {
		// look for a pattern the actual subsequence starts with
		tmpword = [workingword substringFromIndex:i];
		
		NSLog(@"working on %@", tmpword);
		
		for (NSUInteger j = 1; j <= [tmpword length]; j++) {
			// read points				
			NSRange range = NSMakeRange(0, j);
			NSArray *tpoints = [patmap objectForKey:[tmpword substringWithRange:range]];
			
			if ( tpoints != nil )  {
				NSLog(@"%@", tpoints);
				NSLog(@"substring: %@", [tmpword substringWithRange:range]);
				
				// set points if larger than the points already set
				for (NSUInteger l = 0; l < [tpoints count]; l++) {
					if ( [[points objectAtIndex:i+l] compare:[tpoints objectAtIndex:l]] == NSOrderedDescending ) {
						[points replaceObjectAtIndex:i+l withObject:[points objectAtIndex:i+l]];
                        
					} else {
						[points replaceObjectAtIndex:i+l withObject:[tpoints objectAtIndex:l]];
					}
				}
			}
		}
	}
	
	[points replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
	[points replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
	[points replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
	
	NSUInteger len = [points count];
	
	[points replaceObjectAtIndex:len-1 withObject:[NSNumber numberWithInt:0]];
	[points replaceObjectAtIndex:len-2 withObject:[NSNumber numberWithInt:0]];
	[points replaceObjectAtIndex:len-3 withObject:[NSNumber numberWithInt:0]];
	
	NSMutableString *tstr = [[NSMutableString alloc] init];
	
	for (NSUInteger i = 0; i < [points count] - 3; i++) {
		[tstr appendString:[word substringWithRange:NSMakeRange(i, 1)]];
		if ( ([[points objectAtIndex:(i + 2)] intValue] % 2) == 1) {
			[retlist addObject:tstr];
			[tstr release];
			tstr = nil;
			tstr = [[NSMutableString alloc] init];
		}
		
	}
	
	[retlist addObject:tstr];
	
	[tstr release];
	[points release];
	
	return [retlist autorelease];
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Memory Management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dealloc {
    ANReleaseSafely(&patmap);
    ANReleaseSafely(&excmap);
    ANReleaseSafely(&sep);
	
	[super dealloc];
}

@end
