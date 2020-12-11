//
//  SEPhotoManager.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PHAsset;
#define SEPhotoDefaultManager SEPhotoManager.defaultManager

NS_ASSUME_NONNULL_BEGIN

@class SEPhotoModel,UIImage;

typedef void(^ChoiceCountChangedBlock)(NSInteger choiceCount);
typedef void (^CallBackImageBlock)(UIImage *image);

@interface SEPhotoManager : NSObject

@property (nonatomic ,assign) NSInteger maxImageCount;

@property (nonatomic ,assign) NSInteger choiceCount;

@property (nonatomic ,strong) NSMutableArray<SEPhotoModel *> *photoModelList;

@property (nonatomic ,copy) ChoiceCountChangedBlock choiceCountChangedBlock;


- (void)requestPreviewImage:(PHAsset *)asset callBackImage:(CallBackImageBlock)callBackImageBlock;

- (void)requestThumbImage:(PHAsset *)asset callBackImage:(CallBackImageBlock)callBackImageBlock;

+ (instancetype)defaultManager;

@end

NS_ASSUME_NONNULL_END
