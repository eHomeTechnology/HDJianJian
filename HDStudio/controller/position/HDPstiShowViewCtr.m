//
//  HDPstiShowViewCtr.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPstiShowViewCtr.h"
#import "TWPhotoPickerController.h"
#import "UIImageView+HDDownloadImage.h"

@interface HDPstiShowViewCtr (){
    HDPositionView          *positionView;
    NSMutableArray          *mar_imageViews;
}
@property (strong) HDPositionInfo   *positionInfo;
@property (strong) NSString         *sPositionId;
@end

@implementation HDPstiShowViewCtr

- (id)initWithPositionInfo:(HDPositionInfo *)info{
    if (!info) {
        Dlog(@"传入参数错误！");
        return nil;
    }
    if (self = [super init]) {
        self.positionInfo   = info;
    }
    return self;
}

- (id)initWithPositionIdentifier:(NSString *)pId{

    if (self = [super init]) {
        _sPositionId = pId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self addPositionView];
    [self httpGetPositionInfo:^(HDPositionInfo *info) {
        if (info) {
            self.positionInfo = info;
        }
        [self setUserInterfaceWithData];
        [self showImages];
    }];
}
- (void)setup{
    self.navigationItem.title           = LS(@"TXT_TITLE_POSITION_DETAIL");
}
- (void)addPositionView{
    positionView                        = [HDPositionView loadFromNib];
    NSDictionary *dict1                 = NSDictionaryOfVariableBindings(positionView);
    [positionView.btn_position setTitle:LS(@"TXT_JJ_POSITION_DETAIL_SAVE") forState:UIControlStateNormal];
    [self.view addSubview:positionView];
    [positionView.btn_position addTarget:self action:@selector(doSave:) forControlEvents:UIControlEventTouchUpInside];
    [positionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:FORMAT(@"|[positionView]|")
                                                                      options:0
                                                                      metrics:nil
                                                                        views:dict1]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[positionView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:dict1]];
    
    [positionView.photoCell.btn_addScene addTarget:self action:@selector(doAddScene:) forControlEvents:UIControlEventTouchUpInside];
    NSArray *ar_btns = @[positionView.photoCell.btn_delete0, positionView.photoCell.btn_delete1, positionView.photoCell.btn_delete2, positionView.photoCell.btn_delete3];
    for (int i = 0; i < ar_btns.count; i++) {
        UIButton *btn   = ar_btns[i];
        btn.tag         = i;
        [btn addTarget:self action:@selector(doDeletePhoto:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSArray *ar_imvs                = @[positionView.photoCell.imv_scene0, positionView.photoCell.imv_scene1, positionView.photoCell.imv_scene2, positionView.photoCell.imv_scene3];
    mar_imageViews                  = [[NSMutableArray alloc] initWithArray:ar_imvs];
    for (int i = 0; i < self.positionInfo.mar_urls.count; i++) {
        UIImageView *imv = mar_imageViews[i];
        [imv setImage:HDIMAGE(@"headShadow")];
    }
}

- (void)setUserInterfaceWithData{

    positionView.titleCell.tf_title.text                    = self.positionInfo.sPositionName;
    positionView.positionDescribeCell.tv_positonDesc.text   = self.positionInfo.sRemark;
    positionView.enterpriceCell.tv_enterpriceDesc.text      = self.positionInfo.sComDesc;
    positionView.positionDescribeCell.lb_placeholder.text   = self.positionInfo.sRemark.length > 0? @"": LS(@"TXT_JJ_EMPLOYER_DESCRIBE");
    positionView.enterpriceCell.lb_placeholder.text         = self.positionInfo.sComDesc.length > 0? @"": LS(@"TXT_JJ_POSITION_DESCRIBE");
    [self.view setNeedsUpdateConstraints];
}
- (void)httpGetPositionInfo:(void(^)(HDPositionInfo *info))block{
    if (_sPositionId.length == 0) {
        block(nil);
        return;
    }
    [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo positionId:_sPositionId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDPositionInfo *info) {
        [HDUtility mbSay:sMessage];
        if (!isSuccess) {
            block(nil);
            return ;
        }
        block(info);
    }];
}

- (void)showImages{
    int iCount = (int)_positionInfo.mar_urls.count;
    for (int i = 0; i < (iCount > 4? 4: iCount); i++) {
        UIImageView     *imv        = mar_imageViews[i];
        [imv setImageWithUrlString:_positionInfo.mar_urls[i]];
    }
    for (int i = (int)_positionInfo.mar_urls.count; i < 4; i++) {
        UIImageView *imv    = mar_imageViews[i];
        imv.image           = nil;
        [self.view setNeedsUpdateConstraints];
    }
    [self.view setNeedsLayout];
}
- (void)viewDidAppear:(BOOL)animated{
    [self registerForKeyboardNotifications];
    
}

- (void)viewDidDisappear:(BOOL)animated{
    
    [self removeKeyboardnotification];
}
- (void)viewWillLayoutSubviews{
    positionView.positionDescribeCell.lc_positionDescHeight.constant    = positionView.positionDescribeCell.tv_positonDesc.contentSize.height;
    positionView.enterpriceCell.lc_enterpriceDescHeight.constant        = positionView.enterpriceCell.tv_enterpriceDesc.contentSize.height;
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
    positionView.photoCell.btn_addScene.hidden      = (_positionInfo.mar_urls.count >= 4? YES: NO);
    int count = (int)self.positionInfo.mar_urls.count;
    UIImageView *imv = mar_imageViews[0];
    positionView.photoCell.lc_addScene.constant = (count == 4? 100: 8)+(CGRectGetWidth(imv.frame)+10)*(count);
}

- (void)doSave:(UIButton *)sender{
    BOOL isModify               = YES;
    NSString *sTile             = positionView.titleCell.tf_title.text;
    NSString *sPositionDesc     = positionView.positionDescribeCell.tv_positonDesc.text;
    NSString *sEnterpriceDesc   = positionView.enterpriceCell.tv_enterpriceDesc.text;
    BOOL isSameTile             = [sTile isEqualToString:self.positionInfo.sPositionName];
    BOOL isSamePositionDesc     = [sPositionDesc isEqualToString:self.positionInfo.sRemark];
    BOOL isSameEnterpriceDesc   = [sEnterpriceDesc isEqualToString:self.positionInfo.sComDesc];
    if (isSameTile && isSamePositionDesc && isSameEnterpriceDesc) {
        isModify = NO;
    }
    if (!isModify) {
        [HDUtility mbSay:@"已保存"];
        return;
    }
    HDPositionInfo *p   = [HDPositionInfo new];
    p.sPositionName     = sTile;
    p.sRemark           = sPositionDesc;
    p.sComDesc          = sEnterpriceDesc;
    p.sPositionId       = self.positionInfo.sPositionId;
    HDHUD *hud          = [HDHUD showLoading:@"网络请求中..." on:self.navigationController.view];
    [[HDHttpUtility sharedClient] modifyPosition:[HDGlobalInfo instance].userInfo position:p completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        [hud hiden];
        [HDUtility say:sMessage];
        if (!isSuccess) {
            return ;
        }
        self.positionInfo.sPositionName = sTile;
        self.positionInfo.sRemark       = sPositionDesc;
        self.positionInfo.sComDesc      = sEnterpriceDesc;
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (void)doDeletePhoto:(UIButton *)sender{
    Dlog(@"sender.tag = %d", (int)sender.tag);
    if (sender.tag > self.positionInfo.mar_urls.count - 1) {
        Dlog(@"Error:检测到数据错误，请盘查");
        return;
    }
    int index = [self.positionInfo getRealIndex:self.positionInfo.mar_urls[sender.tag]];
    Dlog(@"index = %d", index);
    [[HDHttpUtility sharedClient] changeImageScene:[HDGlobalInfo instance].userInfo image:nil positionId:self.positionInfo.sPositionId sceneId:FORMAT(@"%d", index+1) isDelete:YES completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        
        if (!isSuccess) {
            [HDUtility say:LS(@"TXT_JJ_DELETE_FALSE")];
            return ;
        }
        [HDUtility mbSay:LS(@"TXT_JJ_DELETE_SUCCESS")];
        [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo positionId:_positionInfo.sPositionId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDPositionInfo *info) {
            self.positionInfo = info;
            for (int i = 0; i < [HDGlobalInfo instance].mar_onPosition.count; i++) {
                HDPositionInfo *pInfo = [HDGlobalInfo instance].mar_onPosition[i];
                if ([pInfo.sPositionId isEqualToString:info.sPositionId]) {
                    [[HDGlobalInfo instance].mar_onPosition replaceObjectAtIndex:i withObject:info];
                }
                [self showImages];
            }
        }];
        
    }];
    
    
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

- (void)doAddScene:(UIButton *)sender{
    UIActionSheet *as_pic;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){//判断是否支持相机
        as_pic  = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照", @"从相册选择", nil];
    }else{
        as_pic = [[UIActionSheet alloc] initWithTitle:@"选择图像" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
    }
    as_pic.tag = 255;
    [as_pic showInView:self.navigationController.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    int index = [_positionInfo getMinimumIndexWitchIsEmpty];
    [[HDHttpUtility sharedClient] changeImageScene:[HDGlobalInfo instance].userInfo image:image positionId:self.positionInfo.sPositionId sceneId:FORMAT(@"%d", index + 1) isDelete:NO completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        [hud hiden];
        [HDUtility mbSay:sMessage];
        if (isSuccess) {
            [[HDHttpUtility sharedClient] getPositionInfo:[HDGlobalInfo instance].userInfo positionId:self.positionInfo.sPositionId completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, HDPositionInfo *info) {
                self.positionInfo = info;
                for (int i = 0; i < [HDGlobalInfo instance].mar_onPosition.count; i++) {
                    HDPositionInfo *pInfo = [HDGlobalInfo instance].mar_onPosition[i];
                    if ([pInfo.sPositionId isEqualToString:_positionInfo.sPositionId]) {
                        [[HDGlobalInfo instance].mar_onPosition replaceObjectAtIndex:i withObject:_positionInfo];
                    }
                }
                [self showImages];
                [self.view setNeedsLayout];
            }];
            
        }
    }];
}

@end
