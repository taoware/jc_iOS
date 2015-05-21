//
//  GXPhotoEngine.m
//  jycs
//
//  Created by appleseed on 5/14/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPhotoEngine.h"
#import "GXUserEngine.h"
#import "UIImage+UIImageFunctions.h"

@implementation GXPhotoEngine



+ (NSString *)uniqueDocumentURL
{
    NSString* username = [GXUserEngine sharedEngine].userLoggedIn.mobile;
    NSString* folderPath = [[self documentDirectory] stringByAppendingPathComponent:username];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:folderPath isDirectory:NULL]) {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
    
    NSString *unique = [NSString stringWithFormat:@"%.10f", [NSDate timeIntervalSinceReferenceDate]];
    unique = [unique stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [username stringByAppendingPathComponent:unique];
}

+ (NSString *)documentDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

+ (NSString *)writePhotoToDisk:(UIImage *)image {
//    UIImage* scaledImage = [image scaleProportionalToSize:[UIScreen mainScreen].bounds.size];  // doesn't scale for now
    NSData* imageData = UIImageJPEGRepresentation(image, 0.8);
    
    NSString* imageRelatveUrl = [self uniqueDocumentURL];
    NSString* pathUrl = [[self documentDirectory] stringByAppendingPathComponent:imageRelatveUrl];
    NSError* error;
    if (![imageData writeToFile:pathUrl options:NSDataWritingAtomic error:&error]) {
        NSLog(@"save photo failed");
        NSLog(@"%@", error);
    }
    return imageRelatveUrl;
}

+ (UIImage *)imageForlocalPhotoUrl:(NSString *)photoUrl {
    NSString* pathUrl = [[self documentDirectory] stringByAppendingPathComponent:photoUrl];
    return [UIImage imageWithContentsOfFile:pathUrl];
}

+ (NSData *)dataForLocalPhotoURL:(NSString *)photoURL {
    NSString* pathURL = [[self documentDirectory] stringByAppendingPathComponent:photoURL];
    return [NSData dataWithContentsOfFile:pathURL];
}

@end
