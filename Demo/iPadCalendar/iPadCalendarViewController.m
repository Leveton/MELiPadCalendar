#import "iPadCalendarViewController.h"
#import "MELiPadCalendarView.h"
#import "SBJson.h"

@interface iPadCalendarViewController () 

@property (nonatomic, strong) MELiPadCalendarView *calendar;
@property (nonatomic, strong) NSDate *orientationDate;
@property (nonatomic, assign) CGRect frameChosen;
@end

@implementation iPadCalendarViewController
@synthesize genericCalendar, apiUrl, tableData0, tableData1, theTodoDates, theStartHours, theEndHours, calendar, orientationDate, frameChosen;

- (id)init {
    self = [super init];
    if (self)
    {
        self.tableData0 = [[NSMutableArray alloc]init];
        self.tableData1 = [[NSMutableArray alloc]init];
        self.theTodoDates = [[NSMutableArray alloc]init];
        self.theStartHours = [[NSMutableArray alloc]init];
        self.theEndHours = [[NSMutableArray alloc]init];
        
        //hit the dummy API from the JSON file
        [self getTodoTimeStamps];
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:theTodoDates startTimes:theStartHours endTimes:theEndHours frame:CGRectMake(127,20,770,640)];
    
    calendar.delegate = self;
    frameChosen = calendar.frame;
    
    orientationDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //highlight the current date, or a range of dates
    NSString *stringFromDate = [dateFormatter stringFromDate:orientationDate];
    calendar.selectedDate = [dateFormatter dateFromString:stringFromDate];
    calendar.minimumDate = [dateFormatter dateFromString:@""];
    calendar.maximumDate = [dateFormatter dateFromString:@""];
    calendar.shouldFillCalendar = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    [self.view addSubview:calendar];
    
    self.view.backgroundColor = BlueColor;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

//- (NSDateFormatter *)dateFormatter
//{
//    if (! _dateFormatter)
//    {
//        _dateFormatter = [[NSDateFormatter alloc] init];
//        _dateFormatter.dateFormat = @"MM/dd/yyyy";
//    }
//    return _dateFormatter;
//}

#pragma delegates

- (void)calendar:(MELiPadCalendarView *)calendar didSelectDate:(NSDate *)date
{
    
}

- (void)transitionToPreviousMonth
{
    [self.calendar removeFromSuperview];
    
    NSCalendar *calendarForOrientation = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    self.orientationDate = [calendarForOrientation dateByAddingComponents:comps toDate:self.orientationDate options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    NSString *stringFromDate = [dateFormatter stringFromDate:self.orientationDate];
    
    calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:theTodoDates startTimes:theStartHours endTimes:theEndHours frame:frameChosen];
    
    calendar.delegate = self;
    calendar.selectedDate = [dateFormatter dateFromString:stringFromDate];
    calendar.shouldFillCalendar = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;

    [self.view addSubview:calendar];
}

- (void)transitionToNextMonth
{
    
    [self.calendar removeFromSuperview];
    
    NSCalendar *calendarForOrientation = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:1];
    self.orientationDate = [calendarForOrientation dateByAddingComponents:comps toDate:self.orientationDate options:0];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    NSString *stringFromDate = [dateFormatter stringFromDate:self.orientationDate];
    
    calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:theTodoDates startTimes:theStartHours endTimes:theEndHours frame:frameChosen];
    
    calendar.delegate = self;
    calendar.selectedDate = [dateFormatter dateFromString:stringFromDate];
    calendar.shouldFillCalendar = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    [self.view addSubview:calendar];
}

#pragma mark dummy API call

-(void)getTodoTimeStamps
{
    @autoreleasepool
    {

        NSError *error;
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *myFile = [mainBundle pathForResource: @"test" ofType: @"json"];
        NSString *response=[NSString stringWithContentsOfFile:myFile
                                                    encoding:NSUTF8StringEncoding
                                                       error:&error];
        if (error)
        {
            NSLog(@"error %@", error);
        }
        
        NSString *validJSON = [self convertResponseIntoValidJSON:response];
        
        SBJsonParser* parser = [[SBJsonParser alloc]init];
        NSDictionary* myDict = [parser objectWithString:validJSON];
        NSArray *resultsArray = [myDict valueForKey:@"Body"];
        NSArray *startTime = [resultsArray valueForKey:@"StartTime"];
        NSArray *endTime = [resultsArray valueForKey:@"EndTime"];
        
        for (id object in startTime) {
            [self.tableData0 addObject:object];
        }
        
        for (id object in endTime) {
            [self.tableData1 addObject:object];
        }
        
        NSArray *startTimeTimeStamps = [self convertResponsesToTimestamps:tableData0];
        NSArray *endTimeTimeStamps = [self convertResponsesToTimestamps:tableData1];
        
        NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"MM/dd/yyyy 'at' hh:mm"];
        
        for (id object in startTimeTimeStamps)
        {
            NSString *timeStamp = object;
            NSTimeInterval _interval=[timeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSString *_date=[_formatter stringFromDate:date];
            //NSLog(@"startDate: %@", _date);
            [self separateStartDateAndHour:_date];
        }
        
        for (id object in endTimeTimeStamps)
        {
            NSString *timeStamp = object;
            NSTimeInterval _interval=[timeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSString *_longDate=[_formatter stringFromDate:date];
            //NSLog(@"endDates %@", _longDate);
            [self separateEndDateAndHour:_longDate];
        }
    }
}

#pragma formatting JSON

- (void)separateStartDateAndHour:(NSString *)longDate
{
    NSString *justTheDate = [longDate substringToIndex:[longDate length] - 9];
    [theTodoDates addObject:justTheDate];
    //NSLog(@"justtheSTARTdate: '%@'", theTodoDates);
    
    NSRange range = [longDate rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, 11)];
    NSString *hourStart = [longDate substringFromIndex:range.location+4];
    [theStartHours addObject:hourStart];
    //NSLog(@"the START Hour: '%@'", theStartHours);
}

- (void)separateEndDateAndHour:(NSString *)longDate
{
    NSString *justTheDate = [longDate substringToIndex:[longDate length] - 9];
    NSLog(@"theEndDate: '%@'", justTheDate);
    
    NSRange range = [longDate rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, 11)];
    NSString *hourStart = [longDate substringFromIndex:range.location+4];
    [theEndHours addObject:hourStart];
    //NSLog(@"the END Hour: '%@'", theEndHours);
}

-(NSString *)convertResponseIntoValidJSON:(NSString *)responseString
{
    responseString=[responseString stringByReplacingOccurrencesOfString:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                                             withString:@""];
    responseString=[responseString stringByReplacingOccurrencesOfString:@"<string xmlns=\"http://tempuri.org/\">"
                                                             withString:@""];
    responseString=[responseString stringByReplacingOccurrencesOfString:@"</string>"
                                                             withString:@""];
    
    return responseString;
}

-(NSArray *)convertResponsesToTimestamps:(NSArray *)responseArray
{
    NSMutableArray *timeStampArry = [[NSMutableArray alloc]init];
    for (id object in responseArray)
    {
        NSString *responseString=[object stringByReplacingOccurrencesOfString:@"/Date("
                                                                   withString:@""];
        responseString=[responseString stringByReplacingOccurrencesOfString:@")/"
                                                                 withString:@""];
        
        if ([responseString length] > 0)
        {
            responseString = [responseString substringToIndex:[responseString length] - 3];
        }

        [timeStampArry addObject:responseString];
        
    }
    
    return timeStampArry;
}

@end