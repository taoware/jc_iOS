//
//  GXMeTableViewController.m
//  jycs
//
//  Created by appleseed on 2/4/15.
//  Copyright (c) 2015 appleseed. All rights reserved.
//

#import "GXMeTableViewController.h"
#import "GXAdminViewController.h"
#import "GXOfficeViewController.h"
#import "GXAdminEmplyeeViewController.h"
#import "GXAdminAdminViewController.h"
#import "GXSettingTableViewController.h"
#import "GXUserEngine.h"
#import "Photo.h"
#import "GXPostedViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GXBookmarkedViewController.h"
#import "GXMyMomentsViewController.h"
#import "UIImage+UIImageFunctions.h"

@interface GXMeTableViewController () <UINavigationControllerDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *phoneNum;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@end

@implementation GXMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.name.text = [GXUserEngine sharedEngine].userLoggedIn.name;
    self.phoneNum.text = [GXUserEngine sharedEngine].userLoggedIn.address;
    NSString* avatarURL = [GXUserEngine sharedEngine].userLoggedIn.avatar.thumbnailURL;
    [self.avatar setImageWithURL:[NSURL URLWithString:avatarURL] placeholderImage:[UIImage imageNamed:@"chatListCellHead.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changAvatarImage:(UITapGestureRecognizer *)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    
    [actionSheet showInView:self.view];
}

//- (IBAction)goToBookmark:(UITapGestureRecognizer *)sender {
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
//    GXBookmarkedViewController* bookmarkVC = [story instantiateViewControllerWithIdentifier:@"bookmarkVC"];
//    [self.navigationController pushViewController:bookmarkVC animated:YES];
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        GXMyMomentsViewController* myVC = [[GXMyMomentsViewController alloc]init];
        [self.navigationController pushViewController:myVC animated:YES];
    }
    if (indexPath.section == 3) {
        [[[UIAlertView alloc]initWithTitle:nil message:@"确定退出?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil]show];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self showHudInView:self.view hint:@"正在登出"];
        [[GXUserEngine sharedEngine] asyncLogoutWithCompletion:^(NSDictionary *info, GXError *error) {
            [self hideHud];
            if (error) {
                NSLog(@"%@", error.description);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@(NO)];
        }];
    }
}


#pragma mark - action sheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {   // take photo from camera
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
            imagePickController.sourceType=UIImagePickerControllerSourceTypeCamera;
            imagePickController.mediaTypes = @[( NSString *)kUTTypeImage];
            imagePickController.allowsEditing = YES;
            imagePickController.delegate=self;
            [self presentViewController:imagePickController animated:YES completion:NULL];
        } else {
            NSLog(@"Camera is not available.");
        }
    } else if (buttonIndex == 1) {  // choose photo from album
        
        UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
        imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickController.delegate=self;
        imagePickController.allowsEditing=TRUE;
        [self presentViewController:imagePickController animated:YES completion:NULL];
        
    }
}


#pragma mark - uiimagepickercontroller delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image=[info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage* scaledImage = image;
    if (image.size.width>480 && image.size.height>480) {
        scaledImage = [image scaleProportionalToSize:CGSizeMake(480, 480)];
    }
    NSData* imageData = UIImageJPEGRepresentation(scaledImage, 0.8);
    
    UIImage* newimage = [UIImage imageWithData:imageData];

    // get the ref url
    NSURL *refURL = [info valueForKey:UIImagePickerControllerReferenceURL];
    
    // define the block to call when we get the asset based on the url (below)
    ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *imageAsset)
    {
        ALAssetRepresentation *imageRep = [imageAsset defaultRepresentation];
        NSString* imageName = [imageRep filename];
        
        [self showHudInView:self.view hint:@"正在更新"];
        [[GXUserEngine sharedEngine] asyncUpdateUserAvatarwithImageData:imageData andImageName:@"avatarImg.jpg" completion:^(NSDictionary *info, GXError *error) {
            [self hideHud];
            if (!error) {
                self.avatar.image = [UIImage imageWithData:imageData];
            } else {
                switch (error.errorCode) {
                    case GXErrorServerNotReachable:
                        TTAlertNoTitle(@"服务器连接失败");
                        break;
                    default:
                        TTAlertNoTitle(@"上传头像失败");
                        break;
                }
            }
        }];

    };
    
    // get the asset library and fetch the asset based on the ref url (pass in block above)
    ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init];
    [assetslibrary assetForURL:refURL resultBlock:resultblock failureBlock:nil];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
