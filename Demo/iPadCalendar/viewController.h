//TODO change NSDateFormatter to dateWithTimeIntervalSince1970 to speed up loading time
//TODO add license

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface viewController : UIViewController

@property (nonatomic, strong) NSCalendar *genericCalendar;
@property (nonatomic, strong) NSString *apiUrl;
@end
