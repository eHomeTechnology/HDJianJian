//
//  HDSelectDescCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WJPositionInfo.h"
@interface ExtendButton : UIButton
@property (assign) CGFloat  height;
@property (strong) WJPositionInfo *position;
@end

@interface HDSelectDescCell : UITableViewCell

@property (strong) IBOutlet NSLayoutConstraint  *lc_tvHeight;
@property (strong) IBOutlet UITextView          *tv;
@property (strong) IBOutlet ExtendButton        *btn_import;
@property (strong) IBOutlet ExtendButton        *btn_extend;

@end



@protocol HDSelectDescDelegate <NSObject>

- (void)selectDescDelegate:(WJPositionInfo *)position;

@end

@interface HDSelectDescCtr : UIViewController

@property (nonatomic, assign) id <HDSelectDescDelegate> descDelegate;

- (id)initWithPositions:(NSArray *)ar;

@end
