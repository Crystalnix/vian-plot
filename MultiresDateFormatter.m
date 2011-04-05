//
//  MultiresDateFormatter.m
//  AAPLot
//
//  Created by admin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MultiresDateFormatter.h"


@implementation MultiresDateFormatter

@synthesize indexConverter;

- (id)initWithStartDate:(NSDate*)aStartDate endDate:(NSDate*)aEndDate// numIndices:(NSUInteger)aNumIndices
{
    if ( (self = [super init]) ) {
        startDate = [aStartDate retain];
        endDate = [aEndDate retain];
        //numIndices = aNumIndices;
        indexConverter = nil;
        
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        NSTimeInterval ti = [endDate timeIntervalSinceReferenceDate] - [startDate timeIntervalSinceReferenceDate];
        if (ti <= 24 * 60 * 60 * 3) {   // 3 days
            resolution = MultiresDateResolutionHours;
            [dateFormatter setDateFormat:@"H"];
        } else if (ti <= 24 * 60 * 60 * 31 * 2) { // 2 months
            resolution = MultiresDateResolutionDays;
            [dateFormatter setDateFormat:@"dd"];
        } else if (ti <= 24 * 60 * 60 * 366 * 2) { // 2 years
            resolution = MultiresDateResolutionMonths;
            [dateFormatter setDateFormat:@"MMM"];
        }
    }
    
    return self;
}

-(void)dealloc
{
    [startDate release];
    [endDate release];
	[dateFormatter release];
	[super dealloc];
}


#pragma mark -
#pragma mark Formatting

/**	@brief Converts decimal number for the time into a date string.
 *  Uses the date formatter to do the conversion. Conversions are relative to the
 *  reference date, unless it is nil, in which case the standard reference date
 *  of 1 January 2001, GMT is used.
 *	@param coordinateValue The time value.
 *	@return The date string.
 **/
-(NSString *)stringForObjectValue:(NSDecimalNumber *)coordinateValue
{
    NSString *string = @"";
    if (indexConverter != nil && [(NSObject*)indexConverter respondsToSelector:@selector(dateFromIndex:)]) {
        NSDate *date = [indexConverter dateFromIndex:coordinateValue];
        NSTimeInterval delta = [endDate timeIntervalSinceDate:startDate];
           
        if ([date timeIntervalSinceDate:startDate] > delta / 12 && [endDate timeIntervalSinceDate:date] > delta / 12)
            string = [dateFormatter stringFromDate:date];
    }
        
    return string;
}

@end
