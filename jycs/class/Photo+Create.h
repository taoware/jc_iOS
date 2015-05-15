//
//  Photo+Create.h
//  jycs
//
//  Created by appleseed on 4/17/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Photo.h"

@interface Photo (Create)

+ (Photo *)photoWithPhotoInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (NSArray *)loadPhotosFromPhotosArray:(NSArray *)photos // of News NSDictionary
       intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
