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
@interface SEPreviewThumbCell ()

@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation SEPreviewThumbCell

- (void)setModel:(SEPhotoModel *)model
{
    _model = model;
    [SEPhotoDefaultManager requestThumbImage:self.model.asset callBackImage:^(UIImage * _Nonnull image) {
        self.imageView.image = image;
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
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}

@end
