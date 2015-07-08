//
//  HDMainViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/11.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDMainViewCtr.h"
#import "HDPositionCell.h"
#import "HDRecommendCell.h"
#import "HDPartnerCell.h"
#import "HDAddPstiViewCtr.h"
#import "UIImageView+AFNetworking.h"
#import "HDMngShopViewCtr.h"
#import "HDWebViewCtr.h"
#import "HDPstiShowViewCtr.h"
#import "HDRcmdShowViewCtr.h"
#import "AAPullToRefresh.h"
#import "HDShopInfo.h"
#import "UMSocial.h"
#import "TOWebViewController.h"
#import "SDRefresh.h"
#import "HDRecommendViewCtr.h"
typedef NS_ENUM(NSInteger, HDMainCellStyle) {
    
    HDMainCellStylePosition = 0,
    HDMainCellStyleRecommend,
    HDMainCellStyleOther,
};

@interface HDMainViewCtr (){
    IBOutlet UIButton       *btn_position;
    IBOutlet UIButton       *btn_logo;
    IBOutlet UIButton       *btn_recommend;
    IBOutlet UIButton       *btn_partner;
    IBOutlet UILabel        *lb_shopName;
    IBOutlet UIView         *v_head;
}
@property (assign) int                     iPositionIndex;  //网络请求起始序列号
@property (assign) int                     iRecommendIndex; //网络请求起始序列号
@property (assign) HDMainCellStyle         mainCellStyle;
@property (strong) NSMutableArray          *mar_positions;
@property (strong) NSMutableArray          *mar_recommend;
@property (strong) AAPullToRefresh         *tv;
@property (strong) AAPullToRefresh         *bv;
@property (strong) IBOutlet UITableView    *tbv;
@property (strong) HDShopInfo              *shopInfo;
@property (strong) HDAddressInfo           *addressInfo;
@property (strong) SDRefreshFooterView     *refreshFooter;
@end

@implementation HDMainViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title          = @"我的才铺";
    lb_shopName.text    = [HDGlobalInfo instance].userInfo.sShopName;
    _mainCellStyle      = HDMainCellStylePosition;
    v_head.frame        = CGRectMake(0, 0, HDDeviceSize.width, 245);
    self.iPositionIndex = 2;
    self.addressInfo    = [HDGlobalInfo instance].addressInfo;
    [self.tbv setTableHeaderView:v_head];
    self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(doAddPosition)];
    self.tbv.contentSize = CGSizeMake(HDDeviceSize.width, MAX(self.tbv.contentSize.height, HDDeviceSize.height));
    [self setupHeader];
    [self setupFooter];
    if ([self isFirstUse]) {
        UIButton *btn_0 = [[UIButton alloc] initWithFrame:self.navigationController.view.frame];
        [btn_0 setBackgroundImage:HDIMAGE(@"guide0") forState:UIControlStateNormal];
        btn_0.tag = 0;
        [btn_0 addTarget:self action:@selector(touchGuide:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.view addSubview:btn_0];
        
        
    }
}
- (BOOL)isFirstUse{
    NSString *sFirst = [[NSUserDefaults standardUserDefaults] objectForKey:IS_FIRST_USE];
    if (sFirst.length == 0) {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:IS_FIRST_USE];
        return YES;
    }else{
        return NO;
    }
}
- (void)touchGuide:(UIButton *)sender{
    if (sender.tag == 0) {
        [sender removeFromSuperview];
        UIButton *btn_1 = [[UIButton alloc] initWithFrame:self.navigationController.view.frame];
        [btn_1 setBackgroundImage:HDIMAGE(@"guide1") forState:UIControlStateNormal];
        btn_1.tag = 1;
        [btn_1 addTarget:self action:@selector(touchGuide:) forControlEvents:UIControlEventTouchUpInside];
        [self.navigationController.view addSubview:btn_1];
    }
    if (sender.tag == 1) {
        [sender removeFromSuperview];
    }
    
}
- (void)viewDidLayoutSubviews{
    Dlog(@"btn_logo.frame.size.width/2 = %f", btn_logo.frame.size.width/2);
    btn_logo.layer.cornerRadius     = 35.;
    btn_logo.layer.masksToBounds    = YES;
}
- (void)viewWillDisappear:(BOOL)animated{

}
- (void)viewWillAppear:(BOOL)animated{
    self.mar_positions  = [HDGlobalInfo instance].mar_positions;
    self.mar_recommend  = [HDGlobalInfo instance].mar_recommend;
    [self.tbv reloadData];
    
    self.shopInfo       = [HDGlobalInfo instance].shopInfo;
    self.addressInfo    = [HDGlobalInfo instance].addressInfo;
    lb_shopName.text    = self.shopInfo.sShopName;
    if (self.shopInfo.sPathLogo) {
        [btn_logo setBackgroundImage:[UIImage imageWithContentsOfFile:self.shopInfo.sPathLogo] forState:UIControlStateNormal];
        return;
    }
    if (self.shopInfo.sUrlLogo.length == 0) {
        Dlog(@"服务器上没有该店铺的logo");
        return;
    }
    //下载才铺商店图片
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.shopInfo.sUrlLogo]];
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
        if (!image) {
            Dlog(@"下载logo图片错误");
        }
        NSString *sPath = [HDUtility pathOfSavedImageName:FORMAT(@"%d", arc4random()) folderName:[HDGlobalInfo instance].userInfo.sUserId];
        BOOL isSuc      = [HDUtility saveToDocument:image withFilePath:sPath];
        if (isSuc) {
            self.shopInfo.sPathLogo = sPath;
            [btn_logo setBackgroundImage:[UIImage imageWithContentsOfFile:self.shopInfo.sPathLogo] forState:UIControlStateNormal];
            [self.shopInfo updatetoDb];
        }
    }];
    [operation start];
    //下载职位position默认图片
    NSURLRequest *r = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.addressInfo.sLogo_position]];
    AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:r success:^(UIImage *image) {
        if (!image) {
            Dlog(@"下载logo图片错误");
        }
        NSString *sPath = [HDUtility saveImage:image imageName:FORMAT(@"%d", arc4random()) folder:[HDGlobalInfo instance].userInfo.sUserId];
        self.shopInfo.sPathLogo = sPath;
        [btn_logo setBackgroundImage:[UIImage imageWithContentsOfFile:self.shopInfo.sPathLogo] forState:UIControlStateNormal];
        [self.shopInfo updatetoDb];
    
    }];
    [o start];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setupHeader
{
    SDRefreshHeaderView *refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:self.tbv];
    __weak SDRefreshHeaderView *weakRefreshHeader = refreshHeader;
    refreshHeader.beginRefreshingOperation = ^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            switch (self.mainCellStyle) {
                case HDMainCellStylePosition:{
                    [[HDHttpUtility sharedClient] getPositionList:[HDGlobalInfo instance].userInfo pageIndex:@"1" pageSize:FORMAT(@"%d", 24) isOffShelve:NO CompletionBlock:^(BOOL isSuccess, BOOL isLastPage, NSArray *positons, NSString *sCode, NSString *sMessage) {
                        if (!isSuccess) {
                            [HDUtility mbSay:sMessage];
                            return;
                        }
                        [HDUtility mbSay:@"刷新成功"];
                        //[HDGlobalInfo instance].isPositionLastPage  = isLastPage;
                        self.iPositionIndex                         = 2;
                        [HDGlobalInfo instance].mar_positions       = [[NSMutableArray alloc] initWithArray:positons];
                        self.mar_positions                          = [HDGlobalInfo instance].mar_positions;
                        //Dlog(@"isPositionLastPage = %d", [HDGlobalInfo instance].isPositionLastPage);
                        [self setupFooter];
                        [self.tbv reloadData];
                    }];
                    break;
                }
                case HDMainCellStyleRecommend:{
                    [[HDHttpUtility sharedClient] getRecommendList:[HDGlobalInfo instance].userInfo position:nil pageIndex:@"1" pageSize:FORMAT(@"%d", (int)self.mar_recommend.count) CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
                        if (!isSuccess) {
                            [HDUtility mbSay:sMessage];
                            return;
                        }
                        [HDUtility mbSay:@"刷新成功"];
                       // [HDGlobalInfo instance].isCommendLastPage   = isLastPage;
                        self.iRecommendIndex                  = 2;
                        [HDGlobalInfo instance].mar_recommend       = [[NSMutableArray alloc] initWithArray:ar_rcmd];
                        self.mar_recommend                    = [HDGlobalInfo instance].mar_recommend;
                        //Dlog(@"isCommendLastPage = %d", [HDGlobalInfo instance].isCommendLastPage);
                        [self setupFooter];
                        [self.tbv reloadData];
                    }];
                    break;
                }
                case HDMainCellStyleOther:{
                    
                    break;
                }
                default:
                    break;
            }
            [weakRefreshHeader endRefreshing];
        });
    };
}

- (void)setupFooter
{
    if (self.refreshFooter) {
        [self.refreshFooter removeFromSuperview];
        self.refreshFooter = nil;
    }
    switch (_mainCellStyle) {
        case HDMainCellStylePosition:{
//            if ([HDGlobalInfo instance].isPositionLastPage) {
//                return ;
//            }else {
//                break;
//            }
        }
        case HDMainCellStyleRecommend:{
//            if ([HDGlobalInfo instance].isCommendLastPage) {
//                return ;
//            }else{
//                break ;
//            }
        }
        default:
            return;
    }
//    SDRefreshFooterView *refreshFooter = [SDRefreshFooterView refreshView];
//    [refreshFooter addToScrollView:self.tbv];
//    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
//    _refreshFooter = refreshFooter;
}

- (void)footerRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        switch (self.mainCellStyle) {
            case HDMainCellStylePosition:{
                [[HDHttpUtility sharedClient] getPositionList:[HDGlobalInfo instance].userInfo pageIndex:FORMAT(@"%d", self.iPositionIndex) pageSize:@"24" isOffShelve:NO CompletionBlock:^(BOOL isSuccess, BOOL isLastPage, NSArray *positons, NSString *sCode, NSString *sMessage) {
                    if (!isSuccess) {
                        [HDUtility mbSay:sMessage];
                        return;
                    }
                    self.iPositionIndex = self.iPositionIndex + 1;
//                    [HDGlobalInfo instance].isPositionLastPage = isLastPage;
//                    Dlog(@"[HDGlobalInfo instance].isPositionLastPage = %d", [HDGlobalInfo instance].isPositionLastPage);
                    [self.mar_positions addObjectsFromArray:positons];
                    [HDGlobalInfo instance].mar_positions = self.mar_positions;
                    [self.tbv reloadData];
                    [self setupFooter];
                }];
                break;
            }
            case HDMainCellStyleRecommend:{
                [[HDHttpUtility sharedClient] getRecommendList:[HDGlobalInfo instance].userInfo position:nil pageIndex:@"1" pageSize:@"24" CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, BOOL isLastPage, NSArray *ar_rcmd) {
                    if (!isSuccess) {
                        [HDUtility mbSay:sMessage];
                        return ;
                    }
//                    [HDGlobalInfo instance].isCommendLastPage = isLastPage;
//                    Dlog(@"isCommendLastPage = %d", [HDGlobalInfo instance].isCommendLastPage);
                    self.iRecommendIndex = self.iRecommendIndex + 1;
                    self.mar_recommend = [[NSMutableArray alloc] initWithArray:ar_rcmd];
                    [HDGlobalInfo instance].mar_recommend = self.mar_recommend;
                    [self setupFooter];
                    [self.tbv reloadData];
                }];
                break;
            }
            case HDMainCellStyleOther:{
                
                break;
            }
            default:
                break;
        }
        //[self.tbv reloadData];
        [self.refreshFooter endRefreshing];
    });
}

- (void)doAddPosition{
    [self.navigationController pushViewController:[HDAddPstiViewCtr new] animated:YES];
}
- (IBAction)doSelectShow:(UIButton *)sender{
    [btn_position   setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_recommend  setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_partner    setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [sender setTitleColor:COLOR_RED forState:UIControlStateNormal];
    if ([sender isEqual:btn_position]) {
        _mainCellStyle   = HDMainCellStylePosition;
    }
    if ([sender isEqual:btn_recommend]) {
        _mainCellStyle   = HDMainCellStyleRecommend;
    }
    if ([sender isEqual:btn_partner]) {
        _mainCellStyle   = HDMainCellStyleOther;
    }
    [self setupFooter];
    [self.tbv reloadData];
}
- (void)goRecommendShow:(UIButton *)sender{
    
    HDPositionInfo *info = self.mar_positions[sender.tag];
    if ([info.sUpCount intValue] == 0) {
        return;
    }
    NSMutableArray *mar_recommeds = [[NSMutableArray alloc] init];
    for (int i = 0; i < [HDGlobalInfo instance].mar_recommend.count; i++) {
        HDRecommendInfo *rInfo = [HDGlobalInfo instance].mar_recommend[i];
        if ([rInfo.sPositionID isEqualToString:info.sPositionId]) {
            [mar_recommeds addObject:rInfo];
        }
    }
    HDRecommendViewCtr *ctr = [[HDRecommendViewCtr alloc] initWithRecommendInfo:mar_recommeds];
    [self.navigationController pushViewController:ctr animated:YES];
    
}
- (IBAction)goManageShop:(id)sender{
    [self.navigationController pushViewController:[[HDMngShopViewCtr alloc] initWithInfo:self.shopInfo] animated:YES];
}

- (IBAction)doPreviewShop:(id)sender{
    NSURL *url = [NSURL URLWithString:[HDGlobalInfo instance].shopInfo.sUrl];
    TOWebViewController *webCtr = [[TOWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webCtr animated:YES];
}

- (IBAction)doCopyAddress:(id)sender{
    UIPasteboard *past = [UIPasteboard generalPasteboard];
    [past setString:[HDGlobalInfo instance].shopInfo.sUrl];
    [HDUtility mbSay:@"地址已复制到剪切板"];
}
- (IBAction)doShareShop:(id)sender{
    UIImage *shareImage = HDIMAGE(@"headShadow");
    if (self.shopInfo.sPathLogo) {
        shareImage = [UIImage imageWithContentsOfFile:self.shopInfo.sPathLogo];
        [HDMainViewCtr umshareUrl:[HDGlobalInfo instance].shopInfo.sUrl title:self.shopInfo.sShopName image:shareImage target:self];
    }else{
        if (self.shopInfo.sUrlLogo.length > 0) {
            NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:self.shopInfo.sUrlLogo]];
            AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:r imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                [HDMainViewCtr umshareUrl:[HDGlobalInfo instance].shopInfo.sUrl title:self.shopInfo.sShopName image:image target:self];
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                [HDUtility say:@"分享失败"];
            }];
            [o start];
        }else{
            NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:self.addressInfo.sLogo_shop]];
            AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:r success:^(UIImage *image) {
                [HDMainViewCtr umshareUrl:[HDGlobalInfo instance].shopInfo.sUrl title:self.shopInfo.sShopName image:image target:self];
            }];
            [o start];
        }
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_mainCellStyle == HDMainCellStylePosition && self.mar_positions.count > 0) {
        HDPstiShowViewCtr *ctr = [[HDPstiShowViewCtr alloc] initWithPositionInfo:self.mar_positions[indexPath.row]];
        [self.navigationController pushViewController:ctr animated:YES];
    }
    if (_mainCellStyle == HDMainCellStyleRecommend && self.mar_recommend.count > 0) {
        HDRcmdShowViewCtr *ctr = [[HDRcmdShowViewCtr alloc] initWithRecommendInfo:self.mar_recommend[indexPath.row]];
        [self.navigationController pushViewController:ctr animated:YES];
    }
}
    
#pragma mark -
#pragma mark UITableViewDatasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if (_mainCellStyle == HDMainCellStylePosition) {
        height = (self.mar_positions.count == 0? 219.: 172.);
    }
    if (_mainCellStyle == HDMainCellStyleRecommend) {
        if (self.mar_recommend.count) {
            return 143.;
        }else{
            if (indexPath.section == 0) {
                return 257.;
            }else{
                return 70;
            }
        }
    }
    if (_mainCellStyle == HDMainCellStyleOther) {
        height  = 300;
    }
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.mar_recommend.count == 0 && _mainCellStyle == HDMainCellStyleRecommend) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    NSInteger count = 0;
    if (_mainCellStyle == HDMainCellStylePosition) {
        count = self.mar_positions.count == 0? 1: self.mar_positions.count;
    }
    if (_mainCellStyle == HDMainCellStyleRecommend) {
        if (self.mar_recommend.count > 0) {
            return self.mar_recommend.count;
        }
        if (self.mar_recommend.count == 0) {
            if (sectionIndex == 0) {
                return 1;
            }else{
                return 3;
            }
        }
    }
    if (_mainCellStyle == HDMainCellStyleOther) {
        count  = 1;
    }
    return count;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lb         = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 50)];
    lb.backgroundColor  = [UIColor clearColor];
    lb.textColor        = [UIColor grayColor];
    if (section == 1) {
        lb.text         = @"    没有人选？看看这个\n";
    }
    return lb;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_mainCellStyle == HDMainCellStylePosition) {
        if (self.mar_positions.count == 0) {
            static NSString *sIdentifier = @"noPositionCell";
            HDNoPositionCell *noPositionCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
            if (!noPositionCell) {
                noPositionCell = [self getNoPositionCell];
            }
            return noPositionCell;
        }else{
            static NSString *sIdentifier = @"positionCell";
            HDPositionCell *positionCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
            if (!positionCell) {
                positionCell = [self getPositionCell];
            }
            HDPositionInfo  *info               = self.mar_positions[indexPath.row];
            positionCell.lb_publishTime.text    = info.sPublishTime;
            positionCell.lb_title.text          = info.sPositionName;
            positionCell.lb_Hit.text            = info.sHit;
            positionCell.lb_upcount.text        = info.sUpCount;
            positionCell.btn_copy.tag           = indexPath.row;
            positionCell.btn_preview.tag        = indexPath.row;
            positionCell.btn_share.tag          = indexPath.row;
            positionCell.btn_goRecommend.tag    = indexPath.row;
            positionCell.imv_head.image         = HDIMAGE(@"headShadow");
            
            [positionCell.btn_copy addTarget:self action:@selector(doCopyPosition:) forControlEvents:UIControlEventTouchUpInside];
            [positionCell.btn_preview addTarget:self action:@selector(doPreviewPosition:) forControlEvents:UIControlEventTouchUpInside];
            [positionCell.btn_share addTarget:self action:@selector(doSharePosition:) forControlEvents:UIControlEventTouchUpInside];
            [positionCell.btn_goRecommend addTarget:self action:@selector(goRecommendShow:) forControlEvents:UIControlEventTouchUpInside];
            if (info.mar_path.count == 0) {
                return positionCell;
            }
            NSDictionary *dic = info.mar_path[0];
            NSString        *sPath      = dic[@"path"];
            NSString        *sUrl       = dic[@"url"];
            NSString        *sIndex     = dic[@"key"];
            Dlog(@"sIndex = %@, sPath = %@, sUrl = %@", sIndex, sPath, sUrl);
            if (sUrl.length == 0) {
                Dlog(@"Error:检测到数据有误，请盘查");
                return positionCell;;
            }
            if (sPath.length > 0) {
                positionCell.imv_head.image = [UIImage imageWithContentsOfFile:sPath];
            }else{
                __weak UITableView *tbv = self.tbv;
                NSURLRequest    *request    =  [NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]];
                [positionCell.imv_head setImageWithURLRequest:request placeholderImage:HDIMAGE(@"placeHold") success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    NSString *sPath = [HDUtility saveImage:image imageName:FORMAT(@"%d", arc4random()) folder:info.sPositionId];
                    [dic setValue:sPath forKey:@"path"];
                    [info.mar_path replaceObjectAtIndex:0 withObject:dic];
                    [HDGlobalInfo instance].mar_positions = self.mar_positions;
                    [tbv reloadData];
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    Dlog(@"图片下载失败：row = %d, sIndex = %@", (int)indexPath.row, sIndex);
                }];
            }
            return positionCell;
        }
    }
    if (_mainCellStyle == HDMainCellStyleRecommend) {
        if (self.mar_recommend.count) {
            static NSString *sIdentifier = @"HDRecommendCell";
            HDRecommendCell *recommendCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
            if (!recommendCell) {
                recommendCell = [self getRecommendCell];
            }
            HDRecommendInfo *recommend          = self.mar_recommend[indexPath.row];
            recommendCell.lb_Name.text          = recommend.sName;
            recommendCell.lb_curPstiNCmp.text   = FORMAT(@"%@ | %@", recommend.sCurCompanyName, recommend.sCurPosition);
            recommendCell.lb_matchCount.text    = recommend.sMatchCount;
            recommendCell.lb_refereeName.text   = FORMAT(@"%@推荐", recommend.sRefereeName);
            recommendCell.lb_createdTime.text   = recommend.sCreatedTime;
            recommendCell.btn_copyIcon.tag      = indexPath.row;
            recommendCell.btn_copyText.tag      = indexPath.row;
            recommendCell.btn_shareText.tag     = indexPath.row;
            recommendCell.btn_shareIcon.tag     = indexPath.row;
            [recommendCell.btn_copyIcon addTarget:self action:@selector(doCopyRecommend:) forControlEvents:UIControlEventTouchUpInside];
            [recommendCell.btn_copyText addTarget:self action:@selector(doCopyRecommend:) forControlEvents:UIControlEventTouchUpInside];
            [recommendCell.btn_shareIcon addTarget:self action:@selector(doShareRecommend:) forControlEvents:UIControlEventTouchUpInside];
            [recommendCell.btn_shareText addTarget:self action:@selector(doShareRecommend:) forControlEvents:UIControlEventTouchUpInside];
            return recommendCell;
        }else{
            if (indexPath.section == 0) {
                static NSString *sIdentifier = @"HDNoRecommendCell";
                HDNoRecommendCell *noRecommendCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
                if (!noRecommendCell) {
                    noRecommendCell = [self getNoRecommendCell];
                }
                return noRecommendCell;
            }else{
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"111"];
                if (!cell) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"111"];
                    cell.backgroundColor = [UIColor clearColor];
                    
                    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, 0, HDDeviceSize.width - 20, 70)];
                    v.backgroundColor       = [UIColor whiteColor];
                    UIView *vLine           = [[UIView alloc] initWithFrame:CGRectMake(0, 69, CGRectGetWidth(v.frame), 0.5)];
                    vLine.backgroundColor   = [UIColor grayColor];
                    vLine.alpha             = 0.4;
                    cell.selectionStyle     = UITableViewCellSelectionStyleNone;
                    [v addSubview:vLine];
                    [cell addSubview:v];
                    [cell sendSubviewToBack:v];
                }
                cell.textLabel.text = @[@"一键设置悬赏，提升推荐人气", @"委托给六度伯乐网，让六度签约猎头来帮忙", @"成为六度签约猎头,获得人选资源在内的加盟服务支持"][indexPath.row];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                return cell;
            }
        }
    }
    if (_mainCellStyle == HDMainCellStyleOther) {
        static NSString *sIdentifier = @"partnerCell";
        HDPartnerCell *partnerCell = [tableView dequeueReusableCellWithIdentifier:sIdentifier];
        if (!partnerCell) {
            partnerCell = [self getPartnerCell];
        }
        return partnerCell;
    }
    return nil;
}

#pragma mark - 
- (HDNoPositionCell *)getNoPositionCell{
    HDNoPositionCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDNoPositionCell class]]) {
            cell = (HDNoPositionCell *)obj;
            [cell.btn_add addTarget:self action:@selector(doAddPosition) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle   = UITableViewCellSelectionStyleNone;
            break;
        }
    }
    return cell;
}
- (HDPositionCell *)getPositionCell{
    HDPositionCell  *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDPositionCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPositionCell class]]) {
            cell = (HDPositionCell *)obj;
            break;
        }
    }
    return cell;
}

- (HDRecommendCell *)getRecommendCell{
    HDRecommendCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRecommendCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDRecommendCell class]]) {
            cell = (HDRecommendCell *)obj;
            break;
        }
    }
    return cell;
}

- (HDNoRecommendCell *)getNoRecommendCell{
    HDNoRecommendCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDRecommendCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDNoRecommendCell class]]) {
            cell = (HDNoRecommendCell *)obj;
            cell.selectionStyle   = UITableViewCellSelectionStyleNone;
            break;
        }
    }
    return cell;
}

- (HDPartnerCell *)getPartnerCell{
    HDPartnerCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDPartnerCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPartnerCell class]]) {
            cell = (HDPartnerCell *)obj;
            break;
        }
    }
    return cell;
}
- (void)doCopyPosition:(UIButton *)sender{
    Dlog(@"sender = %d", (int)sender.tag);
    HDPositionInfo *info = _mar_positions[sender.tag];
    UIPasteboard *past = [UIPasteboard generalPasteboard];
    [past setString:info.sUrl];
    [HDUtility mbSay:@"地址已复制到剪切板"];
}
- (void)doPreviewPosition:(UIButton *)sender{
    Dlog(@"sender = %d", (int)sender.tag);

    HDPositionInfo *info = self.mar_positions[sender.tag];
    NSURL *url = [NSURL URLWithString:info.sUrl];
    TOWebViewController *webCtr = [[TOWebViewController alloc] initWithURL:url];
    [self.navigationController pushViewController:webCtr animated:YES];
}

- (void)doSharePosition:(UIButton *)sender{
    Dlog(@"sender = %d", (int)sender.tag);
    HDPositionInfo *info    = _mar_positions[sender.tag];
    [HDMainViewCtr shareWithPosition:info target:self];
}
- (void)doCopyRecommend:(UIButton *)sender{
    HDRecommendInfo *info = self.mar_recommend[sender.tag];
    NSString *sUrl  = nil;
    for (HDPositionInfo *pInfo in self.mar_positions){
        if ([pInfo.sPositionId isEqualToString:info.sPositionID]) {
            sUrl    = pInfo.sUrl;
            break;
        }
    }
    UIPasteboard *past = [UIPasteboard generalPasteboard];
    [past setString:sUrl];
    [HDUtility mbSay:@"超链接已复制到粘贴板"];
}
- (void)doShareRecommend:(UIButton *)sender{
    HDRecommendInfo *info       = self.mar_recommend[sender.tag];
    HDPositionInfo  *position   = nil;
    for (HDPositionInfo *pInfo in self.mar_positions){
        if ([pInfo.sPositionId isEqualToString:info.sPositionID]) {
            position    = pInfo;
            break;
        }
    }
    if (!position) {
        [HDUtility mbSay:@"Error:数据出错,请联系管理员"];
        return;
    }
    [HDMainViewCtr shareWithPosition:position target:self];
}

+ (void)shareWithPosition:(HDPositionInfo *)info target:(id)target{
    if (info.mar_path.count > 0) {
        NSDictionary *dic   = info.mar_path[0];
        NSString *sPath     = dic[@"path"];
        NSString *sUrl      = dic[@"url"];
        UIImage *shareImage = nil;
        if (sPath.length > 0) {
            shareImage = [UIImage imageWithContentsOfFile:sPath];
            [HDMainViewCtr umshareUrl:info.sUrl title:info.sPositionName image:shareImage target:target];
        }else if(sUrl.length > 0){
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:sUrl]];
            AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
                [HDMainViewCtr umshareUrl:info.sUrl title:info.sPositionName image:image target:target];
            }];
            [o start];
        }else{
            [HDUtility mbSay:@"数据出错，请联系管理员"];
        }
    }else{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[HDGlobalInfo instance].addressInfo.sPath_position]];
        AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
            [HDMainViewCtr umshareUrl:info.sUrl title:info.sPositionName image:image target:target];
        }];
        [o start];
    }
}

+ (void)umshareUrl:(NSString *)url title:(NSString *)title image:(UIImage *)image target:(id)target{
    if (url.length == 0 || title.length == 0 || !image || !target) {
        Dlog(@"传入参数错误");
        return;
    }
    [UMSocialData defaultData].extConfig.wechatSessionData.url      = url;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url     = url;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.url     = url;
    [UMSocialData defaultData].extConfig.wechatSessionData.title    = title;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title   = title;
    [UMSocialData defaultData].extConfig.wechatFavoriteData.title   = title;
    [UMSocialSnsService presentSnsIconSheetView:target
                                         appKey:@UmengAppkey
                                      shareText:LS(@"TXT_SHARE_CONTENT")
                                     shareImage:image
                                shareToSnsNames:[NSArray arrayWithObjects:
                                                 UMShareToEmail,
                                                 UMShareToSms,
                                                 UMShareToWechatTimeline,
                                                 UMShareToWechatSession,
                                                 UMShareToWechatFavorite,
                                                 nil]
                                       delegate:nil];

}

@end
