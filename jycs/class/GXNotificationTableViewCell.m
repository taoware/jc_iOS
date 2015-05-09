//
//  GXNotificationTableViewCell.m
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXNotificationTableViewCell.h"
#import "GXCoreDataController.h"

@interface GXNotificationTableViewCell ()
@property (nonatomic, strong)NSDateFormatter* dateFormatter;
@end

@implementation GXNotificationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setNotification:(Notification *)notification {
    _notification = notification;
    [self updateUI];
}

- (void)updateUI {
    self.titleLabel.text = [self.notification.title substringFromIndex:6];
    self.bodyLabel.text = self.notification.body;

    self.timeLabel.text = [self.dateFormatter stringFromDate:self.notification.timestamp];
    NSString* bookmarkImgName = [self.notification.isFavorite boolValue]?@"bookmarked.png":@"bookmark.png";
    [self.bookmarkButton setBackgroundImage:[UIImage imageNamed:bookmarkImgName] forState:UIControlStateNormal];
    NSString* readImgName = [self.notification.isRead boolValue]?@"read_yes.png":@"read_no.png";
    [self.readButton setBackgroundImage:[UIImage imageNamed:readImgName] forState:UIControlStateNormal];
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

- (IBAction)readButtonTapped:(UIButton *)sender {
    self.notification.isRead = @(YES);
    NSString* readImgName = [self.notification.isRead boolValue]?@"read_yes.png":@"read_no.png";
    [self.readButton setBackgroundImage:[UIImage imageNamed:readImgName] forState:UIControlStateNormal];
    [self saveContext];
    
    EMConversation* conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.notification.groupId isGroup:YES];
    [conversation markMessageWithId:self.notification.messageId asRead:YES];
    
}

- (IBAction)favoriteButtonTapped:(UIButton *)sender {
    self.notification.isFavorite = @(!self.notification.isFavorite.boolValue);
    NSString* bookmarkImgName = [self.notification.isFavorite boolValue]?@"bookmarked.png":@"bookmark.png";
    [self.bookmarkButton setBackgroundImage:[UIImage imageNamed:bookmarkImgName] forState:UIControlStateNormal];
    [self saveContext];
}

- (void)saveContext {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSError *error = nil;
        [[GXCoreDataController sharedInstance] saveBackgroundContext];
        if (error) {
            NSLog(@"Error saving background context after creating objects on server: %@", error);
        }
        
        [[GXCoreDataController sharedInstance] saveMasterContext];
    });
}

@end
