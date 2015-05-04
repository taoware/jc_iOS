//
//  GXCMArticle.h
//  Demo
//
//  Created by appleseed on 1/20/15.
//  Copyright (c) 2015 chenlei. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GXCMArticle : NSObject
@property (nonatomic, copy)NSString* title;
@property (nonatomic, copy)NSString* desc;
@property (nonatomic)int identity;
@property (nonatomic, copy)NSString* iconUrl;
@property (nonatomic, copy)NSString* author;
@property (nonatomic, copy)NSString* createdDate;
@property (nonatomic, copy)NSString* body;
- (id)initWithtitle:(NSString *)title andDesc:(NSString *)desc andIdentity:(NSString *)identity andIconUrl:(NSString *)iconUrl andAuthor:(NSString*)author andcreatedDate:(NSString *)createdDate andBody:(NSString *)body;
@end
