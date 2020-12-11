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
    [self.indicatorView removeFromSuperview];
    
    [self.contentView addSubview:self.scrollView];
    [self.contentView addSubview:self.indicatorView];
}

- (void)loadImage
{
    self.imageView.image = nil;
    [SEPhotoDefaultManager requestPreviewImage:self.model.asset callBackImage:^(UIImage * _Nullable image) {
        self.imageView.image = image;
    }];
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
    }
    [_scrollView addSubview:self.imageView];
    return _scrollView;
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
