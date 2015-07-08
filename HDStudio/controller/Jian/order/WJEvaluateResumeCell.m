//
//  WJEvaluateResumeCell.m
//  JianJian
//
//  Created by Ri on 15/4/30.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJEvaluateResumeCell.h"

@implementation WJEvaluateResumeCell

+ (WJEvaluateResumeCell *)getCell{
    WJEvaluateResumeCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJEvaluateResumeCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[WJEvaluateResumeCell class]]) {
            cell = (WJEvaluateResumeCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)awakeFromNib {
   [self.v_management StarSize:CGSizeMake(20, 20) space:5 numberOfStar:5];
    self.v_management.delegate = self;
    self.v_management.score = 0;
    
    [self.v_professional StarSize:CGSizeMake(20, 20) space:5 numberOfStar:5];
    self.v_professional.delegate = self;
    self.v_professional.score = 0;
    
    [self.v_workAttitude StarSize:CGSizeMake(20, 20) space:5 numberOfStar:5];
    self.v_workAttitude.delegate = self;
    self.v_workAttitude.score = 0;
    
    [self.v_communication StarSize:CGSizeMake(20, 20) space:5 numberOfStar:5];
    self.v_communication.delegate = self;
    self.v_communication.score = 0;
    
    [self.v_professionalQuality StarSize:CGSizeMake(20, 20) space:5 numberOfStar:5];
    self.v_professionalQuality.delegate = self;
    self.v_professionalQuality.score = 0;
}

//选择星星的分数
- (void)getEvaluationScore:(NSInteger)score starsView:(UIView *)view{
    StarsView * starView = (StarsView *)view;
    if (starView == self.v_management) {
        NSLog(@"%ld",(long)score);
        self.str_management = [NSString stringWithFormat:@"%ld",(long)score];
    }else if (starView == self.v_professional){
        NSLog(@"%ld",(long)score);
        self.str_professional = [NSString stringWithFormat:@"%ld",(long)score];
    }else if (starView == self.v_professionalQuality){
        NSLog(@"%ld",(long)score);
        self.str_professionalQuality = [NSString stringWithFormat:@"%ld",(long)score];
    }else if (starView == self.v_communication){
        NSLog(@"%ld",(long)score);
        self.str_communication = [NSString stringWithFormat:@"%ld",(long)score];
    }else if (starView == self.v_workAttitude){
        NSLog(@"%ld",(long)score);
         self.str_workAttitude = [NSString stringWithFormat:@"%ld",(long)score];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end



@implementation HDDescribeCell

+ (HDDescribeCell *)getCell{
    HDDescribeCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"WJEvaluateResumeCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDDescribeCell class]]) {
            cell = (HDDescribeCell *)obj;
            break;
        }
    }
    return cell;
}


@end
