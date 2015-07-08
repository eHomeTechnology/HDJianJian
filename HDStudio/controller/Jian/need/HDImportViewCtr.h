//
//  HDImportViewCtr.h
//  JianJian
//
//  Created by Hu Dennis on 15/3/13.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

typedef NS_ENUM(NSInteger, HDSearchImportType){
    HDSearchImportTypePosition = 0,
    HDSearchImportTypeDescribe,
};

#import <UIKit/UIKit.h>

@interface HDImportViewCtr : UIViewController

- (id)initWithType:(HDSearchImportType)type;

@end
