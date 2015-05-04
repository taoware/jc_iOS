//
//  Moment+Create.h
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Moment.h"

@interface Moment (Create)

+ (Moment *)momentWithMomentInfo:(NSDictionary *)momentDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadMomentsFromMomentsArray:(NSArray *)moments // of Moments NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context;

- (NSDictionary *)JSONToCreateMomentOnServer;

@end
