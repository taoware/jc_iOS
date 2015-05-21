//
//  GXAddMomentTableViewController.m
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXMomentEntryViewController.h"
#import "AddMomentTableViewCell.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPageViewController.h"
#import "CTAssetsPickerController.h"
#import "GXSelectTypeViewController.h"
#import "GXSelectUnitViewController.h"
#import "GXCoreDataController.h"
#import "Moment.h"
#import "Photo.h"
#import "GXMomentsEngine.h"
#import "GXUserEngine.h"
#import "GXAssetsManager.h"
#import "GXPhotoPageViewController.h"
#import "GXPhotoEngine.h"

static NSString * const GXAddMomentCellIdentifier = @"GXAddMomentCellIdentifier";
static NSString * const GXMomentOptionIdentifier = @"GXMomentOptionIdentifier";

@interface GXMomentEntryViewController () <AddMomentCellDelegate, CTAssetsPickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, GXSelectUnitDelegate, GXSelectTypeDelegate>
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@end

@implementation GXMomentEntryViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[AddMomentTableViewCell class] forCellReuseIdentifier:GXAddMomentCellIdentifier];
    
    [self setupButtons];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)setupButtons {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}


#pragma mark - select type delegate
- (void)didFinishSelectType:(NSString *)type {
    if (type) {
        self.momentEntry.type = type;
        [self.tableView reloadData];
    }
    [self toggleDoneButton];
}

#pragma mark - select unit delegate
- (void)didFinishSelectUnit:(Unit *)unit {
    if (unit) {
        self.momentEntry.inUnit = unit;
        [self.tableView reloadData];
    }
    [self toggleDoneButton];
}

- (void)toggleDoneButton {
    BOOL enabled = NO;
    if (self.momentEntry.text.length && self.momentEntry.type && self.momentEntry.inUnit) {
        enabled = YES;
    }
    self.navigationItem.rightBarButtonItem.enabled = enabled;
}

#pragma mark - uiscrollview delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self addMomentCellAtIndexPath:indexPath];
    } else {
        return [self momentOptionCellAtIndexPath:indexPath];
    }
}

- (AddMomentTableViewCell *)addMomentCellAtIndexPath:(NSIndexPath *)indexPath {
    AddMomentTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:GXAddMomentCellIdentifier forIndexPath:indexPath];
    
    cell.momentEntry = self.momentEntry;
    cell.delegate = self;

    return cell;
}

- (UITableViewCell *)momentOptionCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:GXMomentOptionIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:GXMomentOptionIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    if (indexPath.row == 0) {
        cell.textLabel.text = @"所在单位";
        cell.detailTextLabel.text = self.momentEntry.inUnit.name;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"广场类型";
        cell.detailTextLabel.text = self.momentEntry.type;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        NSString* reuseIdentifier = GXAddMomentCellIdentifier;
        
        AddMomentTableViewCell* cell = [self.offscreenCells objectForKey:reuseIdentifier];
        if (!cell) {
            cell = [[AddMomentTableViewCell alloc]init];
            [self.offscreenCells setObject:cell forKey:reuseIdentifier];
        }
        cell.momentEntry = self.momentEntry;
        
        [cell setNeedsUpdateConstraints];
        [cell updateConstraintsIfNeeded];
        
        cell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(tableView.bounds), CGRectGetHeight(cell.bounds));
        
        [cell setNeedsLayout];
        [cell layoutIfNeeded];
        
        CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        height += 1;
        
        return height;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 32;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGFLOAT_MIN;
    }
    return 12.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            GXSelectUnitViewController* unitSelectVC = [[GXSelectUnitViewController alloc]initWithStyle:UITableViewStyleGrouped];
            unitSelectVC.delegate = self;
            unitSelectVC.context = self.context;
            unitSelectVC.unit = self.momentEntry.inUnit;
            [self.navigationController pushViewController:unitSelectVC animated:YES];
        } else if (indexPath.row == 1) {
            GXSelectTypeViewController* typeSelectVC = [[GXSelectTypeViewController alloc]initWithStyle:UITableViewStyleGrouped];
            typeSelectVC.delegate = self;
            typeSelectVC.type = self.momentEntry.type;
            [self.navigationController pushViewController:typeSelectVC animated:YES];
        }
    }
}

#pragma mark - addMomentTablecell

- (void)momentTextDidChange {
    [self toggleDoneButton];
}



- (void)selectImageThunbnailAtIndex:(NSInteger)index {
    GXPhotoPageViewController* pageVC = [[GXPhotoPageViewController alloc]initWithMomoent:self.momentEntry];
    pageVC.pageIndex = index;
    
    [self.navigationController pushViewController:pageVC animated:YES];
}

- (void)addMoreImage {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    
    [actionSheet showInView:self.view];
}

#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {   // take photo from camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
            imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
            imagePickController.mediaTypes = @[( NSString *)kUTTypeImage];
            imagePickController.delegate=self;
            [self presentViewController:imagePickController animated:YES completion:NULL];
        } else {
            NSLog(@"Camera is not available.");
        }
    } else if (buttonIndex == 1) {  // choose photo from album
        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
        picker.assetsFilter         = [ALAssetsFilter allPhotos];
        picker.delegate             = self;
        picker.alwaysEnableDoneButton = YES;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}


#pragma mark - asset pager delegate

- (void)deleteImageAtIndex:(int)index {
    NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:index];
    [self.momentEntry removePhotoAtIndexes:indexSet];
    
    [self.navigationController popToViewController:self animated:YES];
}

- (void)addPhotoWithImageAsset:(ALAsset *)imageAsset {
    Photo* photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.context];
    [self.momentEntry addPhotoObject:photo];
    
    ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
    photo.photoDescription = [imageRep filename];
    UIImage* photoImg = [UIImage imageWithCGImage:imageRep.fullScreenImage scale:imageRep.scale orientation:(UIImageOrientation)imageRep.orientation];
    NSString* photoURL = [GXPhotoEngine writePhotoToDisk:photoImg];
    photo.imageURL = photoURL;
    photo.thumbnailURL = photoURL;
    
    [self.tableView reloadData];
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
                  if (asset) {
                      [self addPhotoWithImageAsset:asset];
                  }
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
    if (assets.count) {
        for (ALAsset* asset in assets) {
            [self addPhotoWithImageAsset:asset];
        }
    }
}


- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    NSUInteger imageNumAllowed = 9 - self.momentEntry.photo.count;
    if (picker.selectedAssets.count >= imageNumAllowed)
    {
        NSString* message = [NSString stringWithFormat:@"Please select not more than %lu assets", (unsigned long)imageNumAllowed];
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:message
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
    
    return (picker.selectedAssets.count < imageNumAllowed && asset.defaultRepresentation != nil);
}


#pragma mark - action

- (void)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)doneButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didFinishMomentEntryViewController:didSave:)]) {
        self.momentEntry.syncStatus = @(GXObjectCreated);
        self.momentEntry.sender = (User*)[self.context objectWithID:[GXUserEngine sharedEngine].userLoggedIn.objectID];
        [self.delegate didFinishMomentEntryViewController:self didSave:YES];
    }
}

@end
