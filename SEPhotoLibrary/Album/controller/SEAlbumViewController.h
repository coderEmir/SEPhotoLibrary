//
//  SEAlbumViewController.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ConfirmActionBlock)(void);
@interface SEAlbumViewController : UIViewController

@property (nonatomic ,copy) ConfirmActionBlock confirmActionBlock;

@end

NS_ASSUME_NONNULL_END
