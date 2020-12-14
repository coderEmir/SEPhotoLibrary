//
//  SEEditPictureViewController.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//  实现图片预览
//裁剪、滤镜添加、旋转

#import "SEEditPictureViewController.h"

#import "SEPhotoManager.h"
#import "SEPhotoModel.h"

#import "SEImageClipScrollView.h"
#import "SEImageToolView.h"

@interface SEEditPictureViewController ()

@property (nonatomic , copy) EditCompleteBlock editCompleteBlock;

@property (nonatomic, strong) SEImageToolView *imageToolView;

@property (nonatomic, strong) SEPhotoModel *imageModel;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) SEImageClipScrollView *clipScrollView;
@end

@implementation SEEditPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.clipScrollView];
    [self.view addSubview:self.imageToolView];
    
    [self renderClipScrollView];
}

- (void)originImageModel:(SEPhotoModel *)model
{
    self.imageModel = model;
    // TODO: 获取待裁剪图片
}

- (void)renderClipScrollView
{
    [self.activityView startAnimating];
    [SEPhotoDefaultManager requestPreviewImage:self.imageModel.asset callBackImage:^(UIImage * _Nullable image) {
        [self.activityView stopAnimating];
        [self.clipScrollView originImage:image];
    }];
}

- (SEImageToolView *)imageToolView
{
    if (!_imageToolView) {
        SEImageToolView *imageToolView = [[SEImageToolView alloc] initWithViewType:SEImageToolViewTypeClip callBackBlock:^(SEImageToolViewCallbackType type) {
            //TODO: 底部工具条事件
            switch (type) {
                case SEImageToolViewCallbackTypeCancleEdit:
                {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                    break;
                case SEImageToolViewCallbackTypeFinishEdit:
                {
                    //TODO: 获取裁剪结果
                    [self dismissViewControllerAnimated:YES completion:nil];
                   
                 }
                    break;
                    
                default:
                    break;
            }
        }];
        imageToolView.backgroundColor = UIColor.blackColor;
        imageToolView.frame = CGRectMake(0, SEScreenHeight - 49 - SEToolBarHeight, SEScreenWidth, 49 + SEToolBarHeight);
        _imageToolView = imageToolView;
    }
    return _imageToolView;
}

- (UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _activityView.center = CGPointMake(self.view.bounds.size.width / 2,self.view.bounds.size.height / 2);
    }
    return _activityView;
}
- (SEImageClipScrollView *)clipScrollView
{
    if (!_clipScrollView) {
        UIEdgeInsets edgeInsets = {SEStateBarH, 0, SEToolBarHeight, 0};
        _clipScrollView = [[SEImageClipScrollView alloc] initWithFrame:self.view.bounds margin:30 contentInset:edgeInsets];
    }
    return _clipScrollView;
}

@end
