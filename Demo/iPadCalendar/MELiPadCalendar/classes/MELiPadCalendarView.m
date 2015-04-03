#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "MELiPadCalendarView.h"

#define BUTTON_MARGIN 4
#define CALENDAR_MARGIN 3
#define TOP_HEIGHT 44
#define DAYS_HEADER_HEIGHT 22
#define DEFAULT_CELL_WIDTH 43
#define CELL_BORDER_WIDTH 1

@interface MELiPadCalendarView ()

@property(nonatomic, strong) UIView *highlight;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIButton *prevButton;
@property(nonatomic, strong) UIButton *nextButton;
@property(nonatomic, strong) UIView *calendarContainer;
@property(nonatomic, strong) UIView *daysHeader;
@property(nonatomic, strong) NSArray *dayOfWeekLabels;
@property(nonatomic, strong) NSMutableArray *dateButtons;
@property(nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, strong) NSDate *monthShowing;
@property(nonatomic, assign) CGFloat cellWidth;

@end

@implementation MELiPadCalendarView

@synthesize highlight = _highlight;
@synthesize titleLabel = _titleLabel;
@synthesize prevButton = _prevButton;
@synthesize nextButton = _nextButton;
@synthesize calendarContainer = _calendarContainer;
@synthesize daysHeader = _daysHeader;
@synthesize dayOfWeekLabels = _dayOfWeekLabels;
@synthesize dateButtons = _dateButtons;
@synthesize monthShowing = _monthShowing;
@synthesize calendar = _calendar;
@synthesize datesAndHours;
@synthesize selectedDate = _selectedDate;
@synthesize delegate = _delegate;
@synthesize datesForTable, startTimesForTable, endTimesForTable;
@synthesize dateTextColor = _dateTextColor;
@synthesize selectedDateTextColor = _selectedDateTextColor;
@synthesize selectedDateBackgroundColor = _selectedDateBackgroundColor;
@synthesize currentDateTextColor = _currentDateTextColor;
@synthesize currentDateBackgroundColor = _currentDateBackgroundColor;
@synthesize nonCurrentMonthDateTextColor = _nonCurrentMonthDateTextColor;
@synthesize disabledDateTextColor = _disabledDateTextColor;
@synthesize disabledDateBackgroundColor = _disabledDateBackgroundColor;
@synthesize cellWidth = _cellWidth;
@synthesize calendarStartDay = _calendarStartDay;
@dynamic locale;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize shouldFillCalendar = _shouldFillCalendar;
@synthesize adaptHeightToNumberOfWeeksInMonth = _adaptHeightToNumberOfWeeksInMonth;


- (id)init
{
    return [self initWithStartDay:startSunday];
}

- (id)initWithStartDay:(startDay)firstDay dates:(NSArray *)dates startTimes:(NSArray *)startTimes endTimes:(NSArray *)endTimes frame:(CGRect)frame
{
    datesForTable = [[NSMutableArray alloc]initWithArray:dates];
    startTimesForTable = [[NSMutableArray alloc]initWithArray:startTimes];
    endTimesForTable = [[NSMutableArray alloc]initWithArray:endTimes];
    return [self initWithStartDay:firstDay frame:frame];
}

- (void)internalInit:(startDay)firstDay {
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [self.calendar setLocale:[NSLocale currentLocale]];
    
    self.cellWidth = DEFAULT_CELL_WIDTH;
    
    //    self.dateFormatter = [[NSDateFormatter alloc] init];
    //    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    //    self.dateFormatter.dateFormat = @"LLLL yyyy";
    
    self.calendarStartDay = firstDay;
    self.shouldFillCalendar = YES;
    self.adaptHeightToNumberOfWeeksInMonth = YES;
    
    self.layer.cornerRadius = 6.0f;
    
    UIView *highlight = [[UIView alloc] initWithFrame:CGRectZero];
    highlight.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    highlight.layer.cornerRadius = 6.0f;
    [self addSubview:highlight];
    self.highlight = highlight;
    
    // SET UP THE HEADER
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    UIButton *prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [prevButton setImage:[UIImage imageNamed:@"left_arrow"] forState:UIControlStateNormal];
    prevButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [prevButton addTarget:self action:@selector(moveCalendarToPreviousMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:prevButton];
    self.prevButton = prevButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextButton setImage:[UIImage imageNamed:@"right_arrow"] forState:UIControlStateNormal];
    nextButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
    [nextButton addTarget:self action:@selector(moveCalendarToNextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextButton];
    self.nextButton = nextButton;
    
    // THE CALENDAR ITSELF
    UIView *calendarContainer = [[UIView alloc] initWithFrame:CGRectZero];
    calendarContainer.layer.borderWidth = 1.0f;
    calendarContainer.layer.borderColor = [UIColor blackColor].CGColor;
    calendarContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    calendarContainer.layer.cornerRadius = 4.0f;
    calendarContainer.clipsToBounds = YES;
    [self addSubview:calendarContainer];
    self.calendarContainer = calendarContainer;
    
    //GradientView *daysHeader = [[GradientView alloc] initWithFrame:CGRectZero];
    UIView *daysHeader = [[UIView alloc]initWithFrame:CGRectZero];
    daysHeader.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    [self.calendarContainer addSubview:daysHeader];
    self.daysHeader = daysHeader;
    
    NSMutableArray *labels = [NSMutableArray array];
    for (int i = 0; i < 7; ++i) {
        UILabel *dayOfWeekLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayOfWeekLabel.textAlignment = NSTextAlignmentCenter;
        dayOfWeekLabel.backgroundColor = [UIColor clearColor];
        dayOfWeekLabel.shadowColor = [UIColor whiteColor];
        dayOfWeekLabel.shadowOffset = CGSizeMake(0, 1);
        [labels addObject:dayOfWeekLabel];
        [self.calendarContainer addSubview:dayOfWeekLabel];
    }
    
    self.dayOfWeekLabels = labels;
    [self updateDayOfWeekLabels];
    
    // the heart of the calendar
    NSMutableArray *dateButtons = [NSMutableArray array];
    for (NSUInteger i = 1; i <= 42; i++) {
        //perhaps use autoreleasepool here??
        //        @autoreleasepool
        //        {
        //        }
        DateTable *dateTable = [[DateTable alloc] init];
        [dateTable setDelegate:dateTable.self];
        [dateTable setDataSource:dateTable.self];
        dateTable.arrayOfDates = datesForTable;
        dateTable.arrayOfStartTimes = startTimesForTable;
        dateTable.arrayOfEndTimes = endTimesForTable;
        dateTable.calendar = self.calendar;
        [dateButtons addObject:dateTable];
    }
    self.dateButtons = dateButtons;
    
    // initialize!
    self.monthShowing = [NSDate date];
    [self setDefaultStyle];
    
    [self layoutSubviews];
}

- (NSDateFormatter *)dateFormatter
{
    if (! _dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        _dateFormatter.dateFormat = @"LLLL yyyy";
    }
    return _dateFormatter;
}

- (id)initWithStartDay:(startDay)firstDay frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit:firstDay];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    return [self initWithStartDay:startSunday frame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self internalInit:startSunday];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat containerWidth = self.bounds.size.width - (CALENDAR_MARGIN * 2);
    //CGFloat containerWidth = 420 - (CALENDAR_MARGIN * 2);
    self.cellWidth = (containerWidth / 7.0) - CELL_BORDER_WIDTH;
    
    NSInteger numberOfWeeksToShow = 6;
    if (self.adaptHeightToNumberOfWeeksInMonth) {
        numberOfWeeksToShow = [self numberOfWeeksInMonthContainingDate:self.monthShowing];
    }
    CGFloat containerHeight = (numberOfWeeksToShow * (self.cellWidth + CELL_BORDER_WIDTH) + DAYS_HEADER_HEIGHT);
    
    CGRect newFrame = self.frame;
    newFrame.size.height = containerHeight + CALENDAR_MARGIN + TOP_HEIGHT;
    self.frame = newFrame;
    
    self.highlight.frame = CGRectMake(1, 1, self.bounds.size.width - 2, 1);
    
    self.titleLabel.text = [self.dateFormatter stringFromDate:_monthShowing];
    self.titleLabel.frame = CGRectMake(0, 0, self.bounds.size.width, TOP_HEIGHT);
    self.prevButton.frame = CGRectMake(BUTTON_MARGIN, BUTTON_MARGIN, 48, 38);
    self.nextButton.frame = CGRectMake(self.bounds.size.width - 48 - BUTTON_MARGIN, BUTTON_MARGIN, 48, 38);
    
    self.calendarContainer.frame = CGRectMake(CALENDAR_MARGIN, CGRectGetMaxY(self.titleLabel.frame), containerWidth, containerHeight);
    self.daysHeader.frame = CGRectMake(0, 0, self.calendarContainer.frame.size.width, DAYS_HEADER_HEIGHT);
    
    CGRect lastDayFrame = CGRectZero;
    for (UILabel *dayLabel in self.dayOfWeekLabels) {
        dayLabel.frame = CGRectMake(CGRectGetMaxX(lastDayFrame) + CELL_BORDER_WIDTH, lastDayFrame.origin.y, self.cellWidth, self.daysHeader.frame.size.height);
        lastDayFrame = dayLabel.frame;
    }
    
    for (DateTable *dateTable in self.dateButtons) {
        [dateTable removeFromSuperview];
    }
    
    NSDate *date = [self firstDayOfMonthContainingDate:self.monthShowing];
    if (self.shouldFillCalendar) {
        while ([self placeInWeekForDate:date] != 0) {
            date = [self previousDay:date];
        }
    }
    
    NSDate *endDate = [self firstDayOfNextMonthContainingDate:self.monthShowing];
    if (self.shouldFillCalendar) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setWeek:numberOfWeeksToShow];
        endDate = [self.calendar dateByAddingComponents:comps toDate:date options:0];
    }
    
    NSUInteger dateButtonPosition = 0;
    while ([date laterDate:endDate] != date) {
        DateTable *dateTable = [self.dateButtons objectAtIndex:dateButtonPosition];
        
        dateTable.date = date;
        if ([self date:dateTable.date isSameDayAsDate:self.selectedDate]) {
            dateTable.backgroundColor = self.selectedDateBackgroundColor;
            //[dateTable setTitleColor:self.selectedDateTextColor forState:UIControlStateNormal];
        } else if ([self dateIsToday:dateTable.date]) {
            [dateTable setBackgroundColor:self.currentDateTextColor];
            dateTable.backgroundColor = self.currentDateBackgroundColor;
        } else if ([date compare:self.minimumDate] == NSOrderedAscending ||
                   [date compare:self.maximumDate] == NSOrderedDescending) {
            [dateTable setBackgroundColor:self.disabledDateTextColor];
            dateTable.backgroundColor = self.disabledDateBackgroundColor;
        } else if (self.shouldFillCalendar && [self compareByMonth:date toDate:self.monthShowing] != NSOrderedSame) {
            [dateTable setBackgroundColor:self.nonCurrentMonthDateTextColor];
            dateTable.backgroundColor = [self dateBackgroundColor];
        } else {
            [dateTable setBackgroundColor:self.dateTextColor];
            dateTable.backgroundColor = [self dateBackgroundColor];
        }
        
        dateTable.frame = [self calculateDayCellFrame:date];
        
        [self.calendarContainer addSubview:dateTable];
        
        date = [self nextDay:date];
        dateButtonPosition++;
    }
}
- (void)updateDayOfWeekLabels {
    NSArray *weekdays = [self.dateFormatter shortWeekdaySymbols];
    // adjust array depending on which weekday should be first
    NSUInteger firstWeekdayIndex = [self.calendar firstWeekday] - 1;
    if (firstWeekdayIndex > 0) {
        weekdays = [[weekdays subarrayWithRange:NSMakeRange(firstWeekdayIndex, 7 - firstWeekdayIndex)]
                    arrayByAddingObjectsFromArray:[weekdays subarrayWithRange:NSMakeRange(0, firstWeekdayIndex)]];
    }
    
    NSUInteger i = 0;
    for (NSString *day in weekdays) {
        [[self.dayOfWeekLabels objectAtIndex:i] setText:[day uppercaseString]];
        i++;
    }
}

- (void)setCalendarStartDay:(startDay)calendarStartDay {
    _calendarStartDay = calendarStartDay;
    [self.calendar setFirstWeekday:self.calendarStartDay];
    [self updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (void)setLocale:(NSLocale *)locale {
    [self.dateFormatter setLocale:locale];
    [self updateDayOfWeekLabels];
    [self setNeedsLayout];
}

- (NSLocale *)locale {
    return self.dateFormatter.locale;
}

- (void)setMonthShowing:(NSDate *)aMonthShowing {
    _monthShowing = [self firstDayOfMonthContainingDate:aMonthShowing];
    
    [self setNeedsLayout];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
    _selectedDate = selectedDate;
    [self setNeedsLayout];
    self.monthShowing = selectedDate;
}

- (void)setShouldFillCalendar:(BOOL)shouldFillCalendar {
    _shouldFillCalendar = shouldFillCalendar;
    [self setNeedsLayout];
}

- (void)setAdaptHeightToNumberOfWeeksInMonth:(BOOL)adaptHeightToNumberOfWeeksInMonth {
    _adaptHeightToNumberOfWeeksInMonth = adaptHeightToNumberOfWeeksInMonth;
    [self setNeedsLayout];
}

- (void)setDefaultStyle {
    //self.backgroundColor = UIColorFromRGB(0x393B40);
    self.backgroundColor = BlueColorMinus3;
    
    [self setTitleColor:f5f5f5];
    [self setTitleFont:[UIFont boldSystemFontOfSize:17.0]];
    
    [self setDayOfWeekFont:[UIFont boldSystemFontOfSize:12.0]];
    [self setDayOfWeekTextColor:UIColorFromRGB(0x999999)];
    [self setDayOfWeekBottomColor:UIColorFromRGB(0xCCCFD5) topColor:[UIColor whiteColor]];
    
    [self setDateFont:[UIFont boldSystemFontOfSize:16.0f]];
    [self setDateTextColor:UIColorFromRGB(0x393B40)];
    [self setDateBackgroundColor:UIColorFromRGB(0xF2F2F2)];
    [self setDateBorderColor:UIColorFromRGB(0xDAE1E6)];
    
    
    [self setSelectedDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setSelectedDateBackgroundColor:UIColorFromRGB(0x88B6DB)];
    
    [self setCurrentDateTextColor:UIColorFromRGB(0xF2F2F2)];
    [self setCurrentDateBackgroundColor:[UIColor lightGrayColor]];
    
    self.nonCurrentMonthDateTextColor = [UIColor lightGrayColor];
    
    self.disabledDateTextColor = [UIColor lightGrayColor];
    self.disabledDateBackgroundColor = self.dateBackgroundColor;
}

- (CGRect)calculateDayCellFrame:(NSDate *)date
{
    NSInteger numberOfDaysSinceBeginningOfThisMonth = [self numberOfDaysFromDate:self.monthShowing toDate:date];
    NSInteger row = (numberOfDaysSinceBeginningOfThisMonth + [self placeInWeekForDate:self.monthShowing]) / 7;
    
    NSInteger placeInWeek = [self placeInWeekForDate:date];
    
    return CGRectMake(placeInWeek * (self.cellWidth + CELL_BORDER_WIDTH), (row * (self.cellWidth + CELL_BORDER_WIDTH)) + CGRectGetMaxY(self.daysHeader.frame) + CELL_BORDER_WIDTH, self.cellWidth, self.cellWidth);
}

- (void)moveCalendarToNextMonth{
    [self.delegate transitionToNextMonth];
}

- (void)moveCalendarToPreviousMonth {
    [self.delegate transitionToPreviousMonth];
}

//- (void)dateButtonPressed:(id)sender {
//    _dateButtons *dateButton = sender;
//    NSDate *date = dateButton.date;
//    if (self.minimumDate && [date compare:self.minimumDate] == NSOrderedAscending) {
//        return;
//    } else if (self.maximumDate && [date compare:self.maximumDate] == NSOrderedDescending) {
//        return;
//    } else {
//        self.selectedDate = date;
//        [self.delegate calendar:self didSelectDate:self.selectedDate];
//    }
//}

#pragma mark - Theming getters/setters

- (void)setTitleFont:(UIFont *)font {
    self.titleLabel.font = font;
}
- (UIFont *)titleFont {
    return self.titleLabel.font;
}

- (void)setTitleColor:(UIColor *)color {
    self.titleLabel.textColor = color;
}
- (UIColor *)titleColor {
    return self.titleLabel.textColor;
}

- (void)setButtonColor:(UIColor *)color
{
    [self.prevButton setImage:[MELiPadCalendarView imageNamed:@"left_arrow" withColor:color] forState:UIControlStateNormal];
    [self.nextButton setImage:[MELiPadCalendarView imageNamed:@"right_arrow" withColor:color] forState:UIControlStateNormal];
}

- (void)setInnerBorderColor:(UIColor *)color {
    self.calendarContainer.layer.borderColor = color.CGColor;
}

- (void)setDayOfWeekFont:(UIFont *)font {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.font = font;
    }
}
- (UIFont *)dayOfWeekFont {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).font : nil;
}

- (void)setDayOfWeekTextColor:(UIColor *)color {
    for (UILabel *label in self.dayOfWeekLabels) {
        label.textColor = color;
    }
}
- (UIColor *)dayOfWeekTextColor {
    return (self.dayOfWeekLabels.count > 0) ? ((UILabel *)[self.dayOfWeekLabels lastObject]).textColor : nil;
}

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor {
    //[self.daysHeader setColors:[NSArray arrayWithObjects:topColor, bottomColor, nil]];
    [self.daysHeader setBackgroundColor:BlueColorMinus1];
}

- (void)setDateFont:(UIFont *)font {
    for (DateTable *dateTable in self.dateButtons) {
        //dateTable.titleLabel.font = font;
    }
}

- (void)setDateTextColor:(UIColor *)color {
    _dateTextColor = color;
    [self setNeedsLayout];
}

- (void)setDisabledDateTextColor:(UIColor *)color {
    _disabledDateTextColor = color;
    [self setNeedsLayout];
}

- (void)setDateBackgroundColor:(UIColor *)color {
    for (DateTable *dateTable in self.dateButtons) {
        dateTable.backgroundColor = color;
    }
}
- (UIColor *)dateBackgroundColor {
    return (self.dateButtons.count > 0) ? ((DateTable *)[self.dateButtons lastObject]).backgroundColor : nil;
}

- (void)setDateBorderColor:(UIColor *)color {
    self.calendarContainer.backgroundColor = color;
}
- (UIColor *)dateBorderColor {
    return self.calendarContainer.backgroundColor;
}

#pragma mark - Calendar helpers

- (NSDate *)firstDayOfMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSDate *)firstDayOfNextMonthContainingDate:(NSDate *)date {
    NSDateComponents *comps = [self.calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:date];
    comps.day = 1;
    comps.month = comps.month + 1;
    return [self.calendar dateFromComponents:comps];
}

- (NSComparisonResult)compareByMonth:(NSDate *)date toDate:(NSDate *)otherDate {
    NSDateComponents *day = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    NSDateComponents *day2 = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:otherDate];
    
    if (day.year < day2.year) {
        return NSOrderedAscending;
    } else if (day.year > day2.year) {
        return NSOrderedDescending;
    } else if (day.month < day2.month) {
        return NSOrderedAscending;
    } else if (day.month > day2.month) {
        return NSOrderedDescending;
    } else {
        return NSOrderedSame;
    }
}

- (NSInteger)placeInWeekForDate:(NSDate *)date {
    NSDateComponents *compsFirstDayInMonth = [self.calendar components:NSWeekdayCalendarUnit fromDate:date];
    return (compsFirstDayInMonth.weekday - 1 - self.calendar.firstWeekday + 8) % 7;
}

- (BOOL)dateIsToday:(NSDate *)date {
    return [self date:[NSDate date] isSameDayAsDate:date];
}

- (BOOL)date:(NSDate *)date1 isSameDayAsDate:(NSDate *)date2 {
    // Both dates must be defined, or they're not the same
    if (date1 == nil || date2 == nil) {
        return NO;
    }
    
    NSDateComponents *day = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date1];
    NSDateComponents *day2 = [self.calendar components:NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date2];
    return ([day2 day] == [day day] &&
            [day2 month] == [day month] &&
            [day2 year] == [day year] &&
            [day2 era] == [day era]);
}

- (NSInteger)weekNumberInMonthForDate:(NSDate *)date {
    // Return zero-based week in month
    NSInteger placeInWeek = [self placeInWeekForDate:self.monthShowing];
    NSDateComponents *comps = [self.calendar components:(NSDayCalendarUnit) fromDate:date];
    return (comps.day + placeInWeek - 1) / 7;
}

- (NSInteger)numberOfWeeksInMonthContainingDate:(NSDate *)date {
    return [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:date].length;
}

- (NSDate *)nextDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSDate *)previousDay:(NSDate *)date {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:-1];
    return [self.calendar dateByAddingComponents:comps toDate:date options:0];
}

- (NSInteger)numberOfDaysFromDate:(NSDate *)startDate toDate:(NSDate *)endDate
{
    NSInteger startDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:startDate];
    NSInteger endDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSEraCalendarUnit forDate:endDate];
    return endDay - startDay;
}

+ (UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    UIImage *img = [UIImage imageNamed:name];
    
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return coloredImg;
}

@end