//
//  HDMyPositionCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMyPositionCell.h"

@implementation HDMyPositionCell

- (void)awakeFromNib {
//    self.btn_edit.buttonStyle       = CELLButtonStyleEdit;
//    self.btn_preview.buttonStyle    = CELLButtonStylePreview;
//    self.btn_share.buttonStyle      = CELLButtonStyleShare;
//    self.btn_unshelve.buttonStyle   = CELLButtonStyleUnshelve;
//    self.btn_recommend.buttonStyle  = CELLButtonStyleRecommend;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end


@implementation HDOffPositionCell

- (void)awakeFromNib {
//    self.btn_reshelve.buttonStyle   = CELLButtonStyleReshelve;
//    self.btn_preview.buttonStyle    = CELLButtonStylePreview;
//    self.btn_recommend.buttonStyle  = CELLButtonStyleRecommend;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end