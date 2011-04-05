//
//  PlotAreaDescription.h
//  AAPLot
//
//  Created by admin on 3/28/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"
#import "MultiresDateFormatter.h"

typedef enum _VianDateResolution {
    VianDateResolutionDay = 0,
    VianDateResolutionWeek,
    VianDateResolutionMonth,
    VianDateResolutionThreeMonths,
    VianDateResolutionSixMonths,
    VianDateResolutionYear,
    VianDateResolutionTwoYears
} VianDateResolution;

typedef enum _VianPlotType {
    VianPlotTypeScatter = 0,
    VianPlotTypeTradingRange,
    VianPlotTypeBar
} VianPlotType;

typedef enum _VianFillType {
    VianFillTypeNone = 0,
    VianFillTypeGradient,
    VianFillTypeStripes
} VianFillType;

@class CPColor;

@interface VianEnums : NSObject {
}

+(NSArray*)dateResolutionStrings;
+(NSArray*)plotTypeStrings;
+(NSArray*)fillTypeStrings;

@end

@interface VianXAxis : NSObject {
    @private
    BOOL isDateAxis;
//    BOOL showGridLines;
//    BOOL showLabels;
    
    VianDateResolution dateResolution;
    NSDate *startDate;
    NSDate *endDate;

    NSDecimalNumber *start;
    NSDecimalNumber *end;
    
    NSArray *values;
    NSArray *dates;
}

@property(nonatomic,assign) BOOL isDateAxis;
//@property(nonatomic,assign) BOOL showGridLines;
//@property(nonatomic,assign) BOOL showLabels;
@property(nonatomic,assign) VianDateResolution dateResolution;
@property(nonatomic,retain) NSDate *startDate;
@property(nonatomic,retain) NSDate *endDate;
@property(nonatomic,retain) NSDecimalNumber *start;
@property(nonatomic,retain) NSDecimalNumber *end;
@property(nonatomic,retain) NSArray *values;
@property(nonatomic,retain) NSArray *dates;

-(id)initWithDictionary:(NSDictionary*)dict;
-(NSDictionary*)dictionaryRepresentation;
@end

@interface VianPlot: NSObject {
    @private
    NSString *identifier;
    
//    BOOL showYGridLines;
//    BOOL showYLabels;
    
    BOOL inMainPlotSpace;
    
    VianPlotType plotType;
    VianFillType fillType;
    CPColor *lineColor;
    
    NSDecimalNumber *low;
    NSDecimalNumber *high;
    
    NSArray *values;
    
    VianXAxis *xAxis;
}

@property(nonatomic,retain) NSString *identifier;
//@property(nonatomic,assign) BOOL showYGridLines;
//@property(nonatomic,assign) BOOL showYLabels;
@property(nonatomic,assign) BOOL inMainPlotSpace;
@property(nonatomic,assign) VianPlotType plotType;
@property(nonatomic,assign) VianFillType fillType;
@property(nonatomic,retain) CPColor* lineColor;
@property(nonatomic,retain) NSDecimalNumber *low;
@property(nonatomic,retain) NSDecimalNumber *high;
@property(nonatomic,retain) NSArray *values;
@property(nonatomic,retain) VianXAxis *xAxis;

-(id)initWithDictionary:(NSDictionary*)dict;
-(NSDictionary*)dictionaryRepresentation;

@end

@interface VianPlotAreaDescription : NSObject <CPPlotDataSource, MultiresDateFromIndexConverter> {
    @private
    NSArray *plots;
    
    BOOL hasSecondaryPlotSpace;
    NSDecimalNumber *secondaryPlotSpaceHeightPercent;
    
    // following properties are computable and do not appear in a dictionary representation
    NSDecimalNumber *mainPlotSpaceLow;
    NSDecimalNumber *mainPlotSpaceHigh;
    NSDecimalNumber *secondaryPlotSpaceLow;
    NSDecimalNumber *secondaryPlotSpaceHigh;
    
    NSDecimalNumber *xAxisLow;
    NSDecimalNumber *xAxisHigh;
    NSDate *lowDate;
    NSDate *highDate;
}

@property(nonatomic,retain) NSArray *plots;
@property(nonatomic,assign) BOOL hasSecondaryPlotSpace;
@property(nonatomic,retain) NSDecimalNumber *secondaryPlotSpaceHeightPercent;

@property(nonatomic,readonly,retain) NSDecimalNumber *mainPlotSpaceLow;
@property(nonatomic,readonly,retain) NSDecimalNumber *mainPlotSpaceHigh;
@property(nonatomic,readonly,retain) NSDecimalNumber *secondaryPlotSpaceLow;
@property(nonatomic,readonly,retain) NSDecimalNumber *secondaryPlotSpaceHigh;

@property(nonatomic,readonly,retain) NSDecimalNumber *xAxisLow;
@property(nonatomic,readonly,retain) NSDecimalNumber *xAxisHigh;

@property(nonatomic,readonly,retain) NSDate *lowDate;
@property(nonatomic,readonly,retain) NSDate *highDate;

-(id)initWithDictionary:(NSDictionary*)dict;
-(NSDictionary*)dictionaryRepresentation;

-(VianPlot*)plotWithIdentifier:(NSString*)identifier;
-(BOOL)hasDateXAxis;

@end
