//
//  Store.h
//  jycs
//
//  Created by appleseed on 5/10/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Store : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSDate * deleteTime;
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * province;
@property (nonatomic, retain) NSString * storeName;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Photo *photo;

@end
