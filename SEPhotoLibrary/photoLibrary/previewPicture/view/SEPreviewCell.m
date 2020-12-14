//
//  SEPreviewCell.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPreviewCell.h"

#import "SEPhotoModel.h"

#import "SEPhotoManager.h"
@interface SEPreviewCell () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation SEPreviewCell

- (void)setModel:(SEPhotoModel *)model
{
    _model = model;
    [self setUp];
    [self loadImage];
    
}

- (void)setUp
{
    [self.imageView removeFromSuperview];
    [self.scrollView removeFromSuperview];
//    [self.indicatorView removeFromSuperview];
    
    [self.contentView addSubview:self.scrollView];
//    [self.contentView addSubview:self.indicatorView];
}

- (void)loadImage
{
    self.imageView.image = nil;
    if (self.model.editedImage) {
        self.imageView.image = self.model.editedImage;
        return;
    }
    self.imageView.image = self.model.thumbImage;
    [SEPhotoDefaultManager requestPreviewImage:self.model.asset callBackImage:^(UIImage * _Nullable image) {
        
        self.imageView.image = image;
        self.imageView.frame = [self calculateContainerFrame:self.imageView.image];
        [self resizeImageView];
    }];
}

- (void)resizeImageView
{
    self.scrollView.zoomScale = 1;
    
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width, MAX(self.imageView.frame.size.height, self.scrollView.bounds.size.height));
    [self.scrollView scrollRectToVisible:self.scrollView.bounds animated:NO];
}

- (CGRect)calculateContainerFrame:(UIImage *)image {
    if (image == nil) return CGRectZero;
    CGRect containerFrame = UIScreen.mainScreen.bounds;
    CGFloat height = floor(image.size.height / image.size.width * containerFrame.size.width);
    containerFrame.size.height = height;
    // 非长图，居中显示
    if (image.size.height / image.size.width < self.scrollView.frame.size.height / containerFrame.size.width) {
        containerFrame.origin.y = (self.bounds.size.height - height) * 0.5;
    }
    return containerFrame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    self.imageView.frame = self.bounds;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGFloat offsetX = scrollView.frame.size.width > scrollView.contentSize.width ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 : 0;
    
    CGFloat offsetY = scrollView.frame.size.height > scrollView.contentSize.height ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0;
    
    self.imageView.center = CGPointMake(scrollView.frame.size.width * 0.5 + offsetX, scrollView.frame.size.height * 0.5 + offsetY);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - event
- (void)singleTap
{
    if ([self.delegate respondsToSelector:@selector(photoModelSingleTapEvent)]) {
        [self.delegate photoModelSingleTapEvent];
    }
}

- (void)doubleTap:(UIGestureRecognizer *)doubleTap
{
    if (self.scrollView.zoomScale > 1.0) {
        self.scrollView.zoomScale = 1;
    }
    else
    {
        CGPoint touchPoint = [doubleTap locationInView:self.imageView];
        CGFloat zoomScale = self.scrollView.maximumZoomScale;
        CGFloat width = self.frame.size.width / zoomScale;
        CGFloat height = self.frame.size.height / zoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - width * 0.5, touchPoint.y - height * 0.5, width, height) animated:YES];
    }
}

#pragma mark - lazyLoad
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [self addGestures];
    }
    [_scrollView addSubview:self.imageView];
    return _scrollView;
}

- (void)addGestures
{
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap)];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [_scrollView addGestureRecognizer:singleTap];
    [_scrollView addGestureRecognizer:doubleTap];
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return _imageView;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.center = self.contentView.center;
    }
    return _indicatorView;
}



@end
