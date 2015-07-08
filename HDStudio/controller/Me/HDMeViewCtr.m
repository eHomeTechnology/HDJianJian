//
//  HDMeViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/12.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMeViewCtr.h"
#import "HDJianCell.h"
#import "HDJJUtility.h"
#import "HDSettingViewCtr.h"
#import "WJMyWalletCtr.h"
#import "HDMyPositionCtr.h"
#import "HDMeCell.h"
#import "TWPhotoPickerController.h"
#import "WJBrokerDetailsCtr.h"
#import "HDMyJianJianCtr.h"
#import "HDMyTalentCtr.h"
#import "WJMyWalletCtr.h"
#import "WJMyRecommendPersonalCtr.h"
#import "WJSellOrderCtr.h"
#import "HDMyPositionCtr.h"
#import "HDFeedbackCtr.h"

@interface HDMeViewCtr ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>{
    IBOutlet UIView     *v_head;
    IBOutlet UIButton   *btn_head;
    IBOutlet UILabel    *lb_v;
    IBOutlet UILabel    *lb_name;
    IBOutlet UILabel    *lb_company;
    IBOutlet UILabel    *lb_headAttention;
    IBOutlet UILabel    *lb_headFan;
    IBOutlet UILabel    *lb_headShare;
    IBOutlet UILabel    *lb_headCollect;
    IBOutlet UIImageView *img_grade;//会员等级
    IBOutlet NSLayoutConstraint *lc_widthHeadName;
}
@property (strong) NSMutableArray *mar_images;
@property (strong) IBOutlet UITableView *tbv;
@property (strong) HDMyJianJianInfo *myJianJianInfo;
@property (strong) AFHTTPRequestOperation *op;

@end

@implementation HDMeViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)viewDidAppear:(BOOL)animated{
    [self setUserInformation];
    [self httpGetMyJianJianInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationController.tabBarController.tabBar.hidden = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.tabBarController.tabBar.hidden = YES;
    }
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 3) {
        [self.navigationController pushViewController:[HDFeedbackCtr new] animated:YES];
    }
}

#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        return 55;
    }
    return 130;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        HDOpinionCell *cell = [HDOpinionCell getOpinionCell];
        return cell;
    }
    static NSString *cellIdentifier = @"HDMeCell";
    HDMeCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell    = [HDMeCell getCell];
    }
    cell.indexPath      = indexPath;
    cell.myJianJianInfo = _myJianJianInfo;
    [cell.btn_0 addTarget:self action:@selector(doCellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_1 addTarget:self action:@selector(doCellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_2 addTarget:self action:@selector(doCellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_3 addTarget:self action:@selector(doCellAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_subTitle addTarget:self action:@selector(doCellAction:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark -
#pragma mark Event Respose
- (void)goSettingCtr:(UIButton *)sender{
    HDSettingViewCtr *ctr = [[HDSettingViewCtr alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
    
}
- (void)httpGetMyJianJianInfo{
    _op = [[HDHttpUtility sharedClient] getMyJianJianInfomation:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDMyJianJianInfo *info) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        self.myJianJianInfo = info;
        [self setHeadJianJianInfo:info];
        [self.tbv reloadData];
    }];
}

- (void)httpChangeAvatar:(UIImage *)image{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op = [[HDHttpUtility sharedClient] uploadLogo:[HDGlobalInfo instance].userInfo flag:@"4" avatar:image completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        if (!isSuccess) {
            [hud hiden];
            [HDUtility mbSay:sMessage];
            return ;
        }
        [HDGlobalInfo instance].userInfo.sAvatarUrl = url;
        [HDJJUtility getImage:url withBlock:^(NSString *code, NSString *message, UIImage *img) {
            [hud hiden];
            [btn_head setBackgroundImage:img forState:UIControlStateNormal];
        }];
    }];
    
}

- (IBAction)doTableHeadActions:(UIButton *)sender{
    switch (sender.tag) {
        case 0:{//头像
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
            [sheet showInView:self.navigationController.view];
            break;
        }
        case 1:{//预览
            WJBrokerDetailsCtr *ctr = [[WJBrokerDetailsCtr alloc] initWithInfoID:[HDGlobalInfo instance].userInfo.sHumanNo];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 2:{//账户管理认证
            [self.navigationController pushViewController:[HDMyJianJianCtr new] animated:YES];
            break;
        }
        case 10:{//关注
            break;
        }
        case 11:{//粉丝
            break;
        }
        case 12:{//分享
            
            break;
        }
        case 13:{//收藏
            
            break;
        }
        default:
            break;
    }

}

- (void)doCellAction:(HDIndexButton *)button{

    switch (button.indexPath.section) {
        case 0:{
            switch (button.tag) {
                case 0:{//发布简历
                    HDMyTalentCtr *talent = [[HDMyTalentCtr alloc] initWithType:HDWhoseTalentMe];
                    [self.navigationController pushViewController:talent animated:YES];
                    break;
                }
                case 1:{//推荐人才
                    [self.navigationController pushViewController:[WJMyRecommendPersonalCtr new] animated:YES];
                    break;
                }
                case 2:{//订单上门
                    WJSellOrderCtr *sellList = [[WJSellOrderCtr alloc] initWithIsSellService:YES];
                    [self.navigationController pushViewController:sellList animated:YES];
                    break;
                }
                case 3:{//领取赏金
                    [self.navigationController pushViewController:[WJMyWalletCtr new] animated:YES];
                    break;
                }
                case 4:{//我的人才
                    [self.navigationController pushViewController:[HDMyTalentCtr new] animated:YES];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 1:{
            switch (button.tag) {
                case 0:{//发布职位
                    HDMyPositionCtr *position = [[HDMyPositionCtr alloc] init];
                    [self.navigationController pushViewController:position animated:YES];
                    break;
                }
                case 1:{//收到简历
                    HDMyTalentCtr *talent = [[HDMyTalentCtr alloc] initWithType:HDWhoseTalentFriend];
                    [self.navigationController pushViewController:talent animated:YES];
                    break;
                }
                case 2:{//我购买的服务
                    WJSellOrderCtr *sellList = [[WJSellOrderCtr alloc] initWithIsSellService:NO];
                    [self.navigationController pushViewController:sellList animated:YES];
                    break;
                }
                case 4:{//职位管理
                    HDMyPositionCtr *position = [[HDMyPositionCtr alloc] init];
                    [self.navigationController pushViewController:position animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2:{
            switch (button.tag) {
                case 0:{//余额
                    
                    break;
                }
                case 1:{//保证金金额
                    
                    break;
                }
                case 4:{//充值收支明细等
                    [self.navigationController pushViewController:[WJMyWalletCtr new] animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 
#pragma mark Getter and Setter
- (void)setup{
    self.navigationItem.title       = LS(@"TXT_TITLE_ME");
    btn_head.layer.cornerRadius     = 36;
    btn_head.layer.masksToBounds    = YES;
    btn_head.layer.borderColor      = [UIColor whiteColor].CGColor;
    btn_head.layer.borderWidth      = 2.0;
    lb_v.layer.cornerRadius         = 7.5;
    lb_v.layer.masksToBounds        = YES;
    v_head.frame                    = CGRectMake(0, 0, HDDeviceSize.width, 160);
    self.tbv.tableHeaderView        = v_head;
    UIButton *btn                   = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, 20, 20)];
    [btn setBackgroundImage:HDIMAGE(@"icon_meSetting") forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goSettingCtr:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self setHeadJianJianInfo:nil];
}

- (void)setHeadJianJianInfo:(HDMyJianJianInfo *)info{
    lb_headAttention.text   = info.sFocusCount;
    lb_headFan.text         = info.sFanCount;
    lb_headShare.text       = info.sCPositionCount;
    lb_headCollect.text     = info.sCBlogCount;
    
}

- (void)setUserInformation{
    HDUserInfo *user = [HDGlobalInfo instance].userInfo;
    [HDJJUtility getImage:user.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        UIImage *image = img;
        if ([code intValue] != 0) {
            image = HDIMAGE(@"icon_headFalse");
        }
        [btn_head setBackgroundImage:image forState:UIControlStateNormal];
        [self.tbv reloadData];
    }];
    lb_v.hidden     = ![user.sRoleType intValue];
    lb_company.text = user.sCurCompany;
    lb_name.text    = user.sName;
    lc_widthHeadName.constant = [HDJJUtility withOfString:user.sName font:[UIFont systemFontOfSize:17] widthMax:120];
    [v_head updateConstraints];
    switch ([user.sMemberLevel integerValue]) {
        case 1://注册会员
        {
        
        }
            break;
        case 2://铜牌会员
        {
            img_grade.image = HDIMAGE(@"v_copper");
        }
            break;
        case 3://银牌会员
        {
            img_grade.image = HDIMAGE(@"v_silver");
        }
            break;
        case 4://金牌会员
        {
            img_grade.image = HDIMAGE(@"v_gold");
        }
            break;
        case 5://钻石会员
        {
            img_grade.image = HDIMAGE(@"v_diamond");
        }
            break;
        case 6://皇冠会员
        {
            
        }
            break;
            
        default:
            break;
    }
    [self.view updateConstraints];
}

#pragma mark - 
#pragma mark choose image 模块
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 2) {//取消
        return;
    }
    if (buttonIndex == 0) {//拍一张
        [self doTakePicture:nil];
        return;
    }
    if (buttonIndex == 1) {//从相册选择
        [self doChooseImageFromAlbum:nil];
        return;
    }
    
}
- (void)doChooseImageFromAlbum:(id)sender{
    TWPhotoPickerController *photoPicker    = [[TWPhotoPickerController alloc] init];
    photoPicker.cropBlock = ^(UIImage *image) {
        UIImage *image_ = [HDUtility resizeImage:image];
        if (!image_) {
            Dlog(@"Error:图片压缩失败");
            return ;
        }
        [self httpChangeAvatar:image];
    };
    [self.navigationController.tabBarController presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)doTakePicture:(id)sender{
    UIImagePickerController *imagePickerCtr  = [[UIImagePickerController alloc] init];
    imagePickerCtr.delegate                  = self;
    imagePickerCtr.allowsEditing             = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerCtr.sourceType            = UIImagePickerControllerSourceTypeCamera;
    }
    [self.navigationController.tabBarController presentViewController:imagePickerCtr animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img_original       = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *data = UIImageJPEGRepresentation(img_original, 1);
        [picker dismissViewControllerAnimated:YES completion:nil];
        if (data.length == 0) {
            Dlog(@"图片获取失败");
            return;
        }
        UIImage *image = [HDUtility resizeImage:img_original];
        if (!image) {
            Dlog(@"Error:压缩图片失败");
            return;
        }
        [self httpChangeAvatar:image];
    }else{
        Dlog(@"Error:获取图片失败");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    Dlog(@"获取图片失败");
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
