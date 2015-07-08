//
//  HDNewPosition2Ctr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/23.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewPosition2Ctr.h"
#import "HDTableView.h"
#import "HDNewPositionCell.h"
#import "TWPhotoPickerController.h"
#import "HDExtendListCtr.h"
#import "HDEmployerListCtr.h"
#import "HDAddSucViewCtr.h"
#import "HDNewPositionCtr.h"

@interface HDNewPosition2Ctr ()<UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, HDExtendListDelegate, HDEmployerListDelegate, UITextFieldDelegate>{
    
    UITextView  *tv;
}

@property (strong) IBOutlet HDTableView     *tbv;
@property (strong) WJPositionInfo           *positionInfo;
@property (strong) NSArray                  *ar_title;
@property (strong) NSMutableArray           *mar_photos;
@property (strong) AFHTTPRequestOperation   *op;
@property (strong) IBOutlet NSLayoutConstraint  *lc_tbvBottom;
@end

@implementation HDNewPosition2Ctr

- (id)initWithPosition:(WJPositionInfo *)position{

    if (self = [super init]) {
        self.positionInfo = position;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section != 0 || indexPath.row == 0) {
        return;
    }
    if (indexPath.row == 1) {//行业
        HDExtendListCtr *ctr    = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeTrade object:nil maxSelectCount:1];
        ctr.delegate            = self;
        [self.navigationController pushViewController:ctr animated:YES];
    }
    if (indexPath.row == 2) {//性质
        HDExtendListCtr *ctr    = [[HDExtendListCtr alloc] initWithExtendType:HDExtendTypeProperty object:nil maxSelectCount:1];
        ctr.delegate            = self;
        [self.navigationController pushViewController:ctr animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 40;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 1) {
        return nil;
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {
        CGFloat height_ = [HDUtility measureHeightOfUITextView:tv];
        return MIN(MAX(55, height_+30), 100000);;
    }
    if (indexPath.section == 2 && indexPath.row == 1) {
        return 95;
    }
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return 3;
    }
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 1) {//描述
        HDPositionDescCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"HDPositionDescCell"];
        if (cell0 == nil) {
            cell0 = [HDPositionDescCell getPositionDescCell];
        }
        cell0.tv.text       = _positionInfo.employerInfo.sRemark;
        cell0.tv.delegate   = self;
        cell0.tv.textColor  = [UIColor blackColor];
        cell0.tv.alpha      = 1.0;
        tv                  = cell0.tv;
        if ([cell0.tv.text length] == 0) {
            cell0.tv.textColor  = [UIColor grayColor];
            cell0.tv.alpha      = 0.5;
            cell0.tv.text       = LS(@"TXT_JJ_POSITION_DESC_PLACEHOLD");
        }
        cell0.selectionStyle    = UITableViewCellSelectionStyleNone;
        return cell0;
    }
    if (indexPath.section == 2 && indexPath.row == 1) {//Photo
        HDPositionPhotoCell *cell0 = [tableView dequeueReusableCellWithIdentifier:@"HDPositionDescCell"];
        if (cell0 == nil) {
            cell0 = [HDPositionPhotoCell getPhotoDescCell];
        }
        [cell0.btn_addScene addTarget:self action:@selector(doChoosePic:) forControlEvents:UIControlEventTouchUpInside];
        NSArray *ar_imv     = @[cell0.imv_scene0, cell0.imv_scene1, cell0.imv_scene2, cell0.imv_scene3];
        NSArray *ar_delete  = @[cell0.btn_delete0, cell0.btn_delete1, cell0.btn_delete2, cell0.btn_delete3];
        for (UIImageView *imv in ar_imv) {
            imv.image = nil;
        }
        for (int i = 0; i < MIN(_mar_photos.count, 4); i++) {
            UIImage *image      = _mar_photos[i];
            UIImageView *imv    = ar_imv[i];
            [imv setImage:image];
        }
        for (int i = 0; i < ar_delete.count; i ++) {
            UIButton *btn       = ar_delete[i];
            btn.tag             = i;
            UIImageView *imv    = ar_imv[i];
            btn.hidden          = !imv.image;
            [btn addTarget:self action:@selector(doDeletePhoto:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell0.selectionStyle    = UITableViewCellSelectionStyleNone;
        cell0.lc_addLeadingScene.constant = _mar_photos.count * (CGRectGetWidth(cell0.imv_scene0.frame) + 24);
        [cell0 updateConstraints];
        return cell0;
    }
    
    HDNewPositionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HDNewPositionCell"];
    if (!cell) {
        cell = [HDNewPositionCell getNewPositionCell];
    }
    cell.tf_content.enabled     = (indexPath.section == 0 && indexPath.row == 0);
    cell.tf_content.delegate    = self;
    cell.lb_title.text          = _ar_title[indexPath.section][indexPath.row];
    cell.v_line.hidden          = YES;
    cell.v_lineTrailing.hidden  = YES;
    cell.imv_icon.hidden        = YES;
    cell.lc_titleWith.constant  = 70;
    cell.btn_icon.tag           = indexPath.row;
    cell.selectionStyle         = UITableViewCellSelectionStyleNone;
    cell.imv_icon.image         = indexPath.section == 0 && indexPath.row == 0? HDIMAGE(@"btn_pullBlue"): HDIMAGE(@"btn_pull");
    cell.tf_content.text        = indexPath.section == 0 && indexPath.row == 0? _positionInfo.employerInfo.sName: @"";
    [cell.btn_icon addTarget:self action:@selector(doShowEmployeeList:) forControlEvents:UIControlEventTouchUpInside];
    if (indexPath.section == 0 && indexPath.row != 0) {
        cell.selectionStyle     = UITableViewCellSelectionStyleDefault;
        cell.tf_content.text    = @[_positionInfo.employerInfo.sTradeText? _positionInfo.employerInfo.sTradeText: @"",
                                    _positionInfo.employerInfo.sPropertyText? _positionInfo.employerInfo.sPropertyText: @""
                                    ][indexPath.row - 1];
    }
    if (indexPath.section == 0) {
        cell.v_line.hidden          = NO;
        cell.v_lineTrailing.hidden  = indexPath.row != 0;
        cell.imv_icon.hidden        = NO;
    }
    if (indexPath.section == 2 && indexPath.row == 0) {
        cell.lc_titleWith.constant = 300;
    }
    [cell updateConstraints];
    return cell;
}

#pragma mark -
#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:LS(@"TXT_JJ_POSITION_DESC_PLACEHOLD")]) {
        textView.text       = @"";
        _positionInfo.employerInfo.sRemark  = textView.text;
    }
    
    textView.alpha      = 1.0f;
    textView.textColor  = [UIColor blackColor];
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
   _positionInfo.employerInfo.sRemark = textView.text;
    [_tbv beginUpdates];
    [_tbv endUpdates];
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    _positionInfo.employerInfo.sRemark  = textView.text;
    return YES;
}
#pragma mark -
#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField.text.length + string.length > MAX_EMPLOYEE_NAME) {
        [HDUtility mbSay:FORMAT(@"雇主名称不超过%d个字符", MAX_EMPLOYEE_NAME)];
        return NO;
    }
    _positionInfo.employerInfo.sName = FORMAT(@"%@%@", textField.text, string);
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    _positionInfo.employerInfo.sName = textField.text;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    _positionInfo.employerInfo.sName= textField.text;
    [textField resignFirstResponder];
    return YES;
}

#pragma mark -
#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - HDExtendListDelegate
- (void)extendListFinalChooseValue:(NSMutableArray *)mar type:(HDExtendType)type{
    if (mar.count == 0) {
        Dlog(@"Error:没有选择值");
        return;
    }
    HDValueItem *info = mar[0];
    if (type == HDExtendTypeTrade) {
        _positionInfo.employerInfo.sTradeText = info.sValue;
        _positionInfo.employerInfo.sTradeCode = info.sKey;
    }
    if (type == HDExtendTypeProperty) {
        _positionInfo.employerInfo.sPropertyText = info.sValue;
        _positionInfo.employerInfo.sPropertyCode = info.sKey;
    }
    [_tbv reloadData];
}

#pragma mark HDEmployeeListDelegate
- (void)employerListChooseEmployee:(HDEmployerInfo *)info{
    _positionInfo.employerInfo.sRemark          = info.sRemark;
    _positionInfo.employerInfo.sName            = info.sName;
    _positionInfo.employerInfo.sId              = info.sId;
    _positionInfo.employerInfo.sTradeText       = info.sTradeText;
    _positionInfo.employerInfo.sTradeCode       = info.sTradeCode;
    _positionInfo.employerInfo.sPropertyText    = info.sPropertyText;
    _positionInfo.employerInfo.sPropertyCode    = info.sPropertyCode;
    _positionInfo.employerInfo.sScene01         = info.sScene01;
    _positionInfo.employerInfo.sScene02         = info.sScene02;
    _positionInfo.employerInfo.sScene03         = info.sScene03;
    _positionInfo.employerInfo.sScene04         = info.sScene04;
    [_tbv reloadData];
}

#pragma mark - Event and Respond
- (void)doChoosePic:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
    [sheet showInView:self.navigationController.view];
}

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _lc_tbvBottom.constant  = kbSize.height;
    [self.view updateConstraints];
}

- (void)handleKeyboardWillHide:(NSNotification *)notification{
    _lc_tbvBottom.constant = 0.;
    [self.view updateConstraints];
}

- (void)doDeletePhoto:(UIButton *)sender{
    if (sender.tag < _mar_photos.count) {
        [_mar_photos removeObjectAtIndex:sender.tag];
        [_tbv reloadData];
    }
}

- (void)doShowEmployeeList:(UIButton *)sender{
    if (sender.tag != 0) {
        return;
    }
    HDEmployerListCtr *employeeListCtr  = [HDEmployerListCtr new];
    employeeListCtr.delegate            = self;
    [self.navigationController pushViewController:employeeListCtr animated:YES];
}

- (IBAction)doComplete:(id)sender{
    [self httpReleasePosition];
}

- (void)httpModifyPosition{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    _op = [[HDHttpUtility sharedClient] modifyPosition:[HDGlobalInfo instance].userInfo position:self.positionInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
        //[self push2NextPage:self.positionInfo.sPositionNo];
    }];
}

- (void)httpChangeEmployerImage:(UIImage *)image option:(BOOL)isDelete block:(void(^)(BOOL isSuccess, NSString *url))block{
    _op = [[HDHttpUtility sharedClient] changeImageScene:[HDGlobalInfo instance].userInfo image:image positionId:_positionInfo.sPositionNo sceneId:@(image.index).stringValue isDelete:isDelete completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            block(NO, nil);
            return ;
        }
        block(YES, url);
    }];
}

- (void)httpReleasePosition{
    HDHUD *hud = [HDHUD showLoading:LS(@"发布中...") on:self.view];
    HDEmployerInfo *e = _positionInfo.employerInfo;
    BOOL isNoEmployerInfo = e.sName.length == 0 && e.sTradeCode.length == 0 && e.sPropertyCode.length == 0 && e.sRemark.length == 0 && e.mar_urls.count == 0;
    int type = 2;
    if (isNoEmployerInfo) {
        type = 0;
    }
    _op = [[HDHttpUtility sharedClient] releasePosition:[HDGlobalInfo instance].userInfo opType:type position:_positionInfo images:_mar_photos CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *positionId) {
        [HDUtility mbSay:sMessage];
        [hud hiden];
        if (!isSuccess) {
            return ;
        }
        _positionInfo.sUrl          = FORMAT(@"%@Position/Position?pos=%@", [HDGlobalInfo instance].addressInfo.sWebsite_waproot, positionId);
        _positionInfo.sPositionNo   = positionId;
        [self push2NextPage:positionId];
    }];
}

- (void)push2NextPage:(NSString *)positionId{
    HDAddSucViewCtr *ctr = [[HDAddSucViewCtr alloc] initWithPosition:_positionInfo];
    [self.navigationController pushViewController:ctr animated:YES];
    NSMutableArray *mar_ctrs = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (int i = 0; i < mar_ctrs.count; i++) {
        UIViewController *ctr = mar_ctrs[i];
        if ([ctr isKindOfClass:[HDNewPosition2Ctr class]] || [ctr isKindOfClass:[HDNewPositionCtr class]]) {
            [mar_ctrs removeObject:ctr];
            i = 0;
        }
    }
    self.navigationController.viewControllers = mar_ctrs;
}
#pragma mark - setter and getter
- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_RELEASE_POSITION");
    _mar_photos = [NSMutableArray new];
    if (self.positionInfo.employerInfo.sId.length > 0) {
        self.navigationItem.title = @"修改雇主信息";
        HDEmployerInfo *e = self.positionInfo.employerInfo;
        NSArray *ar_urls = @[e.sScene01? e.sScene01: @"", e.sScene02? e.sScene02: @"", e.sScene03? e.sScene03: @"", e.sScene04? e.sScene04: @""];
        for (int i = 0; i < ar_urls.count; i++) {
            NSString *s = ar_urls[i];
            if (s.length == 0) {
                continue;
            }
            [HDJJUtility getImage:s withBlock:^(NSString *code, NSString *message, UIImage *img) {
                [_mar_photos addObject:img];
                [self.tbv reloadData];
            }];
        }
    }
    _ar_title   = @[@[@"雇主名称", @"行       业", @"性       质"], @[@"雇主描述"], @[@"图片(非必填，展示雇主形象)"]];
    UIView *v_ = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 50)];
    v_.backgroundColor = [UIColor clearColor];
    [_tbv setTableFooterView:v_];
}

#pragma mark -
#pragma mark - choose image
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
        UIImage *image_ = [self resizeImage:image];
        if (image_) {
            [_mar_photos addObject:image_];
            [self.tbv reloadData];
        }else{
            Dlog(@"Error:压缩图片出错");
        }
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
        if (data.length == 0) {
            Dlog(@"图片获取失败");
            return;
        }
        UIImage *image = [self resizeImage:img_original];
        if (image) {
            [_mar_photos addObject:image];
            [_tbv reloadData];
        }else{
            Dlog(@"Error:压缩图片出错");
        }
        
        [picker dismissViewControllerAnimated:YES completion:nil];
    }else{
        Dlog(@"获取图片失败");
    }
}
- (UIImage *)resizeImage:(UIImage *)img_original{
    if (!img_original) {
        Dlog(@"Error:传入参数错误");
        return nil;
    }
    NSData *imgSizeData     = UIImageJPEGRepresentation(img_original, 0.5);
    UIImage *image          = [UIImage imageWithData:imgSizeData];
    if (([imgSizeData length] > 1024 * 500) && [imgSizeData length] <= 1024 * 1000){//图片小于300K 不压缩
        image   = [self scaleImage:img_original toScale:0.8];
    }else if( [imgSizeData length] > 1024 * 1000){
        image   = [self scaleImage:img_original toScale:0.7];
    }
    return image;
}
-(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    Dlog(@"获取图片失败");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end



