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
    SEImageToolViewCallbackTypeFinishEdit
} SEImageToolViewCallbackType;

typedef void(^CallBackBlock)(SEImageToolViewCallbackType);

NS_ASSUME_NONNULL_BEGIN

@interface SEImageToolView : UIView

- (instancetype)initWithViewType:(SEImageToolViewType)type callBackBlock:(CallBackBlock)callBackBlock;

@end

NS_ASSUME_NONNULL_END
