//
//  Moment.h
//  jycs
//
//  Created by appleseed on 4/27/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Unit, User;

@interface Moment : NSManagedObject

@property (nonatomic, retain) NSDate * createTime;
@property (nonatomic, retain) NSDate * deleteTime;
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) Unit *inUnit;
@property (nonatomic, retain) NSSet *photo;
@property (nonatomic, retain) User *sender;
@end

@interface Moment (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

@end
