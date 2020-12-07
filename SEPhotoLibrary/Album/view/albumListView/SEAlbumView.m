//
//  SEAlbumView.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/7.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEAlbumView.h"
#import "SEAlbumModel.h"
#import "SEAlbumListView.h"

#define ScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight [[UIScreen mainScreen] bounds].size.height

typedef void(^SEAlbumViewSelectBlock)(SEAlbumModel *albumModel);

@interface SEAlbumView()

/// 相册数组
@property (nonatomic, strong) NSMutableArray<SEAlbumModel *> *assetCollectionList;
/// 灰色透明按钮
@property (nonatomic, strong) UIButton *greyTransparentButton;
/// 相册表格背景view
@property (nonatomic, strong) UIView *tableViewBackgroundView;
/// 相册列表
@property (nonatomic, strong) SEAlbumListView *tableView;
/// 列表的高度
@property (nonatomic, assign) CGFloat presentHeight;
/// navigation的最大Y值
@property (nonatomic, assign) CGFloat navigationBarMaxY;
/// 选中的相册
@property (nonatomic, copy) SEAlbumViewSelectBlock selectAction;

@end
@implementation SEAlbumView

+(void)showAlbumView:(NSMutableArray<SEAlbumModel *> *)assetCollectionList navigationBarMaxY:(CGFloat)navigationBarMaxY complete:(void(^)(SEAlbumModel *albumModel))complete
{
    SEAlbumView *albumView = [[SEAlbumView alloc] init];
    
    albumView.navigationBarMaxY = navigationBarMaxY;
    albumView.selectAction = complete;
    albumView.assetCollectionList = assetCollectionList;
}

-(instancetype)init {
    if (self = [super init]) {
        [self setupAlbumView];
    }
    
    return self;
}

/// 设置相册页面
-(void)setupAlbumView {
    self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:self];
    
    [self greyTransparentButton];
    [self tableView];
}

#pragma mark - 显示动画
-(void)showAnimate {
    [self layoutIfNeeded];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.greyTransparentButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
        weakSelf.tableViewBackgroundView.frame = CGRectMake(0, self.navigationBarMaxY, ScreenWidth, weakSelf.presentHeight);
    } completion:^(BOOL finished) {}];
}

#pragma mark - 隐藏动画
-(void)endAnimate {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.greyTransparentButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        weakSelf.tableViewBackgroundView.frame = CGRectMake(0, self.navigationBarMaxY, ScreenWidth, 0.00001);
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 点击事件
-(void)clickCancel:(UIButton *)button {
    if (self.selectAction) {
        self.selectAction(nil);
    }
    
    [self endAnimate];
}

#pragma mark - Set方法
-(void)setAssetCollectionList:(NSMutableArray<SEAlbumModel *> *)assetCollectionList {
    _assetCollectionList = assetCollectionList;
    
    /// 相册列表的高度是80.f
    self.presentHeight = assetCollectionList.count * 80.f;
    if (self.presentHeight > 400.f) {
        self.presentHeight = 400.f;
    }
    
    self.tableViewBackgroundView.frame = CGRectMake(0, self.navigationBarMaxY, ScreenWidth, 0.0001);
    
    self.tableView.assetCollectionList = assetCollectionList;
    CGRect tableViewFrame = self.tableView.frame;
    tableViewFrame.size = CGSizeMake(tableViewFrame.size.width, self.presentHeight);
    self.tableView.frame = tableViewFrame;
    
    __weak typeof(self) weakSelf = self;
    self.tableView.selectAction = ^(SEAlbumModel *albumModel) {
        if (weakSelf.selectAction) {
            weakSelf.selectAction(albumModel);
        }
        
        [weakSelf endAnimate];
    };
    
    [self showAnimate];
}

#pragma mark - Get方法
-(SEAlbumListView *)tableView {
    if (!_tableView) {
        _tableView = [[SEAlbumListView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) style:UITableViewStylePlain];
        
        [self.tableViewBackgroundView addSubview:_tableView];
    }
    
    return _tableView;
}

-(UIView *)tableViewBackgroundView {
    if (!_tableViewBackgroundView) {
        _tableViewBackgroundView = [[UIView alloc] init];
        _tableViewBackgroundView.backgroundColor = [UIColor whiteColor];
        _tableViewBackgroundView.layer.masksToBounds = YES;
        
        [self addSubview:_tableViewBackgroundView];
    }
    
    return _tableViewBackgroundView;
}

-(UIButton *)greyTransparentButton {
    if (!_greyTransparentButton) {
        _greyTransparentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _greyTransparentButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [_greyTransparentButton addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_greyTransparentButton];
        
        _greyTransparentButton.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }
    
    return _greyTransparentButton;
}

@end
