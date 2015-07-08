//
// HDHUD.m
//  DennisHu
//
//  Created by DennisHu on 14-8-15.
//
//

#import "HDHUD.h"

@interface HDHUD () <MBProgressHUDDelegate>

@end


@implementation HDHUD

+ (HDHUD *)showLoading:(NSString *)text on:(UIView *)view {
    HDHUD *manager  = [[HDHUD alloc] init];
    manager.hud     = [MBProgressHUD showHUDAddedTo:view animated:YES];
    manager.hud.delegate        = manager;
    manager.hud.labelText       = text;
    manager.hud.dimBackground   = YES;
    manager.hud.removeFromSuperViewOnHide = YES;
    return manager;
}

+ (void)showNote:(NSString *)text {
    [self showNote:text on:kWindow];
}

+ (void)showNote:(NSString *)text on:(UIView *)view {
    MBProgressHUD *hud  = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText       = text;
    hud.mode            = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:1];
}
- (void)hudWasHidden:(MBProgressHUD *)hud {
    
}
- (void)hiden {
    [self.hud hide:YES];
}

@end
