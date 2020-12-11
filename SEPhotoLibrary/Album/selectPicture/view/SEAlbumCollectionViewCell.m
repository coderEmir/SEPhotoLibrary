//
//  SEAlbumCollectionViewCell.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/14.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEAlbumCollectionViewCell.h"
#import "SEPhotoManager.h"

static CGFloat const pictureNumber = 3;

@interface SEAlbumCollectionViewCell ()

// 相片
@property (nonatomic, strong) UIImageView *photoImageView;
// 选中按钮
@property (nonatomic, strong) UIButton *selectButton;
// 半透明遮罩
@property (nonatomic, strong) UIView *translucentView;

@property (nonatomic ,strong) UIImageView *cameraImgV;

@property (nonatomic ,strong) UILabel *cameraTitle;

@end

@implementation SEAlbumCollectionViewCell

+ (instancetype)dequeueReusableCellWithCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath
{
    SEAlbumCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:albumCollectionViewCell forIndexPath:indexPath];
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
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setupCell];
//    self.photoImageView.image = nil;
    CGFloat imageWidth = (SEScreenWidth - 20.f) / 5.5;
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = NO;
    [[PHCachingImageManager defaultManager] requestImageForAsset:self.asset targetSize:CGSizeMake(imageWidth * UIScreen.mainScreen.scale, imageWidth * UIScreen.mainScreen.scale) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        if (self.row == indexPath.row) self.photoImageView.image = result;
        [self.contentView addSubview:self.translucentView];
        [self.contentView addSubview:self.selectButton];
    }];
    
    
}

- (void)loadCamera
{
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    CGFloat paddingWidth = (SEScreenWidth - 20.f) / 3;
    self.cameraImgV.frame = CGRectMake((paddingWidth - 27.5) * 0.5, 24, 27.5, 22);
    self.cameraTitle.frame = CGRectMake(0, CGRectGetMaxY(self.cameraImgV.frame) + 7, paddingWidth, 15);
    [self.contentView addSubview:_cameraImgV];
    [self.contentView addSubview:_cameraTitle];
    self.contentView.backgroundColor = [UIColor colorWithRed:37/255.0 green:33/255.0 blue:32/255.0 alpha:1.0];
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
        
        _selectButton.frame = CGRectMake((SEScreenWidth - 20.f) / pictureNumber - 29, 3, 25, 25);
    }
    
    return _selectButton;
}

-(UIView *)translucentView {
    if (!_translucentView) {
        _translucentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (SEScreenWidth - 20.f) / pictureNumber, (SEScreenWidth - 20.f) / pictureNumber)];
        _translucentView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        
        _translucentView.hidden = YES;
    }
    
    return _translucentView;
}

-(UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, (SEScreenWidth - 20.f) / pictureNumber, (SEScreenWidth - 20.f) / pictureNumber)];
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _photoImageView.layer.masksToBounds = YES;
        
    }
    [self.contentView addSubview:_photoImageView];
    return _photoImageView;
}

- (UIImageView *)cameraImgV
{
    if (!_cameraImgV)
    {
        _cameraImgV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera"]];
       
    }
    return _cameraImgV;
}

- (UILabel *)cameraTitle
{
    if (!_cameraTitle)
    {
        _cameraTitle = [[UILabel alloc] init];
        _cameraTitle.text = @"拍照";
        _cameraTitle.textColor = UIColor.whiteColor;
        _cameraTitle.textAlignment = NSTextAlignmentCenter;
        
    }
    return _cameraTitle;
}



@end
