//
//  DPAlbumListViewController.h
//  DPGetAndSelectedAlbumImages
//
//  Created by duanpeng on 17/3/17.
//  Copyright © 2017年 duanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MyTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImageView *cellImageview;
@property (nonatomic, strong) UILabel *cellTitleLabel;

@end

typedef void(^PickerPhotosCallback) (NSMutableArray *photosAraay);
@interface DPAlbumListViewController : UIViewController

//  传递过来参数做具体设置  ------ 如果传入的数大于9，则强制取9.如果小于1，则强制为1
- (void)getParmaterWithYouWantSelectedPhtotsAmount:(NSInteger )amount;

@property (nonatomic, copy) PickerPhotosCallback photosCallback;

@end
