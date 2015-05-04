//
//  GXAssetsManager.m
//  jycs
//
//  Created by appleseed on 4/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXAssetsManager.h"

@implementation GXAssetsManager

+ (ALAssetsLibrary *)defaultAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred, ^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

@end
