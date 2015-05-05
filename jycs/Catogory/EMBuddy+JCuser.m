//
//  EMBuddy+JCuser.m
//  jycs
//
//  Created by appleseed on 5/5/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "EMBuddy+JCuser.h"
#import "GXUserEngine.h"
#import "Photo.h"

@implementation EMBuddy (JCuser)

- (void)setRealName:(NSString *)realName {
    
}

- (void)setAvatarUrl:(NSString *)avatarUrl {
    
}

- (NSString *)realName {
    User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:self.username];
    return user.name;
}

- (NSString *)avatarUrl {
    User* user = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:self.username];
    return user.avatar.thumbnailURL;
}
@end
