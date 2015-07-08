//
//  WJFindTalentView.h
//  JianJian
//
//  Created by liudu on 15/5/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FindTalentViewDelegate <NSObject>

- (void)toFindTalentViewController:(UIViewController *)viewController;

@end

@interface WJFindTalentView : UIView<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic,assign) id<FindTalentViewDelegate>tDelegate;
- (void)clear;
@end
