//
//  Photo.h
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSString * thumbnailURL;

@end
