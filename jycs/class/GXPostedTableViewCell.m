//
//  GXPostedTableViewCell.m
//  jycs
//
//  Created by appleseed on 5/10/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXPostedTableViewCell.h"
#import "User.h"

@interface GXPostedTableViewCell ()
@property (nonatomic, strong)NSDateFormatter* dateFormatter;
@end

@implementation GXPostedTableViewCell

- (void)setMomentToDisplay:(Moment *)momentToDisplay {
    _momentToDisplay = momentToDisplay;
    [self updateUI];
}

- (void)updateUI {
    self.titleLabel.text = self.momentToDisplay.screenName;
    self.bodyLabel.text = self.momentToDisplay.text;
    self.timeLabel.text = [self.dateFormatter stringFromDate:self.momentToDisplay.createTime];
    self.typeLabel.text = [self.momentToDisplay.type stringByAppendingString:@"消息"];
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

@end
