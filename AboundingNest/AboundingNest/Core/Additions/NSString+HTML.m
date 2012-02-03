//
//  NSString+HTML.m
//
//  Created by Samuel Grau on 01/04/10.
//  Copyright 2011 Samuel Grau. 
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//

#import "NSString+HTML.h"


@implementation NSString (HTML)

+ (NSString *)stringByURLEncodingString:(NSString *)aString {
	NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				  NULL,
																				  (CFStringRef)aString,
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8 );
	return [encodedString autorelease];
}

- (NSString *)URLEncode {
	NSString *encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
																				  NULL,
																				  (CFStringRef)self,
																				  NULL,
																				  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
																				  kCFStringEncodingUTF8 );
	return [encodedString autorelease];
}

- (NSString*)URLDecode {
	NSString* urldecodedString = (NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, 
                                                                                       (CFStringRef)self, 
                                                                                       (CFStringRef)@"");
	return [urldecodedString autorelease];
}


@end
