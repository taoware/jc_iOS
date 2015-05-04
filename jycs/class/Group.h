//
//  Group.h
//  jycs
//
//  Created by appleseed on 2/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Group : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSArray *contacts;

- (id)initWithName:(NSString *)name andContacts:(NSArray *)contacts;
@end
