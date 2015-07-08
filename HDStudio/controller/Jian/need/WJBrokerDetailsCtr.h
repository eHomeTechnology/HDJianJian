//
//  WJBrokerDetailsCtr.h
//  JianJian
//
//  Created by liudu on 15/5/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDBrokerIntroCell : UITableViewCell

@property (strong) IBOutlet UILabel *lb_intro;
+ (HDBrokerIntroCell *)getCell;
@end

@interface WJBrokerDetailsCtr : UIViewController

- (id)initWithInfo:(WJBrokerInfo *)info;
- (id)initWithInfoID:(NSString *)infoId;
@end
