//
//  DateTable.m
//  iPadCalendar
//
//  Created by Mike Leveton on 1/26/13.
//  Copyright (c) 2013 Mike Leveton. All rights reserved.
//

#import "DateTable.h"


@interface DateTable ()

@end

@implementation DateTable

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
         _tableViewHeight = frame.size.height;
//        CGFloat xOffset = frame.origin.x;
//        CGFloat yOffset = frame.origin.y;
//        CGFloat width =  frame.size.width;
//        CGFloat height = frame.size.height;
//        NSLog(@"x: %f y: %f width: %f height %f", xOffset, yOffset, width, height);

    }
    return self;
}

- (void)setDate:(NSDate *)date
{
    self.dateTotal = 0;
    self.dataForTable = [NSMutableArray array];
    self.startTimesAndEndTimes = [NSMutableArray array];
    NSString *dash = @" - ";
    _date = date;
    NSDateComponents *comps = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        
    [self.dataForTable addObject:[NSString stringWithFormat:@"%d", comps.day]];

    NSString *dateString = [self.formatter stringFromDate:date];
    
    NSUInteger datesTotal = [self.arrayOfDates count];
    NSUInteger i;
    for (i = 0; i < datesTotal; i++)
    {
        if ([[self.arrayOfDates objectAtIndex:i] isEqualToString:dateString])
        {
            //call method to concatinate times here
            [self.startTimesAndEndTimes addObject:[[self.arrayOfStartTimes objectAtIndex:i] stringByAppendingString:[dash stringByAppendingString:[self.arrayOfEndTimes objectAtIndex:i]]]];
            
                self.dateTotal++;
        }
    }

    
    if (self.dateTotal != 0)
    {
        NSString *numOfDates = [NSString stringWithFormat:@"Todos: %d", self.dateTotal];
        [self.dataForTable addObject:numOfDates];
    }
    [self.dataForTable addObjectsFromArray:self.startTimesAndEndTimes];
        
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
    return [self.dataForTable count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"Cell";
    UITableViewCell *cell1 = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
    if (cell1 == nil) {
        cell1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
    }
    
    NSString *cellData = [self.dataForTable objectAtIndex:indexPath.row];
    cell1.textLabel.text = cellData;
    
    if (indexPath.row == 0)
    {
        cell1.textLabel.textColor = BlueColorMinus3;
        UIFont *myFont = [ UIFont fontWithName: @"Georgia-Bold" size: (_tableViewHeight/9.8f)];
        cell1.textLabel.font = myFont;
        return cell1;
    }
    else
    {
        cell1.textLabel.textColor = [UIColor redColor];
        UIFont *myFont = [ UIFont fontWithName: @"Arial" size: (_tableViewHeight/9.8f)];
        cell1.textLabel.font = myFont;
        return cell1;

    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        cell.backgroundColor = lightBlueDateColor;
    }
    else
    {
        cell.backgroundColor = f5f5f5;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (_tableViewHeight/6);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Date %ld", (long)indexPath.row);
}

-(void)calendar:(MELiPadCalendarView *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"Date %@", date);
}

@end