//
//  HDPreviewImageCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/6/18.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPreviewImageCtr.h"

@interface HDPreviewImageCtr (){
    NSString *sUrl;
    UIImage *image;
}
@property (strong) IBOutlet UIActivityIndicatorView *aiv;
@end

@implementation HDPreviewImageCtr

- (id)initWithImage:(UIImage *)image_{
    if (self = [super init]) {
        image = image_;
    }
    return self;
}

- (id)initWithUrl:(NSString *)url{
    if (self = [super init]) {
        sUrl = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aiv.hidden = YES;
    if (sUrl.length > 0) {
        self.aiv.hidden = NO;
        [self.aiv startAnimating];
        [HDJJUtility getImage:sUrl withBlock:^(NSString *code, NSString *message, UIImage *img) {
            [_aiv stopAnimating];
            _aiv.hidden = YES;
            [self setImage:img];
        }];
        return;
    }
    if (image) {
        [self setImage:image];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)setImage:(UIImage *)image_{
    self.lc_width.constant   = HDDeviceSize.width;
    self.lc_height.constant  = HDDeviceSize.width * image_.size.height/image_.size.width;
    if (self.lc_height.constant > HDDeviceSize.height) {
        self.lc_height.constant  = HDDeviceSize.height;
        self.lc_width.constant   = (HDDeviceSize.height) * image_.size.width/image_.size.height;
    }
    [self.view updateConstraints];
    [self.imv setImage:image_];
}
@end
