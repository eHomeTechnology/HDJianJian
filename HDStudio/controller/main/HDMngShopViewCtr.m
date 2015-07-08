//
//  HDMngShopViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDMngShopViewCtr.h"
#import "AFImageRequestOperation.h"
#import "TWPhotoPickerController.h"
#import "HDMngShopViewCtr.h"
#import "HDChangeLogoViewCtr.h"
#import "TOWebViewController.h"

@interface HDMngShopViewCtr (){

    IBOutlet UIButton       *btn_logo;
    IBOutlet UITextField    *tf_shopName;
    IBOutlet UITextField    *tf_phone;
    IBOutlet UITextField    *tf_wx;
    IBOutlet UITextField    *tf_qq;
    IBOutlet UITextView     *tv_announce;
    
}

@end

@implementation HDMngShopViewCtr

- (id)initWithInfo:(HDShopInfo *)info{
    
    if (self = [super init]) {
        self.shopInfo   = info;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"才铺管理";
    if (self.shopInfo) {
        [self refreshViewWithInfo:self.shopInfo];
        return;
    }
    [[HDHttpUtility sharedClient] getShopInformation:[HDGlobalInfo instance].userInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDShopInfo *info) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return;
        }
        self.shopInfo   = info;
        [self.shopInfo updatetoDb];
        if (self.shopInfo.sUrlLogo.length == 0) {
            Dlog(@"服务器上没有该店铺的logo");
            [self refreshViewWithInfo:self.shopInfo];
            return;
        }
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:info.sUrlLogo]];
        AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:request success:^(UIImage *image) {
            if (!image) {
                Dlog(@"下载logo图片错误");
            }
            NSString *sPath = [HDUtility pathOfSavedImageName:FORMAT(@"%d", arc4random()) folderName:[HDGlobalInfo instance].userInfo.sUserId];
            BOOL isSuc = [HDUtility saveToDocument:image withFilePath:sPath];
            if (isSuc) {
                self.shopInfo.sPathLogo = sPath;
                [self.shopInfo updatetoDb];
                [self refreshViewWithInfo:self.shopInfo];
            }
        }];
        [operation start];
    }];
}
- (void)viewWillLayoutSubviews{
    btn_logo.layer.cornerRadius = btn_logo.frame.size.width/2;
    btn_logo.layer.masksToBounds = YES;
}

- (void)refreshViewWithInfo:(HDShopInfo *)info{
    tf_shopName.text    = info.sShopName;
    tf_phone.text       = info.sMPhone;
    tf_wx.text          = info.sWXUserName;
    tf_qq.text          = info.sQQ;
    tv_announce.text    = info.sAnnounce;
    UIImage *avata      = info.sPathLogo.length > 0? [UIImage imageWithContentsOfFile:info.sPathLogo]: [UIImage imageNamed:@"headShadow"];
    [btn_logo setBackgroundImage:avata forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doChageLogoImage:(id)sender{
    UIActionSheet *as_pic;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){//判断是否支持相机
        as_pic  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        as_pic = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    as_pic.tag = 255;
    [as_pic showInView:self.navigationController.view];

}

- (IBAction)doChageBackgroundImage:(id)sender{

    HDChangeLogoViewCtr *ctr = [[HDChangeLogoViewCtr alloc] initWithInfo:self.shopInfo];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (IBAction)doSaveAndPreview:(id)sender{
    if (tf_shopName.text.length == 0 || tf_shopName.text.length > MAX_SHOP_NAME) {
        [HDUtility say:FORMAT(@"才铺名称长度必须在%d到%d之间", 1, MAX_SHOP_NAME)];
        return;
    }
    if (![HDUtility isValidateMobile:tf_phone.text]) {
        [HDUtility say:@"手机格式不对"];
        return;
    }
    if (tf_wx.text.length > MAX_WEIXIN_NAME) {
        [HDUtility say:FORMAT(@"微信名称最大长度不超过%d", MAX_WEIXIN_NAME)];
        return;
    }
    if (tf_qq.text.length > MAX_QQ_NAME) {
        [HDUtility say:FORMAT(@"qq名称长度最大不超过%d", MAX_QQ_NAME)];
        return;
    }
    if (tv_announce.text.length > MAX_SHOP_ANNOUNCE) {
        [HDUtility say:FORMAT(@"店铺公告名称最大不超过%d", MAX_SHOP_ANNOUNCE)];
        return;
    }
    self.shopInfo.sShopName     = tf_shopName.text;
    self.shopInfo.sMPhone       = tf_phone.text;
    self.shopInfo.sWXUserName   = tf_wx.text;
    self.shopInfo.sQQ           = tf_qq.text;
    self.shopInfo.sAnnounce     = tv_announce.text;
    HDHUD *hud = [HDHUD showLoading:@"数据更新..." on:self.navigationController.view];
    [[HDHttpUtility sharedClient] modifyShopInfo:[HDGlobalInfo instance].userInfo shop:self.shopInfo completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility say:sMessage];
            return ;
        }
        [HDUtility mbSay:sMessage];
        [self.shopInfo updatetoDb];
        HDAddressInfo *addressInfo = nil;
        NSArray *ar = [HDAddressInfo allDbObjects];
        if (ar.count > 0) {
            addressInfo = ar[0];
        }
        TOWebViewController *ctr    = [[TOWebViewController alloc] initWithURLString:self.shopInfo.sUrl];
        [self.navigationController pushViewController:ctr animated:YES];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [tf_phone       resignFirstResponder];
    [tf_shopName    resignFirstResponder];
    [tf_qq          resignFirstResponder];
    [tf_wx          resignFirstResponder];
    [tv_announce    resignFirstResponder];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            return;
        }
        case 1:{ //相机
            UIImagePickerController *imagePickerCtr  = [[UIImagePickerController alloc] init];
            imagePickerCtr.delegate                  = self;
            imagePickerCtr.allowsEditing             = YES;
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePickerCtr.sourceType            = UIImagePickerControllerSourceTypeCamera;
            }
            [self.navigationController presentViewController:imagePickerCtr animated:YES completion:nil];
            break;
        }
        case 2:{//相册
            TWPhotoPickerController *photoPicker    = [[TWPhotoPickerController alloc] init];
            photoPicker.cropBlock = ^(UIImage *image) {
                UIImage *image_ = [self resizeImage:image];
                if (image_) {
                    [self uploadPhoto:image_];
                }else{
                    Dlog(@"Error:压缩图片出错");
                }
            };
            [self presentViewController:photoPicker animated:YES completion:NULL];
            break;
        }
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img_original       = [info objectForKey:UIImagePickerControllerEditedImage];
        if (img_original){
            UIImage *image = [self resizeImage:img_original];
            if (image) {
                [self uploadPhoto:image];
            }else{
                Dlog(@"Error:压缩图片出错");
            }
        }else{
            Dlog(@"获取图片失败");
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

//上传添加图片
- (void)uploadPhoto:(UIImage *)image{
    if (!image) {
        Dlog(@"传入参数错误");
        return;
    }
    HDHUD *hud = [HDHUD showLoading:@"上传中..." on:kWindow];
    [[HDHttpUtility sharedClient] uploadLogo:[HDGlobalInfo instance].userInfo flag:@"1" avatar:image completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        NSString *sPath = [HDUtility pathOfSavedImageName:FORMAT(@"%d", arc4random()) folderName:[HDGlobalInfo instance].userInfo.sUserId];
        BOOL isSuc = [HDUtility saveToDocument:image withFilePath:sPath];
        if (isSuc) {
            self.shopInfo.sPathLogo = sPath;
        }
        [btn_logo setBackgroundImage:[UIImage imageWithContentsOfFile:self.shopInfo.sPathLogo] forState:UIControlStateNormal];
        self.shopInfo.sUrlLogo = url;
        [self.shopInfo updatetoDb];
    }];
}


@end
