//
//  GXStoreEngine.m
//  jycs
//
//  Created by appleseed on 4/9/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXStoreEngine.h"
#import "GXCoreDataController.h"
#import "GXHTTPManager.h"
#import "AFHTTPRequestOperation.h"
#import "ResourceFetcher.h"
#import "Store+Create.h"
#import "GXError.h"

@implementation GXStoreEngine

+ (GXSyncEngine *)sharedEngine {
    static GXStoreEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXStoreEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
    [super startSync];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self downloadDataForStore];
    });
}

- (void)downloadDataForStore {

    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    [[GXHTTPManager sharedManager] GET:@"store" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* stores = [responseObject objectForKey:API_RESULTS];
            [Store loadStoresFromNewsArray:stores intoManagedObjectContext:context];
        }
        [self executeSyncCompletedOperations];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                NSLog(@"store api error message: %@", apiError);
            }
        } else {
            // AFNetworking error handling
            NSLog(@"store network error description: %@", error.localizedDescription);
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
         postNotificationName:kNOTIFICATION_STORESYNCCOMPLETED
         object:nil];
    });
}


@end
