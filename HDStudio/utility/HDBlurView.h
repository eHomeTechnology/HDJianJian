//
//  HDBlurView.h
//  SNVideo
//
//  Created by Hu Dennis on 14-9-15.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIImage (HDBlurView)

- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;

@end

@interface HDBlurView : UIButton

@property (strong)UIButton *btn;
@end
