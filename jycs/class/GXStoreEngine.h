//
//  GXStoreEngine.h
//  jycs
//
//  Created by appleseed on 4/9/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXSyncHeader.h"

@interface GXStoreEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (GXStoreEngine *)sharedEngine;

- (void)startSync;

@end
