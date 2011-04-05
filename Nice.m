//
//  Nice.m
//  AAPLot
//
//  Created by admin on 3/24/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import "Nice.h"

#include <math.h>

const double nice_intervals[] = { 1.0, 2.0, 2.5, 3.0, 5.0, 10.0 };
const int nice_intervals_len = sizeof(nice_intervals) / sizeof(nice_intervals[0]);

double nice_ceil(double x)
{
    if (x == 0)
        return 0;
    if (x < 0)
        return nice_floor(x * -1) * -1;
    double z = pow(10.0, floor(log10(x)));
    for (int i = 0; i < nice_intervals_len-1; ++i) {
        double result = nice_intervals[i] * z;
        if (x <= result)
            return result;
    }
    return nice_intervals[nice_intervals_len - 1] * z;
}

double nice_floor(double x)
{
    if (x == 0)
        return 0;
    if (x < 0)
        return nice_ceil(x * -1) * -1;
    double z = pow(10.0, ceil(log10(x)) - 1.0);
    //double r = x / z;
    for (int i = nice_intervals_len - 1; i > 0; --i) {
        double result = nice_intervals[i] * z;
        if (x >= result)
            return result;
    }
    return nice_intervals[0] * z;
}

double nice_round(double x)
{
    if (x == 0)
        return 0;
    double z = pow(10.0, ceil(log10(x)) - 1.0);
    //double r = x / z;
    for (int i = 0; i < nice_intervals_len-1; ++i) {
        double result = nice_intervals[i] * z;
        double cutoff = (result + nice_intervals[i+1] * z) / 2.0;
        if (x <= cutoff)
            return result;
    }
    return nice_intervals[nice_intervals_len - 1] * z;
}

/*
NSArray *nice_ticks(double lo, double hi) 
{
    return nice_ticks(lo, hi, 5, NO);
}

NSArray *nice_ticks(double lo, double hi, NSUInteger ticks)
{
    return nice_ticks(lo, hi, ticks, NO);
}
*/


@implementation Nice

+(NSArray*)niceTicksWithLo:(double)lo hi:(double)hi ticks:(NSUInteger)ticks inside:(BOOL)inside;
{
    double delta_x = hi - lo;
    if (delta_x == 0) {
        if (lo == 0)
            return [Nice niceTicksWithLo:-1 hi:1 ticks:ticks inside:inside];
        else
            return [Nice niceTicksWithLo:nice_floor(lo) hi:nice_ceil(hi) ticks:ticks inside:inside];
    }
    //double nice_delta_x = nice_ceil(delta_x);
    double delta_t = nice_round(delta_x / (ticks - 1));
    double lo_t, hi_t;
    if (inside) {
        lo_t = ceil(lo / delta_t) * delta_t;
        hi_t = floor(hi / delta_t) * delta_t;
    } else {
        lo_t = floor(lo / delta_t) * delta_t;
        hi_t = ceil(hi / delta_t) * delta_t;
    }
        
    NSMutableArray *m_res = [NSMutableArray arrayWithCapacity:ticks];
    double t = lo_t;
    while (t <= hi_t) {
        [m_res addObject:[NSDecimalNumber decimalNumberWithDecimal:
                          [[NSNumber numberWithDouble:t] decimalValue]
                          ]];
        t += delta_t;
    }
    
    return [NSArray arrayWithArray:m_res];
}

@end

//const NSTimeInterval one_day = 3600 * 24;
//
//NSInteger end_of_month(NSInteger year, NSInteger month)
//{
//    NSInteger resDay;
//    if (month == 12)
//        resDay = 31;
//    else {
//        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//        [dateComponents setMonth:month+1];
//        [dateComponents setDay:1];
//        [dateComponents setYear:year];
//        NSCalendar *gregorian = [[NSCalendar alloc]
//                                 initWithCalendarIdentifier:NSGregorianCalendar];
//        NSDate *refDate = [gregorian dateFromComponents:dateComponents];
//        [dateComponents release];
//        
//        NSDate *earlierDate = [refDate dateByAddingTimeInterval: -one_day];
//        
//        unsigned unitFlags = NSDayCalendarUnit;
//        dateComponents = [gregorian components:unitFlags fromDate:earlierDate];        
//        resDay = [dateComponents day];
//        
//        [dateComponents release];
//        [gregorian release];
//    }
//    
//    return resDay;
//}
//
//NSDate *month_floor(NSDate *dt, NSInteger n)
//{
//    /* Round datetime down to nearest date that falls evenly on an
//     n-month boundary. (E.g., valid intervals for a 3-month
//     boundary are 1/1, 4/1, 7/1, and 10/1) */
//    
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
//    unsigned unitFlags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | 
//        NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
//    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:dt];
//    [dateComponents setMonth: 1];
//    [dateComponents setDay: 1];
//    [dateComponents setHour: 0];
//    [dateComponents setMinute: 0];
//    [dateComponents setSecond: 0];
//    
//    NSDate *res;
//    NSDate *next = [gregorian dateFromComponents:dateComponents];
//    [dateComponents release];
//    NSDate *curr = nil;
//    BOOL releaseNext = YES;
//    if ([next isEqualToDate:dt])
//        res = [dt copy];
//    else {
//        while ([next compare:dt] == NSOrderedAscending) {
//            curr = next;
//            
//            dateComponents = [gregorian components:unitFlags fromDate:next];
//            if ([dateComponents month] + n > 12) {
//                releaseNext = NO;
//                break;
//            }
//            [dateComponents setMonth:[dateComponents month] + n];
//            [next release];
//            next = [gregorian dateFromComponents:dateComponents];
//            [dateComponents release];
//        }
//        res = curr;
//    }
//    if (releaseNext)
//        [next release];
//    [gregorian release];
//    
//    return res;
//}
//
//NSDate *month_ceil(NSDate *dt, NSInteger n)
//{
//    /* Round datetime up to nearest date that falls evenly on an
//     n-month boundary. (E.g., valid intervals for a 3-month
//     boundary are 1/1, 4/1, 7/1, and 10/1) */
//    NSDate *f = month_floor(dt, n);
//    NSCalendar *gregorian = [[NSCalendar alloc]
//                             initWithCalendarIdentifier:NSGregorianCalendar];
//    unsigned unitFlags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | 
//    NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
//    NSDateComponents *dateComponents = [gregorian components:unitFlags fromDate:f];
//    if ([dateComponents month] + n - 1 > 12) {
//        NSInteger new_year = [dateComponents year] + 1;
//        NSInteger new_month = ((([dateComponents month] - 1) + n) % 12) + 1;
//        [dateComponents setYear:new_year];
//        [dateComponents setMonth:new_month];
//    } else
//        [dateComponents setMonth:[dateComponents month] + n - 1];
//    
//    [f release];
//    f = [gregorian dateFromComponents:dateComponents];
//    [dateComponents release];
//    [gregorian release];
//    
//    return f;    
//}
