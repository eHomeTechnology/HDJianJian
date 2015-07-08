//
//  WJEvaluateResume.h
//  JianJian
//
//  Created by liudu on 15/4/30.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WJEvaluateResumeCtr : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong) NSString *PersonalNo;//人选编号
@property (strong) NSString *RecommendID;//推荐id
- (id)initWithRecommendTalent:(NSString *)talentNo recommenNo:(NSString *)recommendNo;
@end
