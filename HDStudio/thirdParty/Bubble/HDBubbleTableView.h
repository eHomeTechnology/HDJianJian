//
//  HDBubbleTableView.h
//
//  Created by DennisHu
//
#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"
#import "HDBubbleTableViewCell.h"
#import "HDTableView.h"

@interface HDBubbleTableView : HDTableView <UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet HDBubbleTableViewCell *bubbleCell;
}

@property (nonatomic, assign) id<HDBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic) NSTimeInterval snapInterval;

@end