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

+ (GXSyncEngine *)sharedEngine {
    static GXNewsEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXNewsEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)startSync {
    [super startSync];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self downloadDataOfNews];
    });
}

- (void)downloadDataOfNews {
    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    User* user = [GXUserEngine sharedEngine].userLoggedIn;
    NSDictionary* parameter = @{@"userId": user.objectId};
    
    [[GXHTTPManager sharedManager] GET:@"news" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* news = [responseObject objectForKey:API_RESULTS];
            [News deleteAllRecordsInManagedObjectContext:context];
            [News loadNewsFromNewsArray:news intoManagedObjectContext:context];
        }
        [self executeSyncCompletedOperations];
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

- (void)downloadDataForNews {
    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();
    
    NSDictionary* parameter = nil;
    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    __block NSError *slideDownloadError = nil;
    __block NSError *listDownError = nil;
    
    // Fire the request
    // DownloadDataForSlidingNews
    parameter = @{@"type": @"slideshow"};
    // Enter the group for each request we create
    dispatch_group_enter(group);
    [[GXHTTPManager sharedManager] GET:@"news" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* news = [responseObject objectForKey:API_RESULTS];
            [News loadNewsFromNewsArray:news intoManagedObjectContext:context];
        }
        // Leave the group as soon as the request succeeded
        dispatch_group_leave(group);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                NSLog(@"slideshow api error message: %@", apiError);
            }
        } else {
            // AFNetworking error handling
            NSLog(@"slideshow network error description: %@", error.localizedDescription);
        }
        
        // Leave the group as soon as the request failed
        dispatch_group_leave(group);
    }];
    
    // DownloadDataForListNews
    parameter = @{@"type": @"listshow"};
    dispatch_group_enter(group);
    [[GXHTTPManager sharedManager] GET:@"news" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* news = [responseObject objectForKey:API_RESULTS];
            [News loadNewsFromNewsArray:news intoManagedObjectContext:context];
        }
        dispatch_group_leave(group);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                NSLog(@"slideshow api error message: %@", apiError);
            }
        } else {
            // AFNetworking error handling
            NSLog(@"slideshow network error description: %@", error.localizedDescription);
        }
        
        dispatch_group_leave(group);
    }];
    
    // Here we wait for all the requests to finish
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // Do whatever you need to do when all requests are finished
        [self executeSyncCompletedOperations];
    });

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
         postNotificationName:kNOTIFICATION_NEWSSYNCCOMPLETED
         object:nil];
    });
}

@end
