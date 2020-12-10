//
//  SEPreviewPictureController.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/9.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPreviewPictureController.h"
#import "SEEditPictureViewController.h"

#import "SEImageToolView.h"
#import "SEImageNavigationView.h"

#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height
#define SEScreenWidth self.view.bounds.size.width

@interface SEPreviewPictureController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic ,strong) NSMutableArray *highLightImages;
@property (nonatomic ,strong) UICollectionView *previewCollectionView;
@property (nonatomic ,strong) UICollectionView *thumbCollectionView;

@property (nonatomic ,assign) NSInteger currentIndex;

@property (nonatomic ,strong) NSMutableArray *imageModels;

@property (nonatomic, strong) SEImageToolView *imageToolView;
@property (nonatomic, strong) SEImageNavigationView *imageNavigationView;

@property (nonatomic, strong) NSMutableArray *selectedImageModels;
@end

@implementation SEPreviewPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.previewCollectionView];
    // 添加顶部导航 imageNavigationView
    
    [self.view addSubview:self.imageToolView];

}

- (void)previewPicture:(UIImage *)image
{
    [self.highLightImages addObject:image];
}

- (void)previewPictureCollection:(NSMutableArray <UIImage *>*)pictureCollection specifySubscript:(NSInteger)index
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
       
        for (UIImage * _Nonnull image in pictureCollection) {
            [weakSelf.highLightImages addObject:image];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [pictureCollection removeAllObjects];
            // TODO: 展示高清图片
            [self.previewCollectionView reloadData];
            [self.thumbCollectionView reloadData];
        });
    });
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        
    return collectionView == self.previewCollectionView ? self.highLightImages.count : self.selectedImageModels.count;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.previewCollectionView) {
        _currentIndex = (NSInteger)round(scrollView.contentOffset.x / scrollView.bounds.size.width);
        if (_currentIndex >= self.imageModels.count) {
            _currentIndex = self.imageModels.count - 1;
        } else if (_currentIndex < 0) {
            _currentIndex = 0;
        }
//        if (NSInteger selectedIndex = pickerController?.selectedImageModels.index(of: imageModels[currentIndex])) {
//            imageNavigationView.selectBtn.setSelectedIndex(selectedIndex)
//            let selectedIndexPath = IndexPath(item: selectedIndex, section: 0)
//            thumbCollectionViewCellDidSelected(at: selectedIndexPath)
//        } else {
//            if thumbSelectedIndexPath != nil{
//                collectionView(thumbCollectionView, didDeselectItemAt: thumbSelectedIndexPath!)
//            }
//            imageNavigationView.selectBtn.setSelectedIndex(-1)
//        }
//    }
    }
}

#pragma mark - event
- (void)thumbCollectionViewHandleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    
}

#pragma mark - lazyLoad
- (NSMutableArray *)highLightImages
{
    if (!_highLightImages)
    {
        _highLightImages = [[NSMutableArray alloc] init];
    }
    return _highLightImages;
}

- (UICollectionView *)previewCollectionView
{
    if (!_previewCollectionView)
    {
        CGFloat cellSpacing = 10;
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 2 * cellSpacing;
        layout.minimumInteritemSpacing = 0;
        layout.sectionInset = UIEdgeInsetsMake(0, cellSpacing, 0, cellSpacing);
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = NO;
        }
        collectionView.frame = CGRectInset(collectionView.frame, -cellSpacing, 0);
        _previewCollectionView = collectionView;
    }
    return _previewCollectionView;
}

- (UICollectionView *)thumbCollectionView
{
    if (!_thumbCollectionView)
    {
        CGFloat cellSpacing = 10;
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 2 * cellSpacing;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSize = CGSizeMake(70, 70);
        // toolBarHeight
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 90, self.view.bounds.size.width, 90) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.97];
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.alwaysBounceHorizontal = YES;
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        
        [collectionView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(thumbCollectionViewHandleLongPressGesture:)]];
        
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = NO;
        }
        collectionView.frame = CGRectInset(collectionView.frame, -cellSpacing, 0);
        _thumbCollectionView = collectionView;
    }
    return _thumbCollectionView;
}

- (SEImageToolView *)imageToolView
{
    if (!_imageToolView) {
        SEImageToolView *imageToolView = [[SEImageToolView alloc] initWithViewType:SEImageToolViewTypePreview callBackBlock:^(SEImageToolViewCallbackType type) {
            
            switch (type) {
                case SEImageToolViewCallbackTypeEnterEdit:
                {
                    SEEditPictureViewController *controller = [[SEEditPictureViewController alloc] init];
                    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [self presentViewController:controller animated:YES completion:nil];
                }
                    break;
                case SEImageToolViewCallbackTypeConfirm:
                {
                    // 完成选择
                }
                    break;
                    
                default:
                    break;
            }
        }];
        _imageToolView = imageToolView;
    }
    return _imageToolView;
}

- (SEImageNavigationView *)imageNavigationView
{
    if (!_imageNavigationView)
    {
        _imageNavigationView = [[SEImageNavigationView alloc] initWithFrame:CGRectMake(0, 0, SEScreenWidth, SEStateBarH + 44)];
    }
    return _imageNavigationView;
}

@end
