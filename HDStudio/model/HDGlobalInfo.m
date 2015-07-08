//
//  HDGlobleInfo.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDGlobalInfo.h"

static HDGlobalInfo *pData = NULL;
@implementation HDGlobalInfo

+ (HDGlobalInfo *)instance{
    @synchronized(self){
        if (pData == NULL){
            pData = [[HDGlobalInfo alloc] init];
            if (!pData.userInfo) {
                pData.userInfo = [HDUserInfo new];
            }
            if (!pData.mar_positions) {
                pData.mar_positions     = [[NSMutableArray alloc] init];
            }
            if (!pData.mar_recommend) {
                pData.mar_recommend     = [[NSMutableArray alloc] init];
            }
            if (!pData.mar_onPosition) {
                pData.mar_onPosition = [NSMutableArray new];
            }
            if (!pData.mar_offPosition) {
                pData.mar_offPosition = [NSMutableArray new];
            }
            if (!pData.mar_feedback) {
                pData.mar_feedback = [NSMutableArray new];
            }
            if (!pData.mar_area) {
                pData.mar_area = [NSMutableArray new];
            }
            if (!pData.mar_post) {
                pData.mar_post = [NSMutableArray new];
            }
            if (!pData.mar_trade) {
                pData.mar_trade = [NSMutableArray new];
            }
            if (!pData.mar_workExp) {
                pData.mar_workExp = [NSMutableArray new];
            }
            if (!pData.mdc_preset) {
                pData.mdc_preset = [NSMutableDictionary new];
            }
            if (!pData.mar_property) {
                pData.mar_property = [NSMutableArray new];
            }
            if (!pData.mar_reward) {
                pData.mar_reward    = [NSMutableArray new];
            }
        }
    }
    return pData;
}

- (void)reset{
    pData = NULL;
}

@end
