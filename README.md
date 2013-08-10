MELiPadCalendar
=======

Calendar for the iPad with UITableViews to display schedule data, extends [CKCalendar](https://github.com/jaykz52/CKCalendar).
Table rows and font sizes scale dynamically depending on how large you make the calendar.

<img src="https://raw.github.com/Leveton/MELiPadCalendar/master/screenshots/calendar.png" alt="TSNavigationStripView examples" width="680" height="484" />

## Requirements

* Xcode 4.5 or higher
* Apple LLVM compiler
* EventKit.framework
* QuartzCore.framework

## Demo

Build and run the `iPadCalendar` project in Xcode. 
I've included a JSON file in the demo to simulate an API response.

## Installation

Drop the `MELiPadCalendar` folder into your project.
Add `QuartzCore.framework` and `EventKit.framework` if you don't already have them in your project.

## Use

Before initiating the calendar, initiate three arrays, one for the dates which will contain data, another for the todo start times and another for the todo end times.
After that, hit your API and populate the three arrays before initiating the calendar.

```objc
- (id)init {
    self = [super init];
    if (self)
    {
        self.theTodoDates = [[NSMutableArray alloc]init];
        self.theStartHours = [[NSMutableArray alloc]init];
        self.theEndHours = [[NSMutableArray alloc]init];
        
        //hit the API
        [self getTodoTimeStamps];
    }
    return self;
}
```

Initiate the calendar.

```objc
	calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:theTodoDates startTimes:theStartHours endTimes:theEndHours frame:CGRectMake(127,54,770,640)];

	calendar.delegate = self;
    frameChosen = calendar.frame;

	orientationDate = [NSDate date];

	//highlight the current date, or a range of dates
	NSString *stringFromDate = [self.dateFormatter stringFromDate:orientationDate];
	calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
	calendar.minimumDate = [self.dateFormatter dateFromString:@""];
	calendar.maximumDate = [self.dateFormatter dateFromString:@""];
	calendar.shouldFillCalendar = NO;
	calendar.adaptHeightToNumberOfWeeksInMonth = YES;

	[self.view addSubview:calendar];
```

- initWithStartDay can either be startSunday or startMonday and the date range will be Sunday to Saturday or Monday to Sunday respectively.

- dates is an NSMutableArray that stores the dates which have data that needs to be shown.

- startTimes is an NSMutableArray that stores the beginning time for the todo.

- endTimes is an NSMutableArray that stores the end time for the todo.

When a user attempts to move to the previous or next month, the calendar will call `transitionToPreviousMonth` and `transitionToNextMonth` respectively on the delegate (if the delegate implements them).
In these methods, the entire calendar must be removed and reinitiated in order to accomodate the new data (thanks LLVM!).

``` objc
- (void)transitionToPreviousMonth
{
    [self.calendar removeFromSuperview];
    
    self.calendarForOrientation = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [[NSDateComponents alloc] init];
    [comps setMonth:-1];
    self.orientationDate = [self.calendarForOrientation dateByAddingComponents:comps toDate:self.orientationDate options:0];
    
    NSString *stringFromDate = [self.dateFormatter stringFromDate:self.orientationDate];
    
   calendar = [[MELiPadCalendarView alloc] initWithStartDay:startSunday dates:theTodoDates startTimes:theStartHours endTimes:theEndHours frame:CGRectMake(127,12,770,580)];
    
    calendar.delegate = self;
    calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
    calendar.shouldFillCalendar = NO;
    calendar.adaptHeightToNumberOfWeeksInMonth = YES;

    [self.view addSubview:calendar];
}
```
##Customizing

- Fonts, text colors, and background colors of nearly every element can be customized.

- For more info, please see [CKCalendar](https://github.com/jaykz52/CKCalendar), the project this one is based on.

## Contact

- Mike Leveton
- mleveton@prepcloud.com

## License

MELiPadCalendar is available under the MIT license.

Copyright © 2013 Mike Leveton

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.