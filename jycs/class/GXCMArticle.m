//
//  GXCMArticle.m
//  Demo
//
//  Created by appleseed on 1/20/15.
//  Copyright (c) 2015 chenlei. All rights reserved.
//

#import "GXCMArticle.h"

#define ARTICLELSKEY @"articleskey"

@implementation GXCMArticle

- (id)initWithtitle:(NSString *)title andDesc:(NSString *)desc andIdentity:(int)identity andIconUrl:(NSString *)iconUrl andAuthor:(NSString*)author andcreatedDate:(NSString *)createdDate andBody:(NSString *)body {
    if (self = [super init]) {
        self.title = title;
        self.desc = desc;
        self.identity = identity;
        self.iconUrl = iconUrl;
        self.author = author;
        self.createdDate = createdDate;
        self.body = body;
    }
    return self;

}

@end
