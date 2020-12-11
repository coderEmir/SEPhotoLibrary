//
//  SEImageNavigationView.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEImageNavigationView.h"
#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height

typedef void(^CancleBlock)(void);
typedef void(^SelectBlock)(BOOL isSelected);

@interface SEImageNavigationView ()

@property (nonatomic ,strong) UIButton *selectBtn;

@property (nonatomic ,strong) UIButton *backBtn;

@property (nonatomic ,strong) UILabel *titleLable;

@property (nonatomic ,copy) CancleBlock cancleBlock;

@property (nonatomic ,copy) SelectBlock selectBlock;
@end


@implementation SEImageNavigationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUpUI];
        [self layoutViews];
    }
    return self;
}

- (void)currentImageIndex:(NSInteger)imageIndex selectState:(BOOL)isSelect
{
    self.titleLable.text = [NSString stringWithFormat:@"%zd/%zd",imageIndex,self.totalImageCount];
    self.selectBtn.selected = isSelect;
}

- (void)setUpUI
{
    [self addSubview:self.backBtn];
    [self addSubview:self.titleLable];
    [self addSubview:self.selectBtn];
}

- (void)rebackEventBlock:(void(^)(void))cancleBlock imageSelectState:(void(^)(BOOL isSelected))selectblock
{
    self.cancleBlock = cancleBlock;
    self.selectBlock = selectblock;
}

- (void)layoutViews
{
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat subButtonY = (viewHeight - 44) * 0.5 + SEStateBarH > 20 ? 20 : 0;
    CGFloat subButtonWH = 44;
    self.backBtn.frame = CGRectMake(16, subButtonY, subButtonWH, subButtonWH);
    self.selectBtn.frame = CGRectMake(viewWidth - 54, subButtonY, subButtonWH, subButtonWH);
    self.titleLable.frame = CGRectMake((viewWidth - 100) * 0.5, subButtonY, 100, subButtonWH);
}

-  (void)backEvent
{
    if (self.cancleBlock) self.cancleBlock();
}

- (void)clickEvent
{
    if(self.selectBlock) self.selectBlock(self.selectBtn.selected);
}

#pragma mark - lazyLoad
- (UIButton *)backBtn
{
    if (!_backBtn)
    {
        UIButton *button = [[UIButton alloc] init];
        button.backgroundColor = UIColor.blueColor;
        [button addTarget:self action:@selector(backEvent) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = button;
    }
    return _backBtn;
}

- (UIButton *)selectBtn
{
    if (!_selectBtn)
    {
        UIButton *button = [[UIButton alloc] init];
        button.backgroundColor = UIColor.magentaColor;
        [button addTarget:self action:@selector(clickEvent) forControlEvents:UIControlEventTouchUpInside];
        _selectBtn = button;
    }
    return _selectBtn;
}

- (UILabel *)titleLable
{
    if (!_titleLable)
    {
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = UIColor.redColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = UIColor.whiteColor;
        _titleLable = label;
    }
    return _titleLable;
}

@end

