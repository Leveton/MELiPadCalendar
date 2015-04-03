#import "viewController.h"
#import "MELiPadCalendarView.h"

@interface viewController ()<CKCalendarDelegate>

@property (nonatomic, strong) MELiPadCalendarView *calendar;
@property (nonatomic, strong) NSDate *orientationDate;
@property (nonatomic, assign) CGRect frameChosen;
@property (nonatomic, strong) NSMutableArray *theStartHours;
@property (nonatomic, strong) NSMutableArray *theEndHours;
@property (nonatomic, strong) NSMutableArray *theTodoDates;

@end

@implementation viewController


- (id)init {
    self = [super init];
    
    if (self)
    {
        self.theTodoDates =[NSMutableArray array];
        self.theStartHours = [NSMutableArray array];
        self.theEndHours = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //self.calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:self.theTodoDates startTimes:self.theStartHours endTimes:self.theEndHours frame:CGRectMake(127,20,770,640)];
    
    self.calendar = [[MELiPadCalendarView alloc]initWithStartDay:startSunday frame:CGRectMake(127, 20, 770, 640)];
    //.14
    //.17
    
    //hit the dummy API from the JSON file
    [self getTheDummyJson];
    
    if (self.theTodoDates && self.theStartHours && self.theEndHours)
    {
       [self.calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours];
    }
    
    self.calendar.delegate = self;
    self.frameChosen = self.calendar.frame;
    
     self.orientationDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    //highlight the current date, or a range of dates
    NSString *stringFromDate = [dateFormatter stringFromDate: self.orientationDate];
    self.calendar.selectedDate = [dateFormatter dateFromString:stringFromDate];
    self.calendar.minimumDate = [dateFormatter dateFromString:@""];
    self.calendar.maximumDate = [dateFormatter dateFromString:@""];
    self.calendar.shouldFillCalendar = NO;
    self.calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    [self.view addSubview:self.calendar];
    
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

#pragma mark - delegates

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
    
    self.calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:self.theTodoDates startTimes:self.theStartHours endTimes:self.theEndHours frame: self.frameChosen];
    
    self.calendar.delegate = self;
    self.calendar.selectedDate = [dateFormatter dateFromString:stringFromDate];
    self.calendar.shouldFillCalendar = NO;
    self.calendar.adaptHeightToNumberOfWeeksInMonth = YES;

    [self.view addSubview:self.calendar];
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
    
    self.calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:self.theTodoDates startTimes:self.theStartHours endTimes:self.theEndHours frame:self.frameChosen];
    
    self.calendar.delegate = self;
    self.calendar.selectedDate = [dateFormatter dateFromString:stringFromDate];
    self.calendar.shouldFillCalendar = NO;
    self.calendar.adaptHeightToNumberOfWeeksInMonth = YES;
    
    [self.view addSubview:self.calendar];
}

#pragma mark - dummy API call

-(void)getTheDummyJson
{
    
    NSError *error;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSString *myFile = [mainBundle pathForResource:@"test" ofType: @"json"];
    NSString *jsonString = [NSString stringWithContentsOfFile:myFile
                                                 encoding:NSUTF8StringEncoding
                                                    error:&error];
    if (error)
    {
        NSLog(@"json error %@", error);
        return;
    }
    
    NSData *dataFromString = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonData = [NSJSONSerialization JSONObjectWithData:dataFromString options:0 error:&error];
    if (jsonData && [NSJSONSerialization isValidJSONObject:jsonData])
    {
        NSArray *body = jsonData[@"Body"];
        NSMutableArray *startTimes = [NSMutableArray array];
        NSMutableArray *endTimes = [NSMutableArray array];
        
        for (NSDictionary *dict in body)
        {
            NSLog(@"end: %@", dict[@"EndTime"]);
            NSLog(@"start: %@", dict[@"StartTime"]);
            
            NSString *startTime = dict[@"StartTime"];
            NSString *endTime = dict[@"EndTime"];
            [startTimes addObject:startTime];
            [endTimes addObject:endTime];
        }
        
        NSArray *startTimeTimeStamps = [self convertResponsesToTimestamps:startTimes];
        NSArray *endTimeTimeStamps = [self convertResponsesToTimestamps:endTimes];
        
        NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
        [_formatter setDateFormat:@"MM/dd/yyyy 'at' hh:mm"];
        
        for (id object in startTimeTimeStamps)
        {
            NSString *timeStamp = object;
            NSTimeInterval _interval=[timeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSString *_date=[_formatter stringFromDate:date];
            NSLog(@"startDate: %@", _date);
            [self separateStartDateAndHour:_date];
        }
        
        for (id object in endTimeTimeStamps)
        {
            NSString *timeStamp = object;
            NSTimeInterval _interval=[timeStamp doubleValue];
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
            NSString *_longDate=[_formatter stringFromDate:date];
            NSLog(@"endDates %@", _longDate);
            [self separateEndDateAndHour:_longDate];
        }
    }
    
}


#pragma mark - formatting JSON

- (void)separateStartDateAndHour:(NSString *)longDate
{
    NSString *justTheDate = [longDate substringToIndex:[longDate length] - 9];
    [self.theTodoDates addObject:justTheDate];
    //NSLog(@"justtheSTARTdate: '%@'", theTodoDates);
    
    NSRange range = [longDate rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, 11)];
    NSString *hourStart = [longDate substringFromIndex:range.location+4];
    [self.theStartHours addObject:hourStart];
    //NSLog(@"the START Hour: '%@'", theStartHours);
}

- (void)separateEndDateAndHour:(NSString *)longDate
{
    //NSString *justTheDate = [longDate substringToIndex:[longDate length] - 9];
    //NSLog(@"theEndDate: '%@'", justTheDate);
    
    NSRange range = [longDate rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(0, 11)];
    NSString *hourStart = [longDate substringFromIndex:range.location+4];
    [self.theEndHours addObject:hourStart];
    //NSLog(@"the END Hour: '%@'", theEndHours);
}

- (NSString *)convertResponseIntoValidJSON:(NSString *)responseString
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