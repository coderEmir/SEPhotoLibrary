//
//  SEEditPictureViewController.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//  实现图片预览
//裁剪、滤镜添加、旋转

#import "SEEditPictureViewController.h"
#import "UIImage+Extension.h"

#import "SDPhotoBrowser.h"

#import <Photos/Photos.h>

#import "SEPhotoModel.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface SEEditPictureViewController () <SDPhotoBrowserDelegate>

@property (nonatomic , copy) EditCompleteBlock editCompleteBlock;

@property (nonatomic ,strong) NSMutableArray *placeholderImages;

@end

@implementation SEEditPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)previewPicture:(UIImage *)image
{
    [self.placeholderImages addObject:image];
    
    SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
    photoBrowser.delegate = self;
    photoBrowser.currentImageIndex = 0;
    photoBrowser.imageCount = 1;
    photoBrowser.sourceImagesContainerView = self.view;
    
    [photoBrowser show];
}

- (void)previewPictureCollection:(NSMutableArray <UIImage *>*)pictureCollection specifySubscript:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        for (UIImage * _Nonnull image in pictureCollection) {
            [weakSelf.placeholderImages addObject:image];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [pictureCollection removeAllObjects];
            SDPhotoBrowser *photoBrowser = [SDPhotoBrowser new];
            photoBrowser.delegate = weakSelf;
            photoBrowser.currentImageIndex = index;
            photoBrowser.imageCount = weakSelf.placeholderImages.count;
            photoBrowser.sourceImagesContainerView = weakSelf.view;
            [photoBrowser show];
        });
    });
}
#pragma mark  SDPhotoBrowserDelegate

// 返回临时占位图片（即原来的小图）
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    return self.placeholderImages[index];
}

- (void)photoBrowserDismiss
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (NSMutableArray *)placeholderImages
{
    if (!_placeholderImages)
    {
        _placeholderImages = [[NSMutableArray alloc] init];
    }
    return _placeholderImages;
}

@end
