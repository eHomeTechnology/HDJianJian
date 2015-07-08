//
//  HDNewPosition2Ctr.h
//  JianJian
//
//  Created by Hu Dennis on 15/4/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage_index.h"

@interface HDNewPosition2Ctr : UIViewController
/**
 @brief     这个congtroller是个复用的congtroller，发布职位第二步骤“添加雇主信息”和修改职位“修改雇主信息”，如果作为修改雇主信息，调用改方法，传入position信息
 @param     position 当作为修改职位信息的界面时，传入position信息
 @return    自身实例
 */
- (id)initWithPosition:(WJPositionInfo *)position;

@end
