//
//  News+Create.h
//  jycs
//
//  Created by appleseed on 4/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "News.h"

@interface News (Create)

+ (News *)newsWithNewsInfo:(NSDictionary *)newsDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadNewsFromNewsArray:(NSArray *)photos // of News NSDictionary
         intoManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteAllRecordsInManagedObjectContext:(NSManagedObjectContext *)context;

@end
