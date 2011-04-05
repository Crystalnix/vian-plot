
#import "APFinancialData.h"
#import "NSDateFormatterExtensions.h"

@implementation NSDictionary (APFinancialData)  


+(id)dictionaryWithCSVLine:(NSString*)csvLine useDates:(BOOL)useDates
{
    NSArray *csvChunks = [csvLine componentsSeparatedByString:@","];
    
    NSMutableDictionary *csvDict = [NSMutableDictionary dictionaryWithCapacity:6];
    static NSNumberFormatter *nf = nil;
    if (nf == nil) {
        nf = [[NSNumberFormatter alloc] init];
    }
    
	// Date/timestamp,Open,High,Low,Close,Volume
    // 20090608/1301491858,143.82,144.23,139.43,143.85
    NSDate *theDate;
    if (useDates)
        theDate = [[NSDateFormatter csvDateFormatter] dateFromString:(NSString *)[csvChunks objectAtIndex:0]];
    else {  // timestamp value
        NSNumber *seconds = [nf numberFromString:(NSString *)[csvChunks objectAtIndex:0]];
        theDate = [NSDate dateWithTimeIntervalSince1970:[seconds doubleValue]];
    }
    
    [csvDict setObject:theDate forKey:@"date"];
    NSDecimalNumber *theOpen = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:1]];
    [csvDict setObject:theOpen forKey:@"close"];
    NSDecimalNumber *theHigh = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:2]];
    [csvDict setObject:theHigh forKey:@"high"];
    NSDecimalNumber *theLow = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:3]];
    [csvDict setObject:theLow forKey:@"low"];    
    NSDecimalNumber *theClose = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:4]];
    [csvDict setObject:theClose forKey:@"open"];
    NSDecimalNumber *theVolume = [NSDecimalNumber decimalNumberWithString:(NSString *)[csvChunks objectAtIndex:5]];
    [csvDict setObject:theVolume forKey:@"volume"];
    
    //non-mutable autoreleased dict
    return [NSDictionary dictionaryWithDictionary:csvDict];
}

@end
