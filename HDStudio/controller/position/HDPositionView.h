//
//  HDPositionView.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDPositionPhotoCell.h"
#import "HDPositionInfo.h"
#import "HDTableView.h"

#define MaxPositionTitle        20
#define MaxPositionDescribe     100
#define MaxEnterpriceDescribe   100
#define MaxPhotos               4


@interface HDPositionView : UIView <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>{

    IBOutlet UIView     *v_footer;
    UIActionSheet       *as_photo;
}

@property (strong) HDPositionInfo               *positionInfo;
@property (strong) IBOutlet HDTableView         *tbv;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;
@property (strong) IBOutlet UIButton            *btn_position;
@property (strong) HDPositionTitleCell          *titleCell;
@property (strong) HDPositionDescribeCell       *positionDescribeCell;
@property (strong) HDPositionEnterpriceCell     *enterpriceCell;
@property (strong) HDPositionPhotoCell          *photoCell;

- (void)keyboardDidShow:(NSNotification *)noti;
- (void)keyboardWillHidden:(NSNotification *)noti;
@end
