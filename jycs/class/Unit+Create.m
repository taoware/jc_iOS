//
//  Unit+Create.m
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Unit+Create.h"
#import "ResourceFetcher.h"

@implementation Unit (Create)

+ (Unit *)unitWithUnitInfo:(NSDictionary *)unitDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Unit* unit = nil;
    
    NSMutableDictionary* nullFreeRecord = [unitDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    unitDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = unitDictionary[RESOURCE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Unit"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for news");
    } else if ([matches count]) {
        unit = [matches firstObject];
    } else {
        unit = [NSEntityDescription insertNewObjectForEntityForName:@"Unit"
                                               inManagedObjectContext:context];
    }
    
    unit.objectId = objectId;
    unit.name = [unitDictionary valueForKey:UNIT_NAME];
    unit.uriName = [unitDictionary valueForKey:UNIT_URINAME];
    unit.category = [unitDictionary valueForKey:UNIT_CATEGORY];
    
    return unit;

}

+ (void)loadUnitsFromUnitsArray:(NSArray *)units intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *unit in units) {
        [self unitWithUnitInfo:unit inManagedObjectContext:context];
    }
}

@end
