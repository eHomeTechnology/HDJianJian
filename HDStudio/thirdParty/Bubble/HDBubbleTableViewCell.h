//
//  HDBubbleTableViewCell.h
//
//  Created by DennisHu
//


#import <UIKit/UIKit.h>
#import "HDBubbleDataInternal.h"

@interface HDBubbleTableViewCell : UITableViewCell

@property (nonatomic, strong) HDBubbleDataInternal *dataInternal;
@property (nonatomic, assign) BOOL  isShowIndicatorView;

@end
