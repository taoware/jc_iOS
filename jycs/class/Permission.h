//
//  Permission.h
//  jycs
//
//  Created by appleseed on 4/22/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Permission : NSManagedObject

@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSString * permissonName;

@end
