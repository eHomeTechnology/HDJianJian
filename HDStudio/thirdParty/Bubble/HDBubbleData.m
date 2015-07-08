//
//  HDBubbleData.m
//
//  Created by DennisHu
//

#import "HDBubbleData.h"

@implementation HDBubbleData

+ (HDBubbleData *)dataWithEMMessage:(EMMessage *)message avatar:(UIImage *)image{
    if (!message || message.messageBodies.count == 0) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.timestamp/1000];
    NSBubbleType bubbleType = ![message.from isEqualToString:[HDGlobalInfo instance].userInfo.sHumanNo];
    HDBubbleData *bubbleData = [HDBubbleData new];
    NSDictionary *dic = message.ext;
    NSNumber *nType = dic[@"chat_formattype"];
    if (message.messageBodies.count == 0) {
        Dlog(@"Error:EM消息体有误，请核查");
        return nil;
    }
    id<IEMMessageBody> body = message.messageBodies[0];
    if (body.messageBodyType == eMessageBodyType_Text && (nType.integerValue == 1 || nType == nil)) {
        EMTextMessageBody *textBody = (EMTextMessageBody *)body;
        bubbleData = [bubbleData initWithText:textBody.text position:nil resume:nil picture:nil andDate:date bubbleType:bubbleType formatType:HDNewsFormatTypeText sendingStatus:(HDSendingNewsStatus)message.deliveryState andImage:image bubbleNo:message.messageId];
        return bubbleData;
    }
    if (body.messageBodyType == eMessageBodyType_Text && nType.integerValue == 7) {//简历
        EMTextMessageBody *textBody = (EMTextMessageBody *)body;
        NSData *data = [textBody.text dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        Dlog(@"__d7 = %@", d);
        HDTalentInfo *talent = [HDTalentInfo new];
        talent.sHumanNo = [HDJJUtility isNull:d[@"PersonalNo"]]?    @"": d[@"PersonalNo"];
        talent.sName    = [HDJJUtility isNull:d[@"PersonalName"]]?  @"": d[@"PersonalName"];
        talent.sPhone   = [HDJJUtility isNull:d[@"PersonalPhone"]]? @"": d[@"PersonalPhone"];
        talent.sCurCompanyName  = [HDJJUtility isNull:d[@"CompanyName"]]?   @"": d[@"CompanyName"];
        talent.sCurPosition     = [HDJJUtility isNull:d[@"PositionName"]]?  @"": d[@"PositionName"];
        talent.sWorkYears       = [HDJJUtility isNull:d[@"WorkYears"]]?     @"": d[@"WorkYears"];
        bubbleData = [bubbleData initWithText:nil position:nil resume:talent picture:nil andDate:date bubbleType:bubbleType formatType:HDNewsFormatTypeResume sendingStatus:(HDSendingNewsStatus)message.deliveryState andImage:image bubbleNo:message.messageId];
        return bubbleData;
    }
    if (body.messageBodyType == eMessageBodyType_Text && nType.integerValue == 8) {//职位
        EMTextMessageBody *textBody = (EMTextMessageBody *)body;
        NSData *data = [textBody.text dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *d = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        Dlog(@"__d8 = %@", d);
        WJPositionInfo *position = [WJPositionInfo new];
        position.employerInfo.sName     = [HDJJUtility isNull:d[@"CompanyName"]]?    @"": d[@"CompanyName"];
        position.sRemark                = [HDJJUtility isNull:d[@"PositionDes"]]?    @"": d[@"PositionDes"];
        position.sPositionName          = [HDJJUtility isNull:d[@"PositionName"]]?   @"": d[@"PositionName"];
        position.sPositionNo            = [HDJJUtility isNull:d[@"PositionNo"]]?     @"": d[@"PositionNo"];
        bubbleData = [bubbleData initWithText:nil position:position resume:nil picture:nil andDate:date bubbleType:bubbleType formatType:HDNewsFormatTypePosition sendingStatus:(HDSendingNewsStatus)message.deliveryState andImage:image bubbleNo:message.messageId];
        return bubbleData;
    }
    if (body.messageBodyType == eMessageBodyType_Image) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)body;
        UIImage *image_ = nil;
        Dlog(@"imageBody.attachmentDownloadStatus = %d", (int)imageBody.attachmentDownloadStatus);
        if (imageBody.attachmentDownloadStatus == EMAttachmentDownloadSuccessed) {
            image_ = [UIImage imageWithContentsOfFile:imageBody.localPath];
        }else {
            if(imageBody.thumbnailDownloadStatus == EMAttachmentDownloadSuccessed){
                image_ = [UIImage imageWithContentsOfFile:imageBody.thumbnailLocalPath];
            }else{
                image_ = HDIMAGE(@"placeHold");
            }
        }
        if (!image_) {
            Dlog(@"Error:image不能为空");
            return nil;
        }
        bubbleData = [bubbleData initWithText:nil position:nil resume:nil picture:image_ andDate:date bubbleType:bubbleType formatType:HDNewsFormatTypeImage sendingStatus:(HDSendingNewsStatus)message.deliveryState andImage:image bubbleNo:message.messageId];
        bubbleData.sImageUrl = imageBody.remotePath;
        return bubbleData;
    }
    return bubbleData;
}

+ (id)dataWithMessageInfo:(HDMessageInfo *)info{
    return [[self alloc] initWithMessageInfo:info];
}

- (id)initWithMessageInfo:(HDMessageInfo *)info{
    if (self = [super init]) {
        WJPositionInfo  *position   = [self positonWithString:info.sContent];
        HDTalentInfo    *talent     = [self talentWithString:info.sContent];
        NSDate *date  = [HDJJUtility dateWithTimeIntervalSiceChristionEra:[info.sCreateTime doubleValue]];
        self = [HDBubbleData dataWithText:info.sContent position:position resume:talent picture:nil andDate:date bubbleType:info.bubbleType formatType:info.formatType sendingStatus:HDSendingNewsStatusSuccess andImage:info.img_avata bubbleNo:info.sMsgID];
    }
    return self;
}

+ (id)dataWithText:(NSString *)text position:(WJPositionInfo *)position resume:(HDTalentInfo *)resume picture:(UIImage *)picture andDate:(NSDate *)date bubbleType:(NSBubbleType)type formatType:(HDNewsFormatType)formatType sendingStatus:(HDSendingNewsStatus)sendingStatus andImage:(UIImage *)img_avatar bubbleNo:(NSString *)n
{
    return [[HDBubbleData alloc] initWithText:text position:position resume:resume picture:nil andDate:date bubbleType:type formatType:formatType sendingStatus:sendingStatus andImage:img_avatar bubbleNo:n];
}

- (id)initWithText:(NSString *)initText position:(WJPositionInfo *)position resume:(HDTalentInfo *)resume picture:(UIImage *)picture andDate:(NSDate *)initDate bubbleType:(NSBubbleType)initType formatType:(HDNewsFormatType)formatType sendingStatus:(HDSendingNewsStatus)sendingStatus andImage:(UIImage *)img_avatar bubbleNo:(NSString *)n
{
    if (!initDate) {
        Dlog(@"Error:传入参数有误");
        return nil;
    }
    self = [super init];
    if (self){
        _text   = initText;
        if (!_text || [_text isEqualToString:@""]) _text = @" ";
        _date           = initDate;
        _bubbleType     = initType;
        _status         = sendingStatus;
        _img_head       = img_avatar;
        _formatType     = formatType;
        _positionInfo   = position;
        _talentInfo     = resume;
        _picture        = picture;
        _bubbleNo       = n;
    }
    return self;
}


#pragma mark - private method
- (WJPositionInfo *)positonWithString:(NSString *)str{
    if (str.length == 0) {
        Dlog(@"警告:传入参数为空");
        return nil;
    }
    NSString *jsonStr= str;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    WJPositionInfo *positionInfo = [WJPositionInfo new];
    positionInfo.sPositionName   = FORMAT(@"%@",[HDJJUtility isNull:json[@"PersonalName"]]? @"": json[@"PersonalName"]);
    positionInfo.sRemark         = FORMAT(@"%@",[HDJJUtility isNull:json[@"Title"]]?        @"": json[@"Title"]);
    positionInfo.sPositionNo     = FORMAT(@"%@",[HDJJUtility isNull:json[@"PersonalNo"]]?   @"": json[@"PersonalNo"]);
    return positionInfo;
}

- (HDTalentInfo *)talentWithString:(NSString *)str{
    if (str.length == 0) {
        Dlog(@"警告:传入参数为空");
        return nil;
    }
    NSString *jsonStr= str;
    NSData *jsonData    = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json  = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    HDTalentInfo *talent    = [HDTalentInfo new];
    talent.sName            = FORMAT(@"%@",[HDJJUtility isNull:json[@"PersonalName"]]? @"": json[@"PersonalName"]);
    talent.sWorkYears       = FORMAT(@"%@",[HDJJUtility isNull:json[@"WorkYears"]]?    @"": json[@"WorkYears"]);
    talent.sCurPosition     = FORMAT(@"%@",[HDJJUtility isNull:json[@"PositionName"]]? @"": json[@"PositionName"]);
    talent.sCurCompanyName  = FORMAT(@"%@",[HDJJUtility isNull:json[@"CompanyName"]]?  @"": json[@"CompanyName"]);
    talent.sHumanNo         = FORMAT(@"%@",[HDJJUtility isNull:json[@"PersonalNo"]]?   @"": json[@"PersonalNo"]);
    talent.sPhone           = FORMAT(@"%@",[HDJJUtility isNull:json[@"PersonalPhone"]]?@"": json[@"PersonalPhone"]);
    return talent;
}


@end
