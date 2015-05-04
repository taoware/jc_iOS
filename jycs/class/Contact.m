//
//  Contact.m
//  jycs
//
//  Created by appleseed on 2/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Contact.h"

@implementation Contact

- (id)initWithName:(NSString *)name andIamgeName:(NSString *)imageName{
    if (self = [super init]) {
        self.name = name;
        self.imageName = imageName;
    }
    return self;
}

@end
