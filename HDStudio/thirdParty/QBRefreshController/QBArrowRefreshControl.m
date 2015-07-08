//
//  QBArrowRefreshControl.m
//  QBRefreshControlDemo
//
//  Created by Katsuma Tanaka on 2012/11/22.
//  Copyright (c) 2012年 Katsuma Tanaka. All rights reserved.
//

#import "QBArrowRefreshControl.h"

@interface QBArrowRefreshControl ()

@property (nonatomic, retain) UIImageView *arrowImageView;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *timeLabel;

@property (nonatomic, readonly) NSString *lastUpdateFormattedString;

@end

@implementation QBArrowRefreshControl

- (id)init
{
    self = [super init];
    
    if(self) {
        
        float height = 150;
        
        self.frame = CGRectMake(0, 0, 320, height);
        self.threshold = -60;
        
        self.backgroundColor = [UIColor grayColor];
        
        self.lastUpdate = nil;
        
        // 矢印画像
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, height - 55, 50, 50)];
        arrowImageView.image = [UIImage imageNamed:@"arrow.png"];
        
        [self addSubview:arrowImageView];
        self.arrowImageView = arrowImageView;
        [arrowImageView release];
        
        //
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        activityIndicatorView.frame = CGRectMake(35, height - 40, 20, 20);
        
        [self addSubview:activityIndicatorView];
        self.activityIndicatorView = activityIndicatorView;
        [activityIndicatorView release];
        
        //
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, height - 53, 193, 21)];
        titleLabel.text = LS(@"Pull to Refresh");
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [titleLabel release];
        
        // 更新時間
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, height - 30, 193, 21)];
        timeLabel.text = LS(@"Last Update: --");
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
        timeLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        [timeLabel release];
    }
    
    return self;
}

- (void)dealloc
{
    [_arrowImageView release];
    [_activityIndicatorView release];
    [_titleLabel release];
    [_timeLabel release];
    
    [_lastUpdate release];
    
    [super dealloc];
}

- (void)setState:(QBRefreshControlState)state
{
    [super setState:state];
    
    switch(state) {
        case QBRefreshControlStateHidden:
        {
            self.activityIndicatorView.hidden = YES;
            [self.activityIndicatorView stopAnimating];
            
            self.arrowImageView.hidden = NO;
        }
            break;
        case QBRefreshControlStatePullingDown:
        {
            self.titleLabel.text = LS(@"Pull to Refresh");
            
            // 
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
            }];
        }
            break;
        case QBRefreshControlStateOveredThreshold:
        {
            self.titleLabel.text = LS(@"Release to Refresh");
            
            //
            [UIView animateWithDuration:0.2 animations:^{
                self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
            }];
        }
            break;
        case QBRefreshControlStateStopping:
        {
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
            
            self.titleLabel.text = LS(@"Loading...");
            
            self.arrowImageView.hidden = YES;
        }
            break;
    }
}

- (void)endRefreshing
{
    [super endRefreshing];
    
    self.lastUpdate = [NSDate date];
    self.timeLabel.text = [NSString stringWithFormat:LS(@"Last Update: %@"), self.lastUpdateFormattedString];
    
    // 
    self.arrowImageView.transform = CGAffineTransformMakeRotation(0);
}


#pragma mark - Additions

- (NSString *)lastUpdateFormattedString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *formattedString = [dateFormatter stringFromDate:self.lastUpdate];
    
    [dateFormatter release];
    
    return formattedString;
}

@end
