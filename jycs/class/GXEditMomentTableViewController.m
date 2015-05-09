//
//  GXAddMomentTableViewController.m
//  jycs
//
//  Created by appleseed on 4/20/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXEditMomentTableViewController.h"
#import "AddMomentTableViewCell.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPageViewController.h"
#import "CTAssetsPickerController.h"
#import "DeleteableCTAssetsPageViewController.h"
#import "GXSelectTypeTableViewController.h"
#import "GXSelectUnitTableViewController.h"
#import "GXCoreDataController.h"
#import "Moment.h"
#import "Photo.h"
#import "GXMomentsEngine.h"
#import "GXUserEngine.h"
#import "GXAssetsManager.h"
#import "UIImage+CS193p.h"

static NSString * const GXAddMomentCellIdentifier = @"GXAddMomentCellIdentifier";
static NSString * const GXMomentOptionIdentifier = @"GXMomentOptionIdentifier";

@interface GXEditMomentTableViewController () <AddMomentCellDelegate, CTAssetsPickerControllerDelegate, DeleteableCTAssetsPageViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, strong)NSManagedObjectContext* managedObjectContext;
@property (nonatomic, strong)NSMutableArray* imagesForMoment;
@property (strong, nonatomic) NSMutableDictionary *offscreenCells;
@property (nonatomic, strong)NSString* momentText;
@end

@implementation GXEditMomentTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView registerClass:[AddMomentTableViewCell class] forCellReuseIdentifier:GXAddMomentCellIdentifier];
    self.managedObjectContext = [[GXCoreDataController sharedInstance] backgroundManagedObjectContext];
    
    [self setupButtons];
}

- (void)setupButtons {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(sendMoment:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - properties

- (void)setImageAssets:(NSMutableArray *)imageAssets {
    _imageAssets = imageAssets;
    [self.imagesForMoment removeAllObjects];
    for (ALAsset* imageAsset in _imageAssets) {
        [self.imagesForMoment addObject:[UIImage imageWithCGImage:imageAsset.thumbnail]];
    }
    [self.tableView reloadData];
}

- (NSMutableArray *)imagesForMoment {
    if (!_imagesForMoment) {
        _imagesForMoment = [[NSMutableArray alloc]init];
    }
    return _imagesForMoment;
}


- (void)setType:(NSString *)type {
    _type = type;
    [self.tableView reloadData];
    [self toggleDoneButton];
}

- (void)setUnitName:(NSString *)unitName {
    _unitName = unitName;
    [self.tableView reloadData];
    [self toggleDoneButton];
}

- (void)toggleDoneButton {
    BOOL enabled = NO;
    if (self.momentText.length && self.type && self.unitName) {
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
    
    cell.imagesForMoment = self.imagesForMoment;
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
        cell.detailTextLabel.text = self.unitName;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"广场类型";
        cell.detailTextLabel.text = self.type;
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
        cell.imagesForMoment = self.imagesForMoment;
        
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
            GXSelectUnitTableViewController* unitSelectVC = [[GXSelectUnitTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
            unitSelectVC.addMomentVC = self;
            unitSelectVC.unitidSelected = @(self.unitId);
            [self.navigationController pushViewController:unitSelectVC animated:YES];
        } else if (indexPath.row == 1) {
            GXSelectTypeTableViewController* typeSelectVC = [[GXSelectTypeTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
            typeSelectVC.addMomentVC = self;
            typeSelectVC.currentType = self.type;
            [self.navigationController pushViewController:typeSelectVC animated:YES];
        }
    }
}

#pragma mark - addMomentTablecell

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.momentText = textView.text;
    [self toggleDoneButton];
}

- (void)selectImageThunbnailAtIndex:(NSInteger)index {
    DeleteableCTAssetsPageViewController *vc = [[DeleteableCTAssetsPageViewController alloc] initWithAssets:self.imageAssets];
    vc.pageIndex = index;
    vc.delegator = self;
    
    [self.navigationController pushViewController:vc animated:YES];
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
    NSMutableArray* imageArr = [self.imageAssets mutableCopy];
    [imageArr removeObjectAtIndex:index];
    self.imageAssets = [imageArr copy];
    
    [self.navigationController popToViewController:self animated:YES];
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
                      self.imageAssets = [[self.imageAssets arrayByAddingObject:asset] copy];
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
        self.imageAssets = [[self.imageAssets arrayByAddingObjectsFromArray:assets] copy];
    }
}


- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    NSUInteger imageNumAllowed = 9 - self.imageAssets.count;
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

- (void)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sendMoment:(id)sender {
    Moment* moment = [NSEntityDescription insertNewObjectForEntityForName:@"Moment" inManagedObjectContext:self.managedObjectContext];
    moment.text = self.momentText;
    moment.type = [self.type substringToIndex:self.type.length-2];
    moment.sender = [[GXUserEngine sharedEngine] userLoggedIn];
    moment.inUnit = self.unit;
    moment.createTime = [NSDate date];
    
    [self showHudInView:self.view hint:@"请稍等"];

    __block NSArray* photos = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        photos = [self savePhotosIntoCoreData];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (Photo* photo in photos) {
                [moment addPhotoObject:photo];
            }
            
            moment.syncStatus = [NSNumber numberWithInt:GXObjectCreated];
            [self.managedObjectContext performBlockAndWait:^{
                NSError *error = nil;
                BOOL saved = [self.managedObjectContext save:&error];
                if (!saved) {
                    // do some real error handling
                    NSLog(@"Could not save Date due to %@", error);
                }
                [[GXCoreDataController sharedInstance] saveMasterContext];
            }];
            [self hideHud];
            [self dismissViewControllerAnimated:YES completion:^{ [self.squareVC sendSquareMomentWithMoment:moment]; }];
        });
    });
}

- (NSArray *)savePhotosIntoCoreData {
    NSMutableArray* photos = [[NSMutableArray alloc]init];
    for (ALAsset* imageAsset in self.imageAssets) {
        Photo* photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        [photos addObject:photo];
        
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        photo.photoDescription = [imageRep filename];
        UIImage* photoImg = [UIImage imageWithCGImage:imageRep.fullScreenImage scale:imageRep.scale orientation:(UIImageOrientation)imageRep.orientation];
        NSURL* photoURL = [self photoURLForImage:photoImg];
        photo.imageURL = [photoURL path];
        photo.thumbnailURL = [[self thumbnailURLForImage:photoImg andPhotoURL:photoURL] absoluteString];
    }
    return [photos copy];
}

- (NSURL *)photoURLForImage:(UIImage *)image {
    NSURL *url = [self uniqueDocumentURL];
    
    NSData* imageData = [self downScaleToOneMega:image];
    
    if(![imageData writeToURL:url atomically:YES]) {
        NSLog(@"save photo failed");
    }
    return url;
}

- (NSData *)downScaleToOneMega:(UIImage *)image {
    NSData  *imageData    = UIImageJPEGRepresentation(image, 0.8);
    double   factor       = 1.0;
    double   adjustment   = 1.0 / sqrt(2.0);  // or use 0.8 or whatever you want
    CGSize   size         = image.size;
    CGSize   currentSize  = size;
    UIImage *currentImage = image;

    while (imageData.length >= (300 * 1024))
    {
        factor      *= adjustment;
        currentSize  = CGSizeMake(roundf(size.width * factor), roundf(size.height * factor));
        currentImage = [image imageByScalingToSize:currentSize];
        imageData    = UIImageJPEGRepresentation(currentImage, 0.8);
    }
    return imageData;
}


- (NSURL *)thumbnailURLForImage:(UIImage *)image andPhotoURL:(NSURL *)photoURL {
    NSURL *url = [photoURL URLByAppendingPathExtension:@"thumbnail"];
    UIImage *thumbnail = [image imageByScalingToSize:CGSizeMake(75, 75)];
    NSData *imageData = UIImageJPEGRepresentation(thumbnail, 0.5);
    if (![imageData writeToURL:url atomically:YES]) {
        NSLog(@"save thumbnail failed");
    }
    
    return url;
}

- (NSURL *)uniqueDocumentURL
{
    NSArray *documentDirectories = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSString *unique = [NSString stringWithFormat:@"%.10f", [NSDate timeIntervalSinceReferenceDate]];
    unique = [unique stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [[documentDirectories firstObject] URLByAppendingPathComponent:unique];
}

@end
