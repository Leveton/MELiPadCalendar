//
//  DateTable.m
//  iPadCalendar
//
//  Created by Mike Leveton on 1/26/13.
//  Copyright (c) 2013 Mike Leveton. All rights reserved.
//

#import "DateTable.h"


@interface DateTable () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation DateTable

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
         _tableViewHeight = frame.size.height;
        [self setSeparatorColor:[UIColor clearColor]];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
         self.tableFooterView = [UIView new];

    }
    return self;
}


- (void)setDate:(NSDate *)date
{
    self.dateTotal = 0;
    self.tableDataArray = [NSMutableArray array];
    self.startTimesAndEndTimes = [NSMutableArray array];
    NSString *dash = @" - ";
    
    _date = date;
    
    if (date)
    {
        NSDateComponents *dateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit fromDate:date];
        [self.tableDataArray addObject:[NSString stringWithFormat:@"%ld", (long)dateComponents.day]];
    }
    else
    {
        [self.tableDataArray addObject:@""];
    }
    
    
    if (self.dateTotal != 0)
    {
        NSString *numOfDates = [NSString stringWithFormat:@"Todos: %ld", (long)self.dateTotal];
        [self.tableDataArray addObject:numOfDates];
    }
    
    NSString *dateString = [self.formatter stringFromDate:date];
    
    NSUInteger datesTotal = [self.arrayOfDates count];
    NSUInteger i;
    for (i = 0; i < datesTotal; i++)
    {
        if ([[self.arrayOfDates objectAtIndex:i] isEqualToString:dateString])
        {
            
            [self.startTimesAndEndTimes addObject:[[self.arrayOfStartTimes objectAtIndex:i] stringByAppendingString:[dash stringByAppendingString:[self.arrayOfEndTimes objectAtIndex:i]]]];
            
            [self.tableDataArray addObject:[self.arrayOfHeaders objectAtIndex:i]];
            
                self.dateTotal++;
        }
    }
        
}

//this is so the object only gets initialized once
- (NSDateFormatter *)formatter
{
    if (! _formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        _formatter.dateFormat = @"MM/dd/yyyy";
    }
    return _formatter;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [self.tableDataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    [cell.textLabel setMinimumScaleFactor:0.05];
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:(_tableViewHeight/9.8f)];
    cell.textLabel.font = font;
    
    if (self.tableDataArray.count > indexPath.row)
    {
        NSString *cellData = [self.tableDataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = cellData;
    }
    else
    {
        cell.textLabel.text = @"";
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.textColor = [UIColor whiteColor];
        return cell;
    }
    else
    {
        cell.textLabel.textColor = REDCOLORPlUS2;
        return cell;

    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        cell.backgroundColor = REDCOLORMINUS2;
    }
    else
    {
        cell.backgroundColor = WHITECOLORPLUSONE;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (_tableViewHeight/6);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath %ld", (long)indexPath.row);
    if (indexPath.row > 0 && [self.dateTableDelegate respondsToSelector:@selector(dateTable:didTapTaskWithHours:)])
    {
        [self.dateTableDelegate dateTable:self didTapTaskWithHours:[self.startTimesAndEndTimes objectAtIndex:indexPath.row-1]];
    }
}


@end