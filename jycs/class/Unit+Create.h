//
//  Unit+Create.h
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Unit.h"

@interface Unit (Create)

+ (Unit *)unitWithUnitInfo:(NSDictionary *)unitDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadUnitsFromUnitsArray:(NSArray *)units // of News NSDictionary
       intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
