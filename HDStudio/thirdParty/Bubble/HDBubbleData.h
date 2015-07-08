//
//  HDBubbleData
//
//  Created by DennisHu
//

#import <Foundation/Foundation.h>
#import "HDNewsInfo.h"
#import "WJPositionInfo.h"

@interface HDBubbleData : NSObject

@property (strong) NSString             *bubbleNo;
@property (strong) NSDate               *date;
@property (assign) HDNewsFormatType     formatType;
@property (assign) NSBubbleType         bubbleType;
@property (assign) HDSendingNewsStatus  status;
@property (strong) NSString             *text;
@property (strong) UIImage              *img_head;
@property (strong) NSString             *sImageUrl;
@property (strong) UIImage              *picture;
@property (strong) WJPositionInfo       *positionInfo;
@property (strong) HDTalentInfo         *talentInfo;

- (id)initWithText:(NSString *)text position:(WJPositionInfo *)position resume:(HDTalentInfo *)resume picture:(UIImage *)picture andDate:(NSDate *)date bubbleType:(NSBubbleType)type formatType:(HDNewsFormatType)formatType sendingStatus:(HDSendingNewsStatus)sendingStatus andImage:(UIImage *)img_avatar bubbleNo:(NSString *)n;
+ (id)dataWithText:(NSString *)text position:(WJPositionInfo *)position resume:(HDTalentInfo *)resume picture:(UIImage *)picture andDate:(NSDate *)date bubbleType:(NSBubbleType)type formatType:(HDNewsFormatType)formatType sendingStatus:(HDSendingNewsStatus)sendingStatus andImage:(UIImage *)img_avatar bubbleNo:(NSString *)n;

- (id)initWithMessageInfo:(HDMessageInfo *)info;
+ (id)dataWithMessageInfo:(HDMessageInfo *)info;
+ (HDBubbleData *)dataWithEMMessage:(EMMessage *)message avatar:(UIImage *)image;
@end
