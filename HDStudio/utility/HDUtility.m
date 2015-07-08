//
//  HDUtility.m
//  SNVideo
//
//  Created by Hu Dennis on 14-8-6.
//  Copyright (c) 2014年 evideo. All rights reserved.
//

#import "HDUtility.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CommonCrypto/CommonDigest.h"
#import "Reachability.h"

@implementation HDUtility

+(NSDictionary *)getConectedWIFI{
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        NSLog(@"%@ => %@", ifnam, info);  //单个数据info[@"SSID"]; info[@"BSSID"];
        if (info && [info count]) {
            dic = (NSDictionary *)info;
            return dic;
        }
    }
    return nil;
}

+ (void)mbSay:(NSString *)sMsg{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = sMsg;
	hud.margin = 10.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:0.7f];
}

+ (void)mbSay:(NSString *)sMsg completion:(void(^)(void))block{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:kWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = sMsg;
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
}
+ (MBProgressHUD *)sayAfterSuccess:(NSString *)s{
    MBProgressHUD *hud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow ];
    hud.customView      = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"success.png"]];
    hud.mode            = MBProgressHUDModeCustomView;
    hud.labelText       = s;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1.0f];
    return hud;
}
+ (MBProgressHUD *)sayAfterFail:(NSString *)s{
    MBProgressHUD *hud  = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow ];
    hud.customView      = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fail.png"]];
    hud.mode            = MBProgressHUDModeCustomView;
    hud.labelText       = s;
    [[UIApplication sharedApplication].keyWindow addSubview:hud];
    [hud show:YES];
    [hud hide:YES afterDelay:1.0f];
    return hud;
}

+ (void)say:(NSString *)sMsg{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"TXT_PROMPT") message:sMsg delegate:self cancelButtonTitle:LS(@"TXT_CONFIRM") otherButtonTitles:nil, nil];
    [alert show];
}

+ (UIAlertView *)say:(NSString *)sMsg Delegate:(id)delegate_{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"TXT_PROMPT") message:sMsg delegate:delegate_ cancelButtonTitle:LS(@"TXT_CONFIRM") otherButtonTitles:nil, nil];
    [alert show];
    return alert;
}
+ (UIAlertView *)say2:(NSString *)sMsg Delegate:(id)delegate_{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:LS(@"TXT_PROMPT") message:sMsg delegate:delegate_ cancelButtonTitle:LS(@"TXT_CANCEL") otherButtonTitles:LS(@"TXT_CONFIRM"), nil];
    [alert show];
    return alert;
}
+ (void)circleTheView:(UIView *)view{
    if (view.frame.size.height != view.frame.size.width) {
        Dlog(@"view不是正方形！");
        return;
    }
    view.layer.cornerRadius     = CGRectGetHeight(view.frame)/2;
    view.layer.masksToBounds    = YES;
    view.layer.borderWidth      = 1.0f;
    view.layer.borderColor      = [UIColor whiteColor].CGColor;
}
+ (void)circleWithNoBorder:(UIView *)view{
    if (view.frame.size.height != view.frame.size.width) {
        Dlog(@"view不是正方形！");
        return;
    }
    view.layer.cornerRadius     = CGRectGetHeight(view.frame)/2;
    view.layer.masksToBounds    = YES;
}

+ (void)rotateView:(UIView *)view angle:(float)angle{

    CALayer *layer = view.layer;
    CAKeyframeAnimation *animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.duration = 0.5f;
    animation.cumulative = YES;
    animation.repeatCount = 1;
    animation.values = [NSArray arrayWithObjects:   	// i.e., Rotation values for the 3 keyframes, in RADIANS
                        [NSNumber numberWithFloat:0.0 * M_PI],
                        [NSNumber numberWithFloat:angle],
                        nil];
    animation.keyTimes = [NSArray arrayWithObjects:     // Relative timing values for the 3 keyframes
                          [NSNumber numberWithFloat:0],
                          [NSNumber numberWithFloat:.3],
                          nil];
    animation.timingFunctions = [NSArray arrayWithObjects:
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],	// from keyframe 1 to keyframe 2
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut], nil];	// from keyframe 2 to keyframe 3
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [layer addAnimation:animation forKey:nil];
}
+ (void)setShadow:(UIView *)view{
    
    view.layer.shadowOpacity    = 0.25f;
    view.layer.shadowOffset     = CGSizeMake(0, 3);
    view.layer.shadowRadius     = 3.0f;
    view.clipsToBounds          = NO;
}


//是否网络可用
+ (BOOL)isEnableNetwork{

    return ([[Reachability reachabilityWithHostName:@"www.baidu.com"] currentReachabilityStatus] != NotReachable);
}
//是否WIFI
+ (BOOL)isEnableWIFI{
    return([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}
// 是否3G
+ (BOOL)isEnable3G{
    return([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable && ![HDUtility isEnableWIFI]);
}

//Unix时间戳
+ (NSString *)UnixTime{

    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time = [date timeIntervalSince1970];
    NSString *strTime = [NSString stringWithFormat:@"%.0f",time];
    return strTime;
}

//MD5加密
+(NSString *)md5:(NSString *)inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}
+ (BOOL)isValidateName:(NSString *)name{
    if (name.length >= 2 && name.length <= 15) {
        return YES;
    }
    return NO;
}

/*邮箱验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateEmail:(NSString *)email{
    
    NSString *emailRegex    = @"^\\s*\\w+(?:\\.{0,1}[\\w-]+)*@[a-zA-Z0-9]+(?:[-.][a-zA-Z0-9]+)*\\.[a-zA-Z]+\\s*$";
    NSPredicate *emailTest  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateMobile:(NSString *)mobile{
    if ([mobile hasPrefix:@"1"] && [mobile length] == 11) {
        return YES;
    }
    return NO;
}


/*车牌号验证 MODIFIED BY DENNISHU*/
+ (BOOL)isValidateCarNo:(NSString *)carNo{
    NSString *carRegex      = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

+ (BOOL)isValidatePassword:(NSString *)sPwd{
    if (sPwd.length < MIN_LENTH_PASSWORD || sPwd.length > MAX_LENTH_PASSWORD) {
        return NO;
    }
    return YES;
}

+ (BOOL)isValidateAccount:(NSString *)s{
    NSString *carRegex      = @"^[a-zA-Z0-9\u4e00-\u9fa5\ue001-\ue537]+$";
    NSPredicate *carTest    = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:s];
    
}
/** 关于date **/
+ (NSString *)readNowTimeWithFormate:(NSString *)yyyyMMddhhmmss{
    
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter	setDateFormat:yyyyMMddhhmmss];//yyyyMMddhhmmss
	NSString *sTime=[formatter stringFromDate: [NSDate date]];
    
	return sTime;
}

+ (NSString *)converDate2String:(NSDate *)date withFormat:(NSString *)format{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter	setDateFormat:format];//yyyyMMddhhmmss
	NSString *sTime=[formatter stringFromDate: date];
    
	return sTime;
    
}

+ (NSString *)formatterDate:(NSDate *)date{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter	setDateFormat:@"YYYY-MM-DD"];
	NSString *sTime=[formatter stringFromDate:date];
    
	return sTime;
    
}

+ (NSDate *)convertDateFromString:(NSString*)sDate{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"YYYY.MM.DD"];
    NSDate *date=[formatter dateFromString:sDate];
    
    return date;
}

+ (NSString *)returnHumanizedTime:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [NSDate date];
    NSDate *tomorrow, *yesterday;
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    NSString * dateString = [[date description] substringToIndex:10];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    if ([dateString isEqualToString:todayString]){
        return [dateFormatter stringFromDate:date];;
    } else if ([dateString isEqualToString:yesterdayString]){
        return FORMAT(@"昨天 %@", [dateFormatter stringFromDate:date]);
    }else if ([dateString isEqualToString:tomorrowString]){
        return FORMAT(@"明天 %@", [dateFormatter stringFromDate:date]);
    }else{
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        return [dateFormatter stringFromDate:date];
    }
}

/** 动画 **/
+ (void)view:(UIView *)view appearAt:(CGPoint)location withDalay:(CGFloat)delay duration:(CGFloat)duration{
    view.center                         = location;
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.duration             = duration;
    scaleAnimation.values               = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.15, 1.15, 1)],[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1)]];
    scaleAnimation.calculationMode      = kCAAnimationLinear;
    scaleAnimation.keyTimes             = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:delay],[NSNumber numberWithFloat:1.0f]];
    view.layer.anchorPoint              = CGPointMake(0.5f, 0.5f);
    [view.layer addAnimation:scaleAnimation forKey:@"buttonAppear"];

}

+ (void)showView:(UIView *)view centerAtPoint:(CGPoint)pos duration:(CGFloat)waitDuration{
    view.center = pos;
    CABasicAnimation *forwardAnimation  = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    forwardAnimation.duration           = waitDuration;
    forwardAnimation.timingFunction     = [CAMediaTimingFunction functionWithControlPoints:0.5f :1.7f :0.6f :0.85f];
    forwardAnimation.fromValue          = [NSNumber numberWithFloat:0.0f];
    forwardAnimation.toValue            = [NSNumber numberWithFloat:1.0f];
    CAAnimationGroup *animationGroup    = [CAAnimationGroup animation];
    animationGroup.animations           = [NSArray arrayWithObjects:forwardAnimation, nil];
    animationGroup.delegate             = self;
    animationGroup.duration             = forwardAnimation.duration;
    animationGroup.removedOnCompletion  = NO;
    animationGroup.fillMode             = kCAFillModeForwards;
    
    [UIView animateWithDuration:animationGroup.duration
                          delay:0.0
                        options:0
                     animations:^{
                         [view.layer addAnimation:animationGroup
                                           forKey:@"kLPAnimationKeyPopup"];
                     }
                     completion:^(BOOL finished) {
                     }];
}
+ (void)hideView:(UIView *)view duration:(CGFloat)waitDuration{
    
    CABasicAnimation *reverseAnimation      = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    reverseAnimation.duration               = 0.3;
    reverseAnimation.beginTime              = 0;
    reverseAnimation.timingFunction         = [CAMediaTimingFunction functionWithControlPoints:0.4f :0.15f :0.5f :-0.7f];
    reverseAnimation.fromValue              = [NSNumber numberWithFloat:1.0f];
    reverseAnimation.toValue                = [NSNumber numberWithFloat:0.0f];
    reverseAnimation.removedOnCompletion    = YES;
    [view.layer addAnimation:reverseAnimation forKey:@"1111"];
}

//截屏
+ (UIImage *)screenshotFromView:(UIView *)theView{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

//获得某个范围内的屏幕图像
+ (UIImage *)screenshotFromView: (UIView *)theView atFrame:(CGRect)r{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context    = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    UIRectClip(r);
    [theView.layer renderInContext:context];
    UIImage *theImage       = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  theImage;//[self getImageAreaFromImage:theImage atFrame:r];
}

//图片下载
+ (NSString *)imageWithUrl:(NSString *)sUrl savedFolderName:(NSString *)sFolder savedFileName:(NSString *)sFile{
    if (sUrl.length <= 0) {
        return nil;
    }
    NSString *sImagename    = [sUrl lastPathComponent];
    NSString *sPath         = [HDUtility pathOfSavedImageName:sFile? sFile: sImagename folderName:sFolder];
    NSFileManager *fileMng  = [NSFileManager defaultManager];
    if ([fileMng fileExistsAtPath:sPath]) {
        Dlog(@"该文件已存在");
        return sPath;
    }
    UIImage *image          = [HDUtility imageWithUrl:sUrl];
    BOOL isSuc              = [HDUtility saveToDocument:image withFilePath:sPath];
    if (!isSuc) {
        return nil;
    }
    return sPath;
}

//从网络获取图片
+ (UIImage *)imageWithUrl:(NSString *)sUrl{
    if (sUrl.length <= 0) {
        return nil;
    }
    NSURL *url      = [NSURL URLWithString:sUrl];
    UIImage *image  = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    if (!image) {
        Dlog(@"图片下载失败，URL：%@", sUrl);
    }
    return image;
}

//将选取的图片保存到沙盒目录文件夹下
+ (BOOL)saveToDocument:(UIImage *)image withFilePath:(NSString *)filePath
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
+ (NSString *)pathOfSavedImageName:(NSString *)imageName folderName:(NSString *)sFolder
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
//直接保存图片，返回保存路径
+ (NSString *)saveImage:(UIImage *)image imageName:(NSString *)name folder:(NSString *)folder{
    NSString *sPath = [HDUtility pathOfSavedImageName:name folderName:folder];
    [HDUtility saveToDocument:image withFilePath:sPath];
    return sPath;
}

+ (BOOL)removeAllFile{
    NSArray *path               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath      = [path objectAtIndex:0];
    NSFileManager *fileMgr      = [NSFileManager defaultManager];
    NSError *err;
    BOOL removFig = [fileMgr removeItemAtPath:documentPath error:&err];
    Dlog(@"Error:%@", err.description);
    return removFig;
}
+ (BOOL)removeFileWithPath:(NSString *)path
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL isRet = [fileMgr fileExistsAtPath:path];
    if (isRet) {
        NSError *err;
        BOOL removFig = [fileMgr removeItemAtPath:path error:&err];
        Dlog(@"Error:%@", err.description);
        return removFig;
    }
    return isRet;
}
+ (NSString*)uuid {
    UIDevice *device = [UIDevice currentDevice];
    return device.identifierForVendor.UUIDString;
}
//相机是否可用
+ (BOOL)isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

+ (BOOL)isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

+ (BOOL)isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL)isValidPNGByImageData:(NSData *)imageData
{
    UIImage* image = [UIImage imageWithData:imageData];
    //第一种情况：通过[UIImage imageWithData:data];直接生成图片时，如果image为nil，那么imageData一定是无效的
    if (image == nil && imageData != nil) {
        return NO;
    }
    //第二种情况：图片有部分是OK的，但是有部分坏掉了，它将通过第一步校验，那么就要用下面这个方法了。将图片转换成PNG的数据，如果PNG数据能正确生成，那么这个图片就是完整OK的，如果不能，那么说明图片有损坏
    NSData* tempData = UIImagePNGRepresentation(image);
    if (tempData == nil) {
        return NO;
    } else {
        return YES;
    }
}

+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView{
    
    if (!textView || textView.font == nil) {
        Dlog(@"传入参数有误！");
        return 0.;
    }
    if ([textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)]){
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        CGRect frame = textView.bounds;
        // Take account of the padding added around the text.
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"]){
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        // NSString class method: boundingRectWithSize:options:attributes:context is
        //available only on ios7.0 sdk.
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *attributes = @{NSFontAttributeName:textView.font, NSParagraphStyleAttributeName:paragraphStyle};
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }else{
        return textView.contentSize.height;
    }
}

+ (UIImage *)resizeImage:(UIImage *)img_original{
    if (!img_original) {
        Dlog(@"Error:传入参数错误");
        return nil;
    }
    NSData *imgSizeData     = UIImageJPEGRepresentation(img_original, 0.5);
    UIImage *image          = [UIImage imageWithData:imgSizeData];
    if (([imgSizeData length] > 1024 * 500) && [imgSizeData length] <= 1024 * 1000){//图片小于300K 不压缩
        image   = [HDUtility scaleImage:img_original toScale:0.8];
    }else if( [imgSizeData length] > 1024 * 1000){
        image   = [HDUtility scaleImage:img_original toScale:0.7];
    }
    return image;
}
+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width*scaleSize,image.size.height*scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height *scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
@end
