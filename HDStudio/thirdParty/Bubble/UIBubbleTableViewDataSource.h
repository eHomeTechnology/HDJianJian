//
//  HDBubbleTableViewDataSource.h
//
//  Created by DennisHu
//

#import <Foundation/Foundation.h>

@class HDBubbleData;
@class HDBubbleTableView;
@protocol HDBubbleTableViewDataSource <NSObject>

@optional

@required

- (NSInteger)rowsForBubbleTable:(HDBubbleTableView *)tableView;
- (HDBubbleData *)bubbleTableView:(HDBubbleTableView *)tableView dataForRow:(NSInteger)row;

@end
