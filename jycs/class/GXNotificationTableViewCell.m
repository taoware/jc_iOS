//
//  GXNotificationTableViewCell.m
//  jycs
//
//  Created by appleseed on 5/7/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXNotificationTableViewCell.h"
#import "GXCoreDataController.h"
#import "ConvertToCommonEmoticonsHelper.h"

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
    EMGroup* group = [EMGroup groupWithId:self.notification.groupId];
    EMConversation* conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.notification.groupId isGroup:YES];
    EMMessage* message = [conversation loadMessageWithId:self.notification.messageId];
    
    self.titleLabel.text = [group.groupSubject substringFromIndex:6];
    NSDate* time = [NSDate dateWithTimeIntervalSince1970: message.timestamp/1000];
    self.timeLabel.text = [self.dateFormatter stringFromDate:time];
    
    id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
    // 表情映射。
    NSString *didReceiveText = [ConvertToCommonEmoticonsHelper
                                convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
    self.bodyLabel.text = didReceiveText;
    
    NSString* bookmarkImgName = [self.notification.isFavorite boolValue]?@"bookmarked.png":@"bookmark.png";
    [self.bookmarkButton setBackgroundImage:[UIImage imageNamed:bookmarkImgName] forState:UIControlStateNormal];
    NSString* readImgName = message.isRead?@"read_yes.png":@"read_no.png";
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
    NSString* readImgName = @"read_yes.png";
    [self.readButton setBackgroundImage:[UIImage imageNamed:readImgName] forState:UIControlStateNormal];
    
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
        
        [[GXCoreDataController sharedInstance] saveMasterContext];
    });
}

@end
