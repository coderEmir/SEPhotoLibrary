//
//  SEAlbumListView.h
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SEAlbumModel;
typedef void(^SEAlbumListViewSelectBlock)(SEAlbumModel *albumModel);

@interface SEAlbumListView : UITableView

// 相册数组
@property (nonatomic, strong) NSMutableArray<SEAlbumModel *> *assetCollectionList;
// 选择的相册
@property (nonatomic, copy) SEAlbumListViewSelectBlock selectAction;

@end

NS_ASSUME_NONNULL_END
