//
//  HDBlogPositionView.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/22.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDTableView.h"
@class HDBlogPositionView;
@protocol HDBlogPositionViewDelegate <NSObject>

- (void)blogPositionView:(HDBlogPositionView *)positionView;
@end

@interface HDBlogPositionView : UIView

@property (nonatomic, strong) HDBlogInfo    *blogInfo;
@property (strong) IBOutlet HDTableView     *tbv;
@property (strong) IBOutlet UIButton        *btn_extend;
@property (strong) IBOutlet NSLayoutConstraint *lc_heightExtend;
@property (assign) id<HDBlogPositionViewDelegate> delegate;


+ (CGFloat)heightOfBlogPositionView:(HDBlogInfo *)blog;

@end
