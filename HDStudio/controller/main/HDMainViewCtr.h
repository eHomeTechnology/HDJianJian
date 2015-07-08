//
//  HDMainViewCtr.h
//  HDStudio
//
//  Created by Hu Dennis on 14/12/11.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDListViewCtr.h"
@interface HDMainViewCtr : HDListViewCtr<UITableViewDataSource, UITableViewDelegate>

+ (void)shareWithPosition:(HDPositionInfo *)info target:(id)target;
+ (void)umshareUrl:(NSString *)url title:(NSString *)title image:(UIImage *)image target:(id)target;
@end
