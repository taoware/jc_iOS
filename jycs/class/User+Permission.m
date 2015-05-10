//
//  User+Permission.m
//  jycs
//
//  Created by appleseed on 5/10/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "User+Permission.h"

@implementation User (Permission)

- (BOOL)canSendMomentForEmployee {
    for (Permission* permission in self.hasPermisson) {
        if ([permission.permissonName isEqualToString:@"staffSquareCreate"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canSendMomentForPurchase {
    for (Permission* permission in self.hasPermisson) {
        if ([permission.permissonName isEqualToString:@"purchasingCreate"]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canSendMomentForSupplier {
    for (Permission* permission in self.hasPermisson) {
        if ([permission.permissonName isEqualToString:@"supplierSquareCreate"]) {
            return YES;
        }
    }
    return NO;
}

@end
