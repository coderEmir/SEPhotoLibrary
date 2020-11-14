//
//  SEAlbumManager.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEAlbumManager.h"
#import "SEAlbumViewController.h"
#import "SEPhotoManager.h"
@implementation SEAlbumManager

+ (void)showPhotoManager:(UIViewController  *)superController withMaxImageCount:(NSInteger)maxImageCount andAlbumArrayBlock:(void(^)(NSMutableArray <SEPhotoModel *> *))albumArrayBlock
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (status == PHAuthorizationStatusAuthorized) {
                // user agree, show album controller.
                [SEPhotoManager defaultManager].maxImageCount = maxImageCount;
                [self showViewControllerWithAlbumArrayBlock:albumArrayBlock inController:superController];
            }
            else
            {
                // alert user open authorization.
                [self showAlertInController:superController];
            }
            
        });
    }];
}

+ (void)showViewControllerWithAlbumArrayBlock:(void(^)(NSMutableArray <SEPhotoModel *> *))albumArrayBlock inController:(UIViewController *)superController
{
    SEAlbumViewController *controller = [[SEAlbumViewController alloc] init];
    controller.confirmActionBlock = ^{
        albumArrayBlock(SEPhotoDefaultManager.photoModelList);
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [superController presentViewController:navController animated:YES completion:nil];
    
}

+ (void)showAlertInController:(UIViewController *)superController
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"访问相册" message:@"照片编辑功能需要您打开相册权限" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([UIApplication.sharedApplication canOpenURL:settingUrl]) {
            [UIApplication.sharedApplication openURL:settingUrl options:@{} completionHandler:nil];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:openAction];
    [controller addAction:cancelAction];
    
    [superController presentViewController:controller animated:YES completion:nil];
}

@end
