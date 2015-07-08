//
//  WJSearchOrderCache.h
//  JianJian
//
//  Created by liudu on 15/4/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WJSearchOrderCache : NSManagedObject

@property (nonatomic, retain) NSString * industryId;
@property (nonatomic, retain) NSString * industryStr;
@property (nonatomic, retain) NSString * keywordStr;
@property (nonatomic, retain) NSString * positionId;
@property (nonatomic, retain) NSString * positionStr;
@property (nonatomic, retain) NSString * workPlaceId;
@property (nonatomic, retain) NSString * workPlaceStr;
@property (nonatomic, retain) NSString * bountyStr;

@end
