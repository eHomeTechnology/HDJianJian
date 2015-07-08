//
//  HDBubbleTableViewDataSource.h
//
//  Created by DennisHu
//

#import "HDBubbleTableViewCell.h"
#import "HDBubbleData.h"
#import "HDPositionDetailCtr.h"

float Wmax  = 200;
float Wmin  = 30;
float Hmax  = 200;
float Hmin  = 30;

@interface HDBubbleTableViewCell (){
    IBOutlet UILabel                    *headerLabel;
    IBOutlet UILabel                    *contentLabel;
    __weak IBOutlet UILabel             *contentLabel_Two;
    IBOutlet UIImageView                *bubbleImage;
    IBOutlet UIImageView                *headImage;
    IBOutlet UIActivityIndicatorView    *aiv;
    IBOutlet UIButton                   *btn_false;
    IBOutlet UIButton                   *btn_icon;  //职位和简历icon
    IBOutlet UILabel                    *lb_2;      //职位需要两个label
    IBOutlet UILabel                    *lb_3;      //简历需要三个label
}

@end

@implementation HDBubbleTableViewCell

@synthesize dataInternal = _dataInternal;

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
	[self setupInternalData];
}
- (void)setIsShowIndicatorView:(BOOL)isShowIndicatorView{

    
}
- (void)setDataInternal:(HDBubbleDataInternal *)value
{
    _dataInternal = nil;
	_dataInternal = value;
	[self setupInternalData];
}

- (void)setupInternalData{
    switch (_dataInternal.data.formatType) {
        case HDNewsFormatTypeText:{
            [self setupInternalData_text];
            break;
        }
        case HDNewsFormatTypeImage:{
            [self setupInternalData_image];
            break;
        }
        case HDNewsFormatTypeResume:{
            [self setupInternalData_resume];
            break;
        }
        case HDNewsFormatTypePosition:{
            [self setupInternalData_position];
            break;
        }
        default:
            break;
    }
}

- (void)setupInternalData_text{
    if (self.dataInternal.header){
        headerLabel.hidden  = NO;
        headerLabel.text    = self.dataInternal.header;
    }else{
        headerLabel.hidden  = YES;
    }
    btn_icon.hidden         = YES;
    lb_2.hidden             = YES;
    lb_3.hidden             = YES;
    contentLabel.hidden     = YES;
    contentLabel_Two.hidden = NO;
    NSBubbleType type       = self.dataInternal.data.bubbleType;
    float x = (type == BubbleTypeSomeoneElse) ? 74 : self.frame.size.width - 74 - self.dataInternal.labelSize.width;
    float y = 5 + (self.dataInternal.header ? 30 : 0);
    headImage.frame     = CGRectMake((type == BubbleTypeSomeoneElse)? 8: self.frame.size.width - 8 - 44, y, 44, 44);
    [headImage setImage:self.dataInternal.data.img_head];
    contentLabel_Two.frame  = CGRectMake(x, y, self.dataInternal.labelSize.width, self.dataInternal.labelSize.height);
    contentLabel_Two.text   = self.dataInternal.data.text;
    if (type == BubbleTypeSomeoneElse){
        bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone"] stretchableImageWithLeftCapWidth:50 topCapHeight:40];
        bubbleImage.frame = CGRectMake(x - 18, y - 4, self.dataInternal.labelSize.width + 30, self.dataInternal.labelSize.height + 15);
        aiv.frame   = CGRectMake(CGRectGetWidth(bubbleImage.frame) + CGRectGetMinX(bubbleImage.frame) + 10, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
        btn_false.hidden    = YES;
        aiv.hidden          = YES;
        return;
    }
    bubbleImage.image = [[UIImage imageNamed:@"bubbleMine"] stretchableImageWithLeftCapWidth:15 topCapHeight:40];
    bubbleImage.frame = CGRectMake(x - 9, y - 4, self.dataInternal.labelSize.width + 26, self.dataInternal.labelSize.height + 15);
    aiv.frame   = CGRectMake(CGRectGetMinX(bubbleImage.frame) - 30, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
    btn_false.frame = aiv.frame;
    switch (_dataInternal.data.status) {
        case HDSendingNewsStatusBegin:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusSending:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusFalse:{
            btn_false.hidden    = NO;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        case HDSendingNewsStatusSuccess:{
            btn_false.hidden    = YES;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        default:
            break;
    }
}

- (void)setupInternalData_resume{
    if (self.dataInternal.header){
        headerLabel.hidden  = NO;
        headerLabel.text    = self.dataInternal.header;
    }else{
        headerLabel.hidden  = YES;
    }
    btn_icon.hidden         = NO;
    lb_2.hidden             = NO;
    lb_3.hidden             = NO;
    contentLabel.hidden     = NO;
    contentLabel_Two.hidden = YES;
    contentLabel.text   = FORMAT(@"%@ | %@",self.dataInternal.data.talentInfo.sName,self.dataInternal.data.talentInfo.sWorkYears);
    lb_2.text           = self.dataInternal.data.talentInfo.sCurPosition;
    lb_3.text           = self.dataInternal.data.talentInfo.sCurCompanyName;
    NSBubbleType type   = self.dataInternal.data.bubbleType;
    lb_2.textColor      = [UIColor grayColor];
    lb_3.textColor      = [UIColor grayColor];
    float x = (type == BubbleTypeSomeoneElse) ? 74 : self.frame.size.width - 74 - self.dataInternal.labelSize.width;
    float y = 5 + (self.dataInternal.header ? 30 : 0);
    headImage.frame     = CGRectMake((type == BubbleTypeSomeoneElse)? 8: self.frame.size.width - 8 - 44, y, 44, 44);
    [headImage setImage:self.dataInternal.data.img_head];
    
    if (type == BubbleTypeSomeoneElse){
        bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone"] stretchableImageWithLeftCapWidth:50 topCapHeight:40];
        bubbleImage.frame = CGRectMake(x - 18, y - 4, 190,75);
        aiv.frame   = CGRectMake(CGRectGetWidth(bubbleImage.frame) + CGRectGetMinX(bubbleImage.frame) + 10, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
        btn_false.hidden    = YES;
        aiv.hidden          = YES;
    }else{
        bubbleImage.image = [[UIImage imageNamed:@"bubbleMine"] stretchableImageWithLeftCapWidth:15 topCapHeight:40];
        bubbleImage.frame = CGRectMake(x - 170, y - 4,190, 75);
        aiv.frame   = CGRectMake(CGRectGetMinX(bubbleImage.frame) - 40,CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10 , 20, 20);
        btn_false.frame     = aiv.frame;
    }
    btn_icon.frame      = CGRectMake((type == BubbleTypeSomeoneElse)? 20: 10, 12, 52, 52);
    btn_icon.userInteractionEnabled = NO;
    [btn_icon setBackgroundImage:[UIImage imageNamed:@"btn_sendTalent"] forState:UIControlStateNormal];
    contentLabel.frame  = CGRectMake((type == BubbleTypeSomeoneElse)? 80: 70, 8, 100, 18);
    lb_2.frame  = CGRectMake((type == BubbleTypeSomeoneElse)? 80: 70, 29, 100, 18);
    lb_3.frame  = CGRectMake((type == BubbleTypeSomeoneElse)? 80: 70, 47, 100, 18);
    [bubbleImage addSubview:btn_icon];
    [bubbleImage addSubview:contentLabel];
    [bubbleImage addSubview:lb_2];
    [bubbleImage addSubview:lb_3];
    
    UITapGestureRecognizer *bubbleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkResume)];
    bubbleImage.userInteractionEnabled = YES;
    [bubbleImage addGestureRecognizer:bubbleImgTap];
    
    switch (_dataInternal.data.status) {
        case HDSendingNewsStatusBegin:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusSending:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusFalse:{
            btn_false.hidden    = NO;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        case HDSendingNewsStatusSuccess:{
            btn_false.hidden    = YES;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        default:
            break;
    }

}

- (void)setupInternalData_position{
    if (self.dataInternal.header){
        headerLabel.hidden  = NO;
        headerLabel.text    = self.dataInternal.header;
    }else{
        headerLabel.hidden  = YES;
    }
    btn_icon.hidden         = NO;
    lb_2.hidden             = NO;
    contentLabel.hidden     = NO;
    contentLabel_Two.hidden = YES;
    lb_3.hidden             = YES;
    contentLabel.text = self.dataInternal.data.positionInfo.sPositionName;
    lb_2.text         = self.dataInternal.data.positionInfo.sRemark;
    NSBubbleType type       = self.dataInternal.data.bubbleType;
    float x = (type == BubbleTypeSomeoneElse) ? 74 : self.frame.size.width - 74 - self.dataInternal.labelSize.width;
    float y = 5 + (self.dataInternal.header ? 30 : 0);
    headImage.frame     = CGRectMake((type == BubbleTypeSomeoneElse)? 8: self.frame.size.width - 8 - 44, y, 44, 44);
    [headImage setImage:self.dataInternal.data.img_head];
    
    if (type == BubbleTypeSomeoneElse){
        bubbleImage.image = [[UIImage imageNamed:@"bubbleSomeone"] stretchableImageWithLeftCapWidth:50 topCapHeight:40];
        bubbleImage.frame = CGRectMake(x - 18, y - 4, 190, 75);
        aiv.frame   = CGRectMake(CGRectGetWidth(bubbleImage.frame) + CGRectGetMinX(bubbleImage.frame) + 10, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
        btn_false.hidden    = YES;
        aiv.hidden          = YES;
    }else{
        bubbleImage.image = [[UIImage imageNamed:@"bubbleMine"] stretchableImageWithLeftCapWidth:15 topCapHeight:40];
        bubbleImage.frame = CGRectMake(x - 170, y - 4, 190, 75);
        aiv.frame   = CGRectMake(CGRectGetMinX(bubbleImage.frame) - 30, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
        btn_false.frame     = aiv.frame;
    }
    
    btn_icon.frame      = CGRectMake((type == BubbleTypeSomeoneElse)? 20: 10, 10, 52, 52);
    btn_icon.userInteractionEnabled = NO;
    [btn_icon setBackgroundImage:[UIImage imageNamed:@"icon_zhaoping"] forState:UIControlStateNormal];
    contentLabel.frame      = CGRectMake((type == BubbleTypeSomeoneElse)? 80: 70, 10, 100, 18);
     lb_2.frame      = CGRectMake((type == BubbleTypeSomeoneElse)? 80: 70, 43, 100, 18);
    [bubbleImage addSubview:btn_icon];
    [bubbleImage addSubview:contentLabel];
    [bubbleImage addSubview:lb_2];
    
    UITapGestureRecognizer *bubbleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkPosition)];
    bubbleImage.userInteractionEnabled = YES;
    [bubbleImage addGestureRecognizer:bubbleImgTap];
    
    switch (_dataInternal.data.status) {
        case HDSendingNewsStatusBegin:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusSending:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusFalse:{
            btn_false.hidden    = NO;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        case HDSendingNewsStatusSuccess:{
            btn_false.hidden    = YES;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        default:
            break;
    }
}

- (void)setupInternalData_image{
    if (self.dataInternal.header){
        headerLabel.hidden  = NO;
        headerLabel.text    = self.dataInternal.header;
    }else{
        headerLabel.hidden  = YES;
    }
    btn_icon.hidden         = NO;
    contentLabel.hidden     = YES;
    contentLabel_Two.hidden = YES;
    lb_2.hidden             = YES;
    lb_3.hidden             = YES;

    NSBubbleType type       = self.dataInternal.data.bubbleType;
    float x = (type == BubbleTypeSomeoneElse) ? 74 : self.frame.size.width - 74;
    float y = 5 + (self.dataInternal.header ? 30 : 0);
    headImage.frame     = CGRectMake((type == BubbleTypeSomeoneElse)? 8: self.frame.size.width - 8 - 44, y, 44, 44);
    [headImage setImage:self.dataInternal.data.img_head];

    if (type == BubbleTypeSomeoneElse){
        bubbleImage.image = [[UIImage imageNamed:@""] stretchableImageWithLeftCapWidth:50 topCapHeight:40];
        float height = 0;
        CGSize size = self.dataInternal.data.picture.size;
        CGFloat maxWith = HDDeviceSize.width/2;
        height = size.width <= maxWith? size.height: (maxWith * size.height/size.width);
        bubbleImage.frame   = CGRectMake(x - 10, y, MIN(maxWith, size.width), height);
        aiv.frame   = CGRectMake(CGRectGetWidth(bubbleImage.frame) + CGRectGetMinX(bubbleImage.frame) + 10, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
        btn_false.hidden    = YES;
        aiv.hidden          = YES;
    }else {
        bubbleImage.image = [[UIImage imageNamed:@""] stretchableImageWithLeftCapWidth:15 topCapHeight:40];
        float height = 0;
        CGSize size = self.dataInternal.data.picture.size;
        CGFloat maxWith = HDDeviceSize.width/2;
        height = size.width <= maxWith? size.height: (maxWith * size.height/size.width);
        bubbleImage.frame   = CGRectMake(x - MIN(maxWith, size.width) + 10, y, MIN(maxWith, size.width), height);
        aiv.frame   = CGRectMake(CGRectGetMinX(bubbleImage.frame) - 30, CGRectGetMinY(bubbleImage.frame) + CGRectGetHeight(bubbleImage.frame)/2 - 10, 20, 20);
        btn_false.frame     = aiv.frame;
    }
    bubbleImage.userInteractionEnabled = YES;
    btn_icon.frame = CGRectMake(0, 0, bubbleImage.frame.size.width, bubbleImage.frame.size.height);
    [btn_icon setBackgroundImage:self.dataInternal.data.picture forState:UIControlStateNormal];
    btn_icon.userInteractionEnabled = NO;
    btn_icon.layer.cornerRadius     = 8;
    btn_icon.layer.masksToBounds    = YES;
    [bubbleImage addSubview:btn_icon];
    
    UITapGestureRecognizer *bubbleImgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkPicture)];
    bubbleImage.userInteractionEnabled = YES;
    [bubbleImage addGestureRecognizer:bubbleImgTap];
    
    switch (_dataInternal.data.status) {
        case HDSendingNewsStatusBegin:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusSending:{
            btn_false.hidden    = YES;
            aiv.hidden          = NO;
            [aiv startAnimating];
            break;
        }
        case HDSendingNewsStatusFalse:{
            btn_false.hidden    = NO;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        case HDSendingNewsStatusSuccess:{
            btn_false.hidden    = YES;
            aiv.hidden          = YES;
            [aiv stopAnimating];
            break;
        }
        default:
            break;
    }
}

- (void)checkPosition{
    NSLog(@"产看职位信息");
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_BUBBLE_CELL_CHECK object:_dataInternal.data.positionInfo userInfo:@{@"key": @"position"}];
    
}

- (void)checkResume{
    NSLog(@"查看简历信息");
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_BUBBLE_CELL_CHECK object:_dataInternal.data.talentInfo userInfo:@{@"key": @"talent"}];
}

- (void)checkPicture{
    [[NSNotificationCenter defaultCenter] postNotificationName:HD_NOTIFICATION_KEY_PREVIEW_BLOG_IMAGE object:self.dataInternal.data.picture];
}

@end
