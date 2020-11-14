//
//  ViewController.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/10.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "ViewController.h"
#import "SEAlbumManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    // OC 语法规定, 对象中的结构体属性中的属性是不允许作单独修改的
    btn.frame = (CGRect){100, 100 ,100, 100};
    [btn addTarget:self action:@selector(btnEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

- (void)btnEvent
{
    [SEAlbumManager showPhotoManager:self withMaxImageCount:5 andAlbumArrayBlock:^(NSMutableArray<SEPhotoModel *> *data) {
        
    }];
}
@end
