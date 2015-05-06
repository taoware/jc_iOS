//
//  GXSyncEngine.h
//  jycs
//
//  Created by appleseed on 3/11/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    GXObjectSynced = 0,
    GXObjectCreated,
    GXObjectDeleted,
    GXObjectSyncing
} GXObjectSyncStatus;

@interface GXSyncEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (GXSyncEngine *)sharedEngine;
- (void)startSync;  // subclass need to call super to start sync progress
- (void)executeSyncCompletedOperations;    

@end
