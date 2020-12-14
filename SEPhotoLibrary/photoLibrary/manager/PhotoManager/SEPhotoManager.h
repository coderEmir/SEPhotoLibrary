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

#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height
#define SEScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define SEScreenHeight [[UIScreen mainScreen] bounds].size.height
#define SEToolBarHeight (SEStateBarH > 20 ? 34 : 0)

NS_ASSUME_NONNULL_BEGIN

@class SEPhotoModel,UIImage;

typedef void(^ChoiceCountChangedBlock)(NSInteger choiceCount);
typedef void (^CallBackImageBlock)(UIImage * image);

@interface SEPhotoManager : NSObject

@property (nonatomic ,assign) NSInteger maxImageCount;

@property (nonatomic ,assign) NSInteger choiceCount;

@property (nonatomic ,strong) NSArray <UIImage *> *photoModelList;

@property (nonatomic ,copy) ChoiceCountChangedBlock choiceCountChangedBlock;

+ (instancetype)defaultManager;

- (void)pickUpImages:(NSMutableArray<SEPhotoModel *> *)model unCheckedIndexes:(NSArray *)unCheckedIndexes stateBlock:(void(^)(BOOL isSuccess))stateBlock;

@end

NS_ASSUME_NONNULL_END
