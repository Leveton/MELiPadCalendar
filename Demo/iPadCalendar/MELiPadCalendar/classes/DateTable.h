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
@property (nonatomic, strong) NSMutableArray *dataForTable;
@property (nonatomic, strong) NSArray *arrayOfDates;
@property (nonatomic, strong) NSArray *arrayOfStartTimes;
@property (nonatomic, strong) NSArray *arrayOfEndTimes;
@property (nonatomic, strong) NSMutableArray *startTimesAndEndTimes;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, strong) NSString *jobForDate;
@property NSInteger dateTotal;
@property NSInteger tableViewHeight;


@end
