//
//  HDBlogTextView.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/22.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDBlogTextView.h"
@interface HDBlogTextView(){
    CGFloat height_text;;
    CGFloat height_pic;
}

@end

@implementation HDBlogTextView

- (void)setBlogInfo:(HDBlogInfo *)blogInfo{
    _blogInfo = blogInfo;
    self.lb_text.text           = blogInfo.blogTextInfo.sText;
    height_text                 = [HDBlogTextView heightOfText:blogInfo.blogTextInfo.sText];
    _lc_textHeight.constant     = height_text;
    [self updateConstraints];
    NSArray *ar_imvs = @[_imv0, _imv1, _imv2];
    for (UIImageView *imv in ar_imvs) {
        [imv setImage:nil];
        imv.hidden = YES;
    }
    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:blogInfo.blogTextInfo.ar_picUrls];
    if (mar.count == 0) {
        height_pic = 0;
        return;
    }
    for (int i = 0; i < mar.count; i++) {
        NSString *s = mar[i];
        if (s.length == 0) {
            [mar removeObjectAtIndex:i];
            i = 0;
            continue;
        }
    }
    for (int i = 0; i < MIN(mar.count, 3); i++) {
        NSString *sUrl = mar[i];
        UIImageView *imv = ar_imvs[i];
        imv.hidden  = NO;
        [HDJJUtility getImage:sUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
            imv.contentMode = UIViewContentModeRedraw;
            if (code.intValue == 0) {
                [imv setImage:img];
            }else{
                [imv setImage:HDIMAGE(@"falseImage")];
            }
        }];
    }
    height_pic = HDDeviceSize.width == 320? 100:(HDDeviceSize.width == 375? 118: 131);
    [self updateConstraints];
}

- (IBAction)doTapPicture:(UIButton *)btn{
    UIImageView *imv = @[_imv0, _imv1, _imv2][btn.tag];
    if (!imv.image) {
        return;
    }
    NSString *str = _blogInfo.blogTextInfo.ar_picUrls[btn.tag];
    NSString *sUrl = [str stringByReplacingOccurrencesOfString:@"BlogThumbnail" withString:@"Blog" options:NSRegularExpressionSearch range:NSMakeRange(0, str.length)];
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_PREVIEW_BLOG_IMAGE object:sUrl];
}
+ (CGFloat)heightOfText:(NSString *)s{
    if (s.length == 0) {
        return 0;
    }
    CGSize size = [s boundingRectWithSize:CGSizeMake(HDDeviceSize.width - 90, 9999)
                    options:NSStringDrawingUsesLineFragmentOrigin
                 attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:15]}
                    context:nil].size;
    return MAX(size.height, 30);
}

+ (CGFloat)heightOfTextView:(HDBlogInfo *)blog{
    CGFloat h_pic = HDDeviceSize.width == 320? 80:(HDDeviceSize.width <= 375? 98: 110);
    CGFloat height_pic = (blog.blogTextInfo.ar_picUrls.count == 0? 0: h_pic);
    CGFloat height_text = [self heightOfText:blog.blogTextInfo.sText];
    return height_pic + height_text;
}

@end
