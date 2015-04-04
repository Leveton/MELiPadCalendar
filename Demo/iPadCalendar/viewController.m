#import "viewController.h"
#import "MELiPadCalendarView.h"

@interface viewController ()<MELiPadCalendarDelegate>

@property (nonatomic, strong) MELiPadCalendarView *calendar;
@property (nonatomic, strong) NSDate *orientationDate;
@property (nonatomic, strong) NSMutableArray *theStartHours;
@property (nonatomic, strong) NSMutableArray *theEndHours;
@property (nonatomic, strong) NSMutableArray *theTodoDates;
@property (nonatomic, strong) NSMutableArray *theHeaders;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSCalendar *calendarForOrientation;
@property (nonatomic, strong) NSDateComponents *dateComponents;
@property CGRect frameChosen;

@end

@implementation viewController


- (id)init {
    self = [super init];
    
    if (self)
    {
        self.theTodoDates =[NSMutableArray array];
        self.theStartHours = [NSMutableArray array];
        self.theEndHours = [NSMutableArray array];
        self.theHeaders = [NSMutableArray array];
        
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    //hit the dummy API from the JSON file
    [self getTheDummyJson];
    
    NSAssert(self.theTodoDates, NSLocalizedString(@"Yo, there ain't no dates", nil));
    NSAssert(self.theStartHours, NSLocalizedString(@"Yo, there ain't no dates", nil));
    NSAssert(self.theEndHours, NSLocalizedString(@"Yo, there ain't no dates", nil));
    
    self.calendar = [[MELiPadCalendarView alloc]initWithStartDay:startSunday frame:CGRectMake(127, 20, 770, 640)];
    
    [self.calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours andHeaders:self.theHeaders];
    
    self.calendar.delegate = self;
    self.frameChosen = self.calendar.frame;
    
    self.orientationDate = [NSDate date];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    self.dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    /*highlight the current date, or a range of dates*/
    NSString *stringFromDate = [self.dateFormatter stringFromDate: self.orientationDate];
    self.calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
    
    [self.view addSubview:self.calendar];
    
    self.view.backgroundColor = BlueColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - utilities

- (void)transitionToPreviousMonth
{
    [self.calendar removeFromSuperview];
    self.calendar = nil;
    
    NSCalendar *calendarForOrientation = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:-1];
    self.orientationDate = [calendarForOrientation dateByAddingComponents:dateComponents toDate:self.orientationDate options:0];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    self.dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    NSString *stringFromDate = [self.dateFormatter stringFromDate:self.orientationDate];
    
    self.calendar = [[MELiPadCalendarView alloc]initWithStartDay:startSunday frame:self.frameChosen];
    [self.calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours andHeaders:self.theHeaders];
    self.calendar.delegate = self;
    self.calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
    
    [self.view addSubview:self.calendar];
}

- (void)transitionToNextMonth
{
    
    [self.calendar removeFromSuperview];
    self.calendar = nil;
    
    NSCalendar *calendarForOrientation = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setMonth:1];
    self.orientationDate = [calendarForOrientation dateByAddingComponents:dateComponents toDate:self.orientationDate options:0];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    self.dateFormatter.dateFormat = @"MM/dd/yyyy";
    
    NSString *stringFromDate = [self.dateFormatter stringFromDate:self.orientationDate];
    
    self.calendar = [[MELiPadCalendarView alloc]initWithStartDay:startSunday frame:self.frameChosen];
    
    [self.calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours andHeaders:self.theHeaders];
    
    self.calendar.delegate = self;
    self.calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
    
    [self.view addSubview:self.calendar];
}

#pragma mark - MELiPadDelegate

- (void)calendar:(MELiPadCalendarView *)calendar didSelectDate:(NSDate *)date
{
    NSLog(@"you've reached didselect date in viewcontroller");
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
//            NSLog(@"end: %@", dict[@"EndTime"]);
//            NSLog(@"start: %@", dict[@"StartTime"]);
            
            NSString *startTime = dict[@"StartTime"];
            NSString *endTime = dict[@"EndTime"];
            NSString *heading = dict[@"Heading"];
            [startTimes addObject:startTime];
            [endTimes addObject:endTime];
            [self.theHeaders addObject:heading];
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


#pragma mark - formatting dummy JSON

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