//
//  UIImageView+HDDownloadImage.m
//  JianJian
//
//  Created by Hu Dennis on 15/3/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "UIImageView+HDDownloadImage.h"

@implementation UIImageView (HDDownloadImage)

- (void)setImageWithUrlString:(NSString *)url{

    [self setImage:url placeholdImage:[UIImage imageNamed:@"placeHold"] falseImage:[UIImage imageNamed:@"falseImage"]];
}

- (void)setImage:(NSString *)url placeholdImage:(UIImage *)placeHoldImage falseImage:(UIImage *)falseImage{

    NSMutableDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_DOCUMENT];
    NSString *sPath = dic[url];
    if (sPath.length > 0) {
        UIImage *img = [UIImage imageWithContentsOfFile:sPath];
        if (img) {
            [self setImage:img];
        }
        return;
    }

    [self setImage:placeHoldImage];
    NSURLRequest *r = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFImageRequestOperation *o = [AFImageRequestOperation imageRequestOperationWithRequest:r imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        NSString *sPath = [self saveImage:image imageName:FORMAT(@"img%d", arc4random()) folder:@"imgs"];
        Dlog(@"spath = %@", sPath);
        UIImage *img = [UIImage imageWithContentsOfFile:sPath];
        [self setImage:img];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:IMAGE_DOCUMENT]];
        [dic setValue:sPath forKey:url];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:IMAGE_DOCUMENT];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        Dlog(@"fales");
        [self setImage:falseImage];
    }];
    [o start];
}

//直接保存图片，返回保存路径
- (NSString *)saveImage:(UIImage *)image imageName:(NSString *)name folder:(NSString *)folder{
    NSString *sPath = [self pathOfSavedImageName:name folderName:folder];
    [self saveImage:image toDocumentPath:sPath];
    return sPath;
}

//将选取的图片保存到沙盒目录文件夹下
- (BOOL)saveImage:(UIImage *)image toDocumentPath:(NSString *)filePath
{
    if ((image == nil) || (filePath == nil) || [filePath isEqualToString:@""]) {
        Dlog(@"传入参数不能为空！");
        return NO;
    }
    @try {
        NSData *imageData = nil;
        NSString *extention = [filePath pathExtension];
        if ([extention isEqualToString:@"png"]) {
            imageData = UIImagePNGRepresentation(image);
        }else{
            imageData = UIImageJPEGRepresentation(image, 0);
        }
        if (imageData == nil || [imageData length] <= 0) {
            Dlog(@"imageData为空，保存失败");
            return NO;
        }
        [imageData writeToFile:filePath atomically:YES];
        return  YES;
    }
    @catch (NSException *exception) {
        Dlog(@"保存图片失败,reason:%@", exception.reason);
    }
    
    return NO;
    
}

//获取将要保存的图片路径
- (NSString *)pathOfSavedImageName:(NSString *)imageName folderName:(NSString *)sFolder
{
    NSArray *path               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath      = [path objectAtIndex:0];
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    NSString *imageDocPath      = nil;
    if (sFolder.length > 0) {
        imageDocPath = [documentPath stringByAppendingPathComponent:FORMAT(@"%@/%@", [HDGlobalInfo instance].userInfo.sHumanNo, sFolder)];
    }else{
        imageDocPath = [documentPath stringByAppendingPathComponent:FORMAT(@"%@", [HDGlobalInfo instance].userInfo.sHumanNo)];
    }
    [fileManager createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //返回保存图片的路径（图片保存在ImageFile文件夹下）
    if (imageName.length > 0) {
        return [imageDocPath stringByAppendingPathComponent:imageName];
    }else{
        return imageDocPath;
    }
}

@end
