//
//  HDShareViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/26.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDShareViewCtr.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MessageUI.h>
@interface HDShareViewCtr ()<UMSocialDataDelegate, UMSocialUIDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (strong) IBOutlet UILabel *lb_title;
@end

@implementation HDShareViewCtr

- (id)initWithPosition:(WJPositionInfo *)position{
    if (self = [super init]) {
        self.positionInfo = position;
    }
    return self;
}

- (id)initWithTalent:(HDTalentInfo *)talent{
    if (self = [super init]) {
        self.talentInfo = talent;
        self.lb_title.text  = @"将人才简历分享出去可以获得更多职位信息！";
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
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

#pragma mark UMSocialDataDelegate
-(void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}
#pragma mark - Event and Respond
- (IBAction)doShare:(UIButton *)sender{
    NSString *sShareType    = UMShareToWechatTimeline;
    NSString *sEmployerName = _positionInfo.employerInfo.sName.length > 0? FORMAT(@"《%@》", _positionInfo.employerInfo.sName): @"";
    NSString *sPName        = _positionInfo.sPositionName.length > 0? FORMAT(@"《%@》", _positionInfo.sPositionName): @"高薪职位";
    NSString *shareTxt      = FORMAT(@"%@诚招%@, 请帮我推荐人选", sEmployerName, sPName);
    if (_positionInfo.isBonus) {
        shareTxt = FORMAT(@"%@, 赏金%0.1f元。", shareTxt, _positionInfo.sReward.floatValue/10);
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


@end
