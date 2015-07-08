//
//  HDCameraPickerController.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDCameraPickerController.h"

@interface HDCameraPickerController ()

@end

@implementation HDCameraPickerController

- (id)init {
    if (self = [super init]) {
        self.imagePickerCtr  = [[UIImagePickerController alloc] init];
        self.imagePickerCtr.delegate                  = self;
        self.imagePickerCtr.allowsEditing             = YES;
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            self.imagePickerCtr.sourceType            = UIImagePickerControllerSourceTypeCamera;
        }
    }
    return self;
}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]){
        UIImage *img_original = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (img_original){
            NSData *imgSizeData = UIImageJPEGRepresentation(img_original, 1.0);
            UIImage *image       = nil;
            if (([imgSizeData length] > 1024 * 300) && [imgSizeData length] <= 1024 * 500){//图片小于300K 不压缩
                image = [self scaleImage:img_original toScale:0.7];
            }else if( [imgSizeData length] > 1024 * 500){
                image = [self scaleImage:img_original toScale:0.3];
            }
            if (image && self.cropBlock) {
                self.cropBlock(image);
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
