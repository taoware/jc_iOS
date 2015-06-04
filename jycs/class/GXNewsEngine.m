//
//  GXNewsEngine.m
//  jycs
//
//  Created by appleseed on 3/18/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXNewsEngine.h"
#import "GXCoreDataController.h"
#import "GXHTTPManager.h"
#import "AFHTTPRequestOperation.h"
#import "ResourceFetcher.h"
#import "News+Create.h"
#import "GXError.h"
#import "GXUserEngine.h"

@implementation GXNewsEngine

+ (GXNewsEngine *)sharedEngine {
    static GXNewsEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXNewsEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
        [self downloadDataOfNews];
}

- (void)downloadDataOfNews {
    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    User* user = [GXUserEngine sharedEngine].userLoggedIn;
    NSDictionary* parameter;
    if (user) {
        parameter = @{@"userId": user.objectId};
    } else {
        parameter = @{@"userId": @(866)};
    }
    
    [[GXHTTPManager sharedManager] GET:@"news" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* news = [responseObject objectForKey:API_RESULTS];
            [context performBlock:^{
                [News loadNewsFromNewsArray:news intoManagedObjectContext:context];
                [self DeleteNewsRecoredNotInObjectIds:[news valueForKey:RESOURCE_ID]];
                [context save:NULL];
                [self executeSyncCompletedOperations];
            }];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                NSLog(@"news api error message: %@", apiError);
            }
        } else {
            // AFNetworking error handling
            NSLog(@"news network error description: %@", error.localizedDescription);
        }
        
        [self executeSyncCompletedOperations];
    }];
}

- (void)DeleteNewsRecoredNotInObjectIds:(NSArray*)idArray {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"News"];
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


- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[GXCoreDataController sharedInstance] saveBackgroundContext];
        [[GXCoreDataController sharedInstance] saveMasterContext];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kNOTIFICATION_NEWSSYNCCOMPLETED
         object:nil];
    });
}

@end
