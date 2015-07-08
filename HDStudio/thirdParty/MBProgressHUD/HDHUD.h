//
//  HDHUD.h
//  DennisHu
//
//  Created by DennisHu on 14-8-15.
//
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
@interface HDHUD : NSObject <MBProgressHUDDelegate>

@property (nonatomic, retain) MBProgressHUD *hud;
+ (HDHUD *)showLoading:(NSString *)text on:(UIView *)view;
+ (void)showNote:(NSString *)text;
+ (void)showNote:(NSString *)text on:(UIView *)view;
- (void)hiden;
@end
