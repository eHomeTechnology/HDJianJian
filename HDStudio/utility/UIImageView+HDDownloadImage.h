//
//  UIImageView+HDDownloadImage.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFImageRequestOperation.h"
#import "UIImageView+AFNetworking.h"

@interface UIImageView (HDDownloadImage)

- (void)setImage:(NSString *)url placeholdImage:(UIImage *)placeHoldImage falseImage:(UIImage *)falseImage;

- (void)setImageWithUrlString:(NSString *)url;

@end
