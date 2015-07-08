//
//  WJFindBrokerView.h
//  JianJian
//
//  Created by liudu on 15/5/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FindBrokerViewDelegate <NSObject>

- (void)toFindBrokerViewController:(UIViewController *)viewController;

@end

@interface WJFindBrokerView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic,assign) id<FindBrokerViewDelegate>bDelegate;
- (void)clear;
@end
