//
//  GXStoreCarouselView.m
//  jycs
//
//  Created by appleseed on 5/22/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXStoreCarouselView.h"
#import "Store.h"

@implementation GXStoreCarouselView

- (void)setStores:(NSArray *)stores {
    _stores = stores;
    NSArray* images = [stores valueForKeyPath:@"photo.imageURL"];
    NSMutableArray* items = [[NSMutableArray alloc]init];
    for (NSString* imageURL in images) {
        GXCarouselURLItem* urlAD = [[GXCarouselURLItem alloc]init];
        urlAD.imageUrl = imageURL;
        [items addObject:urlAD];
    }
    
    [self setItems:items];
    self.indicatorTintColor = [UIColor redColor];
    self.defaultImage = [UIImage imageNamed:@"placeholder.jpg"];
    [self setAutoPagingForInterval:4];
}

@end
