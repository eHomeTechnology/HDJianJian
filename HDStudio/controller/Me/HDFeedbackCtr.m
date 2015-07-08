//
//  HDFeedbackCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDFeedbackCtr.h"

@interface HDFeedbackCtr ()

@property (strong) IBOutlet UITextView *tv;
@property (strong) AFHTTPRequestOperation *op;
@property (strong, nonatomic) IBOutlet UILabel *lb_message;

@end

@implementation HDFeedbackCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    _tv.delegate = self;
    [self setup];
   // self.navigationItem.title = LS(@"");
    _tv.layer.cornerRadius = 5.;
    _tv.layer.masksToBounds = YES;
    [_tv becomeFirstResponder];
}

- (void)setup{
    self.navigationItem.title = LS(@"WJ_TITLE_FEEDBACKS");
    UILabel * textLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, HDDeviceSize.width-30, 30)];
    textLabel.text = @"您的意见对我们很重要!!";
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.textColor = [UIColor grayColor];
    textLabel.tag = 100;
    textLabel.enabled = NO;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.font = [UIFont systemFontOfSize:16];
    [self.tv addSubview:textLabel];
}

#pragma mark - UITextViewDelegate
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [_tv resignFirstResponder];
}
- (void)textViewDidChange:(UITextView *)textView{
    UILabel *label = (UILabel *)[self.view viewWithTag:100];
    if (textView.text.length == 0) {
        label.text = @"您的意见对我们很重要!!";
        self.lb_message.text = @"最多可输入200字";
    }else{
        label.text = @"";
        NSString *str_text = textView.text;
        NSInteger existTextNum = [str_text length];
        self.lb_message.text = FORMAT(@"剩余%d字", (int)(200-existTextNum));
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    int remainTextNum = 200;
    if (range.location>=200) {
        remainTextNum = 0;
        return NO;
    }else{
        return YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if (_op) {
        [_op cancel];
        _op = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)httpSubmit{

    _op = [[HDHttpUtility sharedClient] feedback:[HDGlobalInfo instance].userInfo content:_tv.text completionBlock:^(BOOL isSuccess, NSString *sCode, NSString *sMessage) {
        if (!isSuccess) {
            [HDUtility mbSay:sMessage];
            return ;
        }
        [HDUtility mbSay:@"非常感谢您的意见反馈,我们马上跟进处理!"];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)doSubmit:(id)sender{

    if (_tv.text.length == 0) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_SAY_SOMETHING")];
        return;
    }
    if (_tv.text.length > 1000) {
        [HDUtility mbSay:LS(@"TXT_PLEASE_ENTER_LESS_THEN_1000")];
        return;
    }
    [self httpSubmit];
}
@end
