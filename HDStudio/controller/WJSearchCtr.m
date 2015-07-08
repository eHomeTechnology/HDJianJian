//
//  WJSearchCtr.m
//  JianJian
//
//  Created by liudu on 15/5/25.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "WJSearchCtr.h"

@interface WJSearchCtr ()

@property (strong, nonatomic)   IBOutlet UIButton       *btn_sBroker;
@property (strong, nonatomic)   IBOutlet UIButton       *btn_sTalent;
@property (strong, nonatomic)   IBOutlet UIButton       *btn_sPosition;
@property (strong, nonatomic)   IBOutlet UIScrollView   *scv;
@property (weak, nonatomic)     IBOutlet UIView         *v_line;
@property (weak, nonatomic)     IBOutlet UIView         *v_topView;
@property (strong, nonatomic)   IBOutlet NSLayoutConstraint     *lc_lineWithWidth;
@property (strong, nonatomic)   IBOutlet NSLayoutConstraint     *lc_talentWithWidth;

@property (strong) WJFindBrokerView     *findBrokerView;
@property (strong) WJFindTalentView     *findTalentView;
@property (strong) WJFindPositionView   *findPositionView;
@end

@implementation WJSearchCtr

- (void)viewWillAppear:(BOOL)animated{
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self addSubviews];
}

- (void)setup{
    self.lc_talentWithWidth.constant = self.lc_lineWithWidth.constant =  [UIScreen mainScreen].bounds.size.width/3;
    self.navigationItem.title = LS(@"WJ_TITLE_SEARCH");
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 50, 25);
    rightButton.layer.masksToBounds = YES;
    rightButton.layer.borderColor   = [UIColor whiteColor].CGColor;
    rightButton.layer.borderWidth   = 1;
    rightButton.layer.cornerRadius  = 10.0;
    rightButton.titleLabel.font     = [UIFont systemFontOfSize:14];
    [rightButton setTitle:@"清空" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(clearOnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)clearOnClick{
    if (_findBrokerView) {
        [_findBrokerView clear];
    }
    if (_findTalentView) {
        [_findTalentView clear];
    }
    if (_findPositionView) {
        [_findPositionView clear];
    }
}

- (void)addSubviews{
    self.scv.contentSize = CGSizeMake(HDDeviceSize.width*3, HDDeviceSize.height-110);
    self.scv.indicatorStyle                 = UIScrollViewIndicatorStyleBlack;
    self.scv.showsVerticalScrollIndicator   = NO;
    self.scv.showsHorizontalScrollIndicator = NO;
    self.scv.bounces                        = NO;
    self.scv.pagingEnabled                  = YES;
    self.scv.delegate                       = self;
    
    _findBrokerView = [[WJFindBrokerView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _findBrokerView.bDelegate = self;
    [self.scv addSubview:_findBrokerView];
    
    _findTalentView = [[WJFindTalentView alloc] initWithFrame:CGRectMake(HDDeviceSize.width, 0, HDDeviceSize.width, HDDeviceSize.height-40)];
    _findTalentView.tDelegate = self;
    _findTalentView.backgroundColor = [UIColor orangeColor];
    [self.scv addSubview:_findTalentView];
    
    _findPositionView = [[WJFindPositionView alloc] initWithFrame:CGRectMake(HDDeviceSize.width*2, 0, HDDeviceSize.width, HDDeviceSize.height-40)];
    _findPositionView.pDelegate = self;
    _findPositionView.backgroundColor = [UIColor orangeColor];
    [self.scv addSubview:_findPositionView];
}

#pragma mark - 跳转代理
- (void)toFindBrokerViewController:(UIViewController *)viewController{
        [self.navigationController pushViewController:viewController animated:YES];
}

- (void)toFindTalentViewController:(UIViewController *)viewController{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (void)toFindPositionViewController:(UIViewController *)viewController{
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)doChoose:(UIButton*)btn{
    if (btn == self.btn_sBroker) {
        self.btn_sBroker.selected = YES;
        self.btn_sTalent.selected = NO;
        self.btn_sPosition.selected = NO;
        [self.scv setContentOffset:CGPointMake(0, 0) animated:YES];
    }else if (btn == self.btn_sTalent){
        self.btn_sTalent.selected = YES;
        self.btn_sPosition.selected = NO;
        self.btn_sBroker.selected = NO;
        [self.scv setContentOffset:CGPointMake(HDDeviceSize.width, 0) animated:YES];
    }else{
        self.btn_sPosition.selected = YES;
        self.btn_sTalent.selected = NO;
        self.btn_sBroker.selected = NO;
        [self.scv setContentOffset:CGPointMake(HDDeviceSize.width*2, 0) animated:YES];
    }
    [UIView animateWithDuration:0.25 animations:^{
        CGRect  frame = self.v_line.frame;
        frame.origin.x = btn.frame.origin.x;
        self.v_line.frame = frame;
        
    }];
    for (UIView * view in self.v_topView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton * button = (UIButton*)view;
            if (button.tag == btn.tag) {
                button.selected = YES;
            }else{
                button.selected = NO;
            }
        }
    }
}


#pragma mark -
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint point =scrollView.contentOffset;
    int currentPage = (int)(point.x)/HDDeviceSize.width;
    if (currentPage == 1) {
        self.btn_sTalent.selected = YES;
        self.btn_sPosition.selected = NO;
        self.btn_sBroker.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect  frame = self.v_line.frame;
            frame.origin.x = self.btn_sTalent.frame.origin.x;
            self.v_line.frame = frame;
            
        }];
    }else if (currentPage == 2){
        self.btn_sTalent.selected = NO;
        self.btn_sPosition.selected = YES;
        self.btn_sBroker.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect  frame = self.v_line.frame;
            frame.origin.x = self.btn_sPosition.frame.origin.x;
            self.v_line.frame = frame;
            
        }];
    }else{
        self.btn_sTalent.selected = NO;
        self.btn_sPosition.selected = NO;
        self.btn_sBroker.selected = YES;
        [UIView animateWithDuration:0.25 animations:^{
            CGRect  frame = self.v_line.frame;
            frame.origin.x = self.btn_sBroker.frame.origin.x;
            self.v_line.frame = frame;
            
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
