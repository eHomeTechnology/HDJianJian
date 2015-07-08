//
//  HDChangeLogoViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/3/3.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDChangeLogoViewCtr.h"
#import "TWPhotoPickerController.h"
#import "UIImageView+AFNetworking.h"

@interface HDChangeLogoViewCtr (){

    IBOutlet UIImageView    *imv_background;
}

@property (strong) HDShopInfo *shopInfo;

@end

@implementation HDChangeLogoViewCtr

- (id)initWithInfo:(HDShopInfo *)info{
    if (!info) {
        Dlog(@"传入参数有误");
        return nil;
    }
    if (self = [super init]) {
        self.shopInfo = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title   = @"更换招牌";
    if (self.shopInfo.sPathBackground.length > 0) {
        [imv_background setImage:[UIImage imageWithContentsOfFile:self.shopInfo.sPathBackground]];
        return;
    }
    if (self.shopInfo.sUrlBackground.length > 0) {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.shopInfo.sUrlBackground]];
        [imv_background setImageWithURLRequest:request placeholderImage:HDIMAGE(@"shopBack") success:nil failure:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doChooseImageFromAlbum:(id)sender{
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
}

- (IBAction)doTakePicture:(id)sender{

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
            [self uploadPhoto:image];
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
    [[HDHttpUtility sharedClient] uploadLogo:[HDGlobalInfo instance].userInfo flag:@"2" avatar:img completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        NSString *sPath = [HDUtility pathOfSavedImageName:FORMAT(@"%d", arc4random()) folderName:[HDGlobalInfo instance].userInfo.sHumanNo];
        [HDUtility saveToDocument:img withFilePath:sPath];
        self.shopInfo.sPathBackground   = sPath;
        [imv_background setImage:[UIImage imageWithContentsOfFile:sPath]];
        //[self.shopInfo updatetoDb];
    }];
    
}


@end
