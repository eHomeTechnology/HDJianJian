//
//  HDChatViewCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/24.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDChatViewCtr.h"
#import "HDBubbleTableView.h"
#import "HDBubbleData.h"
#import "EaseMob.h"
#import "HDChatSendHelper.h"
#import "TWPhotoPickerController.h"
#import "HDMyPositionCtr.h"
#import "HDPositionListView.h"
#import "HDPositionDetailCtr.h"
#import "WJAddPersonalCtr.h"
#import "EaseMob.h"
#import "HDEmUserInfo.h"
#import "WJBrokerDetailsCtr.h"
#import "WJCheckPersonalDetailCtr.h"
#import "EGORefreshTableHeaderView.h"
#import "HDNewsInfo.h"
#import "HDRcmdShowViewCtr.h"

@class HDBubbleTableView;
@interface HDChatViewCtr ()<UITextViewDelegate, HDPositionListDelegate, IDeviceManagerDelegate, EMChatManagerDelegate, EMChatManagerChatDelegate, EGORefreshTableDelegate>{
    HDHUD *hud;
    CGFloat height_tvContent;
    BOOL isShowSelfKeyboard;
}
@property (strong) HDSubscriberInfo     *subInfo;
@property (strong) NSMutableArray       *mar_bubbles;
@property (strong) NSLayoutConstraint   *lc_tabbarHeight;
@property (strong) IBOutlet UIView      *v_tabbar;
@property (strong) IBOutlet UITextView  *tv_text;
@property (strong) IBOutlet UIImageView *imv_bg;
@property (strong) IBOutlet UIButton    *btn_plus;
@property (strong) IBOutlet UIButton    *btn_send;
@property (strong) WJPositionInfo       *positionInfo;
@property (assign) BOOL                 isOnShelve;
@property (strong) HDTalentInfo         *talentInfo;
@property (strong) HDRecommendInfo      *recommendInfo;
@property (strong) NSDictionary         *dic_position;
@property (strong) NSDictionary         *dic_talent;
@property (strong) NSDictionary         *dic_recommend;
@property (strong) EMConversation       *emConversation;
@property (strong) WJBrokerInfo         *brokerInfo;
@property (strong) EGORefreshTableHeaderView *refreshHeaderView;
@property (assign) BOOL isReloading;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tvHeight;
@end

@implementation HDChatViewCtr

#pragma mark - Life Cycle
- (id)initWithJianJianConversation:(HDSubscriberInfo *)info{
    if (info.sSubscriberID.length == 0) {
        Dlog(@"Error:传入参数错误");
        return nil;
    }
    if ([info.sSubscriberID isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo]) {
        [HDUtility mbSay:@"您不能和自己聊天"];
        return nil;
    }
    if (self = [super init]) {
        self.subInfo = info;
        if (info.platformType == HDMessagePlatformTypeEasMobe) {
            _emConversation = [[EaseMob sharedInstance].chatManager conversationForChatter:info.sSubscriberID isGroup:NO];
        }
        self.navigationItem.title   = _subInfo.sSubscriberName;
    }
    return self;
}

- (id)initWithHuman:(HDHumanInfo *)human{
    if (!human || human.sHumanNo.length == 0) {
        Dlog(@"Error:传入数据有误");
        return nil;
    }
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return nil;
    }
    if ([human.sHumanNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo]) {
        [HDUtility mbSay:@"您不能和自己聊天"];
        return nil;
    }
    if (human.sName.length == 0 || human.sAvatarUrl.length == 0) {
        return [self initWithChatterId:human.sHumanNo];
    }
    if (self = [super init]) {
         _emConversation = [[EaseMob sharedInstance].chatManager conversationForChatter:human.sHumanNo isGroup:NO];
        _brokerInfo = (WJBrokerInfo *)human;
        self.navigationItem.title = _brokerInfo.sName;
    }
    return self;
}

- (id)initWithChatterId:(NSString *)chatterId{
    if (chatterId.length == 0) {
        Dlog(@"Error:传入参数错误");
        return nil;
    }
    if (![HDGlobalInfo instance].hasLogined) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_NEET_TO_LOGIN object:nil];
        return nil;
    }
    if ([chatterId isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo]) {
        [HDUtility mbSay:@"您不能和自己聊天"];
        return nil;
    }
    if (self = [super init]) {
        _emConversation = [[EaseMob sharedInstance].chatManager conversationForChatter:chatterId isGroup:NO];
    }
    return self;
}

- (void)viewDidLayoutSubviews{
    //[self setHeaderRefreshView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setEMRegisterDelegate];
    if (self.subInfo && self.subInfo.platformType == HDMessagePlatformTypeJianJian) {
        self.v_tabbar.hidden = YES;
        [self httpGetMessageList];
        return;
    }
    [self setNavigationItemRightButton];
    [self httpGetChatterInfo:^(WJBrokerInfo *info) {
        _brokerInfo = info;
        self.navigationItem.title = _brokerInfo.sName;
        if (_emConversation) {
            [self loadAllHumanMessages];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    height_tvContent                = _tv_text.contentSize.height;
    NSNotificationCenter *center    = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doCheckTalentOrPosition:) name:HD_NOTIFICATION_KEY_BUBBLE_CELL_CHECK object:nil];
    [btv reloadData];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    isShowSelfKeyboard = NO;
    [self.view endEditing:YES];
    [self hideKeyboard];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - HDBubbleTableViewDataSource
- (NSInteger)rowsForBubbleTable:(HDBubbleTableView *)tableView
{
    return [_mar_bubbles count];
}

- (HDBubbleData *)bubbleTableView:(HDBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    HDBubbleData *data = [_mar_bubbles objectAtIndex:row];
    return data;
}

#pragma mark EGORefreshTableDelegate
- (void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos{
    [self beginToReloadData:aRefreshPos];
}

- (BOOL)egoRefreshTableDataSourceIsLoading:(UIView*)view{
    
    return _isReloading;
}
- (NSDate*)egoRefreshTableDataSourceLastUpdated:(UIView*)view{
    
    return [NSDate date];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
}
#pragma mark EMChatManagerChatDelegate
- (void)willReceiveOfflineMessages{

}

- (void)didFinishedReceiveOfflineMessages:(NSArray *)offlineMessage{
    Dlog(@"offlineMessage = %@", offlineMessage);
}

- (void)didReceiveMessageId:(NSString *)messageId
                    chatter:(NSString *)conversationChatter
                      error:(EMError *)error{
    
    
}

- (void)didReceiveMessage:(EMMessage *)message{
    Dlog(@"message = %@", message);
    [_emConversation markAllMessagesAsRead:YES];
    [HDJJUtility getImage:_brokerInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message_, UIImage *img) {
        HDBubbleData *bubble = [HDBubbleData dataWithEMMessage:message avatar:img];
        [_mar_bubbles addObject:bubble];
        [btv reloadData];
        [self scrollBottom];
    }];
}
- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message error:(EMError *)error{
    Dlog(@"finished");
    if (message.messageBodies.count == 0) {
        Dlog(@"这个必须返回");
        return;
    }
    if (![message.messageBodies[0] isKindOfClass:[EMImageMessageBody class]]) {
        Dlog(@"不是图片消息，不用下载附件");
        return;
    }
    [[EaseMob sharedInstance].chatManager asyncFetchMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *error) {
        if (error) {
            Dlog(@"下载附件失败！aMessage = %@", aMessage);
            return ;
        }
        [HDJJUtility getImage:_brokerInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message_, UIImage *img) {
            HDBubbleData *bubble = [HDBubbleData dataWithEMMessage:message avatar:img];
            HDBubbleData *d = _mar_bubbles.lastObject;
            if ([d.bubbleNo isEqualToString:bubble.bubbleNo]) {
                [_mar_bubbles removeLastObject];
                [_mar_bubbles addObject:bubble];
            }
            [btv reloadData];
            [self scrollBottom];
        }];
    } onQueue:nil];
}
#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {//send message
        [self sendTextTypeMessage:textView.text type:1];
        _tv_text.text = @"";
        [self textViewDidChange:textView];
        return NO;
    }
    if (textView.text.length > 500) {
        return NO;
    }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    CGFloat height = [HDUtility measureHeightOfUITextView:textView] + 5;
    if (height > 100) {
        return;
    }
    _lc_tvHeight.constant       = height;
    CGFloat d                   = height - height_tvContent;
    if (d == 0) {
        return;
    }
    height_tvContent            = height;
    _lc_tabbarHeight.constant   = _lc_tabbarHeight.constant + d;
    _lc_tbvBottom.constant      = _lc_tabbarHeight.constant;
    _imv_bg.image = [[UIImage imageNamed:@"bg_tabbar"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    [UIView animateWithDuration:0.1 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark HDPositionListDelegate
- (void)positionListDidSelectPosition:(WJPositionInfo *)info isOnShelve:(BOOL)isOn{
    self.positionInfo = info;
    self.isOnShelve = isOn;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送职位" message:@"确定发送该职位?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = 999;
    [alert show];
}

#pragma mark HDMyTalentDelegate
- (void)myTalentDidSelectTalent:(HDRecommendInfo *)info isMeAddTalent:(BOOL)isOn{
    _isOnShelve = isOn;
    _recommendInfo = info;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送简历" message:@"确定发送该简历?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
    alert.tag = 888;
    [alert show];
}

#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 999 && buttonIndex == 0) {//职位
        [self sendPosition:self.positionInfo];
    }
    if (alertView.tag == 888 && buttonIndex == 0) {//简历
        [self sendResume:self.recommendInfo];
    }
}

#pragma mark - Event and Respond

- (void)loadAllHumanMessages{
    NSArray *ar = [_emConversation loadAllMessages];
    for (int i = 0; i < ar.count; i++) {
        EMMessage *message_ = ar[i];
        BOOL isMyMessage = [message_.from isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
        NSString *sUrl = isMyMessage? [HDGlobalInfo instance].userInfo.sAvatarUrl: _brokerInfo.sAvatarUrl;
        [HDJJUtility getImage:sUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
            if (message_.messageBodies.count == 0) {
                NSLog(@"奔溃了？请看这里！");
            }
            if ([message_.messageBodies[0] isKindOfClass:[EMImageMessageBody class]]) {//如果是图片，下载附件后处理数据
                [[EaseMob sharedInstance].chatManager asyncFetchMessage:message_ progress:nil completion:^(EMMessage *aMessage, EMError *error) {
                    HDBubbleData *data = [HDBubbleData dataWithEMMessage:message_ avatar:img];
                    if (data) {
                        [_mar_bubbles addObject:data];
                    }
                    [btv reloadData];
                    [self scrollBottom];
                } onQueue:nil];
            }else{
                HDBubbleData *data = [HDBubbleData dataWithEMMessage:message_ avatar:img];
                if (data) {
                    [_mar_bubbles addObject:data];
                }
            }
            [btv reloadData];
            [self scrollBottom];
        }];
    }
    [self finishReloadingData];
    [btv reloadData];
    [self scrollBottom];
}
- (void)doShowChatterDetail{
    if (self.brokerInfo) {
        [self.navigationController pushViewController:[[WJBrokerDetailsCtr alloc] initWithInfo:_brokerInfo] animated:YES];
        return;
    }
    NSString *sChatterId = _emConversation? _emConversation.chatter: self.subInfo.sSubscriberID;
    [self.navigationController pushViewController:[[WJBrokerDetailsCtr alloc] initWithInfoID:sChatterId] animated:YES];
}

- (void)doCheckTalentOrPosition:(NSNotification *)noti{
    NSDictionary *dic = noti.userInfo;
    if ([dic[@"key"] isEqualToString:@"talent"]) {
        HDTalentInfo *talentInfo    = noti.object;
        BOOL isMytalent = [talentInfo.sUserNo isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
        if (!isMytalent) {
            return;
        }
        WJCheckPersonalDetailCtr *ctr = [[WJCheckPersonalDetailCtr alloc] initWithPersonalno:talentInfo.sHumanNo isOpen:talentInfo.isOpen];
        [self.navigationController pushViewController:ctr animated:YES];
        return;
    }
    if ([dic[@"key"] isEqualToString:@"position"]) {
        WJPositionInfo *positionInfo = noti.object;
        HDPositionDetailCtr *details = [[HDPositionDetailCtr alloc] initWithPosition:positionInfo.sPositionNo isOnShelve:self.isOnShelve];
        [self.navigationController pushViewController:details animated:YES];
    }
}

- (IBAction)doShowMyKeyboard:(id)sender{
    if (!isShowSelfKeyboard) {
        isShowSelfKeyboard = YES;
        [self.view endEditing:YES];
        _lc_tabbarHeight.constant   = height_tvContent + KEYBOARD_HEIGHT;
        _lc_tbvBottom.constant      = _lc_tabbarHeight.constant;
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        [self scrollBottom];
        return;
    }
    isShowSelfKeyboard = NO;
    [_tv_text becomeFirstResponder];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tabbarHeight.constant   = kbSize.height + height_tvContent + 16;
    _lc_tbvBottom.constant      = _lc_tabbarHeight.constant;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    [self scrollBottom];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification{
    if (isShowSelfKeyboard) {
        return;
    }
    [self hideKeyboard];
}

- (void)uploadPhoto:(UIImage *)img_{
    if (!img_) {
        Dlog(@"Error:传入参数错误，imgs不能为空");
        return;
    }
    [HDJJUtility getImage:[HDGlobalInfo instance].userInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        EMChatImage *chatImage = [[EMChatImage alloc] initWithUIImage:img_ displayName:@"image.jpg"];
        EMImageMessageBody *body = [[EMImageMessageBody alloc] initWithImage:chatImage thumbnailImage:chatImage];
        EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:_emConversation.chatter bodies:[NSArray arrayWithObject:body]];
        retureMsg.requireEncryption = NO;
        retureMsg.isGroup = NO;
        HDBubbleData *data = [HDBubbleData dataWithEMMessage:retureMsg avatar:img];
        [_mar_bubbles addObject:data];
        [btv reloadData];
        [self scrollBottom];
        [[EaseMob sharedInstance].chatManager asyncSendMessage:retureMsg progress:nil prepare:nil onQueue:nil completion:^(EMMessage *message, EMError *error) {
            HDBubbleData *d = [HDBubbleData dataWithEMMessage:retureMsg avatar:img];
            [_mar_bubbles removeLastObject];
            [_mar_bubbles addObject:d];
            [btv reloadData];
            [self scrollBottom];
            [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_CONVERSATION_LIST object:nil];
        } onQueue:nil];
    }];
}
-(IBAction)doSendInfo:(UIButton *)sender{
    switch (sender.tag) {
        case 0:{//图片
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
            [sheet showInView:self.navigationController.view];
            break;
        }
        case 1:{//职位
            HDMyPositionCtr *position   = [[HDMyPositionCtr alloc] initWithObject:self];
            [self.navigationController pushViewController:position animated:YES];
            break;
        }
        case 2:{//简历
            HDMyTalentCtr *talents   = [[HDMyTalentCtr alloc] init];
            talents.myDelegate = self;
            [self.navigationController pushViewController:talents animated:YES];
            break;
        }
        default:
            break;
    }
}
- (IBAction)doSendText:(id)sender{
    if (self.tv_text.text.length == 0) {
        return;
    }
    [self sendTextTypeMessage:_tv_text.text type:1];
}
- (void)sendTextTypeMessage:(NSString *)txt type:(int)type{//type:1、字符串，7、简历，8、职位
    if (txt.length == 0 || type < 1 || type > 8 || (type < 7 && type > 1)) {
        Dlog(@"Error:传入参数有误");
        return;
    }
    [HDJJUtility getImage:[HDGlobalInfo instance].userInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        EMChatText *text = [[EMChatText alloc] initWithText:txt];
        EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
        EMMessage *retureMsg = [[EMMessage alloc] initWithReceiver:_emConversation.chatter bodies:@[body]];
        retureMsg.requireEncryption = NO;
        retureMsg.isGroup   = NO;
        NSString *sAvatar   = [HDGlobalInfo instance].userInfo.sAvatarUrl? [HDGlobalInfo instance].userInfo.sAvatarUrl: @"";
        NSString *sName     = [HDGlobalInfo instance].userInfo.sName? [HDGlobalInfo instance].userInfo.sName: @"";
        retureMsg.ext = @{@"chat_formattype": @(type), @"chat_head_url": sAvatar, @"chat_nick_name": sName};
        HDBubbleData *data = [HDBubbleData dataWithEMMessage:retureMsg avatar:img];
        [_mar_bubbles addObject:data];
        [btv reloadData];
        [self scrollBottom];
        data.status = HDSendingNewsStatusSuccess;
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_CONVERSATION_LIST object:nil];
        EMError *error = nil;
        [[EaseMob sharedInstance].chatManager sendMessage:retureMsg progress:nil error:&error];
        if (!error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_CONVERSATION_LIST object:nil];
        }
        [btv reloadData];
        [self scrollBottom];
    }];
}

- (void)scrollBottom{
    if (btv.contentSize.height < btv.frame.size.height) {
        return;
    }
    CGPoint bottomOffset = CGPointMake(0, btv.contentSize.height - btv.bounds.size.height);
    [btv setContentOffset:bottomOffset animated:NO];
}

- (void)hideKeyboard{
    _lc_tabbarHeight.constant   = height_tvContent + 16;
    _lc_tbvBottom.constant      = _lc_tabbarHeight.constant;
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)httpGetChatterInfo:(void(^)(WJBrokerInfo *info))block{
    hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    NSString *sChatterId = _emConversation? _emConversation.chatter: self.subInfo.sSubscriberID;
    [[HDHttpUtility sharedClient] getBrokerInfo:[HDGlobalInfo instance].userInfo userno:sChatterId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            block(nil);
            return ;
        }
        _brokerInfo = info;
        block(info);
    }];
}
- (void)httpGetMessageList{
    hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    [[HDHttpUtility sharedClient] getSubscribeDetail:[HDGlobalInfo instance].userInfo subscribeId:_subInfo.sSubscriberID lastTicks:@"0" completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSArray *list, BOOL isLastPage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [HDJJUtility getImage:_subInfo.sSubscriberLogo withBlock:^(NSString *code, NSString *message, UIImage *img){
            UIImage *image = img;
            if ([code intValue] != 0) {
                image = HDIMAGE(@"icon_headFalse");
            }
            for (int i = 0; i < list.count; i++) {
                HDMessageInfo *info = list[i];
                info.img_avata = image;
                HDBubbleData *data = [HDBubbleData dataWithMessageInfo:info];
                int index = [self hasBubbleData:data];
                if (index > 0) {
                    [_mar_bubbles replaceObjectAtIndex:index withObject:data];
                }else{
                    [_mar_bubbles addObject:data];
                }
            }
            [btv reloadData];
            [self scrollBottom];
        }];
    }];
}

- (int)hasBubbleData:(HDBubbleData *)bubble{
    for (int i = 0; i < _mar_bubbles.count; i++) {
        HDBubbleData *d = _mar_bubbles[i];
        if ([d.bubbleNo isEqualToString:bubble.bubbleNo] && d.bubbleType == bubble.bubbleType) {
            return i;
        }
    }
    return -1;
}
- (void)sendPosition:(WJPositionInfo *)position{
    WJPositionInfo *p = position;
    NSString *sRemark = p.sRemark.length > 100? [p.sRemark substringToIndex:100]: p.sRemark;
    NSDictionary *dic = @{@"CompanyName": (p.employerInfo.sName? p.employerInfo.sName:@""), @"PositionDes": (sRemark? sRemark: @""), @"PositionName": (p.sPositionName? p.sPositionName: @""), @"PositionNo": (p.sPositionNo?  p.sPositionNo: @"")};
    NSString *str = [dic JSONRepresentation];
    Dlog(@"str = %@", str);
    [self sendTextTypeMessage:str type:8];
}
- (void)sendResume:(HDRecommendInfo *)recommend{
    HDRecommendInfo *p = recommend;
    NSDictionary *dic = @{@"CompanyName": (p.sCurCompanyName? p.sCurCompanyName: @""), @"PersonalName": (p.sName? p.sName: @""), @"PersonalNo": (p.sHumanNo? p.sHumanNo: @""), @"PersonalPhone": (p.sPhone? p.sPhone: @""), @"PositionName": (p.sCurPosition? p.sCurPosition: @""), @"WorkYears": (p.sWorkYears? p.sWorkYears: @"")};
    NSString *str = [dic JSONRepresentation];
    [self sendTextTypeMessage:str type:7];
}
#pragma mark - Getter and Setter
- (void)setup{
    self.dic_position   = [[NSDictionary alloc] init];
    self.dic_talent     = [[NSDictionary alloc] init];
    self.dic_recommend  = [[NSDictionary alloc] init];
    self.btn_plus.hidden        = self.subInfo && (self.subInfo.platformType == HDMessagePlatformTypeJianJian);
    btv.bubbleDataSource        = self;
    _mar_bubbles                = [[NSMutableArray alloc] init];
    isShowSelfKeyboard          = NO;
    _btn_send.hidden            = !self.btn_plus.hidden;
    _btn_send.layer.cornerRadius    = 5;
    _btn_send.layer.masksToBounds   = YES;
    [self.view addSubview:_v_tabbar];
    [self.view bringSubviewToFront:_v_tabbar];
    [_v_tabbar setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *dict1         = NSDictionaryOfVariableBindings(_v_tabbar);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT(@"|[_v_tabbar]|")
                                                                      options:0
                                                                      metrics:nil
                                                                        views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_v_tabbar(50)]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:dict1]];
    [self.view.constraints enumerateObjectsUsingBlock:^(NSLayoutConstraint *constraint, NSUInteger idx, BOOL *stop) {
        if ((constraint.firstItem == _v_tabbar) && (constraint.firstAttribute == NSLayoutAttributeHeight)) {
            _lc_tabbarHeight = constraint;
            Dlog(@"_lc_tabbarHeight.constent = %f", _lc_tabbarHeight.constant);
        }
    }];
    _lc_tbvBottom.constant = 50;
}

- (void)setEMRegisterDelegate{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
    //注册为SDK的ChatManager的delegate
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}
- (void)setNavigationItemRightButton{
    UIButton *btn_camera = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_camera.frame = CGRectMake(0, 0, 25, 25);
    [btn_camera setBackgroundImage:HDIMAGE(@"btn_checkBroker") forState:UIControlStateNormal];
    [btn_camera addTarget:self action:@selector(doShowChatterDetail) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_camera];
}
#pragma mark - choose image 模块
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
    photoPicker.cropOriginalBlock = ^(UIImage *image) {
        UIImage *image_ = [HDUtility resizeImage:image];
        if (!image_) {
            Dlog(@"Error:图片压缩失败");
            return ;
        }
        [self uploadPhoto:image];
    };
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)doTakePicture:(id)sender{
    UIImagePickerController *imagePickerCtr  = [[UIImagePickerController alloc] init];
    imagePickerCtr.delegate                  = self;
    imagePickerCtr.allowsEditing             = YES;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerCtr.sourceType            = UIImagePickerControllerSourceTypeCamera;
    }
    [self.navigationController presentViewController:imagePickerCtr animated:YES completion:nil];
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
        [self uploadPhoto:image];
    }else{
        Dlog(@"Error:获取图片失败");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    Dlog(@"获取图片失败");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark refresh模块
-(void)setHeaderRefreshView{
    if (_refreshHeaderView && [_refreshHeaderView superview]) {
        [_refreshHeaderView removeFromSuperview];
    }
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.view.bounds.size.height, self.view.frame.size.width, self.view.bounds.size.height)];
    _refreshHeaderView.delegate = self;
    [btv addSubview:_refreshHeaderView];
    [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)beginToReloadData:(EGORefreshPos)aRefreshPos{
    _isReloading = YES;
    if (aRefreshPos == EGORefreshHeader) {
        [self loadAllHumanMessages];
    }
}

- (void)finishReloadingData{
    _isReloading = NO;
    if (_refreshHeaderView) {
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:btv];
    }
}

@end
