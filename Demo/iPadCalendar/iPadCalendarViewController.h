//TODO change NSDateFormatter to dateWithTimeIntervalSince1970 to speed up loading time
//TODO add license

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface iPadCalendarViewController : UIViewController

@property (nonatomic, strong) NSCalendar *genericCalendar;
@property (nonatomic, retain) NSMutableArray *tableData0;
@property (nonatomic, retain) NSMutableArray *tableData1;
@property (nonatomic, retain) NSMutableArray *theTodoDates;
@property (nonatomic, retain) NSMutableArray *theStartHours;
@property (nonatomic, retain) NSMutableArray *theEndHours;
@property (nonatomic, retain) NSString *apiUrl;
@end
