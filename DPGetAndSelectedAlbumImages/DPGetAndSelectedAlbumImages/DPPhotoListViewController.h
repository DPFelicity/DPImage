//
//  DPPhotoListViewController.h
//  DPGetAndSelectedAlbumImages
//
//  Created by duanpeng on 17/3/17.
//  Copyright © 2017年 duanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Photos;

@interface MyCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageview ;
@property (nonatomic, assign) BOOL isChosse;

@end

typedef void(^PickerPhotosCallback) (NSMutableArray *photosAraay);

@interface DPPhotoListViewController : UIViewController

//  将要展示的图片数据源
@property (nonatomic, strong) PHFetchResult *photoResult;

//  传递过来参数做具体设置  ------ 如果传入的数大于9，则强制取9.如果小于1，则强制为1
- (instancetype)initWithYouWantSelectedPhtotsAmount:(NSInteger )amount;

//  回调
- (void)getSelectedPhotosBack:(PickerPhotosCallback)callback;

@property (nonatomic, copy) PickerPhotosCallback photosCallback;

@end
