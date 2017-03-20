//
//  ViewController.m
//  DPGetAndSelectedAlbumImages
//
//  Created by duanpeng on 17/3/17.
//  Copyright © 2017年 duanpeng. All rights reserved.
//

#import "ViewController.h"
#import "DPPhotoListViewController.h"
#import "DPAlbumListViewController.h"
#import "ReportedViewController.h"



@interface ViewController ()
@property (nonatomic, strong) NSMutableArray *imagesArr;



@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UITextField *TF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"标题";
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)updateImage:(id)sender {
    ReportedViewController *report = [[ReportedViewController alloc]init];
    
    [self.navigationController pushViewController:report animated:YES];
    
}



- (IBAction)buttonclicked:(UIButton *)sender {
    self.imagesArr  = [NSMutableArray array];
    DPAlbumListViewController *rootVC = [[DPAlbumListViewController alloc]init];
    __block UINavigationController *rootnavi = [[UINavigationController alloc]initWithRootViewController:rootVC];
    rootVC.navigationItem.title = @"相册";
    //  图片数量
    int selectAmount = 100;
    [rootVC getParmaterWithYouWantSelectedPhtotsAmount:selectAmount];
    DPPhotoListViewController *showVC = [[DPPhotoListViewController alloc]initWithYouWantSelectedPhtotsAmount:selectAmount];
    [rootVC.navigationController pushViewController:showVC animated:NO];
    
    [self presentViewController:rootnavi animated:YES completion:^{
        
        rootVC.photosCallback = showVC.photosCallback;
    }];
    
    
    [showVC getSelectedPhotosBack:^(NSArray *photosAraay) {
        UIImage* image = photosAraay[0];
        float W = image.size.width;
        float H = image.size.height;
        self.imageV.frame = CGRectMake(50, 200, 200, 200*H/W);
        
        self.imageV.image = image;
        
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        
        NSLog(@"--------%ld",data.length);
        NSLog(@"--------%@",image);
        NSLog(@"--------%ld",photosAraay.count);
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
