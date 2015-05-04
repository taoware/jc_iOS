//
//  GXError.m
//  jycs
//
//  Created by appleseed on 3/12/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXError.h"

@implementation GXError
@synthesize description = _description;

+ (GXError *)errorWithCode:(GXErrorType)errCode andDescription:(NSString *)description {
    GXError* error = [[GXError alloc]init];
    error.errorCode = errCode;
    error.description = description;
    return error;
}

@end
