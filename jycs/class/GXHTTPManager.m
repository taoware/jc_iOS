//
//  AFBmobHTTPClient.m
//  jycs
//
//  Created by appleseed on 3/16/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXHTTPManager.h"

static NSString * const kAPIBaseURLString = @"http://vps1.taoware.com:8080/jc/";

#define kErrorResponseObjectKey @"kErrorResponseObjectKey"

@implementation GXHTTPManager

+ (GXHTTPManager *)sharedManager
{
    static GXHTTPManager *_sharedManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kAPIBaseURLString]];
    });
    
    return _sharedManager;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }

    return self;
}

/// This wraps the completion handler with a shim that injects the responseObject into the error.
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(void (^)(NSURLResponse *, id, NSError *))originalCompletionHandler {
    return [super dataTaskWithRequest:request
                    completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
    {
                        
        // If there's an error, store the response in it if we've got one.
        if (error && responseObject) {
            if (error.userInfo) { // Already has a dictionary, so we need to add to it.
                NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
                userInfo[kErrorResponseObjectKey] = responseObject;
                error = [NSError errorWithDomain:error.domain
                                            code:error.code
                                        userInfo:[userInfo copy]];
            } else { // No dictionary, make a new one.
                error = [NSError errorWithDomain:error.domain
                                            code:error.code
                                        userInfo:@{kErrorResponseObjectKey: responseObject}];
            }
        }
        // Call the original handler.
        if (originalCompletionHandler) {
            originalCompletionHandler(response, responseObject, error);
        }
    }];
}

@end
