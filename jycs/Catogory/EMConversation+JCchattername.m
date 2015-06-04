//
//  EMConversation+JCchattername.m
//  jycs
//
//  Created by appleseed on 5/28/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "EMConversation+JCchattername.h"
#import "GXUserEngine.h"

@implementation EMConversation (JCchattername)

- (void)setChatterJCname:(NSString *)chatterJCname {
    
}

- (NSString *)chatterJCname {
    NSString* name = @"未知";
    
    NSString* chatter = self.chatter;
    if (!self.isGroup) {
        name = [[GXUserEngine sharedEngine] queryUserInfoUsingEasmobUsername:chatter].name;
    } else {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *group in groupArray) {
            if ([group.groupId isEqualToString:self.chatter]) {
                name = [group.groupSubject substringFromIndex:6];
                break;
            }
        }
    }
    return name;
}

@end
