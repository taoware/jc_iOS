//
//  Unit.h
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Unit : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * uriName;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * objectId;

@end
