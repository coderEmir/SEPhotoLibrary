//
//  SEImageNavigationView.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEImageNavigationView.h"
#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height
@interface SEImageNavigationView ()

@property (nonatomic ,strong) UIButton *selectBtn;

@property (nonatomic ,strong) UIButton *backBtn;

@property (nonatomic ,strong) UILabel *titleLable;

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

- (void)currentImageIndex:(NSString *)imageIndex selectState:(BOOL)isSelect
{
    self.titleLable.text = imageIndex;
    self.selectBtn.selected =isSelect;
}

- (void)setUpUI
{
    [self addSubview:self.backBtn];
    [self addSubview:self.titleLable];
    [self addSubview:self.selectBtn];
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

- (UIButton *)backBtn
{
    if (!_backBtn)
    {
        UIButton *button = [[UIButton alloc] init];
        button.backgroundColor = UIColor.blueColor;
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

