//
//  SEPhotoManager.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SEPhotoDefaultManager SEPhotoManager.defaultManager

NS_ASSUME_NONNULL_BEGIN

@class SEPhotoModel;
typedef void(^ChoiceCountChangedBlock)(NSInteger choiceCount);
@interface SEPhotoManager : NSObject

@property (nonatomic ,assign) NSInteger maxImageCount;

@property (nonatomic ,assign) NSInteger choiceCount;

@property (nonatomic ,strong) NSMutableArray<SEPhotoModel *> *photoModelList;

@property (nonatomic ,copy) ChoiceCountChangedBlock choiceCountChangedBlock;

+ (instancetype)defaultManager;

- (void)saveCameraImage;

@end

NS_ASSUME_NONNULL_END
