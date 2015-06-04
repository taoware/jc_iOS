//
//  User.h
//  jycs
//
//  Created by appleseed on 5/29/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Permission, Photo, Unit;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * audit;
@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSDate * deleteTime;
@property (nonatomic, retain) NSString * imPassword;
@property (nonatomic, retain) NSString * imUsername;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) Photo *avatar;
@property (nonatomic, retain) NSSet *hasPermisson;
@property (nonatomic, retain) NSSet *inUnit;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addHasPermissonObject:(Permission *)value;
- (void)removeHasPermissonObject:(Permission *)value;
- (void)addHasPermisson:(NSSet *)values;
- (void)removeHasPermisson:(NSSet *)values;

- (void)addInUnitObject:(Unit *)value;
- (void)removeInUnitObject:(Unit *)value;
- (void)addInUnit:(NSSet *)values;
- (void)removeInUnit:(NSSet *)values;

@end
