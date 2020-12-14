//
//  SEAlbumManager.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface SEAlbumManager : NSObject

+ (void)showPhotoManager:(UIViewController *)superController withMaxImageCount:(NSInteger)maxImageCount showCamera:(BOOL)isShowCamera showFilter:(BOOL)isShowFilter pictureScrollsFromTheTop:(BOOL)isScrollTop andAlbumArrayBlock:(void(^)(NSArray <UIImage *> *photoModel))albumArrayBlock;

@end

NS_ASSUME_NONNULL_END
