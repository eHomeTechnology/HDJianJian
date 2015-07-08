//
//  HDAddPositionViewCtrViewController.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/9.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDAddPstiViewCtr.h"
#import "UIView+LoadFromNib.h"
#import "HDPositionView.h"
#import "TWPhotoPickerController.h"
#import "HDAddSucViewCtr.h"

@interface HDAddPstiViewCtr (){
    
    HDPositionView      *positionView;
    NSMutableArray      *mar_imageViews;
    NSMutableArray      *mar_photos;
    HDHUD               *hud;
}
@property (strong) HDPositionInfo *positionInfo;
@end


@implementation HDAddPstiViewCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title   = @"添加职位";
    mar_imageViews              = [NSMutableArray new];
    mar_photos                  = [NSMutableArray new];
    self.positionInfo           = [HDPositionInfo new];
    positionView = [HDPositionView loadFromNib];
    [self.view addSubview:positionView];
    [positionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *dict1                 = NSDictionaryOfVariableBindings(positionView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT(@"|[positionView]|")
                                                                      options:0
                                                                      metrics:nil
                                                                        views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[positionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:dict1]];
    [positionView.btn_position addTarget:self action:@selector(doAddPosition:) forControlEvents:UIControlEventTouchUpInside];
    [positionView.photoCell.btn_addScene addTarget:self action:@selector(doAddPhoto:) forControlEvents:UIControlEventTouchUpInside];
    NSArray *ar = @[positionView.photoCell.imv_scene0, positionView.photoCell.imv_scene1, positionView.photoCell.imv_scene2, positionView.photoCell.imv_scene3];
    [mar_imageViews addObjectsFromArray:ar];
}

- (void)viewWillLayoutSubviews{
    positionView.positionDescribeCell.lc_positionDescHeight.constant    = positionView.positionDescribeCell.tv_positonDesc.contentSize.height;
    positionView.enterpriceCell.lc_enterpriceDescHeight.constant        = positionView.enterpriceCell.tv_enterpriceDesc.contentSize.height;
    [positionView setNeedsUpdateConstraints];
    [positionView.tbv beginUpdates];
    [positionView.tbv endUpdates];
    
    CGFloat with = positionView.photoCell.imv_scene0.bounds.size.width;
    positionView.photoCell.lc_delete0_x.constant    = with + 10 - 15;
    positionView.photoCell.lc_delete0_y.constant    = with + 10 - 15;
    positionView.photoCell.lc_delete1_x.constant    = with + 10 - 30;
    positionView.photoCell.lc_delete2_x.constant    = with + 10 - 30;
    positionView.photoCell.lc_delete3_x.constant    = with + 10 - 30;
    positionView.photoCell.btn_delete0.hidden       = !positionView.photoCell.imv_scene0.image;
    positionView.photoCell.btn_delete1.hidden       = !positionView.photoCell.imv_scene1.image;
    positionView.photoCell.btn_delete2.hidden       = !positionView.photoCell.imv_scene2.image;
    positionView.photoCell.btn_delete3.hidden       = !positionView.photoCell.imv_scene3.image;
    positionView.photoCell.lc_addScene.constant     = 8+(CGRectGetWidth(positionView.photoCell.imv_scene0.frame)+10)*(mar_photos.count);
    [positionView needsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:positionView
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:positionView
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}
- (void)removeKeyboardnotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:positionView name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:positionView name:UIKeyboardWillHideNotification object:nil];
}
- (void)doAddPosition:(UIButton *)sender{
    if (positionView.titleCell.tf_title.text.length == 0) {
        [HDUtility say:@"请输入标题"];
        return;
    }
    if (positionView.titleCell.tf_title.text.length > MaxPositionTitle) {
        [HDUtility say:FORMAT(@"标题字数不超过%d个", MaxPositionTitle)];
        return;
    }
    if (positionView.positionDescribeCell.tv_positonDesc.text.length == 0) {
        [HDUtility say:@"请输入职位描述"];
        return;
    }
    if (positionView.positionDescribeCell.tv_positonDesc.text.length > MaxPositionDescribe) {
        [HDUtility say:FORMAT(@"职位描述字数不超过%d个", MaxPositionDescribe)];
        return;
    }
    if (positionView.enterpriceCell.tv_enterpriceDesc.text.length == 0) {
        [HDUtility say:@"请输入雇主描述"];
        return;
    }
    if (positionView.enterpriceCell.tv_enterpriceDesc.text.length > MaxEnterpriceDescribe) {
        [HDUtility say:@"请输入职位描述"];
        return;
    }
    _positionInfo.sPositionName     = positionView.titleCell.tf_title.text;
    _positionInfo.sRemark           = positionView.positionDescribeCell.tv_positonDesc.text;
    _positionInfo.sComDesc          = positionView.enterpriceCell.tv_enterpriceDesc.text;
    hud = [HDHUD showLoading:@"请求中..." on:self.navigationController.view];
    [[HDHttpUtility sharedClient] releasePosition:[HDGlobalInfo instance].userInfo position:_positionInfo images:mar_photos CompletionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *positionId) {
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            [hud hiden];
            [HDUtility say:sMessage];
            return ;
        }
        [self requestForNewPositionInfo:positionId];
    }];
}

- (void)doAddPhoto:(UIButton *)sender{

    UIActionSheet *as_pic;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){//判断是否支持相机
        as_pic  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        as_pic = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    as_pic.tag = 255;
    [as_pic showInView:self.navigationController.view];
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
                    [mar_photos addObject:image_];
                    [self reloadImage];
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
                [mar_photos addObject:image];
                [self reloadImage];
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
    NSData *imgSizeData     = UIImageJPEGRepresentation(img_original, 1.0);
    UIImage *image          = img_original;
    if (([imgSizeData length] > 1024 * 500) && [imgSizeData length] <= 1024 * 1000){//图片小于300K 不压缩
        image   = [self scaleImage:img_original toScale:0.8];
    }else if( [imgSizeData length] > 1024 * 1000){
        image   = [self scaleImage:img_original toScale:0.5];
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

- (void)reloadImage{
    Dlog(@"mar_photos.count = %d", (int)mar_photos.count);
    for (int i = 0; i < (mar_photos.count > 4? 4: mar_photos.count); i++) {
        UIImageView *imv = mar_imageViews[i];
        UIImage     *img = mar_photos[i];
        [imv setImage:img];
    }
    [self.view setNeedsLayout];
}
- (void)requestForNewPositionInfo:(NSString *)positionId{
    hud.hud.labelText = @"更新数据...";
    [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo positionId:positionId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDPositionInfo *info) {
        [hud hiden];
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        self.positionInfo   = info;
        
        [[HDGlobalInfo instance].mar_positions insertObject:self.positionInfo atIndex:0];
        HDAddSucViewCtr *ctr = [[HDAddSucViewCtr alloc] initWithPosition:self.positionInfo];
        [self.navigationController pushViewController:ctr animated:YES];
    }];
}
@end
