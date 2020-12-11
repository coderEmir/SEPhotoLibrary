//
//  SEPreviewPictureController.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/9.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPreviewPictureController.h"
#import "SEEditPictureViewController.h"

#import "SEPreviewCell.h"
#import "SEPreviewThumbCell.h"

#import "SEImageToolView.h"
#import "SEImageNavigationView.h"

#import "SEPhotoModel.h"

#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height
#define SEScreenWidth self.view.bounds.size.width

static NSString *const previewCell = @"SEPreviewCell";
static NSString *const previewThumbCell = @"SEPreviewThumbCell";

@interface SEPreviewPictureController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic ,strong) NSMutableArray *assetsModels;
@property (nonatomic ,strong) UICollectionView *previewCollectionView;
@property (nonatomic ,strong) UICollectionView *thumbCollectionView;

@property (nonatomic ,assign) NSInteger currentIndex;

@property (nonatomic ,strong) NSMutableArray *imageModels;

@property (nonatomic, strong) SEImageToolView *imageToolView;
@property (nonatomic, strong) SEImageNavigationView *imageNavigationView;

@property (nonatomic, strong) NSMutableArray *selectedImageModels;

@property (nonatomic, assign) CGPoint tmpThumbCenterOffset;
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

- (void)previewPicture:(SEPhotoModel *)imageModel
{
    [self.assetsModels addObject:imageModel];
}

- (void)previewPictureCollection:(NSMutableArray <PHAsset *>*)pictureCollection specifySubscript:(NSInteger)index
{
    self.assetsModels = pictureCollection.mutableCopy;
    [pictureCollection removeAllObjects];
    
    [self.previewCollectionView reloadData];
    [self.thumbCollectionView reloadData];
//    __weak typeof(self) weakSelf = self;
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//        for (PHAsset * _Nonnull asset in pictureCollection) {
//            [weakSelf.highLightImages addObject:asset];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [pictureCollection removeAllObjects];
//            // TODO: 展示高清图片
//            [self.previewCollectionView reloadData];
//            [self.thumbCollectionView reloadData];
//        });
//    });
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        
    return collectionView == self.previewCollectionView ? self.imageModels.count : self.selectedImageModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.previewCollectionView) {
        SEPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:previewCell forIndexPath:indexPath];
        cell.model = self.assetsModels[indexPath.row];
        return cell;
    }
    else
    {
        SEPreviewThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:previewThumbCell forIndexPath:indexPath];
        cell.model = self.assetsModels[indexPath.row];
        return cell;
    }
    return nil;
}



- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.thumbCollectionView) {
        SEPreviewThumbCell *cell = (SEPreviewThumbCell *)[self.thumbCollectionView cellForItemAtIndexPath:indexPath];
        cell.layer.borderColor = UIColor.clearColor.CGColor;
        cell.layer.borderWidth = 0;
        [self.thumbCollectionView reloadData];
    }
}

//- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
//{
//
//}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return collectionView == self.thumbCollectionView;
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
    }
}

#pragma mark - event
- (void)thumbCollectionViewHandleLongPressGesture:(UILongPressGestureRecognizer *)gesture
{
    CGPoint locationCenter = [gesture locationInView:self.thumbCollectionView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSIndexPath *indexPath = [self.thumbCollectionView indexPathForItemAtPoint:locationCenter];
            SEPreviewThumbCell *cell = (SEPreviewThumbCell *)[self.thumbCollectionView cellForItemAtIndexPath:indexPath];
            self.tmpThumbCenterOffset = CGPointMake(cell.center.x - locationCenter.x, cell.center.y - locationCenter.y);
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint targetPosition = CGPointApplyAffineTransform(locationCenter, CGAffineTransformMakeTranslation(self.tmpThumbCenterOffset.x, self.tmpThumbCenterOffset.y));
            [self.thumbCollectionView updateInteractiveMovementTargetPosition:targetPosition];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.thumbCollectionView endInteractiveMovement];
            [self.thumbCollectionView cancelInteractiveMovement];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - lazyLoad
- (NSMutableArray *)assetsModels
{
    if (!_assetsModels)
    {
        _assetsModels = [[NSMutableArray alloc] init];
    }
    return _assetsModels;
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
        [collectionView registerClass:SEPreviewCell.class forCellWithReuseIdentifier:previewCell];
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
        
        [collectionView registerClass:SEPreviewThumbCell.class forCellWithReuseIdentifier:previewThumbCell];
        
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
