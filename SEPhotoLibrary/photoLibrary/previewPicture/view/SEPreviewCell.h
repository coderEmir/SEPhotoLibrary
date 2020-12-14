//
//  SEPreviewCell.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SEPhotoModelDelegate <NSObject>
@optional;
- (void)photoModelSingleTapEvent;

@end

NS_ASSUME_NONNULL_BEGIN
@class SEPhotoModel;
@interface SEPreviewCell : UICollectionViewCell

@property (nonatomic, strong) SEPhotoModel *model;

@property(nullable,nonatomic,weak) id<SEPhotoModelDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
