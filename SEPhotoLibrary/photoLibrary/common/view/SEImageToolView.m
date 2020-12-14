//
//  SEImageToolView.m
//  SEPhotoLibrary
//
//  Created by xKing on 2020/12/9.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEImageToolView.h"
#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height
#define SEToolBarHeight (SEStateBarH > 20 ? 34 : 0)
@interface SEImageToolView ()

//@property (nonatomic, strong) UIButton *previewBtn;

@property (nonatomic, strong) UIButton *editBtn;

@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, strong) UIView *lineView;

@property (nonatomic , assign) SEImageToolViewType type;

@property (nonatomic , copy) CallBackBlock callBackBlock;

@property (nonatomic ,strong) UIButton *rotateBtn;

@property (nonatomic ,strong) UIButton *rebackBtn;

@end

@implementation SEImageToolView

- (instancetype)initWithViewType:(SEImageToolViewType)type callBackBlock:(nonnull CallBackBlock)callBackBlock
{
     self = [super init];
    if (self)
    {
        self.type = type;
        self.callBackBlock = callBackBlock;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.lineView];
    switch (self.type)
    {
        case SEImageToolViewTypePreview:
        {
            [self.contentView addSubview:self.editBtn];
            [self.contentView addSubview:self.confirmBtn];
            [self.editBtn addTarget:self action:@selector(enterEdit) forControlEvents:UIControlEventTouchUpInside];
            [self.confirmBtn addTarget:self action:@selector(confirmEvent) forControlEvents:UIControlEventTouchUpInside];
            
        }
            break;
        case SEImageToolViewTypeClip:
        {
            [self.contentView addSubview:self.cancelBtn];
            [self.contentView addSubview:self.confirmBtn];
            [self.contentView addSubview:self.rebackBtn];
            [self.contentView addSubview:self.rotateBtn];
            [self.cancelBtn addTarget:self action:@selector(cancleEdit) forControlEvents:UIControlEventTouchUpInside];
            [self.confirmBtn addTarget:self action:@selector(finishEdit) forControlEvents:UIControlEventTouchUpInside];
            [self.rebackBtn addTarget:self action:@selector(rebackEdit) forControlEvents:UIControlEventTouchUpInside];
            [self.rotateBtn addTarget:self action:@selector(rotateEdit) forControlEvents:UIControlEventTouchUpInside];
        }
            break;
    }
}

- (void)enterEdit
{
    if (self.callBackBlock) self.callBackBlock(SEImageToolViewCallbackTypeEnterEdit);
}

- (void)confirmEvent
{
    if (self.callBackBlock) self.callBackBlock(SEImageToolViewCallbackTypeConfirm);
}

- (void)cancleEdit
{
    if (self.callBackBlock) self.callBackBlock(SEImageToolViewCallbackTypeCancleEdit);
}

- (void)finishEdit
{
    if (self.callBackBlock) self.callBackBlock(SEImageToolViewCallbackTypeFinishEdit);
}

- (void)rebackEdit
{
    if (self.callBackBlock) self.callBackBlock(SEImageToolViewCallbackTypeReback);
}

- (void)rotateEdit
{
    if (self.callBackBlock) self.callBackBlock(SEImageToolViewCallbackTypeRotate);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat height = self.bounds.size.height - SEToolBarHeight;
    CGFloat contentViewW = self.bounds.size.width;
    self.contentView.frame = CGRectMake(0, 0, contentViewW, height);
    self.lineView.frame = CGRectMake(0, 0, self.bounds.size.width, 0.5);
    switch (self.type) {
        case SEImageToolViewTypePreview:
        {
            self.editBtn.frame = CGRectMake(0, (height - 44) * 0.5, 70, 44);
            self.confirmBtn.frame = CGRectMake(contentViewW - 70, (height - 28) * 0.5, 70, 28);
            [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        }
            break;
            
        case SEImageToolViewTypeClip:
        {
            CGFloat functionBtnW = (contentViewW - 170) * 0.5;
            CGFloat subBtnH = 44;
            self.cancelBtn.frame = CGRectMake(0, (height - subBtnH) * 0.5, 70, subBtnH);
            self.confirmBtn.frame = CGRectMake(contentViewW - 70, self.cancelBtn.frame.origin.y, 70, subBtnH);
            self.rotateBtn.frame = CGRectMake(85, self.cancelBtn.frame.origin.y, functionBtnW, subBtnH);
            self.rebackBtn.frame = CGRectMake(90 + functionBtnW, self.cancelBtn.frame.origin.y, functionBtnW, subBtnH);
        }
            break;
    }
}

- (UIView *)lineView
{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    }
    return _lineView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = UIColor.blackColor;
    }
    return _contentView;
}

- (UIButton *)editBtn
{
    if (!_editBtn) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        _editBtn = button;
    }
    return _editBtn;
}

- (UIButton *)confirmBtn
{
    if (!_confirmBtn) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        _confirmBtn = button;
    }
    return _confirmBtn;
}


- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"取消" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        _cancelBtn = button;
    }
    return _cancelBtn;
}

- (UIButton *)rotateBtn
{
    if (!_rotateBtn)
    {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"旋转" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        _rotateBtn = button;
    }
    return _rotateBtn;
}

- (UIButton *)rebackBtn
{
    if (!_rebackBtn)
    {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"还原" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        _rebackBtn = button;
    }
    return _rebackBtn;
}

@end
