//
//  SEPreviewPictureController.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/12/9.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEPreviewPictureController.h"

#import "SEPhotoLibrary-Swift.h"
#import "SEPreviewCell.h"
#import "SEPreviewThumbCell.h"

#import "SEImageToolView.h"
#import "SEImageNavigationView.h"

#import "SEPhotoModel.h"

#import "UIScrollView+Extension.h"

#import "SEPhotoManager.h"

static NSString *const previewCell = @"SEPreviewCell";
static NSString *const previewThumbCell = @"SEPreviewThumbCell";

@interface SEPreviewPictureController () <UICollectionViewDelegate, UICollectionViewDataSource, SEPhotoModelDelegate>

@property (nonatomic ,strong) NSMutableArray *assetsModels;
@property (nonatomic ,strong) UICollectionView *previewCollectionView;
@property (nonatomic ,strong) UICollectionView *thumbCollectionView;

@property (nonatomic ,assign) NSInteger currentIndex;

@property (nonatomic ,strong) NSMutableArray *imageModels;

@property (nonatomic, strong) SEImageToolView *imageToolView;
@property (nonatomic, strong) SEImageNavigationView *imageNavigationView;

@property (nonatomic, assign) CGPoint tmpThumbCenterOffset;

@property (nonatomic ,assign) NSInteger specifySubscript;

@property (nonatomic, strong) NSMutableArray *unCheckedIndexes;

@property (nonatomic , copy) ChangeCheckBlock changeCheckBlock;

@property (nonatomic , copy) ComfirmBlock comfirmBlock;
@end

@implementation SEPreviewPictureController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.hidden = YES;
    [self setUp];
}

- (void)dealloc
{
    [self.assetsModels removeAllObjects];
}

- (void)setUp
{
    [self.view addSubview:self.previewCollectionView];
    [self.view addSubview:self.imageNavigationView];
    [self.view addSubview:self.thumbCollectionView];
    [self.view addSubview:self.imageToolView];
    
    [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.specifySubscript inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)previewPictureCollection:(NSMutableArray <SEPhotoModel *>*)pictureCollection specifySubscript:(NSInteger)specifySubscript changeCheck:(ChangeCheckBlock)changeCheckBlock comfirmBlock:(ComfirmBlock)comfirmBlock
{
    self.changeCheckBlock = changeCheckBlock;
    self.comfirmBlock = comfirmBlock;
    self.specifySubscript = specifySubscript;
    self.assetsModels = pictureCollection.mutableCopy;
    [pictureCollection removeAllObjects];
    [self setNavigationView];
}

- (void)setNavigationView
{
    // TODO: 处理导航栏事件
    self.imageNavigationView.totalImageCount = self.assetsModels.count;
    SEPhotoModel *currentModel = self.assetsModels[self.specifySubscript];
    [self.imageNavigationView currentImageIndex:self.specifySubscript selectState:currentModel.isChecked];
    [self.imageNavigationView rebackEventBlock:^{
        
        if (self.changeCheckBlock)
        {
            self.changeCheckBlock(self.unCheckedIndexes);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
        } imageSelectState:^(BOOL isChecked) {
            
            SEPhotoModel *model = self.assetsModels[self.specifySubscript];
            model.isChecked = isChecked;
            if (isChecked) return;
            if ([self.unCheckedIndexes containsObject:@(self.specifySubscript)]) {
                [self.unCheckedIndexes removeObject:@(self.specifySubscript)];
            }
            else
            {
                [self.unCheckedIndexes addObject:@(self.specifySubscript)];
            }
    }];
}

#pragma mark - SEPhotoModelDelegate
- (void)photoModelSingleTapEvent
{
    self.imageNavigationView.hidden = !self.imageNavigationView.hidden;
    self.imageToolView.hidden = !self.imageToolView.hidden;
    self.thumbCollectionView.hidden = !self.thumbCollectionView.hidden;
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
        cell.delegate = self;
        return cell;
    }
    else if ([collectionView.viewName containsString:previewThumbCell]) {
        SEPreviewThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:previewThumbCell forIndexPath:indexPath];
        cell.model = self.assetsModels[indexPath.row];
        
        return cell;
    }
    return nil;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([scrollView.viewName containsString:previewCell]) {
        NSInteger currentPage = scrollView.contentOffset.x / SEScreenWidth;
        [self changeViewStateWithIndex:currentPage];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView.viewName containsString:previewThumbCell])
    {
        [self changeViewStateWithIndex:indexPath.row];
        
        [self.previewCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.specifySubscript inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)changeViewStateWithIndex:(NSInteger)index
{
    SEPhotoModel *oldModel = self.assetsModels[self.specifySubscript];
    oldModel.isSelectedPage = NO;
    SEPhotoModel *currentModel = self.assetsModels[index];
    currentModel.isSelectedPage = YES;
    self.specifySubscript = index;
    [self.thumbCollectionView reloadData];
    
    [self.thumbCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.specifySubscript inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [self.imageNavigationView currentImageIndex:self.specifySubscript selectState:currentModel.isChecked];
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView.viewName containsString:previewThumbCell];
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
        layout.minimumLineSpacing = cellSpacing;
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSize = CGSizeMake(70, 70);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        // toolBarHeight
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SEScreenHeight - 90 - 49 - SEToolBarHeight, SEScreenWidth, 90) collectionViewLayout:layout];
        collectionView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
        collectionView.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.97];
        collectionView.pagingEnabled = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.alwaysBounceHorizontal = YES;
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
        _thumbCollectionView.userInteractionEnabled = YES;
        collectionView.viewName = previewThumbCell;
        [collectionView registerClass:SEPreviewThumbCell.class forCellWithReuseIdentifier:previewThumbCell];
        
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
            //TODO: 底部工具条事件
            switch (type) {
                case SEImageToolViewCallbackTypeEnterEdit:
                {
                    __block SEPhotoModel *specifySubscriptModel = self.assetsModels[self.specifySubscript];
                    HXImageClipViewController *controller = [[HXImageClipViewController alloc] init];
                    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
                    [controller editImageWithModel:specifySubscriptModel clipImageCallback:^(SEPhotoModel * _Nonnull model) {
                        specifySubscriptModel = model;
                        [self.thumbCollectionView reloadData];
                        [self.previewCollectionView reloadData];
                    }];
                    [self.navigationController pushViewController:controller animated:YES];
//                    [self presentViewController:controller animated:YES completion:nil];
                }
                    break;
                case SEImageToolViewCallbackTypeConfirm:
                {
//                    __weak typeof(self)weakSelf = self;
                    [SEPhotoDefaultManager pickUpImages:self.assetsModels unCheckedIndexes:self.unCheckedIndexes stateBlock:^(BOOL isSuccess) {
                        if (isSuccess) {
                            self.comfirmBlock();
                            [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                        }
                    }];
                 }
                    break;
                    
                default:
                    break;
            }
        }];
        imageToolView.backgroundColor = UIColor.blackColor;
        imageToolView.frame = CGRectMake(0, SEScreenHeight - 49 - SEToolBarHeight, SEScreenWidth, 49 + SEToolBarHeight);
        _imageToolView = imageToolView;
    }
    return _imageToolView;
}

- (SEImageNavigationView *)imageNavigationView
{
    if (!_imageNavigationView)
    {
        _imageNavigationView = [[SEImageNavigationView alloc] initWithFrame:CGRectMake(0, 0, SEScreenWidth, SEStateBarH + 44)];
        _imageNavigationView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.85];
    }
    return _imageNavigationView;
}

- (NSMutableArray *)unCheckedIndexes
{
    if (!_unCheckedIndexes) {
        _unCheckedIndexes = [[NSMutableArray array] init];
    }
    return _unCheckedIndexes;
}
@end
