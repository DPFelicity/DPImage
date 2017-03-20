//
//  ReportedViewController.m
//  IHKApp
//
//  Created by duanpeng on 17/3/7.
//  Copyright © 2017年 www.ihk.cn. All rights reserved.
//

#import "ReportedViewController.h"
#import "DPImagePickerVC.h"
#import <AssetsLibrary/AssetsLibrary.h>

#import "UIViewController+BackButton.h"

@implementation ReportCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.imageV = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageV];
        
        
        
        self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.backView.backgroundColor = [UIColor grayColor];
        self.backView.alpha = 0.7;
        self.backView.hidden = YES;
        [self addSubview:self.backView];
        
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        self.progressLayer = [CAShapeLayer layer];
        [path moveToPoint:CGPointMake(frame.size.width/2 , frame.size.height)];
        [path addLineToPoint:CGPointMake(frame.size.width/2 ,0)];
        self.progressLayer.path = path.CGPath;
        self.progressLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.strokeColor = [UIColor colorWithRed:231.0/255.0 green:56.0/255.0 blue:32.0/255.0 alpha:1.0].CGColor;
        self.progressLayer.lineWidth = frame.size.width;
        self.progressLayer.strokeStart = 0.0;
        self.progressLayer.strokeEnd = 1.0;
        self.progressLayer.hidden = YES;
        [self.layer addSublayer:self.progressLayer];
        
        
        //  在右上角添加删除按钮
        self.seleceButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-20, 0, 20, 20)];
        [self.seleceButton setBackgroundImage:[UIImage imageNamed:@"delete_image"] forState:UIControlStateNormal];
        [self.seleceButton addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.seleceButton];
        
        
        self.topLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height/2 - 20, frame.size.width, 20)];
        self.topLabel.text = @"图片上传中";
        self.topLabel.backgroundColor = [UIColor clearColor];
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        self.topLabel.hidden = YES;
        self.topLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.topLabel];
        
        self.pregressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width, 20)];
        self.pregressLabel.text = @"0%";
        self.pregressLabel.backgroundColor = [UIColor clearColor];
        self.pregressLabel.textAlignment = NSTextAlignmentCenter;
        self.pregressLabel.hidden = YES;
        self.pregressLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.pregressLabel];
        
    }
    return self;
}
- (void)delete{
    
    self.deleteImage(self.index);
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end


@interface ReportedViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DPImagePickerDelegate,UIScrollViewDelegate>


@property (nonatomic,strong)UICollectionView *collectionView;

@property (nonatomic,strong)UIButton *rightButton;

@property (nonatomic,strong)NSMutableArray *addDataArray;//新添加的图片

@property (nonatomic,strong)UIScrollView *scrollV;
@property (nonatomic,strong)UIView *backView;

@end

@implementation ReportedViewController{
    CGRect rectInSuperview;
    UIImageView *scrollImageV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"上传到访客户资料";
    [self getUI];
    [self getCollectionView];
    
    
    
    // Do any additional setup after loading the view from its nib.
}


//自带返回按钮方法获取
- (BOOL)navigationShouldPopOnBackButton{
    [[[UIAlertView alloc] initWithTitle:@"提示" message:@"确定返回上一界面?"
                               delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
    return NO;
}
// UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSMutableArray *)addDataArray{
    if (!_addDataArray) {
        _addDataArray = [NSMutableArray array];
    }
    return _addDataArray;
}


- (void)getUI{
    self.rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 30)];
    [self.rightButton setTitle:@"确认" forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.rightButton addTarget:self action:@selector(updateImage:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.hidden = YES;
    UIBarButtonItem *bookmarksButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightButton];
    self.navigationItem.rightBarButtonItem = bookmarksButtonItem;
    
    
    
}


/**
 判断是否是纯数字

 @param string 要判断的字符串
 @return 返回结果
 */
- (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}



#pragma mark -- 提交图片到服务器
- (void)updateImage:(UIButton *)sender {
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:@"确定提交？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        for (int i = 0; i < self.addDataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i + 1 inSection:0];
            ReportCollectionViewCell *cell = (ReportCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            cell.topLabel.hidden = NO;
            cell.pregressLabel.hidden = NO;
            cell.progressLayer.hidden = NO;
            cell.backView.hidden = NO;
        }
        
        
        
       [self updateImageWithPicData:self.addDataArray[0] deleteIds:@"" pictureIndex:0 guestConfirmedNo:@"55555555"];
    }];
    [alertVc addAction:confirm];
    
    [self presentViewController:alertVc animated:YES completion:nil];
 
}
//有图片上传
- (void)updateImageWithPicData:(NSData *)picData deleteIds:(NSString *)deleteIds pictureIndex:(NSInteger)index guestConfirmedNo:(NSString *)guestConfirmedNo{
    NSArray *picDataArray = [NSArray arrayWithObject:picData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index + 1 inSection:0];
    ReportCollectionViewCell *cell = (ReportCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    
    [self linkReach_VisitUploadPicsWithLinkId:@"1270843"
                                          picCount:@"1"
                                           arrPicData:picDataArray
                                         deleteIds:deleteIds
                                  guestConfirmedNo:guestConfirmedNo
                                          progress:^(float currentProgress) {
                                              dispatch_async(dispatch_get_main_queue(),^{
                                                  cell.progressLayer.strokeEnd = 1 - currentProgress;
                                                  cell.pregressLabel.text = [NSString stringWithFormat:@"%.2f%%",currentProgress*100];
                                              });
                                              
   } success:^(NSDictionary *result) {
       NSLog(@"++result:%@",result);
       if([ [NSString stringWithFormat:@"%@",[result valueForKey:@"result"]]  isEqualToString:@"10000"]) {
           
           cell.topLabel.hidden = YES;
           cell.pregressLabel.hidden = YES;
           cell.progressLayer.hidden = YES;
           cell.backView.hidden = YES;
           
           if (index + 1 == self.addDataArray.count) {
 
               
            }else{
                
               
            [self updateImageWithPicData:self.addDataArray[index+1] deleteIds:@"" pictureIndex:index+1 guestConfirmedNo:guestConfirmedNo];
               
           }
       }else{
           
           
       }
       
   } fail:^(NSError *error) {
       NSLog(@"++error:%@",error);
       

   }];
        
}


- (void)linkReach_VisitUploadPicsWithLinkId:(NSString *)linkId
                                   picCount:(NSString *)picCount
                                 arrPicData:(NSArray *)arrPicData
                                  deleteIds:(NSString *)deleteIds
                           guestConfirmedNo:(NSString *)guestConfirmedNo
                                   progress:(void (^)(float currentProgress))progress
                                    success:(void (^)(NSDictionary *result))success
                                       fail:(void (^)(NSError *error))fail {
    
    NSMutableDictionary *paras = [[NSMutableDictionary alloc]init];
    [paras setValue:[NSString stringWithFormat:@"%@",linkId] forKey:@"linkId"];
    [paras setValue:[NSString stringWithFormat:@"%@",picCount] forKey:@"picCount"];
    [paras setValue:[NSString stringWithFormat:@"%@",deleteIds] forKey:@"ids"];
    [paras setValue:[NSString stringWithFormat:@"%@",guestConfirmedNo] forKey:@"guestConfirmedNo"];
    
    [self postDataWithImageArray:@"https://appwebtest.ihk.cn/ihkapp_web/wap/applinkreach/visitUploadPics.htm" paras:paras imageDataArray:arrPicData imageName:@"imageFileList" progress:^(float currentProgress) {
        progress(currentProgress);
    } success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } fail:^(NSError *error) {
        if (fail) {
            fail(error);
        }
    }];
}

//https://appwebtest.ihk.cn/ihkapp_web/wap/applinkreach/visitUploadPics.htm
//https://appwebtest.ihk.cn/ihkapp_web/wap/applinkreach/visitUploadPics.htm?picCount=1&linkId=1270843&guestConfirmedNo=55555555&appVersion=2.0.4&ids=&usersId=173&userPushToken=iosdevice-F9B3A11A-0938-4177-9004-58DF647BA380&appType=IOS&ukey=98b0eef82360a52b0cc8ff2cf3d74dc4

-(void)postDataWithImageArray:(NSString *)serverUrl
                        paras:(NSMutableDictionary *)paras
               imageDataArray:(NSArray *)imageDataArray
                    imageName:(NSString *)imageName
                     progress:(void (^)(float currentProgress))progress
                      success:(void (^)(NSDictionary *result))success
                         fail:(void (^)(NSError *error))fail {
    
    [paras setValue:@"98b0eef82360a52b0cc8ff2cf3d74dc4" forKey:@"ukey"];
    [paras setValue:@"IOS" forKey:@"appType"];
    NSDictionary *infoDic = [[NSBundle mainBundle]infoDictionary];
    [paras setValue:[infoDic objectForKey:@"CFBundleShortVersionString"] forKey:@"appVersion"];
    [paras setValue:@"iosdevice-F9B3A11A-0938-4177-9004-58DF647BA380" forKey:@"userPushToken"];
    [paras setValue:@"173" forKey:@"usersId"];
    
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    session.responseSerializer = [AFHTTPResponseSerializer serializer];
    session.requestSerializer.timeoutInterval = 300;//单位是秒
    
    
    [session POST:serverUrl parameters:paras constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        if (imageDataArray) {
            for (int i = 0; i < imageDataArray.count; i++) {
                
                NSData *data = (NSData *)imageDataArray[i];
                if (data) {
                    [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"%@%d", imageName, i+1] fileName:[NSString stringWithFormat:@"%@%d.jpg", imageName, i+1] mimeType:@"image/jpeg"];
                }
            }
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress((float)1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        success(result);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
    }];
}


- (void)finishUpload{
    [self.navigationController popViewControllerAnimated:YES];
    
}


- (void)getCollectionView{
    
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    CGFloat imageH = (kScreenWidth - 25)/4;
    flow.itemSize = CGSizeMake(imageH, imageH);
    flow.minimumLineSpacing = 5;
    flow.minimumInteritemSpacing = 5;
    flow.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:flow];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.collectionView registerClass:[ReportCollectionViewCell class] forCellWithReuseIdentifier:@"ReportCollectionViewCell"];
    flow.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [self.view addSubview:self.collectionView];
    
    
    
}

#pragma mark -- UICollectionViewDelegate and DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.addDataArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ReportCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ReportCollectionViewCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.imageV.image = [UIImage imageNamed:@"check_photo_camera"];
        cell.seleceButton.hidden = YES;
        cell.progressLayer.hidden = YES;
    }else{
        cell.seleceButton.hidden = NO;
        cell.index = indexPath;
        
        cell.imageV.image = [UIImage imageWithData:self.addDataArray[indexPath.row - 1]];
            
        //删除按钮回调
        __weak typeof(self) weakSelf = self;
        cell.deleteImage = ^(NSIndexPath *index){

            
            [weakSelf.addDataArray removeObjectAtIndex:indexPath.row - 1];

            [weakSelf.collectionView reloadData];
            weakSelf.rightButton.hidden = NO;
            
        };
        
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ReportCollectionViewCell *cell = (ReportCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (indexPath.row == 0) {
        [self chooseImage];
        
    }else{
        
        //        cell在屏幕上的位置
        rectInSuperview = [self.collectionView convertRect:cell.frame toView:[self.collectionView superview]];
        
        [self getScrollView:[UIImage imageWithData:self.addDataArray[indexPath.row - 1 ]]];
        
        
    }
}

- (void)getScrollView:(UIImage *)image{
    
    self.scrollV = [[UIScrollView alloc]init];
    self.scrollV.backgroundColor = [UIColor blackColor];
    self.scrollV.frame = CGRectMake(rectInSuperview.origin.x, rectInSuperview.origin.y, rectInSuperview.size.width, rectInSuperview.size.height);
    self.scrollV.alpha = 0.5;
    
    scrollImageV = [[UIImageView alloc]init];
    scrollImageV.image = image;
    scrollImageV.userInteractionEnabled = YES;
    scrollImageV.frame = CGRectMake(0, 0, (kScreenWidth - 25)/4, (kScreenWidth - 25)/4);
    
    self.scrollV.minimumZoomScale = 1.0;
    self.scrollV.maximumZoomScale = 2.0;
    self.scrollV.delegate = self;
    
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGesture:)];
    doubleTapGesture.numberOfTapsRequired = 2; //点击次数
    doubleTapGesture.numberOfTouchesRequired = 1; //点击手指数
    [self.scrollV addGestureRecognizer:doubleTapGesture];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchGesture:)];
    tapGesture.numberOfTapsRequired = 1; //点击次数
    tapGesture.numberOfTouchesRequired = 1; //点击手指数
    [self.scrollV addGestureRecognizer:tapGesture];
    
    //只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
    [self.scrollV addSubview:scrollImageV];
    
    [[[UIApplication sharedApplication] delegate] window].backgroundColor = [UIColor blackColor];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self.scrollV];
    CGFloat W = image.size.width;
    CGFloat H = image.size.height;
    
    if (W > H ) {
        if (H > kScreenHeight) {
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                self.scrollV.alpha = 1.0;
                scrollImageV.frame = CGRectMake(0, 0, kScreenHeight*W/H, kScreenHeight);
                scrollImageV.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
            }];
        }else{
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                self.scrollV.alpha = 1.0;
                scrollImageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*H/W);
                scrollImageV.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
            }];
        }
        
        
        
    }else{
        if (W > kScreenWidth) {
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                self.scrollV.alpha = 1.0;
                scrollImageV.frame = CGRectMake(0, 0, kScreenWidth, kScreenWidth*H/W);
                scrollImageV.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
            }];
        }else{
            [UIView animateWithDuration:0.5 animations:^{
                self.scrollV.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
                self.scrollV.alpha = 1.0;
                scrollImageV.frame = CGRectMake(0, 0, kScreenHeight*W/H, kScreenHeight);
                scrollImageV.center = CGPointMake(kScreenWidth/2, kScreenHeight/2);
            }];
        }
        
    }
    
}


- (void)touchGesture:(UITapGestureRecognizer *)sender{
    
    if (sender.numberOfTapsRequired == 2) {
        
        UIScrollView *scrllV =(UIScrollView *)sender.view;
        CGFloat zoomScale = scrllV.zoomScale;
        zoomScale = (zoomScale == 1.0) ? 2.0 : 1.0;
        CGRect zoomRect;
        zoomRect.size.height = scrllV.frame.size.height / zoomScale;
        zoomRect.size.width  = scrllV.frame.size.width  / zoomScale;
        zoomRect.origin.x = [sender locationInView:sender.view].x - (zoomRect.size.width/2.0);
        zoomRect.origin.y = [sender locationInView:sender.view].y - (zoomRect.size.height/2.0);
        [scrllV zoomToRect:zoomRect animated:YES];
        
        
    }else{
        
        [self removeScrollView];
        
    }
}

- (void)removeScrollView{
    if (self.scrollV) {
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollV.frame = CGRectMake(rectInSuperview.origin.x, rectInSuperview.origin.y, rectInSuperview.size.width, rectInSuperview.size.height);
            scrollImageV.frame = CGRectMake(0, 0, (kScreenWidth - 25)/4, (kScreenWidth - 25)/4);
            self.scrollV.alpha = 0.5;
        }];
        [[[UIApplication sharedApplication] delegate] window].backgroundColor = [UIColor clearColor];
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [self.scrollV removeFromSuperview];
            
        });
        
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    UIImageView *imageV = [scrollView subviews][0];
    return imageV;
    
}


-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    UIImageView *imageV = [scrollView subviews][0];
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    imageV.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    
    if (self.scrollV.zoomScale <= 0.7) {
        [self removeScrollView];
    }
    
}


#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    NSData *data = UIImagePNGRepresentation(image);
    [self.addDataArray addObject:data];
    [self.collectionView reloadData];
    self.rightButton.hidden = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
    [assetsLibrary writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)image.imageOrientation completionBlock:nil];
}

- (void)chooseImage{
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
#if TARGET_IPHONE_SIMULATOR
        //模拟器
        UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"提醒" message:@"请真机测试！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alerView show];
#elif TARGET_OS_IPHONE
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:kUIColor_Main,NSForegroundColorAttributeName, nil];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
#endif
        
        
        
    }];
    UIAlertAction *confirmTwo = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        DPImagePickerVC *vc = [[DPImagePickerVC alloc]init];
        vc.delegate = self;
        vc.imageMaxCount = 1000;
        [self.navigationController pushViewController:vc animated:YES];
        
        
    }];
    [alertVc addAction:cancle];
    [alertVc addAction:confirm];
    [alertVc addAction:confirmTwo];
    [self presentViewController:alertVc animated:YES completion:nil];
    
    
}

#pragma mark  DPImagePickerDelegate

- (void)getImageArray:(NSMutableArray *)arrayImage urlStringArray:(NSMutableArray *)arrayUrl{
    if (arrayImage) {
        for (int i = 0; i < arrayImage.count; i ++) {
            NSData *data = UIImagePNGRepresentation(arrayImage[i]);
            [self.addDataArray addObject:data];
            
        }
        
        [self.collectionView reloadData];
        self.rightButton.hidden = NO;
    }
    
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
