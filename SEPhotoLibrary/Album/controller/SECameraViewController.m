//
//  SECameraViewController.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SECameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import "SEPhotoManager.h"
@interface SECameraViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic ,strong) UIImagePickerController *imagePickerVc;
@property (nonatomic ,copy) savePhotoBlock savePhotoBlock;

@end

@implementation SECameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showPhotoView];
}

- (void)showPhotoView {
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                self.imagePickerVc.sourceType = UIImagePickerControllerSourceTypeCamera;
                self.imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
                [self presentViewController:self.imagePickerVc animated:YES completion:nil];
            }
            else
            {
                [self showAlertInController];
            }
            
        });
    }];
}

- (void)savePhotoSuccessBlock:(savePhotoBlock)savePhotoBlock
{
    self.savePhotoBlock = savePhotoBlock;
}

- (void)showAlertInController
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"访问相机" message:@"相机功能需要您打开相机权限" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *openAction = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingUrl = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([UIApplication.sharedApplication canOpenURL:settingUrl]) {
            [UIApplication.sharedApplication openURL:settingUrl options:@{} completionHandler:nil];
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:openAction];
    [controller addAction:cancelAction];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@",@"保存失败");
                } else {
                    NSLog(@"%@",@"保存成功");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.savePhotoBlock();
                        [picker dismissViewControllerAnimated:YES completion:nil];
                        [self dismissViewControllerAnimated:YES completion:nil];
                });
            }
        }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;

        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
    return _imagePickerVc;
}

@end
