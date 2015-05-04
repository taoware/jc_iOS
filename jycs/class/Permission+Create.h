//
//  Permission+Create.h
//  jycs
//
//  Created by appleseed on 4/22/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Permission.h"

@interface Permission (Create)

+ (Permission *)permissionWithPermissionInfo:(NSDictionary *)permissionDictionary
                      inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadPermissionsFromPermissionsArray:(NSArray *)permissions // of Permission NSDictionary
                   intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
