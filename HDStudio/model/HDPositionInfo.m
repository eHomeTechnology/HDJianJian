//
//  HDPositionInfo.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPositionInfo.h"
#import "AFImageRequestOperation.h"

//@implementation HDPositionInfo
//
//- (id)init{
//    if ([super init]) {
//        if (!self.mar_urls) {
//            self.mar_urls = [NSMutableArray new];
//        }
//    }
//    return self;
//}
//
//- (NSString *)changeBr2n:(NSString *)s{
//    if (s.length == 0) {
//        Dlog(@"Error:传入参数有误");
//        return s;
//    }
//    NSString *s2 = [s stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n" options:NSRegularExpressionSearch range:NSMakeRange(0, s.length)];
//    return s2;
//}
//
///*返回没有图片的序列号最小的那个序列*/
//- (int)getMinimumIndexWitchIsEmpty{
//    if (self.sUrlScene0.length == 0) {
//        return 0;
//    }
//    if (self.sUrlScene1.length == 0) {
//        return 1;
//    }
//    if (self.sUrlScene2.length == 0) {
//        return 2;
//    }
//    if (self.sUrlScene3.length == 0) {
//        return 3;
//    }
//    return -1;
//}
//
////==============================================
//
//- (int)getMinimumIndexOfSceneWhichHasValue:(HDPositionInfo *)info{
//    NSMutableArray *mar = [[NSMutableArray alloc] initWithCapacity:4];
//    [mar addObject:(info.sUrlScene0 == nil? @"": info.sUrlScene0)];
//    [mar addObject:(info.sUrlScene1 == nil? @"": info.sUrlScene1)];
//    [mar addObject:(info.sUrlScene2 == nil? @"": info.sUrlScene2)];
//    [mar addObject:(info.sUrlScene3 == nil? @"": info.sUrlScene3)];
//    for (int i = 0; i < mar.count; i++) {
//        NSString *s = mar[i];
//        if (s.length > 0) {
//            return i;
//        }
//    }
//    return -1;
//}
//
//- (int)getRealIndex:(NSString *)s{
//    int index = -1;
//    if (s.length == 0) {
//        Dlog(@"传入参数有误");
//        return index;
//    }
//    if ([self.sUrlScene0 isEqualToString:s]) {
//        index = 0;
//    }
//    if ([self.sUrlScene1 isEqualToString:s]) {
//        index = 1;
//    }
//    if ([self.sUrlScene2 isEqualToString:s]) {
//        index = 2;
//    }
//    if ([self.sUrlScene3 isEqualToString:s]) {
//        index = 3;
//    }
//    return index;
//}
//@end
