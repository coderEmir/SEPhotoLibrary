//
//  SEAlbumManager.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SEPhotoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface SEAlbumManager : NSObject

+ (void)showPhotoManager:(UIViewController  *)superController withMaxImageCount:(NSInteger)maxImageCount andAlbumArrayBlock:(void(^)(NSMutableArray <SEPhotoModel *> *))albumArrayBlock;

@end

NS_ASSUME_NONNULL_END
