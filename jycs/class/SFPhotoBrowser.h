
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "AFNetworking.h"

@interface SFPhotoBrowser : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>

+(void)animateShowBigPhotosFromThumbImageViews:(NSArray *)thumbImageViews fromViewController:(UIViewController *)fromViewController bigPhotoesURL:(NSArray *)bigPhotoesURLS curIndex:(int)index didEndShowing:(void (^)(void))didEndShowing didEndDismissing:(void (^)(void))didEndShowing;


@end
