//
//  News+Create.m
//  jycs
//
//  Created by appleseed on 4/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "ResourceFetcher.h"
#import "News+Create.h"
#import "Photo+Create.h"

@implementation News (Create)

+ (News *)newsWithNewsInfo:(NSDictionary *)newsDictionary inManagedObjectContext:(NSManagedObjectContext *)context
{
    News *news = nil;
    
    NSMutableDictionary* nullFreeRecord = [newsDictionary mutableCopy];
    [nullFreeRecord enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSNull class]]) {
            [nullFreeRecord setValue:nil forKey:key];
        }
    }];
    newsDictionary = [nullFreeRecord copy];
    
    NSNumber *objectId = newsDictionary[RESOURCE_ID];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"News"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectId = %@", objectId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for news");
    } else if ([matches count]) {
        news = [matches firstObject];
    } else {
        news = [NSEntityDescription insertNewObjectForEntityForName:@"News"
                                              inManagedObjectContext:context];
    }

    news.objectId = objectId;
    news.title = [newsDictionary valueForKeyPath:NEWS_TITLE];
    news.subtitle = [newsDictionary valueForKeyPath:NEWS_SUBTILTE];
    news.content = [newsDictionary valueForKeyPath:NEWS_CONTENT];
    news.type = [newsDictionary valueForKeyPath:NEWS_TYPE];
    news.url = [newsDictionary valueForKeyPath:NEWS_URL];
    news.updateTime = [ResourceFetcher dateUsingStringFromAPI:[newsDictionary valueForKeyPath:RESOURCE_UPDATED_DATE]];
    news.createTime = [ResourceFetcher dateUsingStringFromAPI:[newsDictionary valueForKeyPath:RESOURCE_CREATED_DATE]];
    news.deleteTime = [ResourceFetcher dateUsingStringFromAPI:[newsDictionary valueForKeyPath:RESOURCE_DELETED_DATE]];
    NSDictionary* photoDictionary = [newsDictionary valueForKeyPath:NEWS_PHOTO];
    news.photo = [Photo photoWithPhotoInfo:photoDictionary inManagedObjectContext:context];
    
    return news;
}

+ (void)loadNewsFromNewsArray:(NSArray *)newsArray intoManagedObjectContext:(NSManagedObjectContext *)context
{
    for (NSDictionary *news in newsArray) {
        [self newsWithNewsInfo:news inManagedObjectContext:context];
    }
}

+ (void)deleteAllRecordsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest * allRecords = [[NSFetchRequest alloc] init];
    [allRecords setEntity:[NSEntityDescription entityForName:@"News" inManagedObjectContext:context]];
    [allRecords setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * records = [context executeFetchRequest:allRecords error:&error];
    //error handling goes here
    for (NSManagedObject * record in records) {
        [context deleteObject:record];
    }
}

@end
