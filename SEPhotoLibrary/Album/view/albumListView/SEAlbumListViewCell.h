//
//  SEAlbumListViewCell.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class SEAlbumModel;

@interface SEAlbumListViewCell : UITableViewCell
/// 相册
@property (nonatomic, strong) SEAlbumModel *albumModel;

/// 行数
@property (nonatomic, assign) NSInteger row;

/// 加载图片
-(void)loadImage:(NSIndexPath *)index;

@end

NS_ASSUME_NONNULL_END
