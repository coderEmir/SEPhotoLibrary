//
//  SEAlbumCollectionViewCell.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/14.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEAlbumCollectionViewCell.h"
#import "SEPhotoManager.h"

@interface SEAlbumCollectionViewCell ()

// 相片
@property (nonatomic, strong) UIImageView *photoImageView;
// 选中按钮
@property (nonatomic, strong) UIButton *selectButton;
// 半透明遮罩
@property (nonatomic, strong) UIView *translucentView;

@end

@implementation SEAlbumCollectionViewCell

+ (instancetype)dequeueReusableCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath
{
    SEAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:albumCollectionViewCell forIndexPath:indexPath];
    [cell setupCell];
    cell.contentView.backgroundColor = UIColor.redColor;
    return cell;
}

-(void)setupCell {
    [self photoImageView];
    [self translucentView];
    [self selectButton];
}

- (void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    UIImage *bgImage = isSelect ? [UIImage imageNamed: @"selectImage_select"] : nil;
    [self.selectButton setImage:bgImage forState:UIControlStateNormal];
    _translucentView.hidden = YES;
    if (SEPhotoDefaultManager.maxImageCount == SEPhotoDefaultManager.choiceCount) {
        self.translucentView.hidden = NO;
        UIColor *bgColor = isSelect ? [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2] : [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
        _translucentView.backgroundColor = bgColor;
    }
}

#pragma mark - event
- (void)selectPhoto:(UIButton *)btn
{
    if  (self.cellSelectedBlock) self.cellSelectedBlock(self.asset);
}

-(void)loadImage:(NSIndexPath *)indexPath {
    
    self.photoImageView.image = nil;
    CGFloat imageWidth = (ScreenWidth - 20.f) / 5.5;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = NO;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset targetSize:CGSizeMake(imageWidth * UIScreen.mainScreen.scale, imageWidth * UIScreen.mainScreen.scale) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (self.row == indexPath.row) self.photoImageView.image = result;
    }];
}
#pragma mark - lazyLoad
-(UIButton *)selectButton
{
    if (!_selectButton)
    {
        _selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectButton.layer.borderColor = UIColor.whiteColor.CGColor;
        _selectButton.layer.borderWidth = 1.f;
        _selectButton.layer.cornerRadius = 12.5f;
        _selectButton.layer.masksToBounds = YES;
        [_selectButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_selectButton addTarget:self action:@selector(selectPhoto:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:_selectButton];
        _selectButton.frame = CGRectMake((ScreenWidth - 20.f) / 3.f - 29, 3, 25, 25);
    }
    
    return _selectButton;
}

-(UIView *)translucentView {
    if (!_translucentView) {
        _translucentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (ScreenWidth - 20.f) / 3.f, (ScreenWidth - 20.f) / 3.f)];
        _translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        [self.contentView addSubview:_translucentView];
        _translucentView.hidden = YES;
    }
    
    return _translucentView;
}

-(UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (ScreenWidth - 20.f) / 3.f, (ScreenWidth - 20.f) / 3.f)];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_photoImageView];
    }
    
    return _photoImageView;
}

@end
