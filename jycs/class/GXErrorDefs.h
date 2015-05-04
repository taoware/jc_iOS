//
//  GXErrorDefs.h
//  jycs
//
//  Created by appleseed on 3/12/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#ifndef jycs_GXErrorDefs_h
#define jycs_GXErrorDefs_h

typedef enum : NSUInteger {
    //server error
    GXErrorServerNotLogin       = 0,         // 未登陆
    GXErrorServerNotReachable,               // 连接服务器失败(Ex. 手机客户端无网的时候, 会返回的error)
    GXErrorServerTimeout,                    // 连接超时(Ex. 服务器连接超时会返回的error)
    
    // user error
    GXErrorAuthenticationFailure,      // 登录时用户名密码错误
    GXErrorJCServerAuthenticationFailure, // 教超验证失败
    GXErrorEaseMobSeverError,            // 环信连接失败
    GXErrorEaseMobAuthenticationFailure,  // 环信验证失败
    GXErrorRegistrationFailure,        // 注册失败
    GXErrorUserUpdateFailure,          // 用户更新失败
    GXErrorUserQueryFailure,           // 用户查询失败
    GXErrorOldPasswordInvalid,          // 密码重置旧密码错误
    GXErrorPasswordResetFailure,       // 密码重置失败
    
    // moment error
    GXErrorMomentSendFailure           // 消息发送失败

}GXErrorType;

#endif
