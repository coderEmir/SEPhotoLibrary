//
//  SEImageNavigationView.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SEImageNavigationView : UIView

@property (nonatomic ,assign) NSInteger totalImageCount;

- (void)currentImageIndex:(NSInteger)index selectState:(BOOL)isSelect;

- (void)rebackEventBlock:(void(^)(void))block imageSelectState:(void(^)(BOOL isChecked))block;

@end

NS_ASSUME_NONNULL_END
