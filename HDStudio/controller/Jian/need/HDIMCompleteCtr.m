//
//  HDIMCompleteCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/16.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDIMCompleteCtr.h"
#import "HDMyPositionCtr.h"

@interface HDIMCompleteCtr (){

    NSArray             *ar_positions;
    IBOutlet UILabel    *lb_;
}

@end

@implementation HDIMCompleteCtr
@class HDSelectPositionCtr;
@class HDImportViewCtr;
- (id)initWithPositions:(NSArray *)ar{

    if (self = [super init]) {
        ar_positions = ar;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    lb_.text = FORMAT(@"恭喜，您已经成功发布%d个职位", (int)ar_positions.count);
    self.navigationItem.title   = LS(@"TXT_TITLE_IMPORT_SUCCESS");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doCheckPositions:(id)sender{

    NSMutableArray *mar = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    HDMyPositionCtr *ctr = [HDMyPositionCtr new];
    [mar insertObject:ctr atIndex:mar.count-4];
    self.navigationController.viewControllers = mar;
    [self.navigationController popToViewController:ctr animated:YES];
}


@end
