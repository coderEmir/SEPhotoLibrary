//
//  SEImageToolView.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/9.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SEImageToolViewTypePreview,
    SEImageToolViewTypeClip,
} SEImageToolViewType;

typedef enum : NSUInteger {
    SEImageToolViewCallbackTypeConfirm,
    SEImageToolViewCallbackTypeEnterEdit,
    SEImageToolViewCallbackTypeCancleEdit,
    SEImageToolViewCallbackTypeFinishEdit,
    SEImageToolViewCallbackTypeReback,
    SEImageToolViewCallbackTypeRotate
} SEImageToolViewCallbackType;

typedef void(^CallBackBlock)(SEImageToolViewCallbackType);

NS_ASSUME_NONNULL_BEGIN

@interface SEImageToolView : UIView

@property (nonatomic ,strong, readonly) UIButton *rebackBtn;
@property (nonatomic, strong, readonly) UIButton *confirmBtn;
@property (nonatomic, strong, readonly) UIButton *cancelBtn;

- (instancetype)initWithViewType:(SEImageToolViewType)type callBackBlock:(CallBackBlock)callBackBlock;

@end

NS_ASSUME_NONNULL_END
