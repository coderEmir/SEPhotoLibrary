//
//  SEPreviewThumbCell.h
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SEPhotoModel;
NS_ASSUME_NONNULL_BEGIN

@interface SEPreviewThumbCell : UICollectionViewCell

@property (nonatomic, strong) SEPhotoModel *model;

@end

NS_ASSUME_NONNULL_END
