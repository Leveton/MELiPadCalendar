MELiPadCalendar
=======

Calendar for the iPad with table views to display and return scheduling data.

<img src="https://raw.github.com/Leveton/MELiPadCalendar/master/screenshots/calendar.png" alt="TSNavigationStripView examples" width="680" height="484" />

## Requirements

* Xcode 4.5 or higher
* Apple LLVM compiler
* EventKit.framework
* QuartzCore.framework

## Demo

Build and run the `iPadCalendar` project in Xcode. 
I've included a JSON file for adding todo times, start times, end times, and event labels.

## Installation

Drop the `MELiPadCalendar` folder into your project.  Make sure 'Copy items if needed' and 'Create groups' is checked.

Add `QuartzCore.framework` and `EventKit.framework` if you don't already have them in your project.

## Use

Have your view controller conform to the MELiPadCalendarDelegate so that you can change months and receive data on when a row in the day is tapped.

Before initiating the calendar, initiate three arrays, one for the dates which will contain data, another for the todo start times and another for the todo end times.

You can send the calendar arrays of todo dates, start hours, end hours, and header labels.


Initiate the calendar:
The frame and date need to be captured for transitioning between months.

```objc
	self.calendar = [[MELiPadCalendarView alloc]initWithXoffset:128 andYoffset:0 withDimension:768];
    self.calendar.delegate = self;
    self.orientationDate = [NSDate date];
    NSString *stringFromDate = [self.dateFormatter stringFromDate:self.orientationDate];
    self.calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
    [self.calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours andHeaders:self.theHeaders];
    [self.view addSubview:self.calendar];
```

When a user attempts to move to the previous or next month, the calendar will call `transitionMonth:` on the delegate.
In these methods, the entire calendar must be removed and reinitiated in order to accomodate larger months such as June, and any new data.

``` objc
- (void)transitionMonth:(BOOL)forward
{
    CGRect frameChosen = self.calendar.frame;
    
    [self.calendar removeFromSuperview];
    self.calendar = nil;
    
    if (forward)
    {
        [self.dateComponents setMonth:1];
    }
    else
    {
        [self.dateComponents setMonth:-1];
    }
    
    self.orientationDate = [self.calendarForOrientation dateByAddingComponents:self.dateComponents toDate:self.orientationDate options:0];
    NSString *stringFromDate = [self.dateFormatter stringFromDate:self.orientationDate];
    self.calendar = [[MELiPadCalendarView alloc]initWithXoffset:frameChosen.origin.x andYoffset:frameChosen.origin.y withDimension:frameChosen.size.width];
    self.calendar.delegate = self;
    self.calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
    [self.calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours andHeaders:self.theHeaders];
    [self.view addSubview:self.calendar];
}
```
##Customizing

- Fonts, text colors, and background colors of nearly every element can be customized.


## Contact

- Mike Leveton
- mleveton@prepcloud.com

## License

MELiPadCalendar is available under the MIT license.

Copyright © 2015 Mike Leveton

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.