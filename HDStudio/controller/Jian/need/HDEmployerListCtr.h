//
//  HDEmployeeListCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/5/5.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HDEmployerListDelegate <NSObject>

- (void)employerListChooseEmployee:(HDEmployerInfo *)info;

@end

@interface HDEmployerListCtr : UIViewController

@property (nonatomic, assign) id <HDEmployerListDelegate> delegate;

@end
