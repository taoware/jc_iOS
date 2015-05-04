//
//  GXSyncEngine.m
//  jycs
//
//  Created by appleseed on 3/11/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSyncEngine.h"
#import "GXCoreDataController.h"
#import "GXHTTPManager.h"
#import "AFHTTPRequestOperation.h"
#import "GXUserEngine.h"

@interface GXSyncEngine ()

@end

@implementation GXSyncEngine

@synthesize syncInProgress = _syncInProgress;

+ (GXSyncEngine *)sharedEngine {
    static GXSyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXSyncEngine alloc] init];
    });
    
    return sharedEngine;
}


- (void)startSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
    }
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        [[GXCoreDataController sharedInstance] saveBackgroundContext];
        if (error) {
            NSLog(@"Error saving background context after creating objects on server: %@", error);
        }
        
        [[GXCoreDataController sharedInstance] saveMasterContext];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

//
//- (void)downloadDataForObjectsUsingUpdatedAtDate:(BOOL)useUpdatedAtDate toDeleteLocalRecords:(BOOL)toDelete{
//    // Create a dispatch group
//    dispatch_group_t group = dispatch_group_create();
//    
//    NSDate *mostRecentUpdatedDate = nil;
//    NSDictionary* parameter = nil;
//
//    if (useUpdatedAtDate) {
//        mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:self.className];
//        if (mostRecentUpdatedDate) {
//            NSString* dateApi = [self dateStringForAPIUsingDate:mostRecentUpdatedDate];
//            NSString *dateString = [NSString
//                                    stringWithFormat:@"\"updatedAt\":{\"$gte\":{\"__type\":\"Date\",\"iso\":\"%@\"}}", dateApi];
//            [self.jsonQueryString appendString:dateString];
//        } 
//    }
//    
//    parameter = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"{%@}", self.jsonQueryString] forKey:@"where"];
//    // Enter the group for each request we create
//    dispatch_group_enter(group);
//    // Fire the request
//    [[GXHTTPManager sharedManager] GET:[@"classes/" stringByAppendingString:self.className] parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
//        if ([responseObject isKindOfClass:[NSDictionary class]]) {
//            [self writeJSONResponse:responseObject toDiskForClassWithName:self.className];
//        }
//        // Leave the group as soon as the request succeeded
//        dispatch_group_leave(group);
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//        // Leave the group as soon as the request failed
//        NSLog(@"%@", [[error userInfo] objectForKey:@"kErrorResponseObjectKey"]);
//        dispatch_group_leave(group);
//    }];
//
//    
//    // Here we wait for all the requests to finish
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        // Do whatever you need to do when all requests are finished
//        [self processJSONDataRecordsIntoCoreData];
//    });
//}
//
//- (void)processJSONDataRecordsIntoCoreData {
//    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
//    if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
//        NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:self.className];
//        NSArray *records = [JSONDictionary objectForKey:@"results"];
//        for (NSDictionary *record in records) {
//            [self newManagedObjectWithClassName:self.className forRecord:record];
//        }
//    } else {
//        NSArray *downloadedRecords = [self JSONDataRecordsForClass:self.className sortedByKey:@"objectId"];
//        if ([downloadedRecords lastObject]) {
//            for (NSDictionary *record in downloadedRecords) {
//                NSString* objectId = [record objectForKey:@"objectId"];
//                NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:self.className];
//                request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
//                
//                NSError *error;
//                NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
//                
//                if (!matches || error || ([matches count] > 1)) {
//                    // handle error
//                } else if ([matches count]) {
//                    [self updateManagedObject:[matches firstObject] withRecord:record];
//                    if ([self.className isEqualToString:@"Moments"]) {
//                        [[GXUserEngine checkForAutoLoginUser] addHasMomentsObject:[matches firstObject]];
//                    }
//                } else {
//                    NSManagedObject* managedObject = [self newManagedObjectWithClassName:self.className forRecord:record];
//                    if ([self.className isEqualToString:@"Moments"]) {
//                        [[GXUserEngine checkForAutoLoginUser] addHasMomentsObject:managedObject];
//                    }
//                }
//            }
//        }
//    }
//
//    [managedObjectContext performBlockAndWait:^{
//        NSError *error = nil;
//        if (![managedObjectContext save:&error]) {
//            NSLog(@"Unable to save context for class %@", self.className);
//        }
//    }];
//
//    [self downloadDataForObjectsUsingUpdatedAtDate:NO toDeleteLocalRecords:YES];
//}
//
//- (void)processJSONDataRecordsForDeletion {
//    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
//
//    NSArray *JSONRecords = [self JSONDataRecordsForClass:self.className sortedByKey:@"objectId"];
//    if ([JSONRecords count] > 0) {
//        NSArray *storedRecords = [self
//                                  managedObjectsForClass:self.className
//                                  sortedByKey:@"objectId"
//                                  usingArrayOfIds:[JSONRecords valueForKey:@"objectId"]
//                                  inArrayOfIds:NO];
//        
//        [managedObjectContext performBlockAndWait:^{
//            for (NSManagedObject *managedObject in storedRecords) {
//                [managedObjectContext deleteObject:managedObject];
//            }
//            NSError *error = nil;
//            BOOL saved = [managedObjectContext save:&error];
//            if (!saved) {
//                NSLog(@"Unable to save context after deleting records for class %@ because %@", self.className, error);
//            }
//        }];
//    }
//
//    [self executeSyncCompletedOperations];
//}
//
//- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
//    __block NSArray *results = nil;
//    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
//    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
//    NSPredicate *predicate;
//    if (inIds) {
//        predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", idArray];
//    } else {
//        predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
//    }
//    
//    [fetchRequest setPredicate:predicate];
//    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
//                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
//    [managedObjectContext performBlockAndWait:^{
//        NSError *error = nil;
//        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    }];
//    
//    return results;
//}


@end
