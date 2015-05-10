//
//  User+Permission.h
//  jycs
//
//  Created by appleseed on 5/10/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "User.h"
#import "Permission.h"

@interface User (Permission)

- (BOOL)canSendMomentForEmployee;
- (BOOL)canSendMomentForSupplier;
- (BOOL)canSendMomentForPurchase;

@end
