//
//  SEPreviewPictureController.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/9.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeCheckBlock)(NSArray * _Nullable unCheckedIndexes);
typedef void(^ComfirmBlock)(void);
NS_ASSUME_NONNULL_BEGIN
@class SEPhotoModel;
@interface SEPreviewPictureController : UIViewController

- (void)previewPictureCollection:(NSMutableArray <SEPhotoModel *>*)pictureCollection specifySubscript:(NSInteger)specifySubscript changeCheck:(ChangeCheckBlock)changeCheckBlock comfirmBlock:(ComfirmBlock)comfirmBlock;
@end

NS_ASSUME_NONNULL_END
