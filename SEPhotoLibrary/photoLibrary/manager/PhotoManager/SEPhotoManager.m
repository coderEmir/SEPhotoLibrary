//
//  SEPhotoManager.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPhotoManager.h"
#import "SEPhotoModel.h"
#import <Photos/Photos.h>
#import <UIKit/UIImage.h>
@implementation SEPhotoManager

+ (instancetype)defaultManager
{
    static SEPhotoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)setMaxImageCount:(NSInteger)maxImageCount
{
    _maxImageCount = maxImageCount;
    self.photoModelList = NSMutableArray.array;
    self.choiceCount = 0;
}

- (void)setChoiceCount:(NSInteger)choiceCount
{
    _choiceCount = choiceCount;
    if (self.choiceCountChangedBlock) self.choiceCountChangedBlock(_choiceCount);
}

- (void)requestPreviewImage:(PHAsset *)asset callBackImage:(CallBackImageBlock)callBackImageBlock
{
    CGSize targetSize = [self getPriviewSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight) standard:0];
    [self requestImageAsyncChronous:asset targetSize:targetSize callBackImageBlock:callBackImageBlock];
}

- (void)requestThumbImage:(PHAsset *)asset callBackImage:(CallBackImageBlock)callBackImageBlock
{
    CGSize targetSize = [self getPriviewSize:CGSizeMake(200, 200) standard:0];
    [self requestImageAsyncChronous:asset targetSize:targetSize callBackImageBlock:callBackImageBlock];
}

- (void)requestImageAsyncChronous:(PHAsset *)asset targetSize:(CGSize)targetSize callBackImageBlock:(CallBackImageBlock)callBackImageBlock
{
    @autoreleasepool {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            options.synchronous = NO;
            options.networkAccessAllowed = YES;
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                UIImage *image = [UIImage imageWithData:imageData];
                if (callBackImageBlock) callBackImageBlock(image);
            }];
    }
    
//    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//        if (callBackImageBlock) callBackImageBlock(result);
//    }];
}

- (CGSize)getPriviewSize:(CGSize)originSize standard:(CGFloat)standard
{
    standard = standard > 0 ? standard : 600;
    CGFloat width = originSize.width;
    CGFloat height = originSize.height;
    
    CGFloat pixelScale = width / height;
    
    CGSize targetSize = CGSizeZero;
    
    if (width < standard && height <= standard) {
        // 图片宽或者高均小于或等于standard时图片尺寸保持不变，不改变图片大小
        targetSize = CGSizeMake(width, height);
    }
    else if (width > standard && height > standard) {
        // 宽以及高均大于standard，但是图片宽高比例大于(小于)2时，则宽或者高取小(大)的等比压缩至standard
        if (pixelScale > 2) {
            targetSize.width = standard * pixelScale;
            targetSize.height = standard;
        } else if (pixelScale < 0.5) {
            targetSize.width = standard;
            targetSize.height = standard / pixelScale;
        } else if (pixelScale > 1) {
            targetSize.width = standard;
            targetSize.height = standard / pixelScale;
        } else {
            targetSize.width = standard * pixelScale;
            targetSize.height = standard;
        }
    }
    else
    {
        // 宽或者高大于standard，但是图片宽度高度比例小于或等于2，则将图片宽或者高取大的等比压缩至standard
        if (pixelScale <= 2 && pixelScale > 1) {
            targetSize.width = standard;
            targetSize.height = standard / pixelScale;
        } else if (pixelScale > 0.5 && pixelScale <= 1) {
            targetSize.width = standard * pixelScale;
            targetSize.height = standard;
        } else {
            targetSize.width = width;
            targetSize.height = height;
        }
    }
    return targetSize;
}

- (void)pickUpImages:(NSMutableArray<SEPhotoModel *> *)assetsModels unCheckedIndexes:( NSArray *)unCheckedIndexes stateBlock:(nonnull void (^)(BOOL))stateBlock
{
    dispatch_group_t group = dispatch_group_create();
    NSInteger assetsIndex = -1;
    NSInteger selectImageIndex = 0;

    __block NSMutableArray *images = NSMutableArray.array;
    for (SEPhotoModel *model in assetsModels) {
        
        assetsIndex ++;
        if (unCheckedIndexes.count > 0) {
            if ([unCheckedIndexes containsObject:@(assetsIndex)]) continue;
        }
        dispatch_group_enter(group);
        
        [images addObject:UIImage.new];
        
        [SEPhotoDefaultManager requestPreviewImage:model.asset callBackImage:^(UIImage * _Nullable image) {
            if (image != nil) {
                [images replaceObjectAtIndex:selectImageIndex withObject:image];
            }
            dispatch_group_leave(group);
        }];
        selectImageIndex ++;
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (stateBlock) stateBlock(images.count == selectImageIndex);
    });
}

@end
