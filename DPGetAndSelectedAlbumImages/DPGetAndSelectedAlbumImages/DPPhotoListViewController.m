//
//  DPPhotoListViewController.m
//  DPGetAndSelectedAlbumImages
//
//  Created by duanpeng on 17/3/17.
//  Copyright © 2017年 duanpeng. All rights reserved.
//

#import "DPPhotoListViewController.h"
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_WIDTH  [UIScreen mainScreen].bounds.size.width

#define ImageHeight ([UIScreen mainScreen].bounds.size.width-25)/4
#import "LookPreviewViewController.h"
@import Photos;

@implementation MyCollectionCell{
    UIButton *_seleceButton;
}

static CGSize AssetGridThumbnailSize;

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageview = [[UIImageView alloc]initWithFrame:self.bounds];
        self.imageview.layer.masksToBounds = YES;
        [self.imageview setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:self.imageview];
        
        //  在右上角添加选择键
        _seleceButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width * 3 / 4.0 - 3,
                                                                  3,
                                                                  self.frame.size.width / 4.0,
                                                                  self.frame.size.width / 4.0)];
        [_seleceButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
        _seleceButton.layer.masksToBounds = YES;
        _seleceButton.layer.cornerRadius = _seleceButton.frame.size.width / 2.0;
        [_seleceButton setBackgroundImage:[UIImage imageNamed:@"iw_unselected"] forState:UIControlStateNormal];
        [_seleceButton setBackgroundImage:[UIImage imageNamed:@"iw_selected"] forState:UIControlStateSelected];
        _seleceButton.userInteractionEnabled = NO;
        [self.contentView addSubview:_seleceButton];
        
    }
    return self;
}

-(void)setIsChosse:(BOOL)isChosse{
    _isChosse = isChosse;
    _seleceButton.selected = isChosse;
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    
}

@end


@interface DPPhotoListViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,PHPhotoLibraryChangeObserver>

//  全部照片数据源，
@property (nonatomic, strong) PHFetchResult *allPhotosResult;
//  缓存图片的方法
@property (nonatomic, strong) PHCachingImageManager *cacheManager;
//  collectionView，用来展示图片
@property (nonatomic, strong) UICollectionView *collectionview;
//  图片数组
@property (nonatomic, strong) NSMutableArray *imageArray;
//  显示图片数量的视图

@property (nonatomic, strong) UIView *showAndSureBtnView;
//  已选择的图片数组
@property (nonatomic, strong) NSMutableArray *selectedImagesArray;
//  显示已选图片数量的label
@property (nonatomic, strong) UILabel *amountLabel;
//  最多能选几张照片
@property (nonatomic, assign) NSInteger maxAmount;

@end

@implementation DPPhotoListViewController{
    NSInteger NaviHeight;
}

//  初始化
- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc]initWithCapacity:0];
    }
    return _imageArray;
}

-(NSMutableArray *)selectedImagesArray{
    if (!_selectedImagesArray) {
        _selectedImagesArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _selectedImagesArray;
}

-(instancetype)initWithYouWantSelectedPhtotsAmount:(NSInteger)amount{
    self = [DPPhotoListViewController new];
    if (self) {
        NaviHeight = 0;
        //  如果传入的数组大于9，则强制取9.如果小于1，则强制为1
        self.maxAmount = amount;
        if (amount > 9) {
            self.maxAmount = 9;
        }
        if (amount < 1) {
            self.maxAmount = 1;
        }
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"所有照片";
    
    self.imageArray = [NSMutableArray arrayWithCapacity:0];
    
    //  初始化
    self.cacheManager = [[PHCachingImageManager alloc]init];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    //  获取全部图片，并按时间排序
    if (self.photoResult.count == 0) {
        PHFetchOptions *allOptions = [[PHFetchOptions alloc]init];
        allOptions.sortDescriptors =  @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        self.allPhotosResult = [PHAsset fetchAssetsWithOptions:allOptions];
    }else{
        self.allPhotosResult = self.photoResult;
    }
    
    
    NSInteger count = self.allPhotosResult.count;
    for (int i= 0; i < count; i++) {
        [self.imageArray addObject:[NSNumber numberWithInt:0]];
    }
    //  创建一个collectionView
    self.collectionview = [self createCollectionView];
    
    //  创建一个显示选择数量的视图
    self.showAndSureBtnView = [self selectedAmountAndSureButtonView];
    
    //  右上角添加取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction)];
}


- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //      获取全部图片，并按时间排序
        if (self.photoResult.count == 0) {
            PHFetchOptions *allOptions = [[PHFetchOptions alloc]init];
            allOptions.sortDescriptors =  @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            self.allPhotosResult = [PHAsset fetchAssetsWithOptions:allOptions];
        }else{
            self.allPhotosResult = self.photoResult;
        }
        for (int i= 0; i < self.allPhotosResult.count; i++) {
            [self.imageArray addObject:[NSNumber numberWithInt:0]];
        }
        [self.collectionview reloadData];
        
    });
}


- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

//  返回
- (void)dismissAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark- 选择图片的数量
- (UIView *)selectedAmountAndSureButtonView{
    UIView *amountView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44)];
    amountView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:amountView];
    
    
    //  添加确定按钮
    UIButton *sendButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 4, 80, 36)];
    [sendButton addTarget:self action:@selector(selectedOverAndCallback) forControlEvents:UIControlEventTouchUpInside];
    sendButton.backgroundColor = [UIColor orangeColor];
    sendButton.layer.masksToBounds = YES;
    sendButton.layer.cornerRadius = 4;
    [amountView addSubview:sendButton];
    //  添加显示数量的label
    self.amountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, sendButton.frame.size.width, sendButton.frame.size.height)];
    self.amountLabel.font = [UIFont boldSystemFontOfSize:16];
    self.amountLabel.textColor = [UIColor whiteColor];
    self.amountLabel.textAlignment = NSTextAlignmentCenter;
    [sendButton addSubview:self.amountLabel];
    
    UIButton *lookButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 4, 40, 36)];
    [lookButton addTarget:self action:@selector(lookBigPicture) forControlEvents:UIControlEventTouchUpInside];
    [lookButton setTitle:@"预览" forState:UIControlStateNormal];
    [lookButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [amountView addSubview:lookButton];
    
    
    return amountView;
}

#pragma mark-  预览图片
- (void)lookBigPicture{
    LookPreviewViewController *look = [[LookPreviewViewController alloc]init];
    look.imageArray = self.selectedImagesArray;
    
    [self.navigationController pushViewController:look animated:YES];
    
}

#pragma mark-  点击确定按钮，但会选择的图片
- (void)selectedOverAndCallback{
    
    __block NSMutableArray *imagesArray = [NSMutableArray array];
    __block __weak DPPhotoListViewController *weakself = self;
    //  转化图片
    
    for (PHAsset *asset in self.selectedImagesArray) {
        __block UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc]init];
        indicator.center = CGPointMake(SCREEN_WIDTH / 2.0f, SCREEN_HEIGHT / 2.0f);
        [self.view addSubview:indicator];
        [indicator startAnimating];
        
        //        PHImageManagerMaximumSize   AssetGridThumbnailSize
        
        PHImageRequestOptions *imageRequestOption = [[PHImageRequestOptions alloc] init];
        imageRequestOption.synchronous = NO;//异步加载，默认为NO
        imageRequestOption.networkAccessAllowed = YES;
        //图片下载进度
        imageRequestOption.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%f",progress);
            });
        };
        
        imageRequestOption.resizeMode = PHImageRequestOptionsResizeModeFast;
        imageRequestOption.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:imageRequestOption
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                    
                                                    if (downloadFinined) {
                                                        [imagesArray addObject:result];
                                                    }
                                                    if (imagesArray.count == self.selectedImagesArray.count) {
                                                        weakself.photosCallback(imagesArray);
                                                        
                                                        
                                                        
                                                        [weakself.view addSubview:indicator];
                                                        
                                                        [weakself dismissViewControllerAnimated:YES completion:^{
                                                            [indicator stopAnimating];
                                                        }];
                                                    }
                                                    
                                                }];
        
    }
}





/**
 回调方法
 
 @param callback 回调函数block
 */
-(void)getSelectedPhotosBack:(PickerPhotosCallback)callback{
    self.photosCallback = callback;
}


//视图旋转方向发生改变时会自动调用

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.collectionview removeFromSuperview];
    if (SCREEN_HEIGHT > SCREEN_WIDTH) {
        NaviHeight = 64;
    }else{
        NaviHeight = 40;
    }
    
    //  创建一个collectionView
    self.collectionview = [self createCollectionView];
    self.showAndSureBtnView = nil;
    //  创建一个显示选择数量的视图
    self.showAndSureBtnView = [self selectedAmountAndSureButtonView];
}


#pragma mark- 创建一个collectionView
- (UICollectionView *)createCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.itemSize = CGSizeMake(ImageHeight, ImageHeight);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    
    UICollectionView *collectionview = [[UICollectionView alloc]initWithFrame:CGRectMake(0, NaviHeight, SCREEN_WIDTH, SCREEN_HEIGHT - NaviHeight) collectionViewLayout:flow];
    collectionview.backgroundColor = [UIColor whiteColor];
    [collectionview registerClass:[MyCollectionCell class] forCellWithReuseIdentifier:@"myCell"];
    collectionview.dataSource = self;
    collectionview.delegate = self;
    [self.view addSubview:collectionview];
    
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize cellSize = flow.itemSize;
    AssetGridThumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);
    
    return collectionview;
    
    
}

#pragma mark- collctionview delegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.allPhotosResult.count;
    
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"myCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[MyCollectionCell alloc]init];
    }
    PHAsset *asset = self.allPhotosResult[indexPath.row];
    [self.cacheManager requestImageForAsset:asset
                                 targetSize:CGSizeZero
                                contentMode:PHImageContentModeAspectFit
                                    options:nil
                              resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                  cell.imageview.image = result;
                                  cell.isChosse = [(NSNumber *)[self.imageArray objectAtIndex:indexPath.row] boolValue];
                              }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MyCollectionCell *cell = (id)[collectionView cellForItemAtIndexPath:indexPath];
    
    //  如果只选择一张
    if (self.maxAmount == 1) {
        [self.selectedImagesArray addObject:self.allPhotosResult[indexPath.row]];
        [self selectedOverAndCallback];
    }else{
        //  多张选择
        //  判断是否已经选择足够
        if (self.selectedImagesArray.count < self.maxAmount) {
            //  还没选够，
            cell.isChosse = !cell.isChosse;
            if (cell.isChosse) {
                [self.selectedImagesArray addObject:self.allPhotosResult[indexPath.row]];
            }
            if (!cell.isChosse && self.selectedImagesArray.count > 0) {
                [self.selectedImagesArray removeObject:self.allPhotosResult[indexPath.row]];
            }
            
            if (self.selectedImagesArray.count > 0) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.showAndSureBtnView.frame = CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44);
                    
                    //  collectionview大小随着改变
                    self.collectionview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 44);
                }];
            }else{
                [UIView animateWithDuration:0.3 animations:^{
                    self.showAndSureBtnView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44);
                    
                    //  collectionview大小随着改变
                    self.collectionview.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
                }];
            }
            
            [self amountLabelAnimation];
            
            self.imageArray[indexPath.row] = [NSNumber numberWithBool:cell.isChosse];
            
        }else{      //  选够了，不能走，此时能取消，不能添加选择  [NSString stringWithFormat:@"最多只能选择%ld张",self.maxAmount]
            if (!cell.isChosse) {
                UIAlertController *alertC = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"最多只能选择%ld张",(long )self.maxAmount]
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
                
                [alertC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    //  啥也不做就行了
                }]];
                [self presentViewController:alertC animated:YES completion:^{
                    
                }];
            }else{
                cell.isChosse = NO;
                //  此时点击的是选中的，减少就好了
                [self.selectedImagesArray removeObject:self.allPhotosResult[indexPath.row]];
                if (self.selectedImagesArray.count == 0) {
                    [UIView animateWithDuration:0.3 animations:^{
                        self.showAndSureBtnView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 44);
                    }];
                }
                [self amountLabelAnimation];
                
                self.imageArray[indexPath.row] = [NSNumber numberWithBool:cell.isChosse];
            }
            
        }
        
    }
    
}

//   数字变化的动态展示
- (void)amountLabelAnimation{
    self.amountLabel.text = [NSString stringWithFormat:@"发送(%ld)",(long)self.selectedImagesArray.count];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
