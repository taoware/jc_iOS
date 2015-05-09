//
//  Notification+Create.m
//  jycs
//
//  Created by appleseed on 5/8/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Notification+Create.h"
#import "ConvertToCommonEmoticonsHelper.h"

@implementation Notification (Create)

+ (Notification *)notificationWithEMMessage:(EMMessage *)message inManagedObjectContext:(NSManagedObjectContext *)context {
    Notification* notificaion = nil;
    NSString* messageId = message.messageId;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Notification"];
    request.predicate = [NSPredicate predicateWithFormat:@"messageId = %@", messageId];
    
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
    }
    
    notificaion.messageId = messageId;
    EMGroup* group = [EMGroup groupWithId:message.from];
    notificaion.title = group.groupSubject;
    notificaion.groupId = message.from;
    notificaion.timestamp = [NSDate dateWithTimeIntervalSince1970: message.timestamp/1000];
    notificaion.isRead = @(message.isRead);
    notificaion.isFavorite = @(NO);
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    // 表情映射。
    NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
    notificaion.body = didReceiveText;
    
    return notificaion;
}

+ (void)loadNotificationsFromNotificationsArray:(NSArray *)messages intoManagedObjectContext:(NSManagedObjectContext *)context {
    for (EMMessage* message in messages) {
        [Notification notificationWithEMMessage:message inManagedObjectContext:context];
    }
}

@end
