//
//  Notification+Create.m
//  jycs
//
//  Created by appleseed on 5/8/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Notification+Create.h"

@implementation Notification (Create)

+ (Notification *)notificationWithEMMessage:(EMMessage *)message inManagedObjectContext:(NSManagedObjectContext *)context {
    Notification* notificaion = nil;
    NSString* messageId = message.messageId;
    NSString* groupId = message.from;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId = %@ AND groupId = %@", messageId, groupId];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) {
        // handle error
        NSLog(@"database error for news");
    } else if ([matches count]) {
        notificaion = [matches firstObject];
    } else {
        notificaion = [NSEntityDescription insertNewObjectForEntityForName:@"Notification"
                                               inManagedObjectContext:context];
        notificaion.messageId = messageId;
        notificaion.timestamp = @(message.timestamp);
        notificaion.groupId = groupId;
        notificaion.isFavorite = @(NO);
    }
    
    return notificaion;
}

+ (NSArray*)loadNotificationsFromNotificationsArray:(NSArray *)messages intoManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray* notificatons = [[NSMutableArray alloc]init];
    for (EMMessage* message in messages) {
        [notificatons addObject: [Notification notificationWithEMMessage:message inManagedObjectContext:context]];
    }
    return notificatons;
}

@end
