//
//  GXPhotoEngine.h
//  jycs
//
//  Created by appleseed on 5/14/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GXPhotoEngine : NSObject

+ (NSString *)writePhotoToDisk:(UIImage* )image;
+ (void)deleteLocalPhotoWithURL:(NSString *)photoURL;
+ (UIImage *)imageForlocalPhotoUrl:(NSString *)photoUrl;
+ (NSData *)dataForLocalPhotoURL:(NSString *)photoURL;

@end
