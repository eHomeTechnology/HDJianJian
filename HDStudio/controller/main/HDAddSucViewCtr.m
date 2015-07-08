//
//  HDAddSucViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/3/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDAddSucViewCtr.h"
#import "HDNewPositionCtr.h"
#import "TOWebViewController.h"
#import "UMSocial.h"
#import "AFImageRequestOperation.h"
#import "WJSettingRewardCtr.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import "HDContactViewCtr.h"
#import <MessageUI/MessageUI.h>
@interface HDAddSucViewCtr ()<UMSocialDataDelegate, UMSocialUIDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>{

    IBOutlet UIButton   *btn_201;
    IBOutlet UIButton   *btn_202;
    IBOutlet UIButton   *btn_203;
    IBOutlet UIButton   *btn_204;
    IBOutlet UIButton   *btn_301;
    IBOutlet UIButton   *btn_302;
    IBOutlet UIButton   *btn_303;
    IBOutlet UILabel    *lb_201;
    IBOutlet UILabel    *lb_202;
    IBOutlet UILabel    *lb_203;
    IBOutlet UILabel    *lb_204;
    IBOutlet UILabel    *lb_301;
    IBOutlet UILabel    *lb_302;
    IBOutlet UILabel    *lb_303;
    
    IBOutlet NSLayoutConstraint *lc_shareBgHeight;
}

@property (strong) WJPositionInfo *positionInfo;
@end

@implementation HDAddSucViewCtr

- (id)initWithPosition:(WJPositionInfo *)info{
    if (self = [super init]) {
        self.positionInfo   = info;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title   = @"添加成功";
    [self setControlsHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result == MFMailComposeResultSent) {
        [HDUtility mbSay:@"发送成功"];
    }
    if (result == MFMailComposeResultFailed) {
        [HDUtility mbSay:@"发送失败"];
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark MFMessageComposeViewControllerDelegate
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (result == MessageComposeResultSent){
        [HDUtility mbSay:@"短信发送成功"];
    }
    if (result == MessageComposeResultFailed) {
        [HDUtility mbSay:@"短信发送失败"];
    }
    
}

#pragma mark - event and respond
- (void)removeControllers{
    NSMutableArray *mar_ctrs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (int i = 0; i < mar_ctrs.count; i++) {
        UIViewController *ctr = mar_ctrs[i];
        if ([ctr isKindOfClass:[HDAddSucViewCtr class]]) {
            [mar_ctrs removeObject:ctr];
            i = 0;
        }
    }
    self.navigationController.viewControllers = mar_ctrs;
}
- (IBAction)doPreview:(UIButton *)sender{
    TOWebViewController *ctr        = [[TOWebViewController alloc] initWithURLString:self.positionInfo.sUrl];
    UINavigationController *nav     = [[UINavigationController alloc] initWithRootViewController:ctr];
    nav.navigationBar.barTintColor  = HDCOLOR_RED;
    nav.navigationBar.tintColor     = [UIColor whiteColor];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)doCopy:(id)sender{
    UIPasteboard *past = [UIPasteboard generalPasteboard];
    if (self.positionInfo.sUrl.length > 0) {
        past.string = self.positionInfo.sUrl;
        [HDUtility say:@"地址信息已复制到粘贴板"];
    }else{
        [HDUtility mbSay:@"获取参数错误，请稍后再试"];
    }
}

- (IBAction)continueAddPositoin:(id)sender{
    HDNewPositionCtr *ctr = [[HDNewPositionCtr alloc] init];
    [self.navigationController pushViewController:ctr animated:YES];
    [self removeControllers];
}

- (IBAction)doSetReward:(id)sender{
    WJSettingRewardCtr *ctr = [[WJSettingRewardCtr alloc] initWithInfo:_positionInfo];
    [self.navigationController pushViewController:ctr animated:YES];
    [self removeControllers];
}

- (IBAction)doShowMoreShare:(UIButton *)sender{
    sender.superview.hidden = YES;
    [self setControlsHidden:NO];
    lc_shareBgHeight.constant = 390;
    [self.view updateConstraints];
}

- (IBAction)doShare:(UIButton *)sender{
    NSString *sShareType    = UMShareToWechatTimeline;
    NSString *sEmployerName = _positionInfo.employerInfo.sName.length > 0? FORMAT(@"《%@》", _positionInfo.employerInfo.sName): @"";
    NSString *sPName        = _positionInfo.sPositionName.length > 0? FORMAT(@"《%@》", _positionInfo.sPositionName): @"高薪职位";
    NSString *shareTxt      = FORMAT(@"%@诚招%@, 请帮我推荐人选", sEmployerName, sPName);
    if (_positionInfo.isBonus) {
        shareTxt = FORMAT(@"%@, 赏金%@元。", shareTxt, _positionInfo.sReward);
        if (_positionInfo.isDeposit) {
            shareTxt = [shareTxt stringByAppendingString:@"平台担保交易"];
        }
    }
    switch (sender.tag) {
        case 1001:{//荐友
            HDContactViewCtr *ctr = [[HDContactViewCtr alloc] initWithSharePosition:self.positionInfo];
            [self.parentViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:ctr] animated:YES completion:nil];
            return;
        }
        case 1002:{//荐友圈
            [[HDHttpUtility sharedClient] shared2Blog:[HDGlobalInfo instance].userInfo positionId:_positionInfo.sPositionNo resumeId:nil type:1 completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
                [HDUtility mbSay:sMessage];
            }];
            return;
        }
        case 1003:{//微信
            sShareType  = UMShareToWechatSession;
            break;
        }
        case 1004:{//微信朋友圈
            sShareType = UMShareToWechatTimeline;
            break;
        }
        case 2001:{//新浪微博
            sShareType  = UMShareToSina;
            break;
        }
        case 2002:{//QQ好友
            sShareType  = UMShareToQQ;
            break;
        }
        case 2003:{//QQ空间
            sShareType  = UMShareToQzone;
            break;
        }
        case 2004:{//易信好友
            sShareType  = UMShareToYXSession;
            break;
        }
        case 3001:{//易信朋友圈
            sShareType  = UMShareToYXTimeline;
            break;
        }
        case 3002:{//短信
            shareTxt = [shareTxt stringByAppendingString:_positionInfo.sUrl];
            [self sendSMS:shareTxt recipientList:nil];
            return;
        }
        case 3003:{//邮件
            shareTxt = [shareTxt stringByAppendingString:_positionInfo.sUrl];
            [self sendmail:nil title:_positionInfo.sPositionName content:shareTxt];
            return;
        }
        default:
            break;
    }
    if (self.positionInfo.employerInfo.mar_urls.count > 0) {
        NSString *sUrl = self.positionInfo.employerInfo.mar_urls[0];
        [HDJJUtility getImage:sUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
            [HDJJUtility umsharePosition:_positionInfo withType:sShareType image:img shareText:shareTxt delegate:self];
        }];
    }else{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[HDGlobalInfo instance].addressInfo.sLogo_position]];
        AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
            [HDJJUtility umsharePosition:_positionInfo withType:sShareType image:image shareText:shareTxt delegate:self];
        }];
        [o start];
    }
}

- (void)sendSMS:(NSString *)bodyOfMessage recipientList:(NSArray *)recipients{
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.navigationBar.tintColor = [UIColor whiteColor];
    if([MFMessageComposeViewController canSendText]){
        controller.body         = bodyOfMessage;
        controller.recipients   = recipients;
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (void)sendmail:(UIImage *)img title:(NSString *)title content:(NSString *)content{
    if (![MFMailComposeViewController canSendMail]) {
        [HDUtility mbSay:@"您尚未设置邮箱"];
        return;
    }
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.navigationBar.tintColor = [UIColor whiteColor];
    if (title.length > 0) {
        [controller setSubject:title];
    }
    [controller setMessageBody:content isHTML:NO];
    if (img) {
        NSData *imageData = UIImagePNGRepresentation(img);
        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@"position"];
    }
    [controller setMailComposeDelegate:self];
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response{

    
}

#pragma mark - setter and getter
- (void)setControlsHidden:(BOOL)hidden{
    btn_201.hidden  = hidden;
    btn_202.hidden  = hidden;
    btn_203.hidden  = hidden;
    btn_204.hidden  = hidden;
    btn_301.hidden  = hidden;
    btn_302.hidden  = hidden;
    btn_303.hidden  = hidden;
    lb_201.hidden   = hidden;
    lb_202.hidden   = hidden;
    lb_203.hidden   = hidden;
    lb_204.hidden   = hidden;
    lb_301.hidden   = hidden;
    lb_302.hidden   = hidden;
    lb_303.hidden   = hidden;
}
@end
