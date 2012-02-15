//
//  ANCoreDataGrandCentralController.h
//
//  Created by Samuel Grau on 26/11/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANCoreDataController.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface ANCoreDataGrandCentralController : NSObject {
    NSMutableDictionary * _coreDataControllers;
}

+ (ANCoreDataGrandCentralController *)instance;
- (ANCoreDataController *)controllerWithName:(NSString *)name;
- (BOOL)addController:(ANCoreDataController *)controller withName:(NSString *)name;
- (void)saveContexts;
- (void)releaseControllers;

+ (NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key
                                         forMainThread:(BOOL)forMainThread;

@end
