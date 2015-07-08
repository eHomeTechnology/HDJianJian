//
//  HDCameraPickerController.h
//  HDStudio
//
//  Created by Hu Dennis on 15/2/27.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDCameraPickerController : NSObject<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong) UIImagePickerController *imagePickerCtr;

@property (nonatomic, copy) void(^cropBlock)(UIImage *image);

@end
