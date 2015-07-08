//
//  HDCandidateShowCtr.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/10.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HDEvaluateInfo.h"
#import "HDTalentInfo.h"
#import "WJPayRewardCtr.h"
@interface HDCommendCell : UITableViewCell


@property (strong) IBOutlet UILabel     *lb_position;
@property (strong) IBOutlet UIImageView *imv_arrow;

@end

@interface WJCheckCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *img_commit;
@property (strong, nonatomic) IBOutlet UILabel *lb_check;

@end

@interface HDShowPartnerCell : UITableViewCell

@property (strong) IBOutlet UIImageView *imv_arrow;

@end

@interface HDProgressCell : UITableViewCell


@property (strong) IBOutlet UILabel     *lb_content;
@property (strong) IBOutlet UILabel     *lb_time;
@property (strong) IBOutlet UIView      *v_dot;
@property (strong) IBOutlet UIView      *v_lineV;
@property (strong) IBOutlet UIView      *v_lineH;

@end

@interface HDRcmdShowViewCtr : UIViewController<UIActionSheetDelegate, PayRewardDelegate, UIApplicationDelegate>

- (id)initWithRecommendInfo:(HDRecommendInfo *)info isMyRecommend:(BOOL)isMyRecommend;

@end
