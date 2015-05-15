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

@implementation GXMomentsEngine

+ (GXSyncEngine *)sharedEngine {
    static GXMomentsEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXMomentsEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
    [super startSync];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self downloadDataForSquare];
    });
}

- (void)downloadDataForSquare {
    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    User* user = [GXUserEngine sharedEngine].userLoggedIn;
    NSDictionary* parameter = @{@"userId": user.objectId};
    [[GXHTTPManager sharedManager] GET:@"square" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* moments = [responseObject objectForKey:API_RESULTS];
            [Moment loadMomentsFromMomentsArray:moments intoManagedObjectContext:context];
            [self DeleteMomentRecoredNotInObjectIds:[moments valueForKey:RESOURCE_ID]];
        }
        [self executeSyncCompletedOperations];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                NSLog(@"square api error message: %@", apiError);
            }
        } else {
            // AFNetworking error handling
            NSLog(@"news network error description: %@", error.localizedDescription);
        }
        
        [self executeSyncCompletedOperations];
    }];
}

- (void)DeleteMomentRecoredNotInObjectIds:(NSArray*)idArray {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Moment"];
    NSPredicate *predicate;
    predicate = [NSPredicate predicateWithFormat:@"NOT (objectId IN %@)", idArray];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"objectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    for (NSManagedObject *managedObject in results) {
        [managedObjectContext deleteObject:managedObject];
    }
}

- (void)sendMomentWithMoment:(Moment *)moment completion:(void (^)(NSDictionary *, GXError *))completion{

    User* user = moment.sender;
    Unit* unit = moment.inUnit;
    NSDictionary* parameter = [moment JSONToCreateMomentOnServer];
    NSString* endpoint = [NSString stringWithFormat:@"square/user/%@/unit/%@", user.objectId, unit.objectId];
    [[GXHTTPManager sharedManager] POST:endpoint parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSArray* photos = moment.photo.array;
        for (int i = 0; i < photos.count; i++) {
            Photo* photo = [photos objectAtIndex:i];
            NSString* photoName = [[photo.imageURL componentsSeparatedByString:@"/"] lastObject];
            NSURL* documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
            NSURL* photoURL = [documentDirectory URLByAppendingPathComponent:photoName];
            NSData* imageData = [NSData dataWithContentsOfURL:photoURL];
            [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"file%i", i+1] fileName:photo.photoDescription mimeType:@"image/jpeg"];
        }
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray* moments = [responseObject valueForKeyPath:API_RESULTS];
        NSDictionary* momentDic = [moments firstObject];
        moment.syncStatus = @(GXObjectSynced);
        moment.objectId = [momentDic valueForKey:RESOURCE_ID];
        [Moment momentWithMomentInfo:momentDic inManagedObjectContext:moment.managedObjectContext];
        completion(nil,nil);
        [self executeSyncCompletedOperations];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                completion(nil, [GXError errorWithCode:GXErrorMomentSendFailure andDescription:apiError]);
            }
        } else {
            // AFNetworking error handling
            completion(nil, [GXError errorWithCode:GXErrorServerNotReachable andDescription:error.localizedDescription]);
        }
        
        [self executeSyncCompletedOperations];
    }];
}

- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        [[GXCoreDataController sharedInstance] saveBackgroundContext];
        if (error) {
            NSLog(@"Error saving background context after creating objects on server: %@", error);
        }
        
        [[GXCoreDataController sharedInstance] saveMasterContext];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNOTIFICATION_MOMENTSSYNCCOMPLETED
         object:nil];
    });
}

@end
