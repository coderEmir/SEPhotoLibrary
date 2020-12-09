//
//  SEAlbumViewController.m
//  SEPhotoLibrary
//
//  Created by wenchang on 2020/11/13.
//  Copyright © 2020 seeEmil. All rights reserved.
//

#import "SEAlbumViewController.h"

#import "SECameraViewController.h"

#import "SEEditPictureViewController.h"

#import "SEAlbumCollectionViewCell.h"

#import "SEPhotoManager.h"
#import "SEPhotoModel.h"
#import "SEAlbumModel.h"

#import "SEAlbumView.h"

@interface SEAlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic ,strong) UIButton *showAlbumButton;

// 取消按钮
@property (nonatomic, strong) UIButton *cancelButton;
// 确定按钮
@property (nonatomic, strong) UIButton *confirmButton;
// 相册数组
@property (nonatomic ,strong) NSMutableArray <SEAlbumModel *>*assetCollectionList;

// 当前相册
@property (nonatomic, strong) SEAlbumModel *albumModel;

// 相册列表
@property (nonatomic, strong) UICollectionView *albumCollectionView;

@property (nonatomic ,assign) BOOL isShowCamera;

@property (nonatomic ,assign) BOOL isFromTop;

@property (nonatomic ,assign) BOOL isShowFilter;

@end

@implementation SEAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp
{
    [self setNavigationItems];
    [self getThumbnailImages];
    [self handleChooseResult];
}

- (void)showCamera:(BOOL)isShowCamera showFilter:(BOOL)isShowFilter pictureScrollsFromTheTop:(BOOL)isFromTop
{
    self.isShowCamera = isShowCamera;
    self.isFromTop = isFromTop;
    self.isShowFilter = isShowFilter;
}

- (void)setNavigationItems
{
    UIBarButtonItem *backItem = [UIBarButtonItem.alloc initWithCustomView:self.cancelButton];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIView *titleView = [UIView.alloc initWithFrame:CGRectMake(0, 0, 180, 45)];
    [titleView addSubview:self.showAlbumButton];
    self.navigationItem.titleView = titleView;
    
    UIBarButtonItem *confirmItem = [UIBarButtonItem.alloc initWithCustomView:self.confirmButton];
    self.navigationItem.rightBarButtonItem = confirmItem;
}

- (void)handleChooseResult
{
    __weak typeof(self) weakSelf = self;
    SEPhotoDefaultManager.choiceCountChangedBlock = ^(NSInteger choiceCount) {
        weakSelf.confirmButton.enabled = choiceCount != 0;
        if (choiceCount == 0) {
            [weakSelf.confirmButton setTitle:@"预览" forState:UIControlStateNormal];
            [weakSelf.confirmButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        } else {
            [weakSelf.confirmButton setTitle:[NSString stringWithFormat:@"预览%ld/%ld", (long)choiceCount, (long)SEPhotoDefaultManager.maxImageCount] forState:UIControlStateNormal];
            [weakSelf.confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    };
}

-(void)setAlbumModel:(SEAlbumModel *)albumModel {
    _albumModel = albumModel;
    
    [self.showAlbumButton setTitle:albumModel.collectionTitle forState:UIControlStateNormal];
    [self.albumCollectionView reloadData];

    if (self.isFromTop) return;
    [self collectionViewScrollToBottom];
}

- (void)collectionViewScrollToBottom
{
    if (_albumModel.assets.count == 0) return;
    
    CGFloat itemH = ScreenWidth / 3.f;
    NSInteger lastRow = _albumModel.assets.count % 3 == 0 ? 0 : 1;
    CGPoint bottomOffset = CGPointMake(0, (_albumModel.assets.count / 3 + lastRow) * itemH);
    [self.albumCollectionView setContentOffset:bottomOffset animated:NO];
}

// get all custom album.
- (void)getThumbnailImages
{
    self.assetCollectionList = NSMutableArray.array;
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{

        [weakSelf addAlbumToListWithSubtype:PHAssetCollectionSubtypeSmartAlbumFavorites];
        // get camera roll
        [weakSelf addAlbumToListWithSubtype:PHAssetCollectionSubtypeAlbumSyncedAlbum];
        // get person collection album
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.albumModel = weakSelf.assetCollectionList.firstObject;
        });
    });
}

- (void)addAlbumToListWithSubtype:(PHAssetCollectionSubtype)subtype
{
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:subtype options:nil];
    for (PHAssetCollection *collection in collections)
    {
        if ([collection.localizedTitle containsString:@"最近删除"]
            || [collection.localizedTitle containsString:@"实况照片"]
            || [collection.localizedTitle containsString:@"连拍快照"]
            || [collection.localizedTitle containsString:@"视频"]
            ) {
            continue;
        }
        SEAlbumModel *model = SEAlbumModel.alloc.init;
        model.collection = collection;
        if (![model.collectionNumber isEqualToString:@"0"])
        {
            [self.assetCollectionList insertObject:model atIndex:0];
        }
    }
}

#pragma mark - UICollectionViewDataSource, UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albumModel.assets.count + 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SEAlbumCollectionViewCell *cell = [SEAlbumCollectionViewCell dequeueReusableCellWithCollectionView:collectionView forIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        [cell loadCamera];
    }
    else
    {
        cell.row = indexPath.row;
        cell.asset = self.albumModel.assets[indexPath.row - 1];
        [cell loadImage:indexPath];
        cell.isSelect = [self.albumModel.selectRows containsObject:@(indexPath.row)];
        
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        cell.cellSelectedBlock = ^(PHAsset *asset) {
            BOOL isReloadCollectionView = [weakSelf isReloadCollectionViewAtIndexPath:indexPath];;
            if (isReloadCollectionView) {
                [weakSelf.albumCollectionView reloadData];
            } else {
                weakCell.isSelect = [weakSelf.albumModel.selectRows containsObject:@(indexPath.row)];
            }
        };
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        SECameraViewController *controller = [[SECameraViewController alloc] init];
        __weak typeof(self) weakSelf = self;
        [controller savePhotoSuccessBlock:^{
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [weakSelf updatePhotoCollection];
                dispatch_async(dispatch_get_main_queue(), ^{
                    SEPhotoDefaultManager.choiceCount++;
                    [weakSelf.albumCollectionView reloadData];
                });
            });
        }];
        controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
    
    // TODO: 进入图片预览
    // 多图预览
    if ([self.albumModel.selectRows containsObject:@(indexPath.row)])
    {
        [self previewPictureWithSpecifySubscript:indexPath.row];
        return;
    }
    // 单图预览
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeNone;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.networkAccessAllowed = YES;
    PHAsset *asset = self.albumModel.assets[indexPath.row - 1];
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        UIImage * previewPicture = [UIImage imageWithData:imageData];
        if (previewPicture)
        {
            SEEditPictureViewController *controller = [[SEEditPictureViewController alloc] init];
            controller.modalPresentationStyle = UIModalPresentationOverFullScreen;
            
            if (![self.albumModel.selectRows containsObject:@(indexPath.row)]) {
                [controller previewPicture:previewPicture];
            }
            
            [self presentViewController:controller animated:YES completion:nil];
        }
    }];
}

- (void)saveImage:(UIImage *)UIImage
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[PHPhotoLibrary sharedPhotoLibrary]performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:UIImage];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                NSLog(@"%@",@"保存失败");
            } else {
                [self updatePhotoCollection];
            }
        }];
    });
}


- (void)updatePhotoCollection
{
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    NSMutableDictionary *collectionDic = NSMutableDictionary.dictionary;

    for (PHAssetCollection *collection in collections)
    {
        if ([collection.localizedTitle containsString:@"最近添加"]
            || [collection.localizedTitle containsString:@"最近项目"]
            ) {
            collectionDic[collection.localizedTitle] = collection;
        }
        if (collectionDic.allKeys.count == 2) break;
    }
    
    __block NSInteger updateMaxCollectionNum = collectionDic.allKeys.count;
    [self.assetCollectionList enumerateObjectsUsingBlock:^(SEAlbumModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([collectionDic.allKeys containsObject:model.collectionTitle]) {
            updateMaxCollectionNum --;
            model.collection = collectionDic[model.collectionTitle];
            [model.selectRows addObject:@(model.collectionNumber.intValue)];
        }
        *stop = updateMaxCollectionNum == 0;
    }];
}

- (BOOL)isReloadCollectionViewAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.albumModel.selectRows containsObject:@(indexPath.row)])
    {
        [self.albumModel.selectRows removeObject:@(indexPath.row)];
        SEPhotoDefaultManager.choiceCount--;
        return SEPhotoDefaultManager.choiceCount == SEPhotoDefaultManager.maxImageCount - 1;
    }
    else
    {
        if (SEPhotoDefaultManager.maxImageCount == SEPhotoDefaultManager.choiceCount) return NO;
        [self.albumModel.selectRows addObject:@(indexPath.row)];
        SEPhotoDefaultManager.choiceCount++;
        return SEPhotoDefaultManager.choiceCount == SEPhotoDefaultManager.maxImageCount;
    }
}

#pragma mark - event
- (void)backAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
    self.albumModel = nil;
    _albumModel = nil;
}

- (void)previewAction:(UIButton *)btn
{
    [self previewPictureWithSpecifySubscript:0];
}

- (void)previewPictureWithSpecifySubscript:(NSInteger)index
{
    if (SEPhotoDefaultManager.choiceCount == 0) return;
    __block NSMutableArray<UIImage *> *photoList = NSMutableArray.array;
    __block NSMutableDictionary *photoMdic = NSMutableDictionary.dictionary;
    
    NSInteger photoIndex = 0;
    __block NSInteger rebackCount = 0;
    __block NSInteger specifySubscript = 0;
    
    for (SEAlbumModel *albumModel in self.assetCollectionList) {
        for (NSNumber *row in albumModel.selectRows) {
             SEPhotoModel *photoModel = SEPhotoModel.alloc.init;

            __weak typeof(photoModel) weakPhotoModel = photoModel;
            
            BOOL isSelectPhotoIndex = self.albumModel == albumModel && row.integerValue == index;
            photoMdic[@(photoIndex)] = [NSData data];
            photoModel.photoActionBlock = ^{
                
                rebackCount ++;
                
                photoMdic[@(weakPhotoModel.photoIndex)] = UIImagePNGRepresentation(weakPhotoModel.highDefinitionImage);
                
                if (isSelectPhotoIndex) specifySubscript = photoIndex;
                
                if (rebackCount == SEPhotoDefaultManager.choiceCount) {
                    for (NSInteger index = 0; index < photoMdic.allKeys.count; index ++) {
                        [photoList addObject:[UIImage imageWithData:photoMdic[@(index)]]];
                    }
                    [photoMdic removeAllObjects];
                    photoMdic = nil;
                    
                    SEEditPictureViewController *controller = [[SEEditPictureViewController alloc] init];
                    controller.modalPresentationStyle = UIModalPresentationOverFullScreen;

                    [controller previewPictureCollection:photoList specifySubscript:specifySubscript];
                    [self presentViewController:controller animated:YES completion:nil];
                }
            };
            photoModel.asset = albumModel.assets[row.integerValue - 1];
            photoModel.photoIndex = photoIndex;
            photoIndex ++;
        }
    }
}

- (void)showAlbum:(UIButton *)button
{
    button.selected = !button.selected;
    
    [SEAlbumView showAlbumView:self.assetCollectionList navigationBarMaxY:CGRectGetMaxY(self.navigationController.navigationBar.frame) complete:^(SEAlbumModel *albumModel) {
        if (albumModel) {
            self.albumModel = albumModel;
        }
        button.selected = !button.selected;
    }];
}

#pragma mark - lazyLoad

-(UICollectionView *)albumCollectionView {
    if (!_albumCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 5.f;
        layout.minimumInteritemSpacing = 5.f;
        layout.itemSize = CGSizeMake((ScreenWidth - 20.f) / 3.f, (ScreenWidth - 20.f) / 3.f);
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        _albumCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) collectionViewLayout:layout];
        _albumCollectionView.delegate = self;
        _albumCollectionView.dataSource = self;
        _albumCollectionView.backgroundColor = [UIColor whiteColor];
        _albumCollectionView.scrollEnabled = YES;
        _albumCollectionView.alwaysBounceVertical = YES;
        
        [_albumCollectionView registerClass:SEAlbumCollectionViewCell.class forCellWithReuseIdentifier:albumCollectionViewCell];
        
        [self.view addSubview:_albumCollectionView];
    }
    
    return _albumCollectionView;
}

-(UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, 50, 50);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancelButton;
}

-(UIButton *)showAlbumButton {
    if (!_showAlbumButton) {
        _showAlbumButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _showAlbumButton.frame = CGRectMake(0, 0, 180, 45);
        [_showAlbumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_showAlbumButton setImage:[UIImage imageNamed:@"photo_select_down"] forState:UIControlStateNormal];
        [_showAlbumButton setImage:[UIImage imageNamed:@"photo_select_up"] forState:UIControlStateSelected];
        _showAlbumButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _showAlbumButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 10.f);
        [_showAlbumButton addTarget:self action:@selector(showAlbum:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _showAlbumButton;
}

-(UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton addTarget:self action:@selector(previewAction:) forControlEvents:UIControlEventTouchUpInside];
        _confirmButton.enabled = NO;
        _confirmButton.frame = CGRectMake(0, 0, 80, 45);
        _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _confirmButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_confirmButton setTitle:@"预览" forState:UIControlStateNormal];
        [_confirmButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
    
    return _confirmButton;
}

@end
