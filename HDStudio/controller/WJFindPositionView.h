//
//  WJFindPositionView.h
//  JianJian
//
//  Created by liudu on 15/5/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FindPositionViewDelegate <NSObject>

- (void)toFindPositionViewController:(UIViewController *)viewController;

@end

@interface WJFindPositionView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic,assign) id<FindPositionViewDelegate>pDelegate;
- (void)clear;
@end
