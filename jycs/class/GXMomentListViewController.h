//
//  GXSquareTableViewController.h
//  jycs
//
//  Created by appleseed on 4/1/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Moment.h"

@interface GXMomentListViewController : UITableViewController
- (void)showGiftInfo;
- (void)sendSquareMoments;
- (IBAction)refreshButtonTouched:(id)sender;
@end
