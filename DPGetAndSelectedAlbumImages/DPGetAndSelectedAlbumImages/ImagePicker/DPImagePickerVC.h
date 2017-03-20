//
//  DPImagePickerVC.h
//  DPImagePicker
//
//  Created by duanpeng on 16/10/24.
//  Copyright © 2016年 duanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DPImagePickerVC;

@protocol DPImagePickerDelegate <NSObject>

@optional
//传出的拍摄的图片和图片的URL，类型：NSString
- (void)getCutImage:(UIImage *)image urlString:(NSString *)string;


//传出的是UIimage数组和图片的URL，类型：NSString
- (void)getImageArray:(NSMutableArray *)arrayImage urlStringArray:(NSMutableArray *)arrayUrl;



@end

@interface DPImagePickerVC : UIViewController

@property (nonatomic, weak)id<DPImagePickerDelegate>delegate;

//选择图片上限
@property (nonatomic,assign)NSInteger imageMaxCount;




@end
