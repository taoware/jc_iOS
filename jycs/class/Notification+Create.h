//
//  Notification+Create.h
//  jycs
//
//  Created by appleseed on 5/8/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "Notification.h"
#import "EMMessage.h"

@interface Notification (Create)

+ (Notification *)notificationWithEMMessage:(EMMessage *)message
          inManagedObjectContext:(NSManagedObjectContext *)context;
+ (void)loadNotificationsFromNotificationsArray:(NSArray *)messages // of EMMessage
           intoManagedObjectContext:(NSManagedObjectContext *)context;

@end
