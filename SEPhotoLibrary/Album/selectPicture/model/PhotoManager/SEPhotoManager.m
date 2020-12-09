//
//  SEPhotoManager.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPhotoManager.h"

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

@end
