//
//  SEImageClipScrollView.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/12.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEImageClipScrollView.h"
#import "SEImageClipResizeView.h"

@interface SEImageClipScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImage *originImage;
/** 裁剪框 */
@property (nonatomic, strong) SEImageClipResizeView *clipResizeView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic , assign) CGFloat margin;

@property (nonatomic , assign) UIEdgeInsets contentInset;

@property (nonatomic , assign) CGSize contentSize;

@end

@implementation SEImageClipScrollView

- (instancetype)initWithFrame:(CGRect)frame margin:(CGFloat)margin contentInset:(UIEdgeInsets)contentInset
{
    self = [super initWithFrame:frame];
    self.margin = margin;
    self.contentInset = contentInset;
    CGFloat contentWidth = self.bounds.size.width - contentInset.left - contentInset.right;
    CGFloat contentHeight = self.bounds.size.height - contentInset.top - contentInset.bottom;
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
    [self setUpUI];
    return self;
}

- (void)setUpUI
{
    self.clipsToBounds = YES;
    self.backgroundColor = UIColor.blackColor;
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
}

- (void)setupSubviewsLayout
{
    self.scrollView.frame = self.calculateScrollViewFrame;
    self.imageView.frame = self.calculateImageViewFrame;
    
    CGFloat vInset = (self.scrollView.bounds.size.height - self.imageView.bounds.size.height) * 0.5;
    CGFloat hInset = (self.scrollView.bounds.size.width - self.imageView.bounds.size.width) * 0.5;
    self.scrollView.contentSize = self.imageView.frame.size;
    self.scrollView.contentInset = UIEdgeInsetsMake(vInset, hInset, vInset, hInset);
    self.scrollView.contentOffset = CGPointMake(-hInset, -vInset);
}

- (CGRect)calculateScrollViewFrame
{
    CGFloat h = self.contentSize.height;
    CGFloat w = h * h / self.contentSize.width;
    CGFloat x = self.contentInset.left + (self.bounds.size.width - w) / 2;
    CGFloat y = self.contentInset.top;
    return CGRectMake(x, y, w, h);
}

- (CGRect)calculateImageViewFrame
{
    if (self.imageView.image == nil) return CGRectZero;
    CGFloat maxW = self.contentSize.width - 2 * self.margin;
    CGFloat maxH = self.contentSize.height - 2 * self.margin;
    CGFloat whScale = self.imageView.image.size.width / self.imageView.image.size.height;
    CGFloat w = maxW;
    CGFloat h = w / whScale;
    if (h > maxH) {
        h = maxH;
        w = h * whScale;
    }
    return CGRectMake(0, 0, w, h);
}

- (void)setupClipResizeView
{
    [self addSubview:self.clipResizeView];
}

- (void)originImage:(UIImage *)image
{
    self.originImage = image;
    self.imageView.image = image;
    [self setupSubviewsLayout];
    [self setupClipResizeView];
}

- (void)recovery
{
    if (self.clipResizeView.isCanRecovery) return;
    [self.clipResizeView willRecovery];
    [UIView animateWithDuration:animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.clipResizeView recoveryWIthAnimate:YES];
    } completion:^(BOOL finished) {
        [self.clipResizeView doneRecovery];
    }];
}

- (void)clipImageWithImageSizeState:(BOOL)isOriginImageSize referenceWidth:(CGFloat)referenceWidth completion:(void (^)(UIImage *image))completion
{
    [self.clipResizeView clipImageWithReferenceWidth:referenceWidth isOriginImageSize:isOriginImageSize completion:completion];
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    [self.clipResizeView endIamgeResize];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.clipResizeView startImageResize];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) return;
    [self scrollViewDidEndDecelerating:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.clipResizeView endIamgeResize];
}

#pragma mark - lazyLoad
- (SEImageClipResizeView *)clipResizeView
{
    if (!_clipResizeView) {
        _clipResizeView = [[SEImageClipResizeView alloc] initWithFrame:self.scrollView.frame contentSize:self.contentSize margin:self.margin imageView:self.imageView scrollView:self.scrollView];
    }
    return _clipResizeView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.bouncesZoom = true;
        scrollView.maximumZoomScale = CGFLOAT_MAX;
        scrollView.delegate = self;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = YES;
        scrollView.alwaysBounceHorizontal = YES;
        scrollView.clipsToBounds = NO;
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

@end
