//
//  HDBlurView.m
//  SNVideo
//
//  Created by Hu Dennis on 14-9-15.
//  Copyright (c) 2014年 StarNet智能家居研发部. All rights reserved.
//

#import "HDBlurView.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@implementation UIImage (HDBlurView)

- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor
{
    //image must be nonzero size
    if (floorf(self.size.width) * floorf(self.size.height) <= 0.0f) return self;
    //boxsize must be an odd integer
    uint32_t boxSize        = (uint32_t)(radius * self.scale);
    if (boxSize % 2 == 0) boxSize ++;
    //create image buffers
    vImage_Buffer buffer1, buffer2;
    CGImageRef imageRef     = self.CGImage;
    buffer1.width           = buffer2.width = CGImageGetWidth(imageRef);
    buffer1.height          = buffer2.height = CGImageGetHeight(imageRef);
    buffer1.rowBytes        = buffer2.rowBytes = CGImageGetBytesPerRow(imageRef);
    size_t bytes            = buffer1.rowBytes * buffer1.height;
    buffer1.data            = malloc(bytes);
    buffer2.data            = malloc(bytes);
    //create temp buffer
    void *tempBuffer        = malloc((size_t)vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, NULL, 0, 0, boxSize, boxSize,
                                                                 NULL, kvImageEdgeExtend + kvImageGetTempBufferSize));
    //copy image data
    CFDataRef dataSource    = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
    memcpy(buffer1.data, CFDataGetBytePtr(dataSource), bytes);
    CFRelease(dataSource);
    
    for (NSUInteger i = 0; i < iterations; i++){
        //perform blur
        vImageBoxConvolve_ARGB8888(&buffer1, &buffer2, tempBuffer, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
        //swap buffers
        void *temp      = buffer1.data;
        buffer1.data    = buffer2.data;
        buffer2.data    = temp;
    }
    
    //free buffers
    free(buffer2.data);
    free(tempBuffer);
    
    //create image context from buffer
    CGContextRef ctx = CGBitmapContextCreate(buffer1.data, buffer1.width, buffer1.height,
                                             8, buffer1.rowBytes, CGImageGetColorSpace(imageRef),
                                             CGImageGetBitmapInfo(imageRef));
    
    //apply tint
    if (tintColor && CGColorGetAlpha(tintColor.CGColor) > 0.0f){
        CGContextSetFillColorWithColor(ctx, [tintColor colorWithAlphaComponent:0.25].CGColor);
        CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
        CGContextFillRect(ctx, CGRectMake(0, 0, buffer1.width, buffer1.height));
    }
    
    //create image from context
    imageRef        = CGBitmapContextCreateImage(ctx);
    UIImage *image  = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    CGContextRelease(ctx);
    free(buffer1.data);
    return image;
}

@end

@implementation HDBlurView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *img            = [HDUtility screenshotFromView:[UIApplication sharedApplication].keyWindow];
        UIImage *img_compress   = [self compressImage:img toCompress:0.8];
        UIImage *img_blur       = [img_compress blurredImageWithRadius:6 iterations:3 tintColor:[UIColor blackColor]];
        self.backgroundColor    = [UIColor clearColor];
        UIImageView *imv        = [[UIImageView alloc] initWithFrame:frame];
        [imv setImage:img_blur];
        [self addSubview:imv];
        _btn                    = [[UIButton alloc] initWithFrame:frame];
        _btn.backgroundColor    = [UIColor clearColor];
        [self addSubview:_btn];
    }
    return self;
}
- (UIImage *)compressImage:(UIImage *)image toCompress:(float)compressSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * compressSize, image.size.height * compressSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * compressSize, image.size.height * compressSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    
}




@end
