//
//  HDShopInfo.m
//  HDStudio
//
//  Created by Hu Dennis on 15/3/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDShopInfo.h"

@implementation HDShopInfo

- (void)sift{
    self.sAnnounce          = [self siftNull:self.sAnnounce];
    self.sUrlBackground     = [self siftNull:self.sUrlBackground];
    self.sUrlLogo           = [self siftNull:self.sUrlLogo];
    self.sPathBackground    = [self siftNull:self.sPathBackground];
    self.sPathLogo          = [self siftNull:self.sPathLogo];
    self.sMPhone            = [self siftNull:self.sMPhone];
    self.sCreateDate        = [self siftNull:self.sCreateDate];
    self.sUpdateDate        = [self siftNull:self.sUpdateDate];
    self.sProperty          = [self siftNull:self.sProperty];
    self.sQQ                = [self siftNull:self.sQQ];
    self.sUserNumber        = [self siftNull:self.sUserNumber];
    self.sWXUserName        = [self siftNull:self.sWXUserName];
    self.sUrl               = [self siftNull:self.sUrl];
}

- (NSString *)siftNull:(NSString *)s{
    BOOL isNull1 = [s isEqualToString:@"<null>"] || [s isEqualToString:@"(null)"] || [s isEqualToString:@"null"];
    BOOL isNull2 = [s isEqualToString:@"<NULL>"] || [s isEqualToString:@"(NULL)"] || [s isEqualToString:@"NULL"];
    if (isNull1 || isNull2) {
        s = @"";
    }
    return s;
}

@end
