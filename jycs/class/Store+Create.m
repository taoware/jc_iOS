//
//  Store+Create.m
//  jycs
//
//  Created by appleseed on 4/9/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "ResourceFetcher.h"
#import "Store+Create.h"
#import "Photo+Create.h"

@implementation Store (Create)

+ (Store *)storeWithStoreInfo:(NSDictionary *)storeDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    Store *store = nil;
    
    NSMutableDictionary* nullFreeRecord = [storeDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    storeDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = storeDictionary[RESOURCE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Store"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for news");
    } else if ([matches count]) {
        store = [matches firstObject];
    } else {
        store = [NSEntityDescription insertNewObjectForEntityForName:@"Store"
                                             inManagedObjectContext:context];
    }
    
    store.objectId = objectId;
    store.storeName = [storeDictionary valueForKeyPath:STORE_NAME];
    store.subtitle = [storeDictionary valueForKeyPath:STORE_SUBTITLE];
    store.phone = [storeDictionary valueForKeyPath:STORE_PHONE];
    store.address = [storeDictionary valueForKey:STORE_ADDRESS];
    store.province = [storeDictionary valueForKey:STORE_PROVINCE];
    store.type = [storeDictionary valueForKeyPath:STORE_TYPE];
    store.updateTime = [ResourceFetcher dateUsingStringFromAPI:[storeDictionary valueForKeyPath:RESOURCE_UPDATED_DATE]];
    store.createTime = [ResourceFetcher dateUsingStringFromAPI:[storeDictionary valueForKeyPath:RESOURCE_CREATED_DATE]];
    store.deleteTime = [ResourceFetcher dateUsingStringFromAPI:[storeDictionary valueForKeyPath:RESOURCE_DELETED_DATE]];
    NSDictionary* photoDictionary = [storeDictionary valueForKeyPath:STORE_PHOTO];
    store.photo = [Photo photoWithPhotoInfo:photoDictionary inManagedObjectContext:context];
    
    return store;
}

+ (void)loadStoresFromNewsArray:(NSArray *)stores intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *store in stores) {
        [self storeWithStoreInfo:store inManagedObjectContext:context];
    }
}

@end
