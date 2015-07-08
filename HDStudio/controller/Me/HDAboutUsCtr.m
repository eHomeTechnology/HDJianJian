//
//  HDAboutUsCtr.m
//  JianJian
//
//  Created by Hu Dennis on 15/4/8.
//  Copyright (c) 2015年 Hu Dennis. All rights reserved.
//

#import "HDAboutUsCtr.h"


@implementation HDAboutCell



@end


@interface HDAboutUsCtr (){
    
    IBOutlet UIView     *v_head;

}

@property (strong) IBOutlet UITableView *tbv;

@end

@implementation HDAboutUsCtr

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup{
    self.navigationItem.title = LS(@"TXT_TITLE_ABOUT_US");
    v_head.frame = CGRectMake(0, 0, HDDeviceSize.width, 260);
    [self.tbv setTableHeaderView:v_head];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


#pragma mark -
#pragma mark UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark UITableView Datasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"HDJianCell";
    HDAboutCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell    = [self getCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.lb_title.text  = @[LS(@"TXT_ME_ABOUT_SOFT_VERSION"), LS(@"TXT_ME_ABOUT_AFFICEAL_NET_STATE"), LS(@"TXT_ME_ABOUT_EMAIL_ADDRESS")][indexPath.row];
    cell.lb_value.text  = @[@"V1.0.6", @"http://www.liudu.com", @"service@liudu.com"][indexPath.row];
    cell.v_line.hidden = indexPath.row == 2? YES: NO;
    return cell;
}

- (HDAboutCell *)getCell{
    HDAboutCell *cell = nil;
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HDAboutCell" owner:self options:nil];
    for (NSObject *obj in objects) {
        if ([obj isKindOfClass:[HDAboutCell class]]) {
            cell = (HDAboutCell *)obj;
            break;
        }
    }
    return cell;
}

@end
