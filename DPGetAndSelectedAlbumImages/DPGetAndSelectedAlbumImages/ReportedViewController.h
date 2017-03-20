//
//  ReportedViewController.h
//  IHKApp
//
//  Created by duanpeng on 17/3/7.
//  Copyright © 2017年 www.ihk.cn. All rights reserved.
//



#import <UIKit/UIKit.h>

typedef void (^DeleteImageCallBack)(NSIndexPath *index);
@interface ReportCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)UIButton *seleceButton;
@property (nonatomic,strong)UIImageView *imageV;


//@property(nonatomic,copy) void (^deleteImageCallBack)(UIImage *image);
@property (nonatomic,copy)DeleteImageCallBack deleteImage;

@property (nonatomic,strong)NSString *imageId;

@property (nonatomic,assign)NSIndexPath *index;

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic,strong)UILabel *topLabel;
@property (nonatomic,strong)UILabel *pregressLabel;

@property (nonatomic,strong)UIView *backView;


@end

@interface ReportedViewController : UIViewController



@end
