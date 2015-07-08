//
//  HDMyPositionCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/16.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMyPositionCtr.h"
#import "HDMyPositionCell.h"
#import "UMSocial.h"
#import "TOWebViewController.h"
#import "SDRefresh.h"
#import "UIImageView+HDDownloadImage.h"
#import "TOWebViewController.h"
#import "HDJJUtility.h"
#import "HDTalentListViewCtr.h"
#import "HDPositionListView.h"
#import "HDChatViewCtr.h"
#import "HDNewPositionCtr.h"
#import "WJCheckPositionCtr.h"

@interface HDMyPositionCtr (){
    IBOutlet NSLayoutConstraint     *lc_lineLeading;
    IBOutlet UIButton               *btn_onShelve;
    IBOutlet UIButton               *btn_offShelve;
    HDPositionListView              *listViewOn;
    HDPositionListView              *listViewOff;
}
@property (assign) int  iOnIndex;
@property (assign) int  iOffIndex;
@property (assign) BOOL isOnLastPage;
@property (assign) BOOL isOffLastPage;
@property (strong) NSMutableArray           *mar_onPositions;
@property (strong) NSMutableArray           *mar_offPositions;
@property (strong) HDChatViewCtr            *controller;
@property (strong) IBOutlet UIScrollView    *scv;

@end

@implementation HDMyPositionCtr

- (id)initWithObject:(HDChatViewCtr *)obj{
    if (!obj || ![obj isKindOfClass:[HDChatViewCtr class]]) {
        Dlog(@"传入参数有误！");
        return nil;
    }
    if (self = [super init]) {
        _controller = obj;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title   = LS(@"TXT_TITLE_MY_POSITIONS");
    self.mar_onPositions        = [HDGlobalInfo instance].mar_onPosition;
    self.mar_offPositions       = [HDGlobalInfo instance].mar_offPosition;
    [self addSubviews];
    [self setup];
}

- (void)viewDidLayoutSubviews{
   
    
}
- (void)viewDidAppear:(BOOL)animated{

}
- (void)viewWillDisappear:(BOOL)animated{
    if (listViewOff.op) {
        [listViewOff.op cancel];
        listViewOff.op = nil;
    }
    if (listViewOn.op) {
        [listViewOn.op cancel];
        listViewOn = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
   [self scroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scroll:scrollView];
}

- (void)scroll:(UIScrollView *)scrollView{
    CGFloat f = scrollView.contentOffset.x;
    if (f == HDDeviceSize.width) {
        [self setHighlight:btn_offShelve];
        if (listViewOff.mar_value.count == 0 || listViewOn.isOffPositionNeedRefresh) {
            [listViewOff refreshView];
            listViewOn.isOffPositionNeedRefresh = NO;
        }
        return;
    }
    if (f == 0 && listViewOff.isOnPositionNeedRefresh) {
        [listViewOn refreshView];
        listViewOff.isOnPositionNeedRefresh = NO;
    }
    [self setHighlight:btn_onShelve];
}

#pragma mark Event and Respond
- (IBAction)doChoose:(UIButton *)sender{
    [self setHighlight:sender];
}

-(void)setHighlight:(UIButton *)btn{
    [btn_offShelve  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_onShelve   setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setTitleColor:HDCOLOR_RED forState:UIControlStateNormal];
    if ([btn isEqual:btn_offShelve]) {
        lc_lineLeading.constant     = HDDeviceSize.width/2;
        [_scv setContentOffset:CGPointMake(HDDeviceSize.width, 0) animated:YES];
    }else{
        lc_lineLeading.constant     = 0;
        [_scv setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (void)addPosition{
    Dlog(@"添加职位");
    [self.navigationController pushViewController:[HDNewPositionCtr new] animated:YES];
}

#pragma mark - setter and getter
- (void)setup{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 50, 25);
    rightButton.layer.masksToBounds = YES;
    rightButton.layer.borderColor = [UIColor whiteColor].CGColor;
    rightButton.layer.borderWidth = 1;
    rightButton.layer.cornerRadius = 10.0;
    rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightButton setTitle:@"添加" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(addPosition) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)addSubviews{
    listViewOn = [[HDPositionListView alloc] initWithArray:_mar_offPositions isOnPosition:YES owner:self] ;
    listViewOn.translatesAutoresizingMaskIntoConstraints = NO;
    if (_controller) {
        listViewOn.plDelegate = _controller;
    }
    [_scv addSubview:listViewOn];
    [_scv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[listViewOn(==width)]"
                                                                 options:0
                                                                 metrics:@{@"width":@(HDDeviceSize.width)}
                                                                   views:NSDictionaryOfVariableBindings(listViewOn)]];
    [_scv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[listViewOn(==height)]"
                                                                 options:0
                                                                 metrics:@{@"height":@(HDDeviceSize.height - 40 - 20 - 44)}
                                                                   views:NSDictionaryOfVariableBindings(listViewOn)]];
    [listViewOn refreshView];
    listViewOff = [[HDPositionListView alloc] initWithArray:_mar_offPositions isOnPosition:NO owner:self];
    listViewOff.translatesAutoresizingMaskIntoConstraints = NO;
    if (_controller) {
        listViewOff.plDelegate = _controller;
    }
    [_scv addSubview:listViewOff];
    [_scv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[listViewOn][listViewOff(==listViewOn)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(listViewOff, listViewOn)]];
    [_scv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[listViewOff(==listViewOn)]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(listViewOff, listViewOn)]];
}

@end
