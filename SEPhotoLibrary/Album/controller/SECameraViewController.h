//
//  SECameraViewController.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^savePhotoBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface SECameraViewController : UIViewController

- (void)savePhotoSuccessBlock:(savePhotoBlock)savePhotoBlock;

@end

NS_ASSUME_NONNULL_END
