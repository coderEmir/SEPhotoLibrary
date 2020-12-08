//
//  SEEditPictureViewController.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//  实现图片裁剪、滤镜添加、旋转

#import "SEEditPictureViewController.h"
#import "UIImage+Extension.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface SEEditPictureViewController () <UIScrollViewDelegate>

@property (nonatomic , copy) EditCompleteBlock editCompleteBlock;

/** 工具条 */
@property (nonatomic, strong) UIView *toolBar;

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImage * originalImage;

@end

@implementation SEEditPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
    if (_originalImage) {
        self.imageView = [[UIImageView alloc] initWithImage:_originalImage];
        CGFloat img_width = ScreenWidth;
        CGFloat img_height = _originalImage.size.height * (img_width/_originalImage.size.width);
        CGFloat img_y= (img_height - self.view.bounds.size.width)/2.0;
        _imageView.frame = CGRectMake(0,0, img_width, img_height);
        _imageView.userInteractionEnabled = YES;
        [self.scrollView addSubview:_imageView];
        
        
        _scrollView.contentSize = CGSizeMake(img_width, img_height);
        _scrollView.contentOffset = CGPointMake(0, 0);
        [self.view addSubview:self.scrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.imageView.hidden = YES;
}

- (void)willEditPicture:(UIImage *)image editComplete:(EditCompleteBlock)block
{
    self.originalImage = image;
    self.editCompleteBlock = block;
}


#pragma mark -- UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerContent];
}

- (void)centerContent {
    CGRect imageViewFrame = _imageView.frame;
    
    CGRect scrollBounds = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
    if (imageViewFrame.size.height > scrollBounds.size.height) {
        imageViewFrame.origin.y = 0.0f;
    }else {
        imageViewFrame.origin.y = (scrollBounds.size.height - imageViewFrame.size.height) / 2.0;
    }
    if (imageViewFrame.size.width < scrollBounds.size.width) {
        imageViewFrame.origin.x = (scrollBounds.size.width - imageViewFrame.size.width) /2.0;
    }else {
        imageViewFrame.origin.x = 0.0f;
    }
    _imageView.frame = imageViewFrame;
}

- (void)cancelBtnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)cropImage {
    CGPoint offset = _scrollView.contentOffset;
    //图片缩放比例
    CGFloat zoom = _imageView.frame.size.width/_originalImage.size.width;
    //视网膜屏幕倍数相关
    zoom = zoom / [UIScreen mainScreen].scale;
    
    CGFloat width = _scrollView.frame.size.width;
    CGFloat height = _scrollView.frame.size.height;
    if (_imageView.frame.size.height < _scrollView.frame.size.height) {
        offset = CGPointMake(offset.x + (width - _imageView.frame.size.height)/2.0, 0);
        width = height = _imageView.frame.size.height;
    }
    
    CGRect rec = CGRectMake(offset.x/zoom, offset.y/zoom,width/zoom,height/zoom);
    CGImageRef imageRef =CGImageCreateWithImageInRect([_originalImage CGImage],rec);
    UIImage * image = [[UIImage alloc]initWithCGImage:imageRef];
    CGImageRelease(imageRef);

    image = [image beginClip];
    return image;
}


- (UIView *)toolBar
{
    if (!_toolBar) {
        _toolBar = [[UIView alloc] init];
    }
    return _toolBar;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        CGFloat height = (ScreenHeight - 200)/2.0;
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, height ,ScreenWidth,200)];
        _scrollView.bouncesZoom = YES;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        _scrollView.zoomScale = 1;
        _scrollView.delegate = self;
        _scrollView.layer.masksToBounds = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.layer.borderWidth = 1.5;
        _scrollView.layer.borderColor = [UIColor whiteColor].CGColor;
    }
    return _scrollView;
}

@end
