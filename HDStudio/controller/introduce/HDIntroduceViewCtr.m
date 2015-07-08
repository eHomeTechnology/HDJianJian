//
//  HDIntroduceViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/5.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDIntroduceViewCtr.h"
#import "HDSendCodeViewCtr.h"
#import "HDExtendListCtr.h"
#import "HDJJUtility.h"
#import "HDScrollView.h"
#import "AppDelegate.h"

@interface HDIntroduceViewCtr (){

    IBOutlet HDScrollView   *scv;
    IBOutlet UIPageControl  *pg;
    int iPageCount;
}

@property (strong) IBOutlet NSLayoutConstraint *lc_pageControlBottom;

@end

@implementation HDIntroduceViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    iPageCount  = 4;
    for (int i = 0; i < iPageCount; i++) {
        UIImageView *imv    = [[UIImageView alloc] init];
        imv.frame           = CGRectMake(i * HDDeviceSize.width, 0, HDDeviceSize.width, HDDeviceSize.width*1900/1080);
        [imv setImage:[UIImage imageNamed:FORMAT(@"intro_%d", i)]];
        [scv addSubview:imv];
        if (i == 3) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake((HDDeviceSize.width - 780*0.33) * 0.5, HDDeviceSize.height - 50 - 165*0.33, 780*0.33, 165*0.33);
            [btn setBackgroundImage:HDIMAGE(@"btn_go") forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(doStart:) forControlEvents:UIControlEventTouchUpInside];
            imv.userInteractionEnabled = YES;
            [imv addSubview:btn];
        }
    }
    scv.contentSize     = CGSizeMake(HDDeviceSize.width * iPageCount, HDDeviceSize.height-20);
    scv.pagingEnabled   = YES;
    pg.numberOfPages    = iPageCount;
    pg.currentPage      = 0;
    pg.currentPageIndicatorTintColor = HDCOLOR_RED;
}

- (void)viewDidAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidDisappear:(BOOL)animated{
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)doStart:(id)sender{
    UITabBarController *tab = [HDJJUtility structTheBuilding];
    AppDelegate *delegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    tab.delegate = delegate;
    [[UIApplication sharedApplication].keyWindow setRootViewController:tab];
}
#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self actionWhenScrollViewEndAnimation:scrollView];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self actionWhenScrollViewEndAnimation:scrollView];
}

- (void)actionWhenScrollViewEndAnimation:(UIScrollView *)scrollView{
    int iCurrentIndex           = scrollView.contentOffset.x/HDDeviceSize.width;
    [pg setCurrentPage:iCurrentIndex];
}

@end
