//
//  GXMomentsEngine.h
//  jycs
//
//  Created by appleseed on 3/18/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSyncEngine.h"
#import "Moment.h"
#import "GXError.h"

@interface GXMomentsEngine : GXSyncEngine
+ (GXMomentsEngine *)sharedEngine;
- (void)sendMomentWithMoment:(Moment *)moment completion:(void(^)(NSDictionary *momentInfo, GXError *error))completion;
@end
