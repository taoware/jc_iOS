//
//  CustomUIDefine.h
//  jycs
//
//  Created by appleseed on 2/4/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#ifndef jycs_CustomUIDefine_h
#define jycs_CustomUIDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define CUSTOMCOLOR [UIColor colorWithRed:0.0/255.0 green:107.0/255.0 blue:67.0/255.0 alpha:1.0]
#define SEGMENTCONTROLCOLOR [UIColor colorWithRed:192.0/255.0 green:193.0/255.0 blue:193.0/255.0 alpha:1.0]
#define NEWSBGCOLOR [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0]

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define kNOTIFICATION_NEWSSYNCCOMPLETED @"newsSyncCompleted"
#define kNOTIFICATION_STORESYNCCOMPLETED @"storeSyncCompleted"
#define kNOTIFICATION_MOMENTSSYNCCOMPLETED @"momentsSyncCompleted"
#define kNOTIFICATION_NOTIFICATIONRECEIVED @"notificationReceived"

#define SERVICENAME @"com.gxcm.jycs"

#endif
