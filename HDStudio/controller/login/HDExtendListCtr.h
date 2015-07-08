//
//  HDExtendListCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/31.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//
#import <UIKit/UIKit.h>

#import "HDValueItem.h"

#define KEY_PRESET_AREA     "PRESET_AREA"
#define KEY_PRESET_TRADE    "PRESET_TRADE"
#define KEY_PRESET_WORKEXP  "PRESET_WORK_EXP"
#define KEY_PRESET_POST     "PRESET_POST"

#define KEY_PRESET_EDUCATION    "PRESET_EDUCATION"
#define KEY_PRESET_SALARY       "PRESET_SALARY"


//设置代理用于找荐客获取选择类型信息的
@protocol HDExtendListDelegate <NSObject>
@optional
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type;
- (void)extendListFinalChooseValueWithKey:(NSString *)key type:(HDExtendType)type;
@end


@interface HDExtendCell : UITableViewCell

@property (strong) IBOutlet UIImageView     *imv_icon;
@property (strong) IBOutlet UILabel         *lb_title;

+ (HDExtendCell *)getCell;

@end

@interface HDExtendListCtr : UIViewController

@property (nonatomic, assign) id <HDExtendListDelegate> delegate;

- (id)initWithExtendType:(HDExtendType)type object:(id)object maxSelectCount:(int)count;
/**
 @brief     初始化
 
 @return    type        HDExtendType类型
 @return    object      NSArray类型，如果是HDExtendTypeArea和HDExtendTypeWorkExp，也要装到array里面
 @return    self
 
 @discussion 根据不同的HDExtendType，展示不同的界面风格
 */
- (id)initWithExtendType:(HDExtendType)type withObject:(id)object;

@end
