//
//  DateTable.h
//  iPadCalendar
//
//  Created by Mike Leveton on 1/26/13.
//  Copyright (c) 2013 Mike Leveton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MELiPadCalendarView.h"


@interface DateTable : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, retain) NSMutableArray *dataForTable;
@property (nonatomic, retain) NSMutableArray *arrayOfDates;
@property (nonatomic, retain) NSMutableArray *arrayOfStartTimes;
@property (nonatomic, retain) NSMutableArray *arrayOfEndTimes; 
@property (nonatomic, retain) NSMutableArray *startTimesAndEndTimes;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, retain) NSString *jobForDate;
@property (nonatomic, readwrite) int dateTotal;
@property (nonatomic, readwrite) int tableViewHeight;

@end
