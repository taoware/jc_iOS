//
//  User+Query.h
//  jycs
//
//  Created by appleseed on 4/8/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "User.h"

@interface User (Query)

+ (User *)UserWithUserInfo:(NSDictionary *)userDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadUserFromUsersArray:(NSArray *)users // of Users NSDictionary
      intoManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteAllUsersInManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)deleteUser:(User *)user InManagedObjectContext:(NSManagedObjectContext *)context;

@end
