//
//  GXNewsEngine.h
//  jycs
//
//  Created by appleseed on 3/18/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXSyncHeader.h"

@interface GXNewsEngine : NSObject

@property (atomic, readonly) BOOL syncInProgress;

+ (GXNewsEngine *)sharedEngine;

- (void)startSync;

@end
