//
//  HDBlogResumeView.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/22.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDBlogResumeView.h"

@interface HDBlogResumeView(){
    HDBlogInfo  *blog;
}

@end

@implementation HDBlogResumeView

- (void)setBlogInfo:(HDBlogInfo *)blogInfo{
    NSArray *ar_talent = blogInfo.ar_talents;
    blog = blogInfo;
    if (ar_talent.count == 0) {
        Dlog(@"Error:数据有误:blogInfo下面简历为空");
        return;
    }
    HDTalentInfo *info = ar_talent[0];
    self.lb_title.text  = FORMAT(@"%@(%@)", info.sCurPosition, info.sCurCompanyName);
    NSString *str = info.sSexText.length > 0? FORMAT(@"%@|", info.sSexText): @"";
    str = [str stringByAppendingString:(info.sEduLevel.length > 0? FORMAT(@"%@|", info.sEduLevel): @"")];
    str = [str stringByAppendingString:(info.sAreaText.length > 0? FORMAT(@"%@|", info.sAreaText): @"")];
    str = [str stringByAppendingString:(info.sWorkYears.length > 0? FORMAT(@"%@", info.sWorkYears): @"")];
    if ([str hasSuffix:@"|"]) {
        str = [str substringToIndex:str.length - 1];
    }
    self.lb_subscribe.text = str;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doTapAction:)];
    [self addGestureRecognizer:tap];
}

- (void)doTapAction:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_BLOG_CELL_POSITION_ACTION object:blog.ar_talents[0] userInfo:@{@"key": @"resume"}];
}
@end
