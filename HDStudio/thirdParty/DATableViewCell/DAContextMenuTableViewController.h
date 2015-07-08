//
//  DAContextMenuTableViewController.h
//  DAContextMenuTableViewControllerDemo
//
//  Created by DennisHu on 7/24/13.
//  Copyright (c) 2013 DennisHu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAContextMenuCell.h"

@interface DAContextMenuTableViewController : UITableViewController <DAContextMenuCellDelegate>

@property (assign, nonatomic) BOOL shouldDisableUserInteractionWhileEditing;

@end
