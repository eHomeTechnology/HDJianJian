//
//  HDPersonalApproveCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPersonalApproveCtr.h"
#import "HDApproveCell.h"
#import "HDTableView.h"
#import "TWPhotoPickerController.h"
#import "HDAskForApproveCtr.h"
#import "HDApproveSucceeCtr.h"

#define kApprove_realName       @"realName"
#define kApprove_companyName    @"companyName"
#define kApprove_positionName   @"positionName"
#define kApprove_authenType     @"authenType"

@interface HDPersonalApproveCtr () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>{
    
    HDApproveType approveType;
    AFHTTPRequestOperation *op;
}
@property (strong) IBOutlet HDTableView *tbv;
@property (strong) NSMutableArray       *mar_images;
@property (strong) NSMutableDictionary  *mdc_value;
@end

@implementation HDPersonalApproveCtr

#pragma mark - life cycle

- (id)initWithApproveType:(HDApproveType)type{
    if (self = [super init]) {
        approveType = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setTableFooterView_confirmButton];
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
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height = approveType == HDApproveTypePersonal? 50: 30;
    return section == 1? height: 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, HDDeviceSize.width-40, 20)];
        lb.textAlignment    = NSTextAlignmentCenter;
        lb.textColor        = HDCOLOR_RED;
        lb.numberOfLines    = 2;
        lb.text             = @"请上传身份证和职位证明材料的合照，如“身份证+名片”或者”身份证+工牌“";
        if (approveType == HDApproveTypeEnterprise) {
            lb.text         = @"请上传认证公司的营业执照";
        }
        lb.font             = [UIFont systemFontOfSize:14];
        lb.adjustsFontSizeToFitWidth = YES;
        return lb;
    }
    return nil;
}
#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == 1? 145: 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    int count = approveType == HDApproveTypePersonal? 3: 1;
    return sectionIndex == 1? 1: count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        static NSString     *cellIdentifier = @"HDAddPictureCell";
        HDAddPictureCell    *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [HDAddPictureCell getCell];
        }
        [cell.btn_delet0 addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_delet1 addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_delet2 addTarget:self action:@selector(doDelete:) forControlEvents:UIControlEventTouchUpInside];
        cell.mar_images     = _mar_images;
        [cell.btn_add addTarget:self action:@selector(doChooseImage:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    
    static NSString *cellIdentifier = @"HDSimpleEnterCell";
    HDSimpleEnterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [HDSimpleEnterCell getCell];
    }
    cell.tf_title.indexPath = indexPath;
    cell.tf_title.delegate  = self;
    if (approveType == HDApproveTypePersonal) {
        cell.tf_title.placeholder = @[@"真实姓名", @"企业/组织名称", @"职位"][indexPath.row];
    }else{
        cell.tf_title.placeholder = @"企业/组织名称";
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(HDIndexTextField *)textField{
    switch (textField.indexPath.row) {
        case 0:{
            switch (approveType) {
                case HDApproveTypePersonal:{
                    [_mdc_value setValue:textField.text forKey:kApprove_realName];
                    break;
                }
                case HDApproveTypeEnterprise:{
                    [_mdc_value setValue:textField.text forKey:kApprove_companyName];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:{
            [_mdc_value setValue:textField.text forKey:kApprove_companyName];
            break;
        }
        case 2:{
            [_mdc_value setValue:textField.text forKey:kApprove_positionName];
            break;
        }
        default:
            break;
    }
    return YES;
}
#pragma mark - private method
- (void)httpAskForApprove:(HDApproveType)type{
    NSString *str = type == HDApproveTypePersonal? @"0": @"1";
    [_mdc_value setValue:str forKey:kApprove_authenType];
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    op = [[HDHttpUtility sharedClient] askForApprove:[HDGlobalInfo instance].userInfo approveInfo:_mdc_value completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            return ;
        }
       
        [self.navigationController pushViewController:[HDApproveSucceeCtr new] animated:YES];
    }];
}

#pragma mark - Event Responde

- (void)doDelete:(UIButton *)btn{
    [_mar_images removeObjectAtIndex:btn.tag];
    [self.tbv reloadData];
}

- (void)doChooseImage:(UIButton *)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
    [sheet showInView:self.navigationController.view];
}

- (void)doConfirm:(id)sender{
    if (_mar_images.count == 0) {
        [HDUtility mbSay:@"请选择认证照片"];
        return;
    }
    switch (approveType) {
        case HDApproveTypePersonal:{
            if (((NSString *)_mdc_value[kApprove_realName]).length == 0) {
                [HDUtility mbSay:@"请输入真实姓名"];
                return;
            }
            if (((NSString *)_mdc_value[kApprove_companyName]).length == 0) {
                [HDUtility mbSay:@"请输入公司名称"];
                return;
            }
            if (((NSString *)_mdc_value[kApprove_positionName]).length == 0) {
                [HDUtility mbSay:@"请输入职位名称"];
                return;
            }
        }
        case HDApproveTypeEnterprise:{
            if (((NSString *)_mdc_value[kApprove_companyName]).length == 0) {
                [HDUtility mbSay:@"请输入公司名称"];
                return;
            }
        }
        default:
            break;
    }
    [self httpAskForApprove:approveType];
    
}
#pragma mark - 
#pragma mark getter && setter

- (void)setup{
    self.navigationItem.title = @"申请个人认证";
    _mar_images = [NSMutableArray new];
    _mdc_value = [NSMutableDictionary new];
}

- (void)setTableFooterView_confirmButton{

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, HDDeviceSize.width, 70)];
    v.backgroundColor = [UIColor clearColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, HDDeviceSize.width - 40, 50)];
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(doConfirm:) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = HDCOLOR_RED;
    [v addSubview:btn];
    self.tbv.tableFooterView = v;
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
    photoPicker.cropBlock = ^(UIImage *image) {
        UIImage *image_ = [HDUtility resizeImage:image];
        if (!image_) {
            Dlog(@"Error:图片压缩失败");
            return ;
        }
        [_mar_images addObject:image_];
        [self.tbv reloadData];
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
        [_mar_images addObject:image];
        [self.tbv reloadData];
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
