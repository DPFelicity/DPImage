//
//  MyCollectionViewCell.m
//  GetPhotos
//
//  Created by duanpeng on 16/10/21.
//  Copyright © 2016年 duanpeng. All rights reserved.
//

#import "MyCollectionViewCell.h"

@implementation MyCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor redColor];
        self.imageV = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:self.imageV];
        
        //  在右上角添加选择键
        _seleceButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width-20, 5, 15, 15)];
        [_seleceButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.1]];
        _seleceButton.layer.masksToBounds = YES;
        _seleceButton.layer.cornerRadius = _seleceButton.frame.size.width / 2.0;
        [_seleceButton setBackgroundImage:[UIImage imageNamed:@"iw_unselectedd"] forState:UIControlStateNormal];
        [_seleceButton setBackgroundImage:[UIImage imageNamed:@"iw_selected"] forState:UIControlStateSelected];
        _seleceButton.userInteractionEnabled = NO;
        [self addSubview:_seleceButton];
        
        
    }
    return self;
}

- (void)setChoose:(NSString *)choose{
    _choose = choose;
    if ([choose isEqualToString:@"1"]) {
        _seleceButton.selected = YES;
    }else if ([choose isEqualToString:@"0"]){
        _seleceButton.selected = NO;
    }
}


//- (void)setSelected:(BOOL)selected  {
//    [super setSelected:selected];
//    // Configure the view for the selected state
//    
//    if (selected) {
//        [self.seletView setImage:[UIImage imageNamed:@"list_tick_round"]];
//    } else {
//        [self.seletView setImage:[UIImage imageNamed:@"list_no_tick_round"]];
//    }
//    
//}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
