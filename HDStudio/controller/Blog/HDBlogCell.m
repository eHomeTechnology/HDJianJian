//
//  HDBlogCell.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/19.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDBlogCell.h"
#import "HDBlogTextView.h"
#import "HDBlogPositionView.h"
#import "HDBlogResumeView.h"
#import "UIView+LoadFromNib.h"

@interface HDBlogCell(){
    HDBlogTextView      *blogTextView;
    HDBlogPositionView  *blogPositionView;
    HDBlogResumeView    *blogResumView;
}

@end

@implementation HDBlogCell

+ (HDBlogCell *)getBlogCell{
    HDBlogCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDBlogCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDBlogCell class]]) {
            cell = (HDBlogCell *)obj;
            break;
        }
    }
    return cell;
}

- (void)blogPositionView:(HDBlogPositionView *)positionView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(blogCell:)]) {
        [self.delegate blogCell:self];
    }
}

- (void)setBlogInfo:(HDBlogInfo *)blogInfo{
    [HDJJUtility getImage:blogInfo.sAuthorAvatar withBlock:^(NSString *code, NSString *message, UIImage *img) {
        [self.btn_avatar setBackgroundImage:img forState:UIControlStateNormal];
    }];
    self.lb_name.text   = blogInfo.sAuthorName;
    self.lb_time.text   = blogInfo.sCreateTime;
    self.lb_top.hidden  = !blogInfo.isTop;
    self.lc_topHeight.constant = blogInfo.isTop? 0.: 21.;
    self.btn_payAttention.hidden= blogInfo.isAttention;
    self.lc_topHeight.constant  = blogInfo.isTop? 21: 0;
    self.lb_collectCount.text   = blogInfo.sCollectCount;
    self.btn_collect.selected   = blogInfo.isCollect;
    [self updateConstraints];
    UIView *v = nil;
    if (self.v_content.subviews.count > 0) {
        v = self.v_content.subviews[0];
    }
    switch (blogInfo.blogType) {
        case HDBlogTypeText:{
            if (!blogTextView) {
                 blogTextView = [HDBlogTextView loadFromNib];
            }
            blogTextView.hidden     = NO;
            blogPositionView.hidden = YES;
            blogResumView.hidden    = YES;
            blogTextView.blogInfo   = blogInfo;
            blogTextView.backgroundColor = [UIColor clearColor];
            [self.v_content addSubview:blogTextView];
            blogTextView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.v_content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blogTextView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(blogTextView)]];
            [self.v_content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blogTextView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(blogTextView)]];
            break;
        }
        case HDBlogTypePosition:{
            if (!blogPositionView) {
                blogPositionView = [HDBlogPositionView loadFromNib];
            }
            blogTextView.hidden     = YES;
            blogPositionView.hidden = NO;
            blogResumView.hidden    = YES;
            [self.v_content bringSubviewToFront:blogPositionView];
            blogPositionView.blogInfo = blogInfo;
            blogPositionView.delegate = self;
            blogPositionView.backgroundColor = [UIColor clearColor];
            [self.v_content addSubview:blogPositionView];
            blogPositionView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.v_content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blogPositionView]|"
                                                                                    options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(blogPositionView)]];
            [self.v_content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blogPositionView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(blogPositionView)]];
            break;
        }
        case HDBlogTypeResume:{
            if (!blogResumView) {
                blogResumView = [HDBlogResumeView loadFromNib];
            }
            blogTextView.hidden     = YES;
            blogPositionView.hidden = YES;
            blogResumView.hidden    = NO;
            blogResumView.blogInfo = blogInfo;
            [self.v_content addSubview:blogResumView];
            blogResumView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.v_content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blogResumView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(blogResumView)]];
            [self.v_content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blogResumView]|"
                                                                                   options:0
                                                                                   metrics:nil
                                                                                     views:NSDictionaryOfVariableBindings(blogResumView)]];
            break;
        }
        default:
            break;
    }
}
@end


@implementation HDBrokerCell

+ (HDBrokerCell *)getBrokerCell{
    HDBrokerCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDBlogCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDBrokerCell class]]) {
            cell = (HDBrokerCell *)obj;
            break;
        }
    }
    cell.btn_payAttention.layer.cornerRadius    = 5.;
    cell.btn_payAttention.layer.masksToBounds   = YES;
    cell.btn_payAttention.layer.borderWidth     = 1.0;
    cell.btn_payAttention.layer.borderColor     = [UIColor grayColor].CGColor;
    return cell;
}

- (void)setBrokerInfo:(WJBrokerInfo *)brokerInfo{
    [HDJJUtility getImage:brokerInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        [self.btn_avatar setBackgroundImage:img forState:UIControlStateNormal];
    }];
    self.btn_payAttention.hidden    = brokerInfo.isFocus;
    self.lb_name.text       = brokerInfo.sName;
    self.lb_company.text    = brokerInfo.sCurCompany;
    self.lb_position.text   = brokerInfo.sCurPosition;
}

@end