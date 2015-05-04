//
//  GXError.h
//  jycs
//
//  Created by appleseed on 3/12/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GXErrorDefs.h"

@interface GXError : NSObject
@property (nonatomic) GXErrorType errorCode;
@property (nonatomic, copy) NSString *description;

+ (GXError *)errorWithCode:(GXErrorType)errCode
            andDescription:(NSString *)description;
@end
