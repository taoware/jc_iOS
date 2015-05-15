//
//  Photo+Create.m
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Photo+Create.h"
#import "ResourceFetcher.h"

@implementation Photo (Create)

+ (Photo *)photoWithPhotoInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo = nil;
    
    NSMutableDictionary* nullFreeRecord = [photoDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    photoDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = photoDictionary[PHOTO_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for news");
    } else if ([matches count]) {
        photo = [matches firstObject];
    } else {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
    }
    
    photo.objectId = objectId;
    photo.photoDescription = [photoDictionary valueForKeyPath:PHOTO_DESCRIPTION];
    photo.imageURL = [[ResourceFetcher URLforPhoto:photoDictionary format:PhotoFormatLarge] absoluteString];
    photo.thumbnailURL = [[ResourceFetcher URLforPhoto:photoDictionary format:PhotoFormatSquare] absoluteString];
    
    return photo;

}

+ (NSArray* )loadPhotosFromPhotosArray:(NSArray *)photos intoManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray* photosArray = [[NSMutableArray alloc]init];
    for (NSDictionary *photo in photos) {
        [photosArray addObject:[self photoWithPhotoInfo:photo inManagedObjectContext:context]];
    }
    return [photosArray copy];
}

@end
