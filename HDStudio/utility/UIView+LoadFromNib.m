//
//  UIView+LoadFromNib.m
//  HDStudio
//
//  Created by Hu Dennis on 15/1/20.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "UIView+LoadFromNib.h"

@implementation UIView (LoadFromNib)

+ (id)loadFromNib
{
    id view = nil;
    NSString *xibName = NSStringFromClass([self class]);
    UIViewController *temporaryController = [[UIViewController alloc] initWithNibName:xibName bundle:nil];
    view = temporaryController.view;
    return view;
}
@end
