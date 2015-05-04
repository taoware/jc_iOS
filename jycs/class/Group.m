//
//  Group.m
//  jycs
//
//  Created by appleseed on 2/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Group.h"

@implementation Group

- (id)initWithName:(NSString *)name andContacts:(NSArray *)contacts {
    if (self = [super init]) {
        self.name = name;
        self.contacts = contacts;
    }
    return self;
}

@end
