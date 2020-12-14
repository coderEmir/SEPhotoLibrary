//
//  SEPhotoManager.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPhotoManager.h"
#import "SEPhotoModel.h"
#import <Photos/Photos.h>
#import <UIKit/UIImage.h>
#import "SEPhotoLibrary-Swift.h"

@implementation SEPhotoManager

+ (instancetype)defaultManager
{
    static SEPhotoManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)setMaxImageCount:(NSInteger)maxImageCount
{
    _maxImageCount = maxImageCount;
    self.photoModelList = NSMutableArray.array;
    self.choiceCount = 0;
}

- (void)setChoiceCount:(NSInteger)choiceCount
{
    _choiceCount = choiceCount;
    if (self.choiceCountChangedBlock) self.choiceCountChangedBlock(_choiceCount);
}

- (void)pickUpImages:(NSMutableArray<SEPhotoModel *> *)assetsModels unCheckedIndexes:( NSArray *)unCheckedIndexes stateBlock:(nonnull void (^)(BOOL))stateBlock
{
    dispatch_group_t group = dispatch_group_create();
    NSInteger assetsIndex = -1;
    NSInteger selectImageIndex = 0;

    __block NSMutableArray *images = NSMutableArray.array;
    for (SEPhotoModel *model in assetsModels) {
        
        assetsIndex ++;
        if (unCheckedIndexes.count > 0) {
            if ([unCheckedIndexes containsObject:@(assetsIndex)]) continue;
        }
        dispatch_group_enter(group);
        
        [images addObject:UIImage.new];
        if (model.editedImage)
        {
            [images replaceObjectAtIndex:selectImageIndex withObject:model.editedImage];
        }
        else
        {
            [HXPhotoImageManager requestThumbImageFor:model.asset completion:^(UIImage * _Nullable image, BOOL isFinished) {
                if (image != nil) {
                    [images replaceObjectAtIndex:selectImageIndex withObject:image];
                }
                dispatch_group_leave(group);
            }];
        }
        selectImageIndex ++;
    }

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (stateBlock) stateBlock(images.count == selectImageIndex);
    });
}

@end
