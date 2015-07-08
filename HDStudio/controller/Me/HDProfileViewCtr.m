//
//  HDProfileViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 14/12/12.
//  Copyright (c) 2014年 Hu Dennis. All rights reserved.
//

#import "HDProfileViewCtr.h"
#import "HDTableView.h"
#import "HDExtendListCtr.h"
#import "TWPhotoPickerController.h"
#import "WJBrokerDetailsCtr.h"
#import "HDValueItem.h"

@implementation HDIndexPathTextField
@end

@implementation HDJianIntroCell

+ (HDJianIntroCell *)getCell{
    HDJianIntroCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDProfileCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDJianIntroCell class]]) {
            cell = (HDJianIntroCell *)obj;
            break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end

@implementation HDProfileCell

+ (HDProfileCell *)getCell{
    HDProfileCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDProfileCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDProfileCell class]]) {
            cell = (HDProfileCell *)obj;
            break;
        }
    }
    return cell;
}
@end

@interface HDProfileViewCtr ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, HDExtendListDelegate, UITextViewDelegate, UITextFieldDelegate>{
    CGFloat height_JianIntroCell;
    IBOutlet UIView *v_head;
}
@property (strong) HDUserInfo               *userInfo;
@property (strong) IBOutlet HDTableView     *tbv;
@property (strong) IBOutlet UIButton        *btn_avatar;
@property (strong) AFHTTPRequestOperation   *op;
@property (strong) UIImage                  *img_selected;

@property (strong) IBOutlet NSLayoutConstraint   *lc_tbvBottom;
@end

@implementation HDProfileViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self httpGetProfile];
    [self setTableHead];
}

- (void)viewWillAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            HDExtendListCtr *ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeArea object:_userInfo.sAreaKey maxSelectCount:1];
            ctr.delegate = self;
            [self.navigationController pushViewController:ctr animated:YES];
        }
        return;
    }
    HDExtendListCtr *ctr = nil;
    switch (indexPath.row) {
        case 0:{
            ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade object:_userInfo.sTradeKey maxSelectCount:3];
            break;
        }
        case 1:{
            ctr = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypePost object:_userInfo.sPostKey maxSelectCount:3];
            break;
        }
        default:
            break;
    }
    ctr.delegate = self;
    [self.navigationController pushViewController:ctr animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return section == 1? 30: 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, HDDeviceSize.width-40, 20)];
    lb.textAlignment    = NSTextAlignmentCenter;
    lb.textColor        = HDCOLOR_RED;
    lb.text             = @"在此展示您的专长和职业阅历，吸引雇主并获得信赖";
    lb.font             = [UIFont systemFontOfSize:14];
    lb.adjustsFontSizeToFitWidth = YES;
    return lb;
}
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0 && indexPath.row == 3)? height_JianIntroCell + 60: 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return sectionIndex == 0? 4: 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 3 && indexPath.section == 0) {
        HDJianIntroCell *jianInfoCell   = [HDJianIntroCell getCell];
        jianInfoCell.tv.delegate        = self;
        jianInfoCell.tv.text            = _userInfo.sAnnounce;
        return jianInfoCell;
    }
    static NSString *cellIdentifier = @"talentview";
    HDProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDProfileCell getCell];
    }
    cell.btn_pullDown.hidden    = YES;
    cell.lb_nian.hidden         = YES;
    cell.tf_value.enabled       = YES;
    cell.tf_value.indexPath     = indexPath;
    cell.tf_value.delegate      = self;
    cell.tf_value.keyboardType  = UIKeyboardTypeDefault;
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                cell.lb_title.text          = @"昵      称";
                cell.tf_value.text          = _userInfo.sName;
                break;
            }
            case 1:{
                cell.lb_title.text          = @"地      区";
                cell.tf_value.placeholder   = @"建议选择";
                cell.tf_value.enabled       = NO;
                cell.tf_value.text          = [HDAreaInfo getAreaValueWithKey:_userInfo.sAreaKey];
                cell.btn_pullDown.hidden    = NO;
                cell.selectionStyle         = UITableViewCellSelectionStyleGray;
                break;
            }
            case 2:{
                cell.lb_title.text          = @"联系电话";
                cell.tf_value.text          = _userInfo.sShopMPhone;
                cell.tf_value.keyboardType  = UIKeyboardTypePhonePad;
                break;
            }
            default:
                break;
        }
        cell.tf_value.tag   = indexPath.row;
        [cell.tf_value addTarget:self action:@selector(doEndEditingTextField:) forControlEvents:UIControlEventEditingDidEnd];
    }else{
        switch (indexPath.row) {
            case 0:{//行业
                cell.lb_title.text          = @"擅长行业";
                cell.btn_pullDown.hidden    = NO;
                cell.tf_value.placeholder   = @"请选择";
                cell.tf_value.enabled       = NO;
                cell.selectionStyle         = UITableViewCellSelectionStyleGray;
                NSArray *ar                 = [_userInfo.sTradeKey componentsSeparatedByString:@"|"];
                NSString *s                 = [HDTradeInfo getTradeValueWithKeys:ar];
                cell.tf_value.text          = s;
                break;
            }
            case 1:{//职能
                cell.lb_title.text          = @"擅长职位";
                cell.tf_value.placeholder   = @"请选择";
                cell.tf_value.enabled       = NO;
                cell.btn_pullDown.hidden    = NO;
                cell.selectionStyle         = UITableViewCellSelectionStyleGray;
                NSArray *ar                 = [_userInfo.sPostKey componentsSeparatedByString:@"|"];
                NSString *s                 = [HDPostInfo getPostValuesWithKeys:ar];
                cell.tf_value.text          = s;
                break;
            }
            case 2:{//我已经工作年数
                cell.lb_title.text          = @"我已工作";
                cell.lb_nian.hidden         = NO;
                NSString *sYear             = [_userInfo.sWorkYears isEqualToString:@"无"]? @"0": _userInfo.sWorkYears;
                cell.tf_value.text          = [sYear hasSuffix:@"年"]? [sYear substringToIndex:sYear.length - 1]: sYear;
                break;
            }
            case 3:{//当前公司
                cell.lb_title.text          = @"当前公司";
                cell.tf_value.placeholder   = @"为保密，可填“某房地产上市公司”等";
                cell.tf_value.text          = _userInfo.sCurCompany;
                break;
            }
            case 4:{//当前职位
                cell.lb_title.text          = @"当前职位";
                cell.tf_value.text          = _userInfo.sCurPosition;
                break;
            }
            default:
                break;
        }
    }
    return cell;
}


#pragma mark UIActionSheetDelegate and UIImagePickerControllerDelegate
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img_original       = [info objectForKey:UIImagePickerControllerEditedImage];
        NSData *data = UIImageJPEGRepresentation(img_original, 1);
        if (data.length == 0) {
            Dlog(@"图片获取失败");
            return;
        }
        UIImage *image = [HDUtility resizeImage:img_original];
        if (image) {
            _img_selected = image;
            [_btn_avatar setBackgroundImage:_img_selected forState:UIControlStateNormal];
            [self uploadPhoto:image];
        }else{
            Dlog(@"Error:压缩图片出错");
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        Dlog(@"获取图片失败");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    Dlog(@"获取图片失败");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark HDExtendListDelegate

- (void)extendListFinalChooseValueWithKey:(NSString *)key type:(HDExtendType)type{

    switch (type) {
        case HDExtendTypeArea:{
            _userInfo.sAreaKey = key;
            break;
        }
        case HDExtendTypeTrade:{
            _userInfo.sTradeKey = key;
            break;
        }
        case HDExtendTypePost:{
            _userInfo.sPostKey = key;
            break;
        }
        default:
            break;
    }
    [self.tbv reloadData];
}
#pragma mark UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    CGFloat f = [HDUtility measureHeightOfUITextView:textView];
    height_JianIntroCell = MAX(f + 20, 55);
    _userInfo.sAnnounce = textView.text;
    _userInfo.sRemark   = textView.text;
    [self.tbv beginUpdates];
    [self.tbv endUpdates];
}

#pragma mark UITextFieldDelegate 
- (BOOL)textFieldShouldEndEditing:(HDIndexPathTextField *)textField{
    switch (textField.indexPath.section) {
        case 0:{
            switch (textField.indexPath.row) {
                case 0:{//昵称
                    _userInfo.sName = textField.text;
                    break;
                }
                case 2:{//电话
                    _userInfo.sShopMPhone = textField.text;
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 1:{
            switch (textField.indexPath.row) {
                case 2:{//工作年数
                    _userInfo.sWorkYears = [textField.text stringByAppendingString:@"年"];
                    NSString *str = [HDUtility readNowTimeWithFormate:@"YYYY.MM.dd"];
                    Dlog(@"str = %@", str);
                    NSArray *ar = [str componentsSeparatedByString:@"."];
                    NSString *year = ar[0];
                    Dlog(@"year = %@", year);
                    NSString *starYear = FORMAT(@"%@.%@.%@", @(year.intValue - textField.text.intValue), ar[1], ar[2]);
                    _userInfo.sStartWorkDT = starYear;
                    break;
                }
                case 3:{//当前公司
                    _userInfo.sCurCompany = textField.text;
                    break;
                }
                case 4:{//当前职位
                    _userInfo.sCurPosition  = textField.text;
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
    return YES;
}

#pragma mark -
#pragma mark Event Response

- (IBAction)doPreviewAndSaveAction:(UIButton *)sender{
    [self.view endEditing:YES];
    switch (sender.tag) {
        case 0:{
            WJBrokerDetailsCtr *ctr = [[WJBrokerDetailsCtr alloc] initWithInfo:_userInfo];
            [self.navigationController pushViewController:ctr animated:YES];
            break;
        }
        case 1:{
            [self.view endEditing:YES];
            if (_userInfo.sName.length > 25) {
                [HDUtility mbSay:@"用户昵称字符数最大值为25"];
                return;
            }
            if (![HDUtility isValidateMobile:_userInfo.sShopMPhone]) {
                [HDUtility mbSay:@"请输入正确的手机号码"];
                return;
            }
            [self httpUploadData:_userInfo];
            break;
        }
        default:
            break;
    }
}
- (void)doChooseImageFromAlbum:(id)sender{
    TWPhotoPickerController *photoPicker    = [[TWPhotoPickerController alloc] init];
    photoPicker.cropBlock = ^(UIImage *image) {
        UIImage *image_ = [HDUtility resizeImage:image];
        if (image_) {
            _img_selected = image_;
            [_btn_avatar setBackgroundImage:_img_selected forState:UIControlStateNormal];
            [self uploadPhoto:image];
        }else{
            Dlog(@"Error:压缩图片出错");
        }
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

- (IBAction)doChoosePic:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
    [sheet showInView:self.navigationController.view];
}

- (void)doEndEditingTextField:(UITextField *)sender{
    switch (sender.tag) {
        case 0:{
            _userInfo.sName = sender.text;
            break;
        }
        case 1:{
            _userInfo.sShopMPhone    = sender.text;
            break;
        }
        case 2:{
            _userInfo.sWeixin   = sender.text;
            break;
        }
        case 3:{
            _userInfo.sQQ       = sender.text;
            break;
        }
        default:
            break;
    }
}
#pragma mark -
#pragma mark privite method
- (void)uploadPhoto:(UIImage *)img{
    if (!img) {
        Dlog(@"Error:传入参数错误，img不能为空");
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"") on:self.view];
    [[HDHttpUtility sharedClient] uploadLogo:[HDGlobalInfo instance].userInfo flag:@"4" avatar:img completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
        [HDGlobalInfo instance].userInfo.sAvatarUrl = url;
        
    }];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view setNeedsUpdateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 50.;
    [self.view setNeedsUpdateConstraints];
    
}

- (void)httpGetProfile{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.tbv];
    _op = [[HDHttpUtility sharedClient] getBrokerInfo:[HDGlobalInfo instance].userInfo userno:[HDGlobalInfo instance].userInfo.sHumanNo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, WJBrokerInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        _userInfo = [_userInfo initWithBrokerInfo:info];
        [HDGlobalInfo instance].userInfo = _userInfo;
        height_JianIntroCell = [HDJJUtility heightOfString:_userInfo.sAnnounce font:[UIFont systemFontOfSize:15] width:HDDeviceSize.width - 60 maxHeight:9999999] + 30;
        [self.tbv reloadData];
        [HDJJUtility getImage:_userInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
            if ([code intValue] != 0) {
                [_btn_avatar setBackgroundImage:HDIMAGE(@"icon_headFalse") forState:UIControlStateNormal];
                return ;
            }
            [_btn_avatar setBackgroundImage:img forState:UIControlStateNormal];
        }];
    }];
}

- (void)httpUploadData:(HDUserInfo *)user{
    
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op = [[HDHttpUtility sharedClient] modifyProfile:[HDGlobalInfo instance].userInfo modifyUser:user completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
        [HDGlobalInfo instance].userInfo.sName          = user.sName;
        [HDGlobalInfo instance].userInfo.sShopMPhone    = user.sShopMPhone;
        [HDGlobalInfo instance].userInfo.sWeixin        = user.sWeixin;
        [HDGlobalInfo instance].userInfo.sQQ            = user.sQQ;
        [HDGlobalInfo instance].userInfo.sTradeKey      = user.sTradeKey;
        [HDGlobalInfo instance].userInfo.sPostKey       = user.sPostKey;
        [HDGlobalInfo instance].userInfo.sAreaKey       = user.sAreaKey;
        [HDGlobalInfo instance].userInfo.sStartWorkDT   = user.sStartWorkDT;
    }];
}

#pragma mark - 
#pragma mark Setter and Getter
- (void)setTableHead{
    v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 120);
    self.tbv.tableHeaderView = v_head;
}

- (void)setup{
    height_JianIntroCell        = 120;
    self.navigationItem.title   = LS(@"HD_TITLE_MY_PROFILE");
    _userInfo = [HDGlobalInfo instance].userInfo;
    [HDJJUtility getImage:_userInfo.sAvatarUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
        if ([code intValue] != 0) {
            [_btn_avatar setBackgroundImage:HDIMAGE(@"icon_headFalse") forState:UIControlStateNormal];
            return ;
        }
        [_btn_avatar setBackgroundImage:img forState:UIControlStateNormal];
    }];
}

@end
