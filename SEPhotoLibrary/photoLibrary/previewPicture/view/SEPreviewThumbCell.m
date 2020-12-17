//
//  SEPreviewThumbCell.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPreviewThumbCell.h"
#import "SEPhotoModel.h"
#import "SEPhotoManager.h"
#import "SEPhotoLibrary-Swift.h"
@interface SEPreviewThumbCell ()

@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SEPreviewThumbCell

- (void)setModel:(SEPhotoModel *)model
{
    _model = model;
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.imageView.layer.borderWidth = _model.isSelectedPage ? 1 : 0;
    self.imageView.layer.borderColor = _model.isSelectedPage ? UIColor.redColor.CGColor : UIColor.clearColor.CGColor;
    
    self.imageView.image = nil;
    
    if (model.thumbImage) {
         self.imageView.image = model.thumbImage;
        return;
    }
    __weak typeof (self) weakSelf = self;
    [HXPhotoImageManager requestThumbImageFor:self.model.asset completion:^(UIImage * _Nullable image, BOOL isFinished) {
        if (!isFinished) return;
        model.thumbImage = image;
        weakSelf.imageView.image = image;
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    [self.contentView addSubview:_imageView];
    return _imageView;
}

@end
