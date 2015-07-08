//
//  HDPstiShowViewCtr.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDPositionView.h"
#import "UIView+LoadFromNib.h"
#import "HDBackViewCtr.h"
#import "AFImageRequestOperation.h"
#import "HDHttpUtility.h"
#import "HDHUD.h"

@interface HDPstiShowViewCtr : HDBackViewCtr <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

- (id)initWithPositionInfo:(HDPositionInfo *)info;
- (id)initWithPositionIdentifier:(NSString *)pId;
@end
