#import <UIKit/UIKit.h>

#define REDCOLOR [UIColor colorWithRed:246.0/255.0 green:71.0/255 blue:71.0/255 alpha:1.0]
#define REDCOLORPlUS2 [UIColor colorWithRed:244.0/255.0 green:22.0/255 blue:22.0/255 alpha:1.0]
#define REDCOLORMINUS2 [UIColor colorWithRed:250.0/255.0 green:144.0/255 blue:144.0/255 alpha:1.0]
#define WHITECOLORPLUSONE [UIColor colorWithRed:(245.0/255.0) green:(245.0/255) blue:(245.0/255) alpha:1.0]
#define WHITECOLORPLUSTWO [UIColor colorWithRed:(232.0/255.0) green:(232.0/255) blue:(232.0/255) alpha:1.0]

@protocol MELiPadCalendarDelegate;

@interface MELiPadCalendarView : UIView


@property (nonatomic, strong) NSLocale *locale;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, weak) id<MELiPadCalendarDelegate> delegate;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, strong) UIColor *dateTextColor;
@property (nonatomic, strong) UIColor *selectedDateTextColor;
@property (nonatomic, strong) UIColor *selectedDateBackgroundColor;
@property (nonatomic, strong) UIColor *currentDateTextColor;
@property (nonatomic, strong) UIColor *currentDateBackgroundColor;
@property (nonatomic, strong) UIColor *nonCurrentMonthDateTextColor;
@property (nonatomic, strong) UIColor *disabledDateTextColor;
@property (nonatomic, strong) UIColor *disabledDateBackgroundColor;

- (id)initWithXoffset:(CGFloat)XOffset andYoffset:(CGFloat)YOffset withDimension:(CGFloat)dimension;

- (void)setUpTheTodoDates:(NSArray *)todoDates withStartTimes:(NSArray *)startTimes andEndTimes:(NSArray *)endTimes andHeaders:(NSArray *)headers;

- (void)setTitleFont:(UIFont *)font;
- (UIFont *)titleFont;

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor;

- (void)setDateFont:(UIFont *)font;

- (void)setDateBackgroundColor:(UIColor *)color;
- (UIColor *)dateBackgroundColor;

- (void)setDateBorderColor:(UIColor *)color;
- (UIColor *)dateBorderColor;


@end

@protocol MELiPadCalendarDelegate <NSObject>

- (void)calendar:(MELiPadCalendarView *)calendar didTapTransitionMonth:(BOOL)forward;

@optional

- (void)calendar:(MELiPadCalendarView *)calendar didTapTaskWithHours:(NSString *)hours forDate:(NSDate *)date;

@end