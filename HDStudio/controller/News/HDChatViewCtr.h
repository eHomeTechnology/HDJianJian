//
//  HDChatViewCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDNewsInfo.h"
#import "UIBubbleTableViewDataSource.h"
#import "HDJJUtility.h"
#import "HDPositionListView.h"
#import "HDMyTalentCtr.h"

@class HDBubbleTableView;

@interface HDChatViewCtr : UIViewController <HDBubbleTableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate, UIScrollViewDelegate, HDPositionListDelegate, HDMyTalentDelegate, UIAlertViewDelegate>{

    IBOutlet HDBubbleTableView *btv;
}
- (id)initWithHuman:(HDHumanInfo *)human;
- (id)initWithJianJianConversation:(HDSubscriberInfo *)info;
- (id)initWithChatterId:(NSString *)chatterId;
- (void)sendPosition:(WJPositionInfo *)position;
@end
