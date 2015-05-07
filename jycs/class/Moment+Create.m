//
//  Moment+Create.m
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Moment+Create.h"
#import "ResourceFetcher.h"
#import "Photo+Create.h"
#import "GXSyncEngine.h"
#import "User+Query.h"

@implementation Moment (Create)

+ (Moment *)momentWithMomentInfo:(NSDictionary *)momentDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Moment *moment = nil;
    
    NSMutableDictionary* nullFreeRecord = [momentDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    momentDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = momentDictionary[RESOURCE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Moment"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for news");
    } else if ([matches count]) {
        moment = [matches firstObject];
    } else {
        moment = [NSEntityDescription insertNewObjectForEntityForName:@"Moment"
                                              inManagedObjectContext:context];
    }
    
    moment.objectId = objectId;
    moment.text = [momentDictionary valueForKeyPath:MOMENT_TEXT];
    moment.type = [momentDictionary valueForKeyPath:MOMENT_TYPE];
    moment.screenName = [momentDictionary valueForKey:MOMENT_SCREENNAME];
    moment.sender = [User UserWithUserInfo:[momentDictionary valueForKey:MOMENT_SENDER] inManagedObjectContext:context];
    moment.updateTime = [ResourceFetcher dateUsingStringFromAPI:[momentDictionary valueForKeyPath:RESOURCE_UPDATED_DATE]];
    moment.createTime = [ResourceFetcher dateUsingStringFromAPI:[momentDictionary valueForKeyPath:RESOURCE_CREATED_DATE]];
    moment.deleteTime = [ResourceFetcher dateUsingStringFromAPI:[momentDictionary valueForKeyPath:RESOURCE_DELETED_DATE]];
    moment.syncStatus = [NSNumber numberWithInt:GXObjectSynced];
    
    [moment removePhoto:moment.photo];
    NSArray* photoDictionarys = [momentDictionary valueForKey:MOMENT_PHOTOS];
    for (NSDictionary* photoDictionary in photoDictionarys) {
        [moment addPhotoObject:[Photo photoWithPhotoInfo:photoDictionary inManagedObjectContext:context]];
    }

    return moment;

}

+ (void)loadMomentsFromMomentsArray:(NSArray *)moments intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (NSDictionary *moment in moments) {
        [self momentWithMomentInfo:moment inManagedObjectContext:context];
    }
}

- (NSDictionary *)JSONToCreateMomentOnServer {
    NSDictionary* jsonDictionary = @{
                                     @"information": self.text,
                                     @"type": self.type
                                     };
    return jsonDictionary;
}

@end
