#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "MELiPadCalendarView.h"
#import "DateTable.h"

@interface MELiPadCalendarView ()<DateTableDelegate>

@property (nonatomic, strong) UIView *highlight;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *prevButton;
@property (nonatomic, strong) UIButton *nextButton;
@property (nonatomic, strong) UIView *calendarContainer;
@property (nonatomic, strong) UIView *daysHeader;
@property (nonatomic, strong) NSArray *dayOfWeekLabels;
@property (nonatomic, strong) NSMutableArray *dateButtonArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDate *monthShowing;
@property CGFloat cellWidth;
@property CGFloat buttonMargin;
@property CGFloat calendarMargin;
@property CGFloat topHeight;
@property CGFloat daysHeaderHeight;
@property CGFloat cellBorderWidth;
@property CGFloat dateTableViewWidth;
@property CGFloat dateTableViewHeight;

@end

@implementation MELiPadCalendarView

@dynamic locale;


- (id)initWithStartDay:(startDay)firstDay frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _dateTableViewWidth = frame.size.width * .141;
        _dateTableViewHeight = frame.size.height * .171;
        _cellWidth = frame.size.width * .0558;
        _buttonMargin = frame.size.width * .0052;
        _calendarMargin = frame.size.width * .0039;
        _cellBorderWidth = frame.size.width * .0013;
        _topHeight = frame.size.height * .0688;
        _daysHeaderHeight = frame.size.height * .0344;
//        NSLog(@"width: %f", _dateTableViewWidth);
//        NSLog(@"height: %f", _dateTableViewHeight);
        [self internalInit:firstDay];
    }
    return self;
}

- (void)internalInit:(startDay)firstDay
{
    _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [_calendar setLocale:[NSLocale currentLocale]];
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    _dateFormatter.dateFormat = @"LLLL yyyy";
    
    self.dateComponents = [[NSDateComponents alloc] init];
    self.orientationDate = [NSDate date];
    
    _calendarStartDay = firstDay;
    
    self.layer.cornerRadius = 6.0f;
    
    UIView *highlight = [[UIView alloc] initWithFrame:CGRectZero];
    highlight.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    highlight.layer.cornerRadius = 6.0f;
    [self addSubview:highlight];
    _highlight = highlight;
    
    // SET UP THE HEADER
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    prevButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [prevButton addTarget:self action:@selector(moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];
    _prevButton = prevButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [nextButton addTarget:self action:@selector(moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    _nextButton = nextButton;
    
    // THE CALENDAR ITSELF
    UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    calendarContainer.layer.borderWidth = 1.0f;
    calendarContainer.layer.borderColor = [UIColor orangeColor].CGColor;
    calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.layer.cornerRadius = 4.0f;
    calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    _calendarContainer = calendarContainer;
    
    //GradientView *daysHeader = [[GradientView alloc] initWithFrame:CGRectZero];
    UIView *daysHeader = [[UIView alloc]initWithFrame:CGRectZero];
    daysHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [_calendarContainer addSubview:daysHeader];
    _daysHeader = daysHeader;
    
    NSMutableArray *labels = [NSMutableArray array];
    
    for (NSInteger i = 0; i < 7; ++i)
    {
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
        dayOfWeekLabel.backgroundColor = [UIColor clearColor];
        dayOfWeekLabel.shadowColor = [UIColor whiteColor];
        dayOfWeekLabel.shadowOffset = CGSizeMake(0, 1);
        [labels addObject:dayOfWeekLabel];
        [_calendarContainer addSubview:dayOfWeekLabel];
    }
    
    _dayOfWeekLabels = labels;
    [self updateDayOfWeekLabels];
    
    _monthShowing = [NSDate date];
    
    [self setDefaultStyle];
    
    
    [self layoutSubviews];
}

- (void)setUpTheTodoDates:(NSArray *)todoDates withStartTimes:(NSArray *)startTimes andEndTimes:(NSArray *)endTimes andHeaders:(NSArray *)headers
{
    if (!_dateButtonArray)
    {
        _dateButtonArray = [NSMutableArray array];
    }
    
    /* five rows of seven days equals 42 */
    for (NSUInteger i = 1; i <= 42; i++)
    {
        
        DateTable *dateTable = [[DateTable alloc]initWithFrame:CGRectMake(0, 0, _dateTableViewWidth, _dateTableViewHeight)];
        [dateTable setDelegate:dateTable.self];
        [dateTable setDataSource:dateTable.self];
        dateTable.dateTableDelegate = self;
        dateTable.arrayOfDates = todoDates;
        dateTable.arrayOfStartTimes = startTimes;
        dateTable.arrayOfEndTimes = endTimes;
        dateTable.arrayOfHeaders = headers;
        dateTable.calendar = _calendar;
        [_dateButtonArray addObject:dateTable];
    }
    
    [self layoutSubviews];
}

#pragma mark - utilities

- (NSDateFormatter *)getTheDateFormatter
{
    if (! _dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        _dateFormatter.dateFormat = @"LLLL yyyy";
    }
    return _dateFormatter;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;

    
    CGFloat containerWidth = width - (_calendarMargin * 2);
    _cellWidth = (containerWidth / 7.0) - _cellBorderWidth;
    
    NSInteger numberOfWeeksToShow = 6;
    
//    if (_adaptHeightToNumberOfWeeksInMonth)
//    {
//        numberOfWeeksToShow = [self numberOfWeeksInMonthContainingDate:_monthShowing];
//    }
    
    CGFloat containerHeight = (numberOfWeeksToShow * (_cellWidth + _cellBorderWidth) + _daysHeaderHeight);
    
    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + _calendarMargin + _topHeight;
    self.frame = newFrame;
    
    _highlight.frame = CGRectMake(1, 1, width - 2, 1);
    
    //_titleLabel.text = [_dateFormatter stringFromDate:[NSDate date]];
    //NSLog(@"_titleLabel: %@", _titleLabel.text);
    _titleLabel.frame = CGRectMake(0, 0, width, _topHeight);
    _prevButton.frame = CGRectMake(_buttonMargin, _buttonMargin, self.frame.size.width*.0623, self.frame.size.height*.0594);
    _nextButton.frame = CGRectMake(width - self.frame.size.width*.0623 - _buttonMargin, _buttonMargin, self.frame.size.width*.0623, self.frame.size.height*.0594);
    
    _calendarContainer.frame = CGRectMake(_calendarMargin, CGRectGetMaxY(_titleLabel.frame), containerWidth, containerHeight);
    _daysHeader.frame = CGRectMake(0, 0, _calendarContainer.frame.size.width, _daysHeaderHeight);
    
    CGRect lastDayFrame = CGRectZero;
    for (UILabel *dayLabel in _dayOfWeekLabels)
    {
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame) + _cellBorderWidth, lastDayFrame.origin.y, _cellWidth, _daysHeader.frame.size.height);
        lastDayFrame = dayLabel.frame;
    }
    
    for (DateTable *dateTable in _dateButtonArray)
    {
        [dateTable removeFromSuperview];
    }
    
    NSDate *date = [self firstDayOfMonthContainingDate:_monthShowing];
    
//    if (_shouldFillCalendar)
//    {
//        while ([self placeInWeekForDate:date] != 0)
//        {
//            date = [self previousDay:date];
//        }
//    }
    
    NSDate *endDate = [self firstDayOfNextMonthContainingDate:_monthShowing];
    
//    if (_shouldFillCalendar)
//    {
//        NSDateComponents *comps = [[NSDateComponents alloc] init];
//        [comps setWeek:numberOfWeeksToShow];
//        endDate = [_calendar dateByAddingComponents:comps toDate:date options:0];
//    }
    
    NSUInteger dateButtonPosition = 0;
    
    while ([date laterDate:endDate] != date)
    {
        DateTable *dateTable = [_dateButtonArray objectAtIndex:dateButtonPosition];
        
        dateTable.date = date;
        
        if ([self date:dateTable.date isSameDayAsDate:_selectedDate])
        {
            dateTable.backgroundColor = _selectedDateBackgroundColor;
        }
        else if ([self dateIsToday:dateTable.date])
        {
            [dateTable setBackgroundColor:_currentDateTextColor];
            dateTable.backgroundColor = _currentDateBackgroundColor;
        }
        else if ([date compare:_minimumDate] == NSOrderedAscending ||
                   [date compare:_maximumDate] == NSOrderedDescending)
        {
            [dateTable setBackgroundColor:_disabledDateTextColor];
            dateTable.backgroundColor = _disabledDateBackgroundColor;
        }
//        else if (_shouldFillCalendar && [self compareByMonth:date toDate:_monthShowing] != NSOrderedSame)
//        {
//            [dateTable setBackgroundColor:_nonCurrentMonthDateTextColor];
//            dateTable.backgroundColor = [self dateBackgroundColor];
//        }
        else
        {
            [dateTable setBackgroundColor:_dateTextColor];
            dateTable.backgroundColor = [self dateBackgroundColor];
        }
        
        dateTable.frame = [self calculateDayCellFrame:date];
        
        [_calendarContainer addSubview:dateTable];
        
        date = [self nextDay:date];
        dateButtonPosition++;
    }
}
- (void)updateDayOfWeekLabels
{
    NSArray *weekdays = [_dateFormatter shortWeekdaySymbols];
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [_calendar firstWeekday] - 1;
    
    if (firstWeekdayIndex > 0)
    {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }
    
    NSUInteger i = 0;
    
    for (NSString *day in weekdays)
    {
        [[_dayOfWeekLabels objectAtIndex:i] setText:[day uppercaseString]];
        i++;
    }
}

- (NSLocale *)locale
{
    return _dateFormatter.locale;
}


- (void)setSelectedDate:(NSDate *)selectedDate
{
    _selectedDate = selectedDate;
    
    if (! _dateFormatter)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        _dateFormatter.dateFormat = @"LLLL yyyy";
    }
    
    _titleLabel.text = [_dateFormatter stringFromDate:[self firstDayOfMonthContainingDate:_selectedDate]];
    [self setNeedsLayout];
    _monthShowing = selectedDate;
}

//- (void)setShouldFillCalendar:(BOOL)shouldFillCalendar
//{
//    _shouldFillCalendar = shouldFillCalendar;
//    [self setNeedsLayout];
//}
//
//- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth
//{
//
//    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
//    [self setNeedsLayout];
//}

- (void)setDefaultStyle
{
    
    self.backgroundColor = BlueColorMinus3;
    
    [self setTitleColor:f5f5f5];
    [self setTitleFont:[UIFont boldSystemFontOfSize:17.0]];
    
    [self setDayOfWeekFont:[UIFont boldSystemFontOfSize:12.0]];
    [self setDayOfWeekTextColor:[UIColor redColor]];
    [self setDayOfWeekBottomColor:[UIColor greenColor] topColor:[UIColor whiteColor]];
    
    [self setDateFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self setDateTextColor:[UIColor blueColor]];
    [self setDateBackgroundColor:[UIColor purpleColor]];
    [self setDateBorderColor:[UIColor yellowColor]];
    
    
    [self setSelectedDateTextColor:[UIColor redColor]];
    [self setSelectedDateBackgroundColor:[UIColor greenColor]];
    
    [self setCurrentDateTextColor:[UIColor blueColor]];
    [self setCurrentDateBackgroundColor:[UIColor lightGrayColor]];
    
    _nonCurrentMonthDateTextColor = [UIColor lightGrayColor];
    
    _disabledDateTextColor = [UIColor lightGrayColor];
    _disabledDateBackgroundColor = self.dateBackgroundColor;
}

- (CGRect)calculateDayCellFrame:(NSDate *)date
{
    NSInteger numberOfDaysSinceBeginningOfThisMonth = [self numberOfDaysFromDate:_monthShowing toDate:date];
    NSInteger row = (numberOfDaysSinceBeginningOfThisMonth + [self placeInWeekForDate:_monthShowing]) / 7;
    
    NSInteger placeInWeek = [self placeInWeekForDate:date];
    
    return CGRectMake(placeInWeek * (_cellWidth + _cellBorderWidth), (row * (_cellWidth + _cellBorderWidth)) + CGRectGetMaxY(_daysHeader.frame) + _cellBorderWidth, _cellWidth, _cellWidth);
}

- (void)moveCalendarToNextMonth
{
    [_delegate transitionToNextMonth];
}

- (void)moveCalendarToPreviousMonth
{
    [_delegate transitionToPreviousMonth];
}

#pragma mark - getters and setters


- (void)setTitleFont:(UIFont *)font
{
    _titleLabel.font = font;
}
- (UIFont *)titleFont
{
    return _titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color
{

    _titleLabel.textColor = color;
}

- (void)setDayOfWeekFont:(UIFont *)font
{
    for (UILabel *label in _dayOfWeekLabels) {
        label.font = font;
    }
}


- (void)setDayOfWeekTextColor:(UIColor *)color
{
    for (UILabel *label in _dayOfWeekLabels)
    {
        label.textColor = color;
    }
}


- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor
{
    //[_daysHeader setColors:[NSArray arrayWithObjects:topColor, bottomColor, nil]];
    [_daysHeader setBackgroundColor:BlueColorMinus1];
}

- (void)setDateFont:(UIFont *)font
{
//    for (DateTable *dateTable in _dateButtonArray)
//    {
//        //dateTable.titleLabel.font = font;
//    }
}

- (void)setDateTextColor:(UIColor *)color
{
    _dateTextColor = color;
    [self setNeedsLayout];
}

- (void)setDisabledDateTextColor:(UIColor *)color
{
    _disabledDateTextColor = color;
    [self setNeedsLayout];
}

- (void)setDateBackgroundColor:(UIColor *)color
{
    for (DateTable *dateTable in _dateButtonArray)
    {
        dateTable.backgroundColor = color;
    }
}
- (UIColor *)dateBackgroundColor
{
    return (_dateButtonArray.count > 0) ? ((DateTable *)[_dateButtonArray lastObject]).backgroundColor : nil;
}

- (void)setDateBorderColor:(UIColor *)color
{
    _calendarContainer.backgroundColor = color;
}
- (UIColor *)dateBorderColor
{
    return _calendarContainer.backgroundColor;
}

#pragma mark - Calendar helpers

- (NSDate *)firstDayOfMonthContainingDate:(NSDate *)date
{
    NSDateComponents *comps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [_calendar dateFromComponents:comps];
}

- (NSDate *)firstDayOfNextMonthContainingDate:(NSDate *)date
{
    NSDateComponents *comps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [_calendar dateFromComponents:comps];
}

- (NSComparisonResult)compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate
{
    NSDateComponents *day = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [_calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];
    
    if (day.year < day2.year)
    {
        return NSOrderedAscending;
    }
    else if (day.year > day2.year)
    {
        return NSOrderedDescending;
    }
    else if (day.month < day2.month)
    {
        return NSOrderedAscending;
    }
    else if (day.month > day2.month)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedSame;
    }
}

- (NSInteger)placeInWeekForDate:(NSDate *)date
{
    NSDateComponents *compsFirstDayInMonth = [_calendar components:NSWeekdayCalendarUnit fromDate:date];
    return (compsFirstDayInMonth.weekday - 1 - _calendar.firstWeekday + 8) % 7;
}

- (BOOL)dateIsToday:(NSDate *)date
{
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2
{
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil)
    {
        return NO;
    }
    
    NSDateComponents *day = [_calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [_calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)weekNumberInMonthForDate:(NSDate *)date
{
    // Return zero-based week in month
    NSInteger placeInWeek = [self placeInWeekForDate:_monthShowing];
    NSDateComponents *comps = [_calendar components:(NSDayCalendarUnit) fromDate:date];
    return (comps.day + placeInWeek - 1) / 7;
}

- (NSInteger)numberOfWeeksInMonthContainingDate:(NSDate *)date
{
    return [_calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)nextDay:(NSDate *)date
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [_calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)previousDay:(NSDate *)date
{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [_calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSInteger startDay = [_calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [_calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

#pragma mark - DateTableDelegate

- (void)dateTable:(DateTable *)dateTable didTapRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"you've reached dateTable tapped");
}

@end