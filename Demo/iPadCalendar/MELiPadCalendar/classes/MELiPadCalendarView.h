#import "DateTable.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define BlueColor [UIColor colorWithRed:(58.0/255.0) green:(66.0/255) blue:(77.0/255) alpha:1.0]
#define BlueColorMinus1 [UIColor colorWithRed:(42.0/255.0) green:(54.0/255) blue:(62.0/255) alpha:1.0]
#define BlueColorMinus2 [UIColor colorWithRed:(36.0/255.0) green:(41.0/255) blue:(48.0/255) alpha:1.0]
#define BlueColorMinus3 [UIColor colorWithRed:(25.0/255.0) green:(29.0/255) blue:(33.0/255) alpha:1.0]
#define lightBlueDateColor [UIColor colorWithRed:(196.0/255.0) green:(226.0/255) blue:(255.0/255) alpha:1.0]
#define f5f5f5 [UIColor colorWithRed:(245.0/255.0) green:(245.0/255) blue:(245.0/255) alpha:1.0]

@protocol CKCalendarDelegate;

@interface MELiPadCalendarView : UIView

enum
{
    startSunday = 1,
    startMonday = 2,
};

typedef int startDay;

@property (nonatomic) startDay calendarStartDay;
@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *maximumDate;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic) BOOL shouldFillCalendar;
@property (nonatomic) BOOL adaptHeightToNumberOfWeeksInMonth;
@property (nonatomic, weak) id<CKCalendarDelegate> delegate;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, retain) NSMutableArray *datesForTable;
@property (nonatomic, retain) NSMutableArray *startTimesForTable;
@property (nonatomic, retain) NSMutableArray *endTimesForTable;
@property (nonatomic, retain) NSMutableDictionary *datesAndHours;
@property (nonatomic, strong) UIColor *dateTextColor;
@property (nonatomic, strong) UIColor *selectedDateTextColor;
@property (nonatomic, strong) UIColor *selectedDateBackgroundColor;
@property (nonatomic, strong) UIColor *currentDateTextColor;
@property (nonatomic, strong) UIColor *currentDateBackgroundColor;
@property (nonatomic, strong) UIColor *nonCurrentMonthDateTextColor;
@property (nonatomic, strong) UIColor *disabledDateTextColor;
@property (nonatomic, strong) UIColor *disabledDateBackgroundColor;

- (id)initWithStartDay:(startDay)firstDay;
- (id)initWithStartDay:(startDay)firstDay dates:(NSArray *)dates startTimes:(NSArray *)startTimes endTimes:(NSArray *)endTimes frame:(CGRect)frame;

- (void)setTitleFont:(UIFont *)font;
- (UIFont *)titleFont;

- (void)setTitleColor:(UIColor *)color;
- (UIColor *)titleColor;

- (void)setButtonColor:(UIColor *)color;

- (void)setInnerBorderColor:(UIColor *)color;

- (void)setDayOfWeekFont:(UIFont *)font;
- (UIFont *)dayOfWeekFont;

- (void)setDayOfWeekTextColor:(UIColor *)color;
- (UIColor *)dayOfWeekTextColor;

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor;

- (void)setDateFont:(UIFont *)font;
- (UIFont *)dateFont;

- (void)setDateBackgroundColor:(UIColor *)color;
- (UIColor *)dateBackgroundColor;

- (void)setDateBorderColor:(UIColor *)color;
- (UIColor *)dateBorderColor;

@end

@protocol CKCalendarDelegate <NSObject>

- (void)calendar:(MELiPadCalendarView *)calendar didSelectDate:(NSDate *)date;

@optional

- (void)transitionToPreviousMonth;
- (void)transitionToNextMonth;

@end
