//
//  SEEditPictureViewController.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "TOCropViewController.h"

typedef void(^EditCompleteBlock)(UIImage * _Nullable image);
NS_ASSUME_NONNULL_BEGIN

@interface SEEditPictureViewController : TOCropViewController

//- (void)willEditComplete:(EditCompleteBlock)block;

@end

NS_ASSUME_NONNULL_END
