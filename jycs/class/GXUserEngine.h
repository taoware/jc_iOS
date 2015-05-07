//
//  GXAuthEngine.h
//  jycs
//
//  Created by appleseed on 3/12/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXError.h"
#import "User.h"

@interface GXUserEngine : NSObject

+(GXUserEngine *)sharedEngine;

@property (nonatomic, readonly, strong)User* userLoggedIn;

- (void)clearAutoLoginFlagInUserDefault;

- (void)asyncLoginWithUsername:(NSString *)username password:(NSString *)password completion:(void(^)(NSDictionary *loginInfo, GXError *error))completion;
- (void)asyncUserRegisterWithRealName:(NSString *)name andGender:(NSString *)gender andCategory:(NSString *)category andJob:(NSString *)job andArea:(NSString *)area andAddress:(NSString *)address andPhoneNumber:(NSString *)phoneNumber andValidationCode:(NSString *)validationCode andPassword:(NSString *)password andRemark:(NSString *)remark completion:(void(^)(NSDictionary *registerInfo, GXError* error))completion;
- (void)asyncResetPasswordWithOldPass:(NSString *)oldPass andNewPass:(NSString *)newPass  completion:(void(^)(NSDictionary *resetInfo, GXError* error))completion;
- (void)asyncUpdateUserAvatarwithImageData:(NSData *)imageData andImageName:(NSString *) imageName completion:(void (^)(NSDictionary *info, GXError *error))completion;
- (void)asyncLogoutWithCompletion:(void (^)(NSDictionary *info, GXError *error))completion;
- (void)asyncFetchUserInfoWithEasemobUsername:(NSArray *)usernames completion:(void (^)(GXError *error))completion;
- (void)asyncPasswordForgotWithNewPass:(NSString *)newPass completion:(void (^)(GXError *error))completion;

- (User *)queryUserInfoUsingEasmobUsername:(NSString* )easemobUsername;

@end
