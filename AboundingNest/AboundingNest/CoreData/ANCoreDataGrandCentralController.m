//
//  ANCoreDataGrandCentralController.m
//
//  Created by Samuel Grau on 26/11/11.
//  Copyright (c) 2011 Samuel Grau. All rights reserved.
//

#import "ANCoreDataGrandCentralController.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@implementation ANCoreDataGrandCentralController


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Singleton definition
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


ANOBJECT_SINGLETON_BOILERPLATE(ANCoreDataGrandCentralController, instance)


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Initialization
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (id)init {
    self = [super init];
    if (self) {
        _coreDataControllers = [[NSMutableDictionary alloc] init];
        _threadedManagedObjectContexts = [[NSMutableDictionary alloc] init];
    }
    return self;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Memory Management
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)dealloc {
    // This object lives for the entire life of the application. Getting it to support being 
    // deallocated would be quite tricky (particularly from a threading perspective), so we 
    // don't even try.
    
    [super dealloc];
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark - Setters / Getters
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (ANCoreDataController *)controllerWithName:(NSString *)name {
    NSAssert(name, @"Missing parameter name", nil);
    ANCoreDataController * result = nil;
    result = [NSDictionary vfk:name 
                            wd:_coreDataControllers 
                            et:[ANCoreDataController class] 
                            dv:nil];
    return result;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (BOOL)addController:(ANCoreDataController *)controller withName:(NSString *)name {
    NSAssert(name, @"Missing parameter name", nil);
    NSAssert(controller, @"Missing parameter controller", nil);

    [_coreDataControllers setObject:controller forKey:name];

    return !![_coreDataControllers objectForKey:name];
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)saveContexts {
    for (ANCoreDataController * controller in _coreDataControllers) {
        [controller saveContext];
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)releaseControllers {
    [_coreDataControllers removeAllObjects];
}


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)createMutableDictionaryForKey:(id)key {
    NSMutableDictionary * d = [[NSMutableDictionary alloc] init];
    [_threadedManagedObjectContexts setObject:d forKey:key];
    ANReleaseSafely(&d);
} /* createMutableDictionaryForKey */


// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSMutableDictionary *)mocsDictionaryForKey:(id)key {
    @synchronized(self) {
        if ( [_threadedManagedObjectContexts objectForKey:key] == nil ) {
            [self createMutableDictionaryForKey:key];
        }
        
        NSMutableDictionary *vv = [_threadedManagedObjectContexts objectForKey:key];
        
        if ( ![vv isKindOfClass:[NSMutableDictionary class]] ) {
            return nil;
        }
        
        return vv;
    }
} /* usableImageForURL */

#pragma GCC diagnostic ignored "-Wselector"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)removeObserveForManagedObjectContext:(NSManagedObjectContext *)moc withKey:(NSString *)key {
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    NSMutableDictionary * mocs = [self mocsDictionaryForKey:key];
    if (mocs) {
        NSNumber * n = [NSNumber numberWithUnsignedInteger:[moc hash]];
        id object = [mocs objectForKey:n];
        if (object) {
            [nc removeObserver:object name:NSManagedObjectContextDidSaveNotification object:moc];
            
            NSLog(@"============\nObserver Removed %@, %@\n============", moc, key);
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (NSManagedObjectContext *)managedObjectContextForKey:(NSString *)key forMainThread:(BOOL)forMainThread {
    
    // Get a blank managed object context
    ANCoreDataGrandCentralController * cdgcc = [ANCoreDataGrandCentralController instance];
    ANCoreDataController * cdc = [cdgcc controllerWithName:key];
    
    if (forMainThread) {
        return [cdc managedObjectContext];
    }
    
    // Here it is not for the main thread
    NSManagedObjectContext * moc = [[NSManagedObjectContext alloc] init];
    [moc setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    [moc setPersistentStoreCoordinator:[cdc persistentStoreCoordinator]];
    [moc setUndoManager:nil];
    
    NSNotificationCenter * nc = [NSNotificationCenter defaultCenter];
    id object = [nc addObserverForName:NSManagedObjectContextDidSaveNotification 
                                object:moc 
                                 queue:[NSOperationQueue mainQueue] 
                            usingBlock:^(NSNotification * note) {
                                
                                ANCoreDataGrandCentralController * gcc = [ANCoreDataGrandCentralController instance];
                                ANCoreDataController * c = [gcc controllerWithName:key];
                                NSManagedObjectContext * mainContext = [c managedObjectContext];
                                
                                @try {
                                    // Merge changes into the main context on the main thread
                                    SEL mergeSelector = @selector(mergeChangesFromContextDidSaveNotification:);
                                    [mainContext performSelectorOnMainThread:mergeSelector withObject:note waitUntilDone:YES];
                                }
                                @catch (NSException * e) {
                                    NSLog(@"Stopping on exception: %@", [e description]);
                                }
                                @finally {
                                    NSLog(@"============\nNSManagedObjectContextDidSaveNotification %@ \n============", mainContext);
                                }
                            }];
    
    
    // We get a reference to the 
    if (object) {
        NSMutableDictionary * mocs = [self mocsDictionaryForKey:key];
        NSNumber * n = [NSNumber numberWithUnsignedInteger:[moc hash]];
        [mocs setObject:object forKey:n];
        
        NSLog(@"============\nObserver created %@, %@\n============", moc, key);
    }    
    
    return [moc autorelease];
}
#pragma GCC diagnostic warning "-Wselector"

@end
