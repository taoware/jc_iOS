//
//  Notification.h
//  jycs
//
//  Created by appleseed on 5/9/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Notification : NSManagedObject

@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSNumber * timestamp;

@end
