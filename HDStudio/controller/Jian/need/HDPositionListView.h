//
//  HDPositionListView.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/17.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HDPositionListDelegate <NSObject>
- (void)positionListDidSelectPosition:(WJPositionInfo *)info isOnShelve:(BOOL)isOn;
@end

@interface HDPositionListView : UIView

@property (strong) NSMutableArray *mar_value;
@property (strong) AFHTTPRequestOperation *op;
@property (assign) BOOL isOnPositionNeedRefresh;
@property (assign) BOOL isOffPositionNeedRefresh;

- (id)initWithArray:(NSArray *)ar isOnPosition:(BOOL)isOn owner:(id)object;
- (void)refreshView;

@property (nonatomic, assign) id <HDPositionListDelegate> plDelegate;

@end
