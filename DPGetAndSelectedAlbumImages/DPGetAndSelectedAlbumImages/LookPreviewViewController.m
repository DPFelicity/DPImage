//
//  LookPreviewViewController.m
//  GetAndSelectedAlbumImages
//
//  Created by duanpeng on 17/2/14.
//  Copyright © 2017年 Bruce. All rights reserved.
//

#import "LookPreviewViewController.h"
#import <Photos/Photos.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface LookPreviewViewController ()<UIScrollViewDelegate>
@property (nonatomic,strong)UIScrollView *scrollV;

@property (nonatomic,assign)BOOL isHidden;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)NSMutableArray *selecterArray;


@end

@implementation LookPreviewViewController

- (NSMutableArray *)selecterArray{
    if (!_selecterArray) {
        _selecterArray = [NSMutableArray array];
    }
    return _selecterArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.isHidden = YES;
    if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets=NO;
    }
    
    
    [self creatrScrollView];
    [self creagtBtn];
    
    
    // Do any additional setup after loading the view.
}
- (void)creagtBtn
{
    UIButton *returnBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 24, 24)];
    UIImageView* imageView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"back_arrows_icon"]];
    imageView.frame = CGRectMake(-15, 0, 24, 24);
    [returnBtn addSubview:imageView];
    returnBtn.backgroundColor=[UIColor clearColor];
    [returnBtn addTarget:self action:@selector(backNavi:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:returnBtn];
    
    self.rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(-15, 0, 24, 24)];
    
    [self.rightBtn setImage:[UIImage imageNamed:@"iw_selected"] forState:UIControlStateSelected];
    [self.rightBtn setImage:[UIImage imageNamed:@"iw_unselected"] forState:UIControlStateNormal];
    self.rightBtn.selected = YES;
    self.rightBtn.backgroundColor=[UIColor clearColor];
    [self.rightBtn addTarget:self action:@selector(changeChoose:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightBtn];
    
}
#pragma mark 返回
- (void)backNavi:(UIButton *)button{
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)changeChoose:(UIButton *)button{
    int set = self.scrollV.contentOffset.x/kScreenWidth;
    if (button.selected == YES) {
        button.selected = NO;
        
        self.selecterArray[set] = @"0";
        
    }else{
        button.selected = YES;
        
        self.selecterArray[set] = @"1";
    }
    
}

#pragma mark  创建滚动视图
- (void)creatrScrollView{
    self.scrollV = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    for (int i = 0 ; i <self.imageArray.count ; i++) {
        [self.selecterArray addObject:@"1"];
        
        UIScrollView *scrollImage = [[UIScrollView alloc]initWithFrame:CGRectMake( i * kScreenWidth, 0, kScreenWidth, kScreenHeight)];
        UIImageView *imageV = [[UIImageView alloc]init];
        
        
        PHAsset *asset = self.imageArray[i];
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
                                                   targetSize:CGSizeZero
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:nil
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    
            float height = result.size.height;
            float weidth = result.size.width;
            imageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*height/weidth);
            imageV.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
            imageV.image = result;
        
        
    }];
      
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:PHImageManagerMaximumSize
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:imageRequestOption
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                    BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                                                    if (downloadFinined) {
                                                        float height = result.size.height;
                                                        float weidth = result.size.width;
                                                        
                                                        imageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*height/weidth);
                                                        
                                                        imageV.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
                                                        imageV.image = result;
                                                    }
                                                    
                                                    
                                                }];
        
        imageV.userInteractionEnabled = YES;
        
        scrollImage.minimumZoomScale = 1.0;
        scrollImage.maximumZoomScale = 2.0;
        scrollImage.bouncesZoom = YES;
        scrollImage.delegate = self;
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGesture:)];
        doubleTapGesture.numberOfTapsRequired = 2; //点击次数
        doubleTapGesture.numberOfTouchesRequired = 1; //点击手指数
        scrollImage.tag = i+1;//tag值不能为0
        [scrollImage addGestureRecognizer:doubleTapGesture];
        
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGesture:)];
        tapGesture.numberOfTapsRequired = 1; //点击次数
        tapGesture.numberOfTouchesRequired = 1; //点击手指数
        [scrollImage addGestureRecognizer:tapGesture];
        
        //只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
        [scrollImage addSubview:imageV];
        [self.scrollV addSubview:scrollImage];
        
        
    }
    
    self.scrollV.contentSize = CGSizeMake(self.imageArray.count*kScreenWidth, 0);
    
    self.scrollV.pagingEnabled = YES;
    
    self.scrollV.showsHorizontalScrollIndicator = NO ;
    
    self.scrollV.showsVerticalScrollIndicator = NO ;
    
    self.scrollV.contentOffset = CGPointMake(0, 0);
    
    self.scrollV.delegate = self;
    
    [self.view addSubview:self.scrollV];
    
    
}

#pragma mark  点击手势处理


-(void)touchGesture:(UITapGestureRecognizer *)sender{
    if (sender.numberOfTapsRequired == 2) {
        
//        点击位置放大
        UIScrollView *scrllV =(UIScrollView *) [self.view viewWithTag:sender.view.tag ];
        CGFloat zoomScale = scrllV.zoomScale;
        zoomScale = (zoomScale == 1.0) ? 2.0 : 1.0;
        CGRect zoomRect;
        zoomRect.size.height = scrllV.frame.size.height / zoomScale;
        zoomRect.size.width  = scrllV.frame.size.width  / zoomScale;
        zoomRect.origin.x = [sender locationInView:sender.view].x - (zoomRect.size.width/2.0);
        zoomRect.origin.y = [sender locationInView:sender.view].y - (zoomRect.size.height/2.0);
        [scrllV zoomToRect:zoomRect animated:YES];
        
        
    }else{
        
        if (self.isHidden == YES) {
            [UIView animateWithDuration:1 animations:^{
                [self.navigationController setNavigationBarHidden:YES animated:YES];
            }];
            self.isHidden = NO;
        }
        else {
            UIScrollView *scrllV =(UIScrollView *)[self.view viewWithTag:sender.view.tag];
            
            [UIView animateWithDuration:1 animations:^{
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                if (scrllV.zoomScale == 1) {
                    
                }
            }];
            self.isHidden = YES;
        }

        
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{

    

}


#pragma mark 结束减速
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int set = self.scrollV.contentOffset.x/kScreenWidth;
    if (scrollView == self.scrollV) {
        
        NSString *str = self.selecterArray[set];
        if ([str isEqualToString:@"1"]) {
            self.rightBtn.selected = YES;
        }else{
           self.rightBtn.selected = NO;
        }
        
        if (set == 0) {
            
            UIScrollView *scrllV =(UIScrollView *) [self.scrollV viewWithTag:set+1+1 ];
            scrllV.zoomScale = 1.0;
            
        }else if (set == self.selecterArray.count-1){
            
            UIScrollView *scrllV =(UIScrollView *) [self.scrollV viewWithTag:set];
            scrllV.zoomScale = 1.0;
            
        }else{
            
            UIScrollView *scrllV2 =(UIScrollView *) [self.scrollV viewWithTag:set+1+1 ];
            scrllV2.zoomScale = 1.0;
            UIScrollView *scrllV =(UIScrollView *) [self.scrollV viewWithTag:set ];
            scrllV.zoomScale = 1.0;
            
        }
        
        
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([scrollView isEqual:self.scrollV]) {
        
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    //    父子视图访问
    if (scrollView != self.scrollV) {
        UIImageView *imageV = [scrollView subviews][0];
        return imageV;
    }
    return nil;
}

//已经完成缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale; {
    
    
}


-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView != self.scrollV) {
        UIImageView *imageV = [scrollView subviews][0];
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        
        imageV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
        
    }
        
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor blackColor]] forBarMetrics:UIBarMetricsDefault];
    
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController.navigationBar setBackgroundImage:[self imageWithColor:[UIColor whiteColor]] forBarMetrics:UIBarMetricsDefault];
    
}


/**
 color转化为图片

 @param color 颜色
 @return 返回UIImage
 */
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect frame = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(frame.size);
    //    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, frame);
    CGContextSaveGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
