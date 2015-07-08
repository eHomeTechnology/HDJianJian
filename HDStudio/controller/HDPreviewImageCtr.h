//
//  HDPreviewImageCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/6/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDPreviewImageCtr : UIViewController

@property (strong) IBOutlet UIImageView *imv;
@property (strong) IBOutlet NSLayoutConstraint  *lc_width;
@property (strong) IBOutlet NSLayoutConstraint  *lc_height;

- (id)initWithImage:(UIImage *)image_;
- (id)initWithUrl:(NSString *)url;
@end
