//
//  SEPhotoModel.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^PhotoActionBlock)(void);

@interface SEPhotoModel : NSObject
/// 相片
@property (nonatomic, strong) PHAsset *asset;
/// 高清图
@property (nonatomic, strong) UIImage *highDefinitionImage;
/// 获取图片成功事件
@property (nonatomic, copy) PhotoActionBlock photoActionBlock;

@property (nonatomic ,assign) NSInteger photoIndex;

@end

NS_ASSUME_NONNULL_END
