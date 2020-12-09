//
//  SEEditPictureViewController.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset, SEPhotoModel;

typedef void(^EditCompleteBlock)(UIImage * _Nullable image);
NS_ASSUME_NONNULL_BEGIN

@interface SEEditPictureViewController : UIViewController

- (void)previewPicture:(UIImage *)image;

- (void)previewPictureCollection:(NSMutableArray <UIImage *>*)pictureCollection specifySubscript:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
