//
//  HDSearchOrderCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/15.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDSearchOrderCtr : UIViewController<UITableViewDataSource,UITableViewDelegate>

//清空历史记录
@property (weak, nonatomic) IBOutlet UIButton *btn_clearCache;

@end
