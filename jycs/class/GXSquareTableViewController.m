//
//  GXSquareTableViewController.m
//  jycs
//
//  Created by appleseed on 4/1/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXSquareTableViewController.h"
#import "SRRefreshView.h"
#import "GXMomentsEngine.h"
#import "Photo.h"
#import "User.h"
#import "GXCoreDataController.h"
#import "GXMainTabBarViewController.h"
#import "GXMomentsTableViewCell.h"
#import "CTAssetsPickerController.h"
#import "GXEditMomentTableViewController.h"
#import "GXAssetsManager.h"
#import "GXUserInfoViewController.h"

static NSString *CellIdentifier = @"MomentsCellIdentifier";

@interface GXSquareTableViewController () <SRRefreshDelegate, UIActionSheetDelegate, CTAssetsPickerControllerDelegate, GXMomentsTableViewCellDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
// A dictionary of offscreen cells that are used within the tableView:heightForRowAtIndexPath: method to
// handle the height calculations. These are never drawn onscreen. The dictionary is in the format:
//      { NSString *reuseIdentifier : UITableViewCell *offscreenCell, ... }
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;

@property (strong, nonatomic) NSArray* moments;
@property (nonatomic, strong) SRRefreshView *slimeView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation GXSquareTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.allowsSelection = NO;
//    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    self.offscreenCells = [NSMutableDictionary dictionary];
    [self.tableView registerClass:[GXMomentsTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    [self.tableView addSubview:self.slimeView];
    
    self.managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT-8"]];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    [self.slimeView setLoadingWithExpansion];
}

- (void)loadMomentsFromCoreData {
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Moment"];
        [request setSortDescriptors:[NSArray arrayWithObject:
                                     [NSSortDescriptor sortDescriptorWithKey:@"createTime" ascending:NO]]];
        self.moments = [self.managedObjectContext executeFetchRequest:request error:&error];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserverForName:kNOTIFICATION_MOMENTSSYNCCOMPLETED object:nil queue:nil usingBlock:^(NSNotification *note) {
        [self.slimeView endRefresh];
        [self updateUI];
    }];
}

- (void)updateUI {
    [self loadMomentsFromCoreData];
    [self.tableView reloadData];
}

- (SRRefreshView *)slimeView
{
    if (!_slimeView) {
        _slimeView = [[SRRefreshView alloc] init];
        _slimeView.delegate = self;
        _slimeView.upInset = 0;
        _slimeView.slimeMissWhenGoingBack = YES;
        _slimeView.slime.bodyColor = [UIColor grayColor];
        _slimeView.slime.skinColor = [UIColor grayColor];
        _slimeView.slime.lineWith = 1;
        _slimeView.slime.shadowBlur = 4;
        _slimeView.slime.shadowColor = [UIColor grayColor];
        _slimeView.backgroundColor = [UIColor whiteColor];
    }
    
    return _slimeView;
}

#pragma mark - GXMomentCell delegate

- (void)resendButtonTappedWithMoment:(Moment *)moment {
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[self.moments indexOfObject:moment] inSection:0];
    GXMomentsTableViewCell* sendingCell = (GXMomentsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    sendingCell.syncStatus = GXObjectSyncing;
    
    [[GXMomentsEngine sharedEngine] sendMomentWithMoment:moment completion:^(NSDictionary *momentInfo, GXError *error) {
        if (error) {
            TTAlert(@"发送失败");
        }
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
    }];
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

- (void)userInfoTappedWithMoment:(Moment *)moment {
    [self performSegueWithIdentifier:@"go user info" sender:moment];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"go user info"]) {
        GXUserInfoViewController* userInfoVC = (GXUserInfoViewController *)segue.destinationViewController;
        Moment* moment = sender;
        userInfoVC.moment = moment;
    }
}

- (void)setMoment:(Moment *)moment WithStatus:(GXObjectSyncStatus)syncStatus {
    moment.syncStatus = @(syncStatus);
    [self.managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        BOOL saved = [self.managedObjectContext save:&error];
        if (!saved) {
            // do some real error handling
            NSLog(@"Could not save Date due to %@", error);
        }
        [[GXCoreDataController sharedInstance] saveMasterContext];
    }];
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView == self.tableView) {
        [self.slimeView scrollViewDidEndDraging];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.tableView) {
        [self.slimeView scrollViewDidScroll];
    }
}

#pragma mark - slimeRefresh delegate
//刷新消息列表
- (void)slimeRefreshStartRefresh:(SRRefreshView *)refreshView
{
    [[GXMomentsEngine sharedEngine] startSync];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.moments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GXMomentsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.delegate = self;
    
    Moment* moment = self.moments[indexPath.row];
    cell.fromViewController = self;
    cell.momentToDisplay = moment;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *reuseIdentifier = CellIdentifier;
    
    GXMomentsTableViewCell *cell = [self.offscreenCells objectForKey:reuseIdentifier];
    if (!cell) {
        cell = [[GXMomentsTableViewCell alloc] init];
        [self.offscreenCells setObject:cell forKey:reuseIdentifier];
    }
    
    Moment* moment =[self.moments objectAtIndex:indexPath.row];
    cell.momentToDisplay = moment;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));

    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    // Get the actual height required for the cell
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    height += 1;

    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}





#pragma mark - public methods

- (void)sendSquareMomentWithMoment:(Moment *)moment {
    [self updateUI];
    [self resendButtonTappedWithMoment:moment];
}

- (void)showGiftInfo {
    
}

- (void)sendSquareMoments {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"只发文字", @"拍照", @"从相册中选取", nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {  // only text
        GXEditMomentTableViewController* addVC = [[GXEditMomentTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
        addVC.squareVC = self;
        UINavigationController* navi = [[UINavigationController alloc]initWithRootViewController:addVC];
        [self presentViewController:navi animated:YES completion:NULL];
    } else if (buttonIndex == 1) {   // take photo from camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
            imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
            imagePickController.mediaTypes = @[( NSString *)kUTTypeImage];
            imagePickController.delegate=self;
            [self presentViewController:imagePickController animated:YES completion:NULL];
        } else {
            NSLog(@"Camera is not available.");
        }
    } else if (buttonIndex == 2) {  // choose photo from album
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.assetsFilter         = [ALAssetsFilter allPhotos];
        picker.delegate             = self;
        picker.alwaysEnableDoneButton = YES;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - image picker controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    ALAssetsLibrary *library = [GXAssetsManager defaultAssetsLibrary];
    if( [picker sourceType] == UIImagePickerControllerSourceTypeCamera )
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
         {
             [library assetForURL:assetURL resultBlock:^(ALAsset *asset )
              {
                  [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                  GXEditMomentTableViewController* addVC = [[GXEditMomentTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
                  addVC.squareVC = self;
                  addVC.imageAssets = [@[asset] mutableCopy];
                  UINavigationController* navi = [[UINavigationController alloc]initWithRootViewController:addVC];
                  [picker.presentingViewController presentViewController:navi animated:YES completion:NULL];
              }
                     failureBlock:^(NSError *error )
              {
                  NSLog(@"Error loading asset");
              }];
         }];
    }
}



#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    GXEditMomentTableViewController* addVC = [[GXEditMomentTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    addVC.squareVC = self;
    addVC.imageAssets = [assets copy];
    UINavigationController* navi = [[UINavigationController alloc]initWithRootViewController:addVC];
    [picker.presentingViewController presentViewController:navi animated:YES completion:NULL];
}


- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= 9)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Please select not more than 9 assets"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < 9 && asset.defaultRepresentation != nil);
}




@end
