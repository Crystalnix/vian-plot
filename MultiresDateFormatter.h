//
//  MultiresDateFormatter.h
//  AAPLot
//
//  Created by admin on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _MultiresDateResolution {
    MultiresDateResolutionHours,
    MultiresDateResolutionDays,
    MultiresDateResolutionMonths,
} MultiresDateResolution;

@protocol MultiresDateFromIndexConverter
@optional
- (NSDate*)dateFromIndex:(NSDecimalNumber *)index;
@end

@interface MultiresDateFormatter : NSNumberFormatter {
    @private
    NSDate *startDate;
    NSDate *endDate;
    NSUInteger numIndices;
    MultiresDateResolution resolution;
    NSDateFormatter *dateFormatter;
    
    id <MultiresDateFromIndexConverter> indexConverter;
}

@property (nonatomic,readwrite,assign) id <MultiresDateFromIndexConverter> indexConverter;

- (id)initWithStartDate:(NSDate*)aStartDate endDate:(NSDate*)aEndDate /*numIndices:(NSUInteger)aNumIndices*/;

@end
