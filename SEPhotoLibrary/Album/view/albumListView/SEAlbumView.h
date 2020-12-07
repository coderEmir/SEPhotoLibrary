//
//  SEAlbumView.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SEAlbumModel;

@interface SEAlbumView : UIView

/**
 显示相册列表
 
 @param assetCollectionList 相册对象列表
 @param navigationBarMaxY navigationBarMaxY的最大值
 @param complete 返回结果
 */
+(void)showAlbumView:(NSMutableArray<SEAlbumModel *> *)assetCollectionList navigationBarMaxY:(CGFloat)navigationBarMaxY complete:(void(^)(SEAlbumModel *albumModel))complete;

@end

NS_ASSUME_NONNULL_END
