//
//  SEImageClipResizeView.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/12.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SEImageClipResizeCornerLeftTop,
    SEImageClipResizeCornerRightTop,
    SEImageClipResizeCornerLeftBottom,
    SEImageClipResizeCornerRightBottom,
    SEImageClipResizeCornerLeftMiddle,
    SEImageClipResizeCornerRightMiddle,
    SEImageClipResizeCornerBottomMiddle,
    SEImageClipResizeCornerTopMiddle,
    SEImageClipResizeCornerNone
} SEImageClipResizeCornerType;

typedef enum : NSUInteger {
    SEImageClipResizeLineHorizontalTop,
    SEImageClipResizeLineHorizontalBottom,
    SEImageClipResizeLineVerticalLeft,
    SEImageClipResizeLineVerticalRight,
} SEImageClipResizeLinePosition;

static NSTimeInterval const animateDuration = 0.25;

typedef void(^SEImageClipResizeClosure)(BOOL state);

NS_ASSUME_NONNULL_BEGIN

@interface SEImageClipResizeView : UIView

- (instancetype)initWithFrame:(CGRect)frame contentSize:(CGSize)contentSize margin:(CGFloat)margin imageView:(UIImageView *)imageView scrollView:(UIScrollView *)scrollView;

- (void)startImageResize;
- (void)endIamgeResize;

- (void)willRecovery;
- (void)doneRecovery;
- (void)recoveryWIthAnimate:(BOOL)animated;

- (void)clipImageWithReferenceWidth:(CGFloat)referenceWidth isOriginImageSize:(BOOL)isOriginImageSize completion:(void(^)(UIImage *image))completion;

@property (nonatomic , assign) BOOL isCanRecovery;

@property (nonatomic , copy) SEImageClipResizeClosure canRecoveryClosure;

@property (nonatomic , copy) SEImageClipResizeClosure prepareToScaleClosure;

@end

NS_ASSUME_NONNULL_END
