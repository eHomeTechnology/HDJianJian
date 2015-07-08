//
//  HDBubbleDataInternal.h
//
//  Created by DennisHu
//

#import <Foundation/Foundation.h>

@class HDBubbleData;

@interface HDBubbleDataInternal : NSObject

@property (nonatomic, strong) HDBubbleData  *data;
@property (nonatomic, strong) NSString      *header;
@property (nonatomic) float     height;
@property (nonatomic) CGSize    labelSize;

@end
