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

#import "UIScrollView+Extension.h"

#define SEStateBarH [UIApplication sharedApplication].statusBarFrame.size.height
#define SEScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define SEScreenHeight [[UIScreen mainScreen] bounds].size.height
#define SEToolBarHeight SEStateBarH > 20 ? 34 : 0
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

@property (nonatomic ,assign) NSInteger specifySubscript;

@end

@implementation SEPreviewPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setUp];
}

- (void)setUp
{
    [self.view addSubview:self.previewCollectionView];
    [self.view addSubview:self.imageNavigationView];
    [self.view addSubview:self.imageToolView];
}

- (void)previewPicture:(SEPhotoModel *)imageModel
{
    [self.assetsModels addObject:imageModel];
    [self.previewCollectionView reloadData];
}

- (void)previewPictureCollection:(NSMutableArray <SEPhotoModel *>*)pictureCollection specifySubscript:(NSInteger)specifySubscript
{
    self.specifySubscript = specifySubscript;
    self.assetsModels = pictureCollection.mutableCopy;
    [pictureCollection removeAllObjects];
    pictureCollection = nil;
    
    [self.previewCollectionView reloadData];
    [self setNavigationView];
    
    if (self.assetsModels.count > 1) {
        
        [self.view addSubview:self.thumbCollectionView];
        [self.thumbCollectionView reloadData];
    }
}

- (void)setNavigationView
{
    self.imageNavigationView.totalImageCount = self.assetsModels.count;
    [self.imageNavigationView currentImageIndex:self.specifySubscript selectState:YES];
    [self.imageNavigationView rebackEventBlock:^{
            [self dismissViewControllerAnimated:YES completion:nil];
        } imageSelectState:^(BOOL isSelected) {
            [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UICollectionViewDelegate UICollectionViewDataSource
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
        
    return self.assetsModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView.viewName containsString:previewCell]) {
        SEPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:previewCell forIndexPath:indexPath];
        cell.model = self.assetsModels[indexPath.row];
        return cell;
    }
    else if ([collectionView.viewName containsString:previewThumbCell]) {
        SEPreviewThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:previewThumbCell forIndexPath:indexPath];
        cell.model = self.assetsModels[indexPath.row];
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView.viewName containsString:previewThumbCell]) {
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
        if (_currentIndex >= self.imageModels.count)
        {
            _currentIndex = self.imageModels.count - 1;
        }
        else if (_currentIndex < 0)
        {
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
            [self.thumbCollectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
//            CGPoint targetPosition = CGPointApplyAffineTransform(locationCenter, CGAffineTransformMakeTranslation(self.tmpThumbCenterOffset.x, self.tmpThumbCenterOffset.y));
//            [self.thumbCollectionView updateInteractiveMovementTargetPosition:targetPosition];
        }
            break;
        case UIGestureRecognizerStateEnded:
            [self.thumbCollectionView endInteractiveMovement];
            break;
            
        default:
            [self.thumbCollectionView cancelInteractiveMovement];
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
        layout.itemSize = self.view.bounds.size;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        collectionView.backgroundColor = UIColor.clearColor;
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.viewName = previewCell;
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
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // toolBarHeight
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SEScreenHeight - 90, SEScreenWidth, 90) collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.97];
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.alwaysBounceHorizontal = YES;
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.viewName = previewThumbCell;
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
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }];
        imageToolView.frame = CGRectMake(0, SEScreenHeight - SEToolBarHeight, SEScreenWidth, SEToolBarHeight + 49);
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
