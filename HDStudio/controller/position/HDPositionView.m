//
//  HDPositionView.m
//  HDStudio
//
//  Created by Hu Dennis on 15/2/11.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDPositionView.h"


@implementation HDPositionView

- (void)awakeFromNib{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDPositionPhotoCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDPositionTitleCell class]]) {
            self.titleCell = (HDPositionTitleCell *)obj;
        }
        if ([obj isKindOfClass:[HDPositionDescribeCell class]]) {
            self.positionDescribeCell = (HDPositionDescribeCell *)obj;
            self.positionDescribeCell.tv_positonDesc.delegate   = self;
        }
        if ([obj isKindOfClass:[HDPositionEnterpriceCell class]]) {
            self.enterpriceCell = (HDPositionEnterpriceCell *)obj;
            self.enterpriceCell.tv_enterpriceDesc.delegate  = self;
        }
        if ([obj isKindOfClass:[HDPositionPhotoCell class]]) {
            self.photoCell = (HDPositionPhotoCell *)obj;
        }
    }
    v_footer.frame                  = CGRectMake(0, 0, HDDeviceSize.width, 106);
    self.tbv.tableFooterView        = v_footer;
}

- (void)keyboardDidShow:(NSNotification *)noti{
    NSDictionary* info = [noti userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.lc_tbvBottom.constant =  kbSize.height + 30;
    [self setNeedsUpdateConstraints];
}
- (void)keyboardWillHidden:(NSNotification *)noti{
    self.lc_tbvBottom.constant = 0;
    [self setNeedsUpdateConstraints];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    if ([textView isEqual:self.positionDescribeCell.tv_positonDesc]) {
        if (self.positionDescribeCell.tv_positonDesc.text.length > 0) {
            self.positionDescribeCell.lb_placeholder.text   = nil;
        }else{
            self.positionDescribeCell.lb_placeholder.text   = @"职位要求、薪酬福利、推荐有奖等";
        }
    }
    if ([textView isEqual:self.enterpriceCell.tv_enterpriceDesc]) {
        if (self.enterpriceCell.tv_enterpriceDesc.text.length > 0) {
            self.enterpriceCell.lb_placeholder.text         = nil;
        }else{
            self.enterpriceCell.lb_placeholder.text         = @"把雇主的亮点都晒出来吧";
        }
    }
    
    CGFloat htp = self.positionDescribeCell.tv_positonDesc.contentSize.height;
    self.positionDescribeCell.lc_positionDescHeight.constant    = htp;
    
    CGFloat hte = self.enterpriceCell.tv_enterpriceDesc.contentSize.height;
    self.enterpriceCell.lc_enterpriceDescHeight.constant        = hte;
    [textView.superview setNeedsUpdateConstraints];
    [self.tbv beginUpdates];
    [self.tbv endUpdates];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{

    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    return YES;
}

#pragma mark -
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Dlog(@"121212123213213");
}

#pragma mark -
#pragma mark UITableViewDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:{
            return 60;
        }
        case 1:{
            CGFloat height = self.positionDescribeCell.tv_positonDesc.contentSize.height;
            return 68+(height <= 36? 36: height);
        }
        case 2:{
            CGFloat height = self.enterpriceCell.tv_enterpriceDesc.contentSize.height;
            return 73+(height <= 36? 36: height);
        }
        case 3:{
            return 164;
        }
        default:
            break;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
       return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setNeedsUpdateConstraints];
    switch (indexPath.section) {
        case 0:{
            return self.titleCell;
        }
        case 1:{
            return self.positionDescribeCell;
        }
        case 2:{
            return self.enterpriceCell;
        }
        case 3:{
            return self.photoCell;
        }
        default:
            break;
    }
    return nil;
}

#pragma mark - touch

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

    [_positionDescribeCell.tv_positonDesc   resignFirstResponder];
    [_enterpriceCell.tv_enterpriceDesc      resignFirstResponder];
    [_titleCell.tf_title                    resignFirstResponder];
}



@end
