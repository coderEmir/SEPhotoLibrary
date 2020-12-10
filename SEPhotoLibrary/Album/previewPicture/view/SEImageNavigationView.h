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
- (void)currentImageIndex:(NSString *)imageIndex selectState:(BOOL)isSelect;

@end

NS_ASSUME_NONNULL_END
