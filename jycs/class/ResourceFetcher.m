//
//  ResourceFetcher.m
//  jycs
//
//  Created by appleseed on 4/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "ResourceFetcher.h"

static NSString * const kResourceBaseURLString = @"http://vps1.taoware.com:8080/jc/uploaded/";

@implementation ResourceFetcher

+ (NSURL *)URLforPhoto:(NSDictionary *)photo format:(PhotoFormat)format
{
    return [NSURL URLWithString:[self urlStringForPhoto:photo format:format]];
}

+ (NSString *)urlStringForPhoto:(NSDictionary *)photo format:(PhotoFormat)format
{
    NSString* keyForImageUrl;
    switch (format) {
        case PhotoFormatSquare:
            keyForImageUrl = PHOTO_THUMBNAIL_URL;
            break;
        case PhotoFormatLarge:
            keyForImageUrl = PHOTO_URL;
            break;
        default:
            break;
    }
    NSString* imageRelativeUrl = [photo valueForKeyPath:keyForImageUrl];
    return [NSString stringWithFormat:@"%@%@", kResourceBaseURLString, imageRelativeUrl];
}

+ (NSDate *)dateUsingStringFromAPI:(NSString *)dateString
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    
    return [dateFormatter dateFromString:dateString];
}

+ (NSString *)dateStringForAPIUsingDate:(NSDate *)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    
    return [dateFormatter stringFromDate:date];
}

@end
