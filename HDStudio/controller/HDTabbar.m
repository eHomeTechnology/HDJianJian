//
//  HDTabbar.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDTabbar.h"
#import "HDPlusViewCtr.h"
#import "HDNavigationController.h"
#import "HDLoginViewCtr.h"

@implementation HDTabbar

- (IBAction)doSelected:(UIButton *)sender{
    
    [self setSelected:sender.tag];
}
- (IBAction)selectedPlus{
    HDPlusViewCtr *ctr = [[HDPlusViewCtr alloc] init];
    ctr.view.frame = CGRectMake(0, 0, HDDeviceSize.width, HDDeviceSize.height);
    [kWindow addSubview:ctr.view];
    [self.tabCtr addChildViewController:ctr];
}

- (void)setSelected:(NSInteger)index{
    if ((index == 2 || index == 3) && ![HDGlobalInfo instance].hasLogined) {
        [self setLoginController];
        return;
    }
    [self.tabCtr setSelectedIndex:index];
    [self.btn_JCircle_icon  setSelected:NO];
    [self.btn_JCircle_txt   setSelected:NO];
    [self.btn_discover_icon setSelected:NO];
    [self.btn_discover_txt  setSelected:NO];
    [self.btn_chat_icon     setSelected:NO];
    [self.btn_chat_txt      setSelected:NO];
    [self.btn_me_icon       setSelected:NO];
    [self.btn_me_txt        setSelected:NO];
    switch (index) {
        case 0:{
            [self.btn_JCircle_icon  setSelected:YES];
            [self.btn_JCircle_txt   setSelected:YES];
            break;
        }
        case 1:{
            [self.btn_discover_txt  setSelected:YES];
            [self.btn_discover_icon setSelected:YES];
            break;
        }
        case 2:{
            [self.btn_chat_icon     setSelected:YES];
            [self.btn_chat_txt      setSelected:YES];
            break;
        }
        case 3:{
            [self.btn_me_icon       setSelected:YES];
            [self.btn_me_txt        setSelected:YES];
            break;
        }
        default:
            break;
    }
}

- (void)setLoginController{
    HDNavigationController *nav = [[HDNavigationController alloc] initWithRootViewController:[HDLoginViewCtr new]];
    [self.tabCtr presentViewController:nav animated:YES completion:nil];
}
@end
