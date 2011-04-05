
#import <Foundation/Foundation.h>

@interface NSDictionary (APFinancialData)

+(id)dictionaryWithCSVLine:(NSString*)csvLine useDates:(BOOL)useDates;

@end
