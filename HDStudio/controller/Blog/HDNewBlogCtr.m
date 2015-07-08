//
//  HDNewBlogCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/5/28.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDNewBlogCtr.h"
#import "TWPhotoPickerController.h"

@interface HDNewBlogCtr ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>{

    IBOutlet NSLayoutConstraint *lc_addLeadiing;
    IBOutlet NSLayoutConstraint *lc_heightMotherView;
    IBOutlet UIImageView    *imv0;
    IBOutlet UIImageView    *imv1;
    IBOutlet UIImageView    *imv2;
    IBOutlet UIButton       *btn_delet0;
    IBOutlet UIButton       *btn_delet1;
    IBOutlet UIButton       *btn_delet2;
    IBOutlet UIButton       *btn_add;
    IBOutlet UITextView     *tv;
    NSMutableArray          *mar_pics;
    AFHTTPRequestOperation  *op;
}

@property (strong) HDBlogInfo *blogInfo;

@end

@implementation HDNewBlogCtr

#pragma mark -
#pragma mark life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self setDeletButton];
    [self setAddButtonPosition];
    
}
- (void)viewDidAppear:(BOOL)animated{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (op) {
        [op cancel];
        op = nil;
    }
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Event and Respond

- (void)handleKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *info      = [notification userInfo];
    CGSize kbSize           = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    lc_heightMotherView.constant = HDDeviceSize.height - kbSize.height;
    [self.view setNeedsUpdateConstraints];
}
- (void)handleKeyboardWillHide:(NSNotification *)notification{
    lc_heightMotherView.constant = HDDeviceSize.height - 64 - 100;
    [self.view setNeedsUpdateConstraints];
}
- (IBAction)doAddPicture:(id)sender{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:LS(@"TXT_REGISTER_CHOOSE_PICTURE") delegate:self cancelButtonTitle:LS(@"TXT_CANCEL") destructiveButtonTitle:LS(@"TXT_REGISTER_TAKE_PHOTO") otherButtonTitles:LS(@"TXT_CHOOSE_FROM_ALBUM"), nil];
    [sheet showInView:self.navigationController.view];
}

- (IBAction)doConfirm:(id)sender{
    [self.view endEditing:YES];
    [self httpReleaseBlog];
}

- (IBAction)doDelete:(UIButton *)sender{
    if (sender.tag > mar_pics.count - 1) {
        Dlog(@"Error:出错了，delete button的tag可以超出mar_pics边界");
        return;
    }
    [mar_pics removeObjectAtIndex:sender.tag];
    [self setAddButtonPosition];
    [self setImages];
    [self setDeletButton];
}

- (void)doCancel:(UIButton *)sender{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)httpReleaseBlog{
    HDHUD *hud = [HDHUD showLoading:LS(@"TXT_LODING_TRYING") on:self.view];
    op = [[HDHttpUtility sharedClient] releaseBlog:[HDGlobalInfo instance].userInfo images:mar_pics content:tv.text completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage, NSString *url) {
        [HDUtility mbSay:sMessage];
        [hud hiden];
        if (!isSuccess) {
            return ;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_REFRESH_BLOG_LIST object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark -
#pragma mark getter and setter

- (void)setup{
    mar_pics = [NSMutableArray new];
    lc_heightMotherView.constant = HDDeviceSize.height - 64 - 100;
    [self.view setNeedsUpdateConstraints];
    self.navigationItem.title   = @"发表分享";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(doConfirm:)];
    if (self.navigationController.viewControllers.count == 1) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(doCancel:)];
    }
}

- (void)setDeletButton{
    btn_delet0.hidden = !imv0.image;
    btn_delet1.hidden = !imv1.image;
    btn_delet2.hidden = !imv2.image;
}
- (void)setImages{
    for (int i = 0; i < 3; i++) {
        UIImageView *imv = @[imv0, imv1, imv2][i];
        [imv setImage:nil];
    }
    for (int i = 0; i < mar_pics.count; i++) {
        UIImage *img = mar_pics[i];
        UIImageView *imv = @[imv0, imv1, imv2][i];
        [imv setImage:img];
    }
}
- (void)setAddButtonPosition{
    btn_add.hidden = mar_pics.count > 2;
    lc_addLeadiing.constant = 12 + 105 * mar_pics.count;
    [self.view needsUpdateConstraints];
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
        [mar_pics addObject:image_];
        [self setAddButtonPosition];
        [self setImages];
        [self setDeletButton];
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
        [mar_pics addObject:image];
        [self setAddButtonPosition];
        [self setImages];
        [self setDeletButton];
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
