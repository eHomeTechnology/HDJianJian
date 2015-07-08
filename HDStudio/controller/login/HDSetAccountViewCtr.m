//
//  HDEnterPwdViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/6.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDSetAccountViewCtr.h"
#import "LDCry.h"
#import "BaseFunc.h"
#import "HDJJUtility.h"
#import "TWPhotoPickerController.h"
#import "HDBlogViewCtr.h"
#import "HDLoginHelper.h"

@interface HDSetAccountViewCtr ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>{
    IBOutlet UITextField    *tf_pwd;
    IBOutlet UITextField    *tf_nickName;
    IBOutlet UIButton       *btn_choosePic;
    NSString *sPhone;
    NSString *sCode;
    BOOL _isRegister;
    NSString *imgUrl;
}

@property (strong) UIImage *img_head;
@property (strong) UIImage  *avatar;

@end

@implementation HDSetAccountViewCtr

- (id)initWithPhone:(NSString *)phone code:(NSString *)code isRegister:(BOOL)isRegister{

    if (![HDUtility isValidateMobile:phone] || code.length == 0) {
        Dlog(@"传入参数有误，请核对代码");
        return nil;
    }
    if (self = [super init]) {
        sPhone  = phone;
        sCode   = code;
    }
    if (self = [super init]) {
        _isRegister = isRegister;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doChoosePic:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
    [sheet showInView:self.navigationController.view];
}
- (IBAction)doNext:(id)sender{
    if (tf_nickName.text.length == 0) {
        [HDUtility say:LS(@"TXT_PLEASE_ENTER_YOUR_NICK_NAME")];
        return;
    }
    if (tf_nickName.text.length >= 36) {
        [HDUtility say:LS(@"您的昵称输入过长")];
        return;
    }
    if (![HDUtility isValidatePassword:tf_pwd.text]) {
        [HDUtility say:LS(@"TXT_ENTER_LEAST_6_PASSWORD")];
        return;
    }
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.navigationController.view];
    [[HDHttpUtility sharedClient] getRandomKey:^(BOOL isSuccess, NSString *key, NSString *code, NSString *message) {
        if (!isSuccess) {
            [hud hiden];
            [HDUtility say:message];
            return;
        }
        NSString *sRealKey = [BaseFunc getRadomKey:key];
        Dlog(@"sRealKey = %@", sRealKey);
        if (sRealKey.length != 16) {
            [hud hiden];
            [HDUtility say:LS(@"TXT_PROMPT_FAIL_GET_SESSION_KEY")];
            return;
        }
        NSString *sEncryPwd = [LDCry encrypt:tf_pwd.text password:sRealKey];
        [[HDHttpUtility sharedClient] registerWithPhone:sPhone nickname:tf_nickName.text password:sEncryPwd code:sCode CompletionBlock:^(BOOL isSuccess, NSString *sCode, HDUserInfo *user, NSString *sMessage) {
            [hud hiden];
            [HDUtility mbSay:sMessage];
            if (!isSuccess) {
                return ;
            }
            NSString *str       = FORMAT(@"%@%@_jj&", tf_pwd.text, user.sHumanNo);
            NSString *cryPwd    = [LDCry getMd5_32Bit_String:str];
            [HDLoginHelper loginEaseMobe:user.sHumanNo pwd:cryPwd block:^(BOOL isSuccess, EMError *error, HDEmUserInfo *emUser) {
                if (!isSuccess) {
                    [HDUtility mbSay:error.description];
                    return ;
                }
                user.sAvatarUrl     = imgUrl;
                user.sAccount       = sPhone;
                user.sPwd           = tf_pwd.text;
                [HDGlobalInfo instance].userInfo    = user;
                [[NSUserDefaults standardUserDefaults] setObject:user.sAccount  forKey:LOGIN_USER];
                [[NSUserDefaults standardUserDefaults] setObject:user.sPwd      forKey:LOGIN_PWD];
                [HDGlobalInfo instance].hasLogined  = YES;
                
                [self uploadPhoto:self.img_head];
                [HDGlobalInfo instance].emUserInfo = emUser;
                [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REGISTER_SUCCESS object:@(YES)];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }];
//            user.sAvatarUrl     = imgUrl;
//            user.sAccount       = sPhone;
//            user.sPwd           = tf_pwd.text;
//            [HDGlobalInfo instance].userInfo    = user;
//            [HDGlobalInfo instance].hasLogined  = YES;
//            [self uploadPhoto:self.img_head];
//            [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REGISTER_SUCCESS object:@(NO)];
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
}

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
            self.avatar = image_;
            [btn_choosePic setBackgroundImage:self.avatar forState:UIControlStateNormal];
            self.img_head = image;
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
            self.avatar = image;
            [btn_choosePic setBackgroundImage:self.avatar forState:UIControlStateNormal];
            self.img_head = image;
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

- (void)uploadPhoto:(UIImage *)img{
    if (!img) {
        Dlog(@"Error:传入参数错误，img不能为空");
        return;
    }
    [[HDHttpUtility sharedClient] uploadLogo:[HDGlobalInfo instance].userInfo flag:@"4" avatar:img completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [HDGlobalInfo instance].userInfo.sAvatarUrl = url;
        imgUrl = url;
    }];
}

#pragma mark - touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([tf_nickName isFirstResponder]) {
        [tf_nickName resignFirstResponder];
    }
    if ([tf_pwd isFirstResponder]) {
       [tf_pwd resignFirstResponder]; 
    }
    
}

#pragma mark - 
#pragma mark getter && setter
- (void)setup{
    self.avatar = nil;
    self.navigationItem.title = LS(@"TXT_TITLE_SET_JJ_ACCOUNT");
    
}
@end
