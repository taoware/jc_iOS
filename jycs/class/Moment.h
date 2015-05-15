//
//  Moment.h
//  jycs
//
//  Created by appleseed on 5/15/15.
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
@property (nonatomic, retain) NSNumber * syncStatus;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) Unit *inUnit;
@property (nonatomic, retain) NSOrderedSet *photo;
@property (nonatomic, retain) User *sender;
@end

@interface Moment (CoreDataGeneratedAccessors)

- (void)insertObject:(Photo *)value inPhotoAtIndex:(NSUInteger)idx;
- (void)removeObjectFromPhotoAtIndex:(NSUInteger)idx;
- (void)insertPhoto:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removePhotoAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInPhotoAtIndex:(NSUInteger)idx withObject:(Photo *)value;
- (void)replacePhotoAtIndexes:(NSIndexSet *)indexes withPhoto:(NSArray *)values;
- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSOrderedSet *)values;
- (void)removePhoto:(NSOrderedSet *)values;
@end
