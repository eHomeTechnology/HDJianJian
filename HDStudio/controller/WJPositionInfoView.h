//
//  WJPositionInfoView.h
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CheckEmployerDelegate <NSObject>

- (void)toCheckEmployerViewController:(UIViewController *)viewController;

@end

@interface WJPositionInfoView : UIView<UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView  *tbv;

@property (nonatomic,assign) id<CheckEmployerDelegate>eDelegate;
@property (nonatomic, strong) WJPositionInfo *info;
@end
