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

Drop the `MELiPadCalendarView` folder into your project.  Make sure 'Copy items if needed' and 'Create groups' is checked.

Make sure `QuartzCore.framework` and `EventKit.framework` are linked to your project.

## Use

The demo provides a datasource by initiating four arrays, one for the dates which will contain data, another for the task start times, another for the task end times, and one for the task labels.

Initiate the calendar with its x Offset, y Offset and side dimension.  To stay in tune with Apple's [Human Interface Guidelines,](https://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/MobileHIG/) I keep the view a perfect square and prevent it from being less than 512 or greater than 768.  That will fit two calendars in landscape.

```objc
MELiPadCalendarView *calendar = [[MELiPadCalendarView alloc]initWithXoffset:0 andYoffset:0 withDimension:768];
calendar.delegate = self;
self.orientationDate = [NSDate date];
NSString *stringFromDate = [self.dateFormatter stringFromDate:self.orientationDate];
calendar.selectedDate = [self.dateFormatter dateFromString:stringFromDate];
[calendar setUpTheTodoDates:self.theTodoDates withStartTimes:self.theStartHours andEndTimes:self.theEndHours andHeaders:self.theHeaders];
[self.view addSubview:calendar];
```

Have your view controller conform to the MELiPadCalendarDelegate so that you can change months and receive data when a row in the day is tapped.

if a user taps on any date, the delegate gets the date chosen, if they tap on a task, the delegate also gets the hour range for that task:

``` objc
- (void)calendar:(MELiPadCalendarView *)calendar didTapTaskWithHours:(NSString *)hours forDate:(NSDate *)date;
```

For transitioning months, you can either prepare the calendar in the delegate like I do in the demo project, or you can fork this control and prepare it in the view itself.

``` objc
- (void)calendar:(MELiPadCalendarView *)calendar didTapTransitionMonth:(BOOL)forward;
```

##Customizing

- Fonts, text colors, and background colors for most elements can be customized.

## Contact

- Mike Leveton
- mleveton@prepcloud.com

## License

MELiPadCalendar is available under the MIT license.

Copyright © 2015 Mike Leveton

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.