//
//  StarsView.h
//  StarDemo
//
//  Created by fuguangxin on 15/4/29.
//  Copyright (c) 2015年 fuguangxin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StarsViewDelegate <NSObject>

- (void)getEvaluationScore:(NSInteger)score starsView:(UIView*)view;

@end

@interface StarsView : UIView

@property (nonatomic, assign) BOOL selectable;  //是否触摸选择分数
@property (nonatomic, assign) CGFloat score;    //分数
@property (nonatomic, assign) BOOL supportDecimal; //是否支持触摸选择小数
//size是你的图片的size   space是Star间的间距  
- (instancetype)initWithStarSize:(CGSize)size space:(CGFloat)space numberOfStar:(NSInteger)number;
- (void)StarSize:(CGSize)size space:(CGFloat)space numberOfStar:(NSInteger)number;
@property (nonatomic,assign)id<StarsViewDelegate>delegate;
@end
