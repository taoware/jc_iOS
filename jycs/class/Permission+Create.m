//
//  Permission+Create.m
//  jycs
//
//  Created by appleseed on 4/22/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Permission+Create.h"
#import "ResourceFetcher.h"

@implementation Permission (Create)

+ (Permission *)permissionWithPermissionInfo:(NSDictionary *)permissionDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Permission *permission = nil;
    
    NSMutableDictionary* nullFreeRecord = [permissionDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    permissionDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = permissionDictionary[RESOURCE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Permission"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for permission");
    } else if ([matches count]) {
        permission = [matches firstObject];
    } else {
        permission = [NSEntityDescription insertNewObjectForEntityForName:@"Permission"
                                              inManagedObjectContext:context];
    }
    
    permission.objectId = objectId;
    permission.permissonName = [permissionDictionary valueForKey:PERMISSON_NAME];
    
    return permission;
    
}

+ (void)loadPermissionsFromPermissionsArray:(NSArray *)permissions intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *permission in permissions) {
        [self permissionWithPermissionInfo:permission inManagedObjectContext:context];
    }
}


@end
