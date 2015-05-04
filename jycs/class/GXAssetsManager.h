//
//  GXAssetsManager.h
//  jycs
//
//  Created by appleseed on 4/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface GXAssetsManager : NSObject
+ (ALAssetsLibrary *)defaultAssetsLibrary;
@end
