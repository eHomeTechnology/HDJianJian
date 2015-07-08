//
//  HDMngShopViewCtr.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDBackViewCtr.h"
#import "HDShopInfo.h"
#import "HDHttpUtility.h"

@interface HDMngShopViewCtr : HDBackViewCtr<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong) HDShopInfo   *shopInfo;
- (id)initWithInfo:(HDShopInfo *)info;
@end
