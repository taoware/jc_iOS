//
//  User+Query.m
//  jycs
//
//  Created by appleseed on 4/8/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "User+Query.h"
#import "ResourceFetcher.h"
#import "SSKeychain.h"
#import "Photo+Create.h"
#import "Unit+Create.h"
#import "Permission+Create.h"

@implementation User (Query)

+ (User *)UserWithUserInfo:(NSDictionary *)userDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context
{
    User *user = nil;
    
    NSMutableDictionary* nullFreeRecord = [userDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    userDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = userDictionary[RESOURCE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for user");
    } else if ([matches count]) {
        user = [matches firstObject];
    } else {
        user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                             inManagedObjectContext:context];
    }
    
    user.objectId = objectId;
    user.mobile = [userDictionary valueForKeyPath:USER_MOBILE];
    user.name = [userDictionary valueForKeyPath:USER_NAME];
    user.location = [userDictionary valueForKey:USER_LOCATION];
    
    user.imUsername = [userDictionary valueForKeyPath:EASEMOB_USERNAME];
    user.imPassword = [userDictionary valueForKeyPath:EASEMOB_PASSWORD];
    
    user.updateTime = [ResourceFetcher dateUsingStringFromAPI:[userDictionary valueForKeyPath:RESOURCE_UPDATED_DATE]];
    user.createTime = [ResourceFetcher dateUsingStringFromAPI:[userDictionary valueForKeyPath:RESOURCE_CREATED_DATE]];
    user.deleteTime = [ResourceFetcher dateUsingStringFromAPI:[userDictionary valueForKeyPath:RESOURCE_DELETED_DATE]];
    NSDictionary* photoDictionary = [userDictionary valueForKeyPath:USER_AVATAR];
    user.avatar = [Photo photoWithPhotoInfo:photoDictionary inManagedObjectContext:context];
    
    NSArray* units = [userDictionary valueForKey:USER_UNITS];
    for (NSDictionary* unit in units) {
        [user addInUnitObject:[Unit unitWithUnitInfo:unit inManagedObjectContext:context]];
    }
    
    NSArray* permissions = [userDictionary valueForKey:USER_PERMISSIONS];
    for (NSDictionary* permission in permissions) {
        [user addHasPermissonObject:[Permission permissionWithPermissionInfo:permission inManagedObjectContext:context]];
    }
    
    return user;
}

+ (NSArray *)loadUserFromUsersArray:(NSArray *)users // of Users NSDictionary
      intoManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray* userArray = [[NSMutableArray alloc]init];
    for (NSDictionary *user in users) {
        [userArray addObject:[self UserWithUserInfo:user inManagedObjectContext:context]];
    }
    return userArray;
}

+ (void)deleteAllUsersInManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
    [allRecords setEntity:[NSEntityDescription entityForName:@"User" inManagedObjectContext:context]];
    [allRecords setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * records = [context executeFetchRequest:allRecords error:&error];
    //error handling goes here
    for (NSManagedObject * record in records) {
        [context deleteObject:record];
    }
}



@end
