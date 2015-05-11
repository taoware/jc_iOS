//
//  ResourceFetcher.h
//  jycs
//
//  Created by appleseed on 4/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>


// key paths to news at top-level of results
#define API_RESULTS @"results"

// keys to values in a news dictionary
#define NEWS_TITLE @"title"
#define NEWS_SUBTILTE @"summary"
#define NEWS_CONTENT @"content"
#define NEWS_PHOTO @"photo"
#define NEWS_TYPE @"type"
#define NEWS_URL @"url"

// keys to values in a store dictionary
#define STORE_NAME  @"storeName"
#define STORE_SUBTITLE @"summary"
#define STORE_PHONE @"phone"
#define STORE_ADDRESS @"address"
#define STORE_PROVINCE @"province"
#define STORE_PHOTO @"photo"
#define STORE_TYPE @"type"
#define STORE_URL @"url"

// keys to values in a moment dictionary
#define MOMENT_TEXT @"information"
#define MOMENT_TYPE @"type"
#define MOMENT_SCREENNAME @"squareName"
#define MOMENT_SENDER @"user"
#define MOMENT_UNIT @"unit"
#define MOMENT_PHOTOS @"photos"

// keys to values in a unit dictionary
#define UNIT_NAME @"name"
#define UNIT_URINAME @"uriName"
#define UNIT_CATEGORY @"category"

// keypath to values in a photo dictionary
#define PHOTO_ID @"id"
#define PHOTO_URL @"url"
#define PHOTO_THUMBNAIL_URL @"thumbnailUrl"
#define PHOTO_DESCRIPTION @"photoDescription"

// keypath to values in a permisson dictionary
#define PERMISSON_NAME @"perName"

// keys to values in a user dictionary
#define USER_NAME @"name"
#define USER_SCREENNAME @"screenName"
#define USER_MOBILE @"mobile"
#define USER_LOCATION @"location"
#define USER_AUDIT @"audit"
#define USER_AVATAR @"avatar"
#define USER_UNITS @"units"
#define USER_PERMISSIONS @"permissions"

// keys to values in easemob dictionary
#define EASEMOB_USERNAME @"im.username"
#define EASEMOB_PASSWORD @"im.password"

// keys applicable to all types of json dictionaries
#define RESOURCE_ID @"id"
#define RESOURCE_UPDATED_DATE @"updateTime"  // yyyy-MM-dd HH:mm:ss
#define RESOURCE_CREATED_DATE @"createTime"
#define RESOURCE_DELETED_DATE @"deleteTime"

typedef enum {
    PhotoFormatSquare = 1,    // thumbnail
    PhotoFormatLarge = 2,     // normal size
} PhotoFormat;

@interface ResourceFetcher : NSObject

+ (NSURL *)URLforPhoto:(NSDictionary *)photo format:(PhotoFormat)format;

+ (NSDate *)dateUsingStringFromAPI:(NSString *)dateString;
+ (NSString *)dateStringForAPIUsingDate:(NSDate *)date;


@end
