//
//  HDBubbleTableView.m
//
//  Created by DennisHu
//

#import "HDBubbleTableView.h"
#import "HDBubbleData.h"
#import "HDBubbleDataInternal.h"

@interface HDBubbleTableView ()
@property (nonatomic, retain) NSMutableDictionary *bubbleDictionary;

@end

@implementation HDBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleDictionary = _bubbleDictionary;

#pragma mark - Initializators

- (void)initializator
{
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    self.delegate = self;
    self.dataSource = self;
    self.snapInterval = 120;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

#pragma mark - Override

- (void)reloadData
{
	self.bubbleDictionary = nil;
    int count = 0;
    if (self.bubbleDataSource && (count = (int)[self.bubbleDataSource rowsForBubbleTable:self]) > 0){
        self.bubbleDictionary = [[NSMutableDictionary alloc] init];
        NSMutableArray *bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
        for (int i = 0; i < count; i++){
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[HDBubbleData class]]);
            [bubbleData addObject:object];
        }
        [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2){
            HDBubbleData *bubbleData1 = (HDBubbleData *)obj1;
            HDBubbleData *bubbleData2 = (HDBubbleData *)obj2;
            return [bubbleData1.date compare:bubbleData2.date];            
        }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        for (int i = 0; i < count; i++){
            HDBubbleDataInternal *dataInternal = [[HDBubbleDataInternal alloc] init];
            dataInternal.data = (HDBubbleData *)[bubbleData objectAtIndex:i];

            NSString *s = (dataInternal.data.text ? dataInternal.data.text : @"");
            dataInternal.labelSize      = [s boundingRectWithSize:CGSizeMake(HDDeviceSize.width-100, 9999)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                      context:nil].size;
            dataInternal.labelSize  = CGSizeMake(dataInternal.labelSize.width, MAX(dataInternal.labelSize.height, 40));
            dataInternal.height     = dataInternal.labelSize.height + 20;
            dataInternal.header     = nil;
            if ([dataInternal.data.date timeIntervalSinceDate:last] > self.snapInterval){
                currentSection = [[NSMutableArray alloc] init];
                [self.bubbleDictionary setObject:currentSection forKey:[NSString stringWithFormat:@"%d",i]];
                dataInternal.header = [HDUtility returnHumanizedTime:dataInternal.data.date];
                dataInternal.height += 35;
            }
            [currentSection addObject:dataInternal];
            last = dataInternal.data.date;
        }
    }
    [super reloadData];
}

- (CGSize)sizeWithString:(NSString *)s{
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:s];
    
    NSRange allRange = [s rangeOfString:s];
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:13.0]
                    range:allRange];
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor blackColor]
                    range:allRange];
    NSStringDrawingOptions options =  NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(220, 9999)
                                        options:options
                                        context:nil];
    return rect.size;

}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.bubbleDictionary) return 0;
    NSInteger i = [[self.bubbleDictionary allKeys] count];
    return i;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSArray *keys = [self.bubbleDictionary allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
	}];
    NSString *key = [sortedArray objectAtIndex:section];
    return [[self.bubbleDictionary objectForKey:key] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
	NSArray *keys = [self.bubbleDictionary allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
	}];
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    HDBubbleDataInternal *dataInternal = ((HDBubbleDataInternal *)[[self.bubbleDictionary objectForKey:key] objectAtIndex:indexPath.row]);
    switch (dataInternal.data.formatType) {
        case HDNewsFormatTypeText:{
             return (float)dataInternal.height;
        }
        case HDNewsFormatTypeImage:{
            float height = 0;
            CGSize size = dataInternal.data.picture.size;
            CGFloat maxWith = HDDeviceSize.width/2;
            height = size.width <= maxWith? size.height: (maxWith * size.height/size.width);
            return height + dataInternal.height - 30;
        }
        default:
            
            break;
    }

   return (float)dataInternal.height - dataInternal.labelSize.height + 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"tblBubbleCell";
    
	NSArray *keys = [self.bubbleDictionary allKeys];
	NSArray *sortedArray = [keys sortedArrayUsingComparator:^(id firstObject, id secondObject) {
		return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch];
	}];
    NSString *key = [sortedArray objectAtIndex:indexPath.section];
    HDBubbleDataInternal *dataInternal = ((HDBubbleDataInternal *)[[self.bubbleDictionary objectForKey:key] objectAtIndex:indexPath.row]);
    HDBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil){
        bubbleCell = [[NSBundle mainBundle] loadNibNamed:@"HDBubbleTableViewCell" owner:self options:nil][0];
        cell = bubbleCell;
    }
    
    cell.dataInternal = dataInternal;
    return cell;
}

@end
