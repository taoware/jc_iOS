//
//  Store+Create.h
//  jycs
//
//  Created by appleseed on 4/9/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Store.h"

@interface Store (Create)

+ (Store *)storeWithStoreInfo:(NSDictionary *)storeDictionary
    inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadStoresFromNewsArray:(NSArray *)stores // of News NSDictionary
       intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
