//
//  GXMomentsEngine.m
//  jycs
//
//  Created by appleseed on 3/18/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXMomentsEngine.h"
#import "GXUserEngine.h"
#import "GXCoreDataController.h"
#import "Moment+Create.h"
#import "Unit.h"
#import "GXHTTPManager.h"
#import "ResourceFetcher.h"
#import "GXUserEngine.h"
#import "Photo.h"
#import "GXPhotoEngine.h"

NSString * const kGXMomentsSyncEngineInitialCompleteKey = @"GXMomentsSyncEngineInitialSyncCompleted";

@implementation GXMomentsEngine

+ (GXMomentsEngine *)sharedEngine {
    static GXMomentsEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXMomentsEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
    if (!self.syncInProgress) {
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = YES;
        [self didChangeValueForKey:@"syncInProgress"];
        [self downloadDataForMoments:NO toDeleteLocalRecords:NO];
    }
}

- (void)executeSyncCompletedOperations {
    NSLog(@"completed");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        
        [[GXCoreDataController sharedInstance] saveBackgroundContext];
        [[GXCoreDataController sharedInstance] saveMasterContext];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNOTIFICATION_MOMENTSSYNCCOMPLETED
         object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
    });
}

- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kGXMomentsSyncEngineInitialCompleteKey] boolValue];
}

- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kGXMomentsSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    __block NSDate *date = nil;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedTime" ascending:NO]]];
    [request setFetchLimit:1];
    [[[GXCoreDataController sharedInstance] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[GXCoreDataController sharedInstance] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            date = [[results lastObject] valueForKey:@"updatedTime"];
        }
    }];
    
    return date;
}

- (void)downloadDataForMoments:(BOOL)useUpdatedAtDate toDeleteLocalRecords:(BOOL)toDelete {

    NSDate *mostRecentUpdatedDate = nil;
    if (useUpdatedAtDate) {
        mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:@"Moment"];
    }
    
    User* user = [GXUserEngine sharedEngine].userLoggedIn;
    NSDictionary* parameter;
    if (user.objectId) {
        parameter = @{@"userId": user.objectId};
    } else {
        parameter = @{@"userId": @(532)};
    }
    NSLog(@"begin download");
    [[GXHTTPManager sharedManager] GET:@"square" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
            [context performBlock:^{
                [self writeJSONResponse:responseObject toDiskForClassWithName:@"Moment"];
                [self processJSONDataRecordsIntoCoreData];
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Request for moments failed with error: %@", error);
        [self processJSONDataRecordsIntoCoreData];
    }];
    
}

- (void)processJSONDataRecordsIntoCoreData {
    NSLog(@"begin process into core data");
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];

    if (![self initialSyncComplete]) { // import all downloaded data to Core Data for initial sync
        NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:@"Moment"];
        NSArray *records = [JSONDictionary objectForKey:@"results"];
        for (NSDictionary *record in records) {
            [Moment momentWithMomentInfo:record inManagedObjectContext:managedObjectContext];
        }
    } else {
        NSArray *downloadedRecords = [self JSONDataRecordsForClass:@"Moment" sortedByKey:@"objectId"];
        if ([downloadedRecords lastObject]) {
            NSArray *storedRecords = [self managedObjectsForClass:@"Moment" sortedByKey:@"objectId" usingArrayOfIds:[downloadedRecords valueForKey:RESOURCE_ID] inArrayOfIds:YES];
            int currentIndex = 0;
            for (NSDictionary *record in downloadedRecords) {
                NSManagedObject *storedManagedObject = nil;
                if ([storedRecords count] > currentIndex) {
                    storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                }
                
                if ([[storedManagedObject valueForKey:@"objectId"] isEqualToNumber:[record valueForKey:RESOURCE_ID]]) {
                    [Moment updateMoment:[storedRecords objectAtIndex:currentIndex] withMomentInfo:record];

                } else {
                    [Moment momentWithMomentInfo:record inManagedObjectContext:managedObjectContext];
                }
                currentIndex++;
            }
        }
    }

    
//    [self deleteJSONDataRecordsForClassWithName:@"Moment"];
    [self processJSONDataRecordsForDeletion];
}

- (void)processJSONDataRecordsForDeletion {
    NSLog(@"begin deletion");
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];

    NSArray *JSONRecords = [self JSONDataRecordsForClass:@"Moment" sortedByKey:RESOURCE_ID];
    if ([JSONRecords count] > 0) {
        NSArray *storedRecords = [self
                                  managedObjectsForClass:@"Moment"
                                  sortedByKey:@"objectId"
                                  usingArrayOfIds:[JSONRecords valueForKey:RESOURCE_ID]
                                  inArrayOfIds:NO];
        
        for (NSManagedObject *managedObject in storedRecords) {
            Moment* moment = managedObject;
            if ([moment.syncStatus isEqualToNumber:@(GXObjectSynced)]) {
                [managedObjectContext deleteObject:managedObject];
            }
        }

    }
    
    [self deleteJSONDataRecordsForClassWithName:@"Moment"];
    
    [self postLocalObjectsToServer];
}

- (void)postLocalObjectsToServer {
    NSLog(@"begin post");
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    NSArray *objectsToCreate = [self managedObjectsForClass:@"Moment" withSyncStatus:GXObjectCreated];
    for (Moment *moment in objectsToCreate) {
        User* user = moment.sender;
        Unit* unit = moment.inUnit;
        NSNumber* unitId = unit.objectId;
        if (!unit) {
            unitId = @(23);
        }
        NSDictionary* parameter = [moment JSONToCreateMomentOnServer];
        NSString* endpoint = [NSString stringWithFormat:@"square/user/%@/unit/%@", user.objectId, unitId];
        
        dispatch_group_enter(group);
        [[GXHTTPManager sharedManager] POST:endpoint parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSArray* photos = moment.photo.array;
            for (int i = 0; i < photos.count; i++) {
                Photo* photo = [photos objectAtIndex:i];
                NSData* photoData = [GXPhotoEngine dataForLocalPhotoURL:photo.imageURL];
                [formData appendPartWithFileData:photoData name:[NSString stringWithFormat:@"file%i", i+1] fileName:photo.photoDescription mimeType:@"image/jpeg"];
            }
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"Success creation. ");
            
            NSArray* moments = [responseObject valueForKeyPath:API_RESULTS];
            NSDictionary* momentDic = [moments firstObject];
            moment.syncStatus = @(GXObjectSynced);
            moment.objectId = [momentDic valueForKey:RESOURCE_ID];
            moment.createTime = [ResourceFetcher dateUsingStringFromAPI:[momentDic valueForKeyPath:RESOURCE_CREATED_DATE]];
            
            // Leave the group as soon as the request succeeded
            dispatch_group_leave(group);
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"Failed creation: %@", error);
            
            // Leave the group as soon as the request failed
            dispatch_group_leave(group);
        }];
    }
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        [self executeSyncCompletedOperations];
    });
}



- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(GXObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
//    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    }];
    
    return results;
}

- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"objectId IN %@", idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
//    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    }];
    
    return results;
}

#pragma mark - File Management

- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}

- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className {
    NSLog(@"begin write");
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:API_RESULTS];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }
        
        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];
        
        if (![nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            NSLog(@"Failed all attempts to save reponse to disk: %@", response);
        }
    }
}

- (void)deleteJSONDataRecordsForClassWithName:(NSString *)className {
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        NSLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}

- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
    NSArray *records = [JSONDictionary objectForKey:@"results"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}


@end
