//
//  DPAlbumListViewController.m
//  DPGetAndSelectedAlbumImages
//
//  Created by duanpeng on 17/3/17.
//  Copyright © 2017年 duanpeng. All rights reserved.
//

#import "DPAlbumListViewController.h"
#import "DPPhotoListViewController.h"
#import <Photos/Photos.h>
@implementation MyTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.cellImageview = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 90, 90)];
        self.cellImageview.layer.masksToBounds = YES;
        self.cellImageview.layer.cornerRadius = 1;
        self.cellImageview.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.cellImageview];
        
        self.cellTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(105, 5, 150, 90)];
        self.cellTitleLabel.font = [UIFont systemFontOfSize:15.0];
        [self addSubview:self.cellTitleLabel];
    }
    return self;
}


@end

@interface DPAlbumListViewController ()<UITableViewDataSource,UITableViewDelegate,PHPhotoLibraryChangeObserver>

/** 数据源 */
@property (nonatomic, strong) NSMutableArray *datesourceArray;
/** tableview */
@property (nonatomic, strong) UITableView *tableview;
/** 名字数组 */
@property (nonatomic, strong) NSArray *namesArray;

/** 选择照片张数以及照片质量 */
@property (nonatomic, assign) NSInteger selectedAmount;
@property (nonatomic, assign) NSInteger photoRatio;

@end

@implementation DPAlbumListViewController

//  初始化
-(void)getParmaterWithYouWantSelectedPhtotsAmount:(NSInteger)amount{
    self.selectedAmount = amount;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //  设置名字
    //   self.namesArray = @[@"所有照片",@"最近添加",@"屏幕快照",@"个人收藏"];
    
    //  获取所有相册大概信息，包括所有图片，智能相册，个人收藏等
    self.datesourceArray = [self getAllAlbumInformation];
    
    //  获取到信息后，在tableview中展示出来
    self.tableview = [self createAtableViewForAllAlbums];
    
    //  右上角添加取消按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction)];
}



- (void)dismissAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark-  获取所有相册
- (NSMutableArray *)getAllAlbumInformation{
    
    NSMutableArray *allSmartAlbums = [NSMutableArray array];
    //  所有图片
    PHFetchOptions *allOptions = [[PHFetchOptions alloc]init];
    //  时间排序
    allOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allOptions];
    [allSmartAlbums addObject:allPhotos];
    
    //    PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    
    PHFetchResult *smartAlbums2 = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
    PHFetchResult *smartAlbums3 = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
    
    //  个人自定义相册
    PHFetchResult *userDeterminAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    
    NSMutableArray *allAlbums = [NSMutableArray arrayWithObjects:allSmartAlbums,smartAlbums,smartAlbums2,smartAlbums3,userDeterminAlbums, nil];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    return allAlbums;
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    //  获取所有相册大概信息，包括所有图片，智能相册，个人收藏等
    self.datesourceArray = [self getAllAlbumInformation];
    [self.tableview reloadData];
}

#pragma mark- 添加tableview，并实现其协议方法
- (UITableView *)createAtableViewForAllAlbums{
    UITableView *tableview = [[UITableView alloc]initWithFrame:self.view.bounds];
    [tableview registerClass:[MyTableViewCell class] forCellReuseIdentifier:@"myCell"];
    tableview.dataSource = self;
    tableview.delegate = self;
    [self.view addSubview:tableview];
    return tableview;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        NSArray *arr = self.datesourceArray[section];
        return arr.count;
    }else{
        PHFetchResult *result = self.datesourceArray[section];
        return result.count;
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.datesourceArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyTableViewCell *cell = [[MyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myCell"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        NSArray *array = self.datesourceArray[indexPath.section];
        PHFetchResult *result = array[indexPath.row];
        cell.cellTitleLabel.text = [NSString stringWithFormat:@"所有照片(%ld)",result.count];
        //  显示图片
        if (result.count > 0) {
            
            PHAsset *singleAsset = result.firstObject;
            [[PHImageManager defaultManager] requestImageForAsset:singleAsset targetSize:CGSizeZero contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                cell.cellImageview.image = result;
            }];
            NSLog(@"%ld",result.count);
        }else{
            cell.cellImageview.image = [UIImage imageNamed:@"iw_none"];
        }
        
    }else{
        
        PHFetchResult *fetchResult = self.datesourceArray[indexPath.section];
        PHAssetCollection *collection = (PHAssetCollection *)fetchResult[indexPath.row];
        PHFetchResult *singleResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        cell.cellTitleLabel.text = [NSString stringWithFormat:@"%@ (%ld)",collection.localizedTitle,(long )singleResult.count];
        
        if (singleResult.count > 0) {
            PHAsset *singleAsset = singleResult.lastObject;
            [[PHImageManager defaultManager] requestImageForAsset:singleAsset targetSize:CGSizeZero contentMode:PHImageContentModeAspectFit options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                cell.cellImageview.image = result;
            }];
        }else{
            cell.cellImageview.image = [UIImage imageNamed:@"iw_none"];
        }
        
    }
    
    return  cell;
}

//  点击跳转展示
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    __block DPPhotoListViewController *showVC = [[DPPhotoListViewController alloc]initWithYouWantSelectedPhtotsAmount:self.selectedAmount];
    if (indexPath.section == 0) {
        //  全部照片
        NSArray *array = self.datesourceArray[indexPath.section];
        showVC.photoResult = array[indexPath.row];
    }else{
        
        PHFetchResult *fetchResult = self.datesourceArray[indexPath.section];
        PHAssetCollection *collection = (PHAssetCollection *)fetchResult[indexPath.row];
        PHFetchResult *sigle = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
        showVC.photoResult = sigle;
    }
    [showVC getSelectedPhotosBack:^(NSMutableArray *photosAraay) {
        self.photosCallback(photosAraay);
    }];
    
    if (showVC.photoResult.count > 0) {
        [self.navigationController pushViewController:showVC animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
