//
//  GXAuthEngine.m
//  jycs
//
//  Created by appleseed on 3/12/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXUserEngine.h"
#import "GXHTTPManager.h"
#import "AFHTTPRequestOperation.h"
#import "GXError.h"
#import "GXCoreDataController.h"
#import "ResourceFetcher.h"
#import "User+Query.h"
#import "SSKeychain.h"

@interface GXUserEngine ()
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation GXUserEngine

+ (GXUserEngine *)sharedEngine {
    static GXUserEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[GXUserEngine alloc] init];
    });
    
    return sharedEngine;
}

- (void)initializeCurrentUser {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* mobile = [defaults objectForKey:@"userLoggedIn"];
    
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"mobile == %@", mobile];
    fetchRequest.predicate = predicate;
    NSError* error;
    self.userLoggedIn = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] firstObject];
}

- (void)updateUserLoggedInFlagWith:(NSString *)username {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:username forKey:@"userLoggedIn"];
    [defaults synchronize];
}

- (void)enableUserAutoLogin {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(YES) forKey:@"autoLogin"];
    [defaults synchronize];
}

- (void)clearAutoLoginFlagInUserDefault {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@(NO) forKey:@"autoLogin"];
    [defaults synchronize];
}

- (void)saveUserPasswordInKeychainWithUsername:(NSString *)username andPassword:(NSString *)password {
    // save user credential to keychain
    [SSKeychain setPassword:password forService:SERVICENAME account:username];
}

- (void)asyncLoginWithUsername:(NSString *)username password:(NSString *)password completion:(void (^)(NSDictionary *, GXError *))completion {
    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                                    username, @"mobile",
                                    password, @"plainPassword", nil];
    [[GXHTTPManager sharedManager] GET:@"users/login" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray* users = [responseObject valueForKeyPath:API_RESULTS];
        NSDictionary* userDic = [users firstObject];
        User* user = [User UserWithUserInfo:userDic inManagedObjectContext:context]; // load user info into core data
//        if (!user.imUsername || !user.imPassword || user.imUsername.length == 0 || user.imPassword.length == 0) {
//            completion(nil, [GXError errorWithCode:GXErrorEaseMobAuthenticationFailure andDescription:@"server error, this user have no easemob account"]);
//            return ;
//        }
        [self initializeCurrentUser];
        if ([user.audit boolValue]) {
            //环信异步登陆账号
            [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:user.imUsername
                                                                password:user.imPassword
                                                              completion:
             ^(NSDictionary *loginInfo, EMError *error) {
                 if (loginInfo && !error) {
                     [self updateUserLoggedInFlagWith:username];
                     [self enableUserAutoLogin];
                     [self saveUserPasswordInKeychainWithUsername:username andPassword:password];
                     
                     //获取群组列表
                     [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
                     [[EaseMob sharedInstance].chatManager asyncFetchBuddyList];
                     
                     //设置是否自动登录
                     [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
                     //将旧版的coredata数据导入新的数据库
                     EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
                     if (!error) {
                         error = [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
                     }
                     
                     completion(responseObject, nil);
                 }else {
                     switch (error.errorCode) {
                         case EMErrorServerAuthenticationFailure:
                             completion(nil, [GXError errorWithCode:GXErrorEaseMobAuthenticationFailure andDescription:error.description]);
                             break;
                         default:
                             completion(nil, [GXError errorWithCode:GXErrorEaseMobSeverError andDescription:error.description]);
                             break;
                     }
                 }
             } onQueue:nil];
        } else {
            [self updateUserLoggedInFlagWith:username];
            [self enableUserAutoLogin];
            [self saveUserPasswordInKeychainWithUsername:username andPassword:password];
            completion(responseObject, nil);
        }
        
        [self executeCompletedOperations];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                completion(nil, [GXError errorWithCode:GXErrorAuthenticationFailure andDescription:apiError]);
            }
        } else {
            // AFNetworking error handling
            [self initializeCurrentUser];
            completion(nil, [GXError errorWithCode:GXErrorServerNotReachable andDescription:error.localizedDescription]);
        }
        [self executeCompletedOperations];
    }];
}

- (void)asyncUserRegisterWithRealName:(NSString *)name andGender:(NSString *)gender andCategory:(NSString *)category andJob:(NSString *)job andArea:(NSString *)area andAddress:(NSString *)address andPhoneNumber:(NSString *)phoneNumber andValidationCode:(NSString *)validationCode andPassword:(NSString *)password andRemark:(NSString *)remark completion:(void (^)(NSDictionary *, GXError *))completion {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                               name, @"name",
                               gender, @"gender",
                               category, @"category",
                               job, @"position",
                               area, @"location",
                               address, @"address",
                               phoneNumber, @"mobile",
                               password, @"plainPassword",
                               remark, @"notes",
                               nil];
    [[GXHTTPManager sharedManager] POST:@"users" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                completion(nil, [GXError errorWithCode:GXErrorRegistrationFailure andDescription:apiError]);
            }
        } else {
            // AFNetworking error handling
            completion(nil, [GXError errorWithCode:GXErrorServerNotReachable andDescription:error.localizedDescription]);
        }
    }];
}


- (void)asyncResetPasswordWithOldPass:(NSString *)oldPass andNewPass:(NSString *)newPass  completion:(void (^)(NSDictionary *, GXError *))completion {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                                    oldPass, @"oldPassword",
                                    newPass, @"password",
                                    nil];

    NSString* userId = [NSString stringWithFormat:@"%@", self.userLoggedIn.objectId];
    NSString* endpoint = [@"users/password/" stringByAppendingString:userId];
    [[GXHTTPManager sharedManager] POST:endpoint parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {

        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                completion(nil, [GXError errorWithCode:GXErrorOldPasswordInvalid andDescription:apiError]);
            }
        } else {
            // AFNetworking error handling
            completion(nil, [GXError errorWithCode:GXErrorServerNotReachable andDescription:error.localizedDescription]);
        }
    }];
}

- (void)asyncPasswordForgotWithNewPass:(NSString *)newPass completion:(void (^)(GXError *))completion {
    NSDictionary *parameter = [NSDictionary dictionaryWithObjectsAndKeys:
                               newPass, @"password",
                               nil];
    NSString* userId = [NSString stringWithFormat:@"%@", self.userLoggedIn.objectId];
    NSString* endpoint = [NSString stringWithFormat:@"users/%@/forgetPass", userId];
    [[GXHTTPManager sharedManager] POST:endpoint parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                completion([GXError errorWithCode:GXErrorPasswordResetFailure andDescription:apiError]);
            }
        } else {
            // AFNetworking error handling
            completion([GXError errorWithCode:GXErrorServerNotReachable andDescription:error.localizedDescription]);
        }
    }];
}


- (void)executeCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        [[GXCoreDataController sharedInstance] saveBackgroundContext];
        if (error) {
            NSLog(@"Error saving background context after creating objects on server: %@", error);
        }
        
        [[GXCoreDataController sharedInstance] saveMasterContext];
    });
}


- (void)asyncUpdateUserAvatarwithImageData:(NSData *)imageData andImageName:(NSString *)imageName completion:(void (^)(NSDictionary *, GXError *))completion {
    
    User* user = self.userLoggedIn;
    NSString* endpoint = [NSString stringWithFormat:@"users/%@/avatar/", user.objectId];
    [[GXHTTPManager sharedManager] POST:endpoint parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:imageName mimeType:@"image/jpeg"];
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // api error handling
        id responseObject = error.userInfo[@"kErrorResponseObjectKey"];
        if ([responseObject isKindOfClass:[NSDictionary class]]&&responseObject) {
            NSString* apiError = [responseObject objectForKey:@"msg"];
            if (apiError) {
                completion(nil, [GXError errorWithCode:GXErrorUserUpdateFailure andDescription:apiError]);
            }
        } else {
            // AFNetworking error handling
            completion(nil, [GXError errorWithCode:GXErrorServerNotReachable andDescription:error.localizedDescription]);
        }
    }];

}

- (void)asyncLogoutWithCompletion:(void (^)(NSDictionary *, GXError *))completion {
    [self clearAutoLoginFlagInUserDefault];
    
    EMError* emError;
    [[[EaseMob sharedInstance] chatManager] logoffWithUnbindDeviceToken:YES error:&emError];
    
    GXError* error;
    if (emError) {
        error = [GXError errorWithCode:emError.errorCode andDescription:emError.description];
    }
    _userLoggedIn = nil;
    completion(nil, error);
}

- (void)asyncFetchUserInfoWithEasemobUsername:(NSArray *)usernames completion:(void (^)(GXError *))completion {
    NSManagedObjectContext* context = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSString* endpoint = @"users";
    NSString* usernameAsString = [usernames componentsJoinedByString:@","];
    NSDictionary* parameter = @{@"imUsernames": usernameAsString};
    [[GXHTTPManager sharedManager] GET:endpoint parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray* users = [responseObject objectForKey:API_RESULTS];
            [User loadUserFromUsersArray:users intoManagedObjectContext:context];
        }
        [self executeCompletedOperations];
        completion(nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self executeCompletedOperations];
        completion([GXError errorWithCode:GXErrorUserQueryFailure andDescription:@"用户数据查询失败"]);
    }];
}

- (User *)queryUserInfoUsingEasmobUsername:(NSString *)easemobUsername {
    NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc]initWithEntityName:@"User"];
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"imUsername == %@", easemobUsername];
    fetchRequest.predicate = predicate;
    NSError* error;
    User* user = [[managedObjectContext executeFetchRequest:fetchRequest error:&error] firstObject];
    return user;
}

- (void)queryUserInfoUsingMobile:(NSString *)mobile completion:(void (^)(NSArray *, GXError *))completion {NSManagedObjectContext *managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    NSDictionary* parameter = @{@"mobile": mobile};
    [[GXHTTPManager sharedManager] GET:@"users" parameters:parameter success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray* users = [responseObject valueForKeyPath:API_RESULTS];
        NSArray* userArray = [User loadUserFromUsersArray:users intoManagedObjectContext:managedObjectContext]; // load user info into core data
        [self executeCompletedOperations];
        completion(userArray, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, [GXError errorWithCode:GXErrorUserQueryFailure andDescription:@"查询错误"]);
    }];
}

@end
