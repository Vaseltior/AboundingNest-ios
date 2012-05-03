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
    NSMutableDictionary * _threadedManagedObjectContexts;
}

+ (ANCoreDataGrandCentralController *)instance;
- (ANCoreDataController *)controllerWithName:(NSString *)name;
- (BOOL)addController:(ANCoreDataController *)controller withName:(NSString *)name;
- (void)saveContexts;
- (void)releaseControllers;

- (void)removeObserveForManagedObjectContext:(NSManagedObjectContext *)moc withKey:(NSString *)key;
- (NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key forMainThread:(BOOL)forMainThread;

@end
