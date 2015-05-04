//
//  Contact.h
//  jycs
//
//  Created by appleseed on 2/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contact : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic, strong)NSString* imageName;
- (id)initWithName:(NSString *)name andIamgeName:(NSString *)imageName;
@end
