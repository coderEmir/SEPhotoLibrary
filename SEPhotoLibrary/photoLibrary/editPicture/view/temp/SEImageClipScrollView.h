//
//  SEImageClipScrollView.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/12.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SEImageClipScrollView : UIView

- (instancetype)initWithFrame:(CGRect)frame margin:(CGFloat)margin contentInset:(UIEdgeInsets)contentInset;

- (void)originImage:(UIImage *)image;

- (void)recovery;

- (void)clipImageWithImageSizeState:(BOOL)isOriginImageSize referenceWidth:(CGFloat)referenceWidth completion:(void (^)(UIImage *image))completion;

@end

NS_ASSUME_NONNULL_END
