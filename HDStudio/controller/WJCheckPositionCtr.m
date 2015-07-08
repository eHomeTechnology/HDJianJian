//
//  WJCheckPositionCtr.m
//  JianJian
//
//  Created by liudu on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJCheckPositionCtr.h"
#import "UIView+LoadFromNib.h"
#import "WJPositionInfoView.h"
#import "WJRecomendResume.h"
#import "HDMyTalentCtr.h"
#import "HDNewPositionCtr.h"
#import "WJCheckEmployer.h"
#import "WJEvaluateResumeCtr.h"
#import "WJAddPersonalCtr.h"

@interface WJCheckPositionCtr (){

    BOOL isMyPosition;
}

@property (strong) IBOutlet UIButton *btn_position;
@property (strong) IBOutlet UIButton *btn_employer;
@property (strong) IBOutlet UIButton *btn_service;
@property (strong) IBOutlet UIButton *btn_collect;
@property (strong) IBOutlet UIButton *btn_share;
@property (strong) IBOutlet UIButton *btn_recommend;
@property (strong) IBOutlet UIView *v_line;
@property (strong) IBOutlet NSLayoutConstraint *lc_lineWithWidth;
@property (strong) IBOutlet UIScrollView *scv;
@property (strong) IBOutlet NSLayoutConstraint *lc_employerWithWidth;
@property (strong) IBOutlet UIView *v_topView;
@property (strong) WJPositionInfo *positionInfo;
@property (strong) NSString       *positionID;

@end

@implementation WJCheckPositionCtr

- (id)initWithPositionId:(NSString *)sId{
    if (self = [super init]) {
        _positionID = sId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LS(@"WJ_TITLE_CHECK_POSITION");
    self.lc_employerWithWidth.constant = self.lc_lineWithWidth.constant = [UIScreen mainScreen].bounds.size.width/3;
    [self httpRequest];
}

- (void)viewWillAppear:(BOOL)animated{
    
}

#pragma mark - CheckEmployerDelegate
- (void)toCheckEmployerViewController:(UIViewController *)viewController{
    if ([viewController isKindOfClass:[WJCheckEmployer class]]) {
        self.btn_employer.selected  = YES;
        self.btn_position.selected  = NO;
        self.btn_service.selected   = NO;
        [self.scv setContentOffset:CGPointMake(HDDeviceSize.width, 0) animated:YES];
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.v_line.frame;
            frame.origin.x = self.btn_employer.frame.origin.x;
            self.v_line.frame = frame;
        }];
    }else{
       [self.navigationController pushViewController:viewController animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [self.navigationController pushViewController:[WJAddPersonalCtr new] animated:YES];
    }else if (buttonIndex == 1){
        HDMyTalentCtr *ctr  = [[HDMyTalentCtr alloc] initWithPosition:_positionInfo];
        [self.navigationController pushViewController:ctr animated:YES];
    }else{
        NSLog(@"取消");
    }
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    int currentPage = (int)(point.x)/HDDeviceSize.width;
    if (currentPage == 1) {
        self.btn_employer.selected = YES;
        self.btn_position.selected = NO;
        self.btn_service.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.v_line.frame;
            frame.origin.x = self.btn_employer.frame.origin.x;
            self.v_line.frame = frame;
        }];
    }else if (currentPage == 2){
        self.btn_employer.selected = NO;
        self.btn_service.selected = YES;
        self.btn_position.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.v_line.frame;
            frame.origin.x = self.btn_service.frame.origin.x;
            self.v_line.frame = frame;
        }];
    }else{
        self.btn_employer.selected = NO;
        self.btn_service.selected = NO;
        self.btn_position.selected = YES;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.v_line.frame;
            frame.origin.x = self.btn_position.frame.origin.x;
            self.v_line.frame = frame;
        }];
    }
}

#pragma mark - Event and Respond
- (IBAction)doChoose:(UIButton *)btn{
    if (btn == self.btn_position) {
        self.btn_position.selected = YES;
        self.btn_employer.selected = NO;
        self.btn_service.selected = NO;
        [self.scv setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if (btn == self.btn_employer){
        self.btn_employer.selected = YES;
        self.btn_position.selected = NO;
        self.btn_service.selected = NO;
        [self.scv setContentOffset:CGPointMake(HDDeviceSize.width, 0) animated:YES];
    }else{
        self.btn_service.selected = YES;
        self.btn_employer.selected = NO;
        self.btn_position.selected = NO;
        [self.scv setContentOffset:CGPointMake(HDDeviceSize.width*2, 0) animated:YES];
    }
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.v_line.frame;
        frame.origin.x = btn.frame.origin.x;
        self.v_line.frame = frame;
    }];
    for (UIView *view in self.v_topView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            if (button.tag == btn.tag) {
                button.selected = YES;
            }else{
                button.selected = NO;
            }
        }
    }
}

- (IBAction)share:(UIButton *)sender {
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_SHARE_POSITION object:_positionInfo];
}

- (IBAction)recommend:(UIButton *)sender {
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return;
    }
    if (isMyPosition) {
        HDNewPositionCtr *ctr = [[HDNewPositionCtr alloc] initWithPosition:self.positionInfo];
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"新增人选" otherButtonTitles:@"我的人才库", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;//透明色
    [actionSheet showInView:self.view];
}

#pragma mark - Private method
- (void)httpRequest{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_UPDATE_DATA") on:self.view];
    _positionInfo = [[WJPositionInfo alloc] init];
    [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo pid:_positionID completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJPositionInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _positionInfo = info;
        isMyPosition = [_positionInfo.brokerInfo.sHumanNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
        if (isMyPosition) {
            [_btn_recommend setTitle:@"修改职位" forState:UIControlStateNormal];
        }
        [self addSubviews];
    }];
}

- (void)addSubviews{
    self.scv.contentSize = CGSizeMake(HDDeviceSize.width*3, HDDeviceSize.height-45-20-44-49);
    self.scv.indicatorStyle                 = UIScrollViewIndicatorStyleBlack;
    self.scv.showsVerticalScrollIndicator   = NO;
    self.scv.showsHorizontalScrollIndicator = NO;
    self.scv.bounces                        = NO;
    self.scv.pagingEnabled                  = YES;
    self.scv.delegate                       = self;
    WJPositionInfoView *positionInfoView = [WJPositionInfoView loadFromNib];
    positionInfoView.info = _positionInfo;
    positionInfoView.eDelegate = self;
    [self.scv addSubview:positionInfoView];
    positionInfoView.translatesAutoresizingMaskIntoConstraints = NO;
    Dlog(@"%f",HDDeviceSize.width);
    [self.scv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[positionInfoView(==width)]"
                                                                     options:0
                                                                     metrics:@{@"width":@(HDDeviceSize.width)}
                                                                       views:NSDictionaryOfVariableBindings(positionInfoView)]];
    [self.scv addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[positionInfoView(==height)]"
                                                                     options:0
                                                                     metrics:@{@"height":@(self.scv.frame.size.height)}
                                                                       views:NSDictionaryOfVariableBindings(positionInfoView)]];
    
    WJEmployerInfoView *employerInfoView = [[WJEmployerInfoView alloc] initWithFrame:CGRectMake(HDDeviceSize.width, 0, HDDeviceSize.width, HDDeviceSize.height)];
    employerInfoView.info = _positionInfo;
    [self.scv addSubview:employerInfoView];
    
    
    WJServiceInfoView *serviceInfoView = [[WJServiceInfoView alloc]initWithFrame:CGRectMake(HDDeviceSize.width*2, 0, HDDeviceSize.width, HDDeviceSize.height)];
    serviceInfoView.info = _positionInfo;
    [self.scv addSubview:serviceInfoView];
    
}


@end
