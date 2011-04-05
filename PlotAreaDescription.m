//
//  PlotAreaDescription.m
//  AAPLot
//
//  Created by admin on 3/28/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import "PlotAreaDescription.h"
#import "CorePlot-CocoaTouch.h"
#import "UIColor-Expanded.h"

@implementation VianEnums

+(NSArray*)dateResolutionStrings
{
    static NSArray *dateResolutionStringsArray = nil;
    if (dateResolutionStringsArray == nil) {
        dateResolutionStringsArray = [[NSArray arrayWithObjects:
                                      @"DateResolutionDay",
                                      @"DateResolutionWeek",
                                      @"DateResolutionMonth",
                                      @"DateResolutionThreeMonths", 
                                      @"DateResolutionSixMonths", 
                                      @"DateResolutionYear", 
                                      @"DateResolutionTwoYears", 
                                      nil] retain];
    }
    
    return dateResolutionStringsArray;
}

+(NSArray*)plotTypeStrings
{
    static NSArray *plotTypeStringsArray = nil;
    if (plotTypeStringsArray == nil) {
        plotTypeStringsArray = [[NSArray arrayWithObjects:
                                      @"PlotTypeScatter",
                                      @"PlotTypeTradingRange",
                                      @"PlotTypeBar",
                                      nil] retain];
    }
    
    return plotTypeStringsArray;
}

+(NSArray*)fillTypeStrings
{
    static NSArray *fillTypeStringsArray = nil;
    if (fillTypeStringsArray == nil) {
        fillTypeStringsArray = [[NSArray arrayWithObjects:
                                @"FillTypeNone",
                                @"FillTypeGradient",
                                @"FillTypeStripes",
                                nil] retain];
    }
    
    return fillTypeStringsArray;
}

@end

@implementation VianXAxis

@synthesize isDateAxis, /*showGridLines, showLabels,*/ dateResolution, startDate, endDate, start, end, values, dates;

-(id)initWithDictionary:(NSDictionary*)dict
{
    if ( (self = [super init]) ) {
        isDateAxis = [[dict objectForKey:@"isDateAxis"] boolValue];
        //showGridLines = [[dict objectForKey:@"showGridLines"] boolValue];
        //showLabels = [[dict objectForKey:@"showLabels"] boolValue];
        
        if (isDateAxis) {
            NSString *dateResolutionStr = (NSString*)[dict objectForKey:@"dateResolution"];
            dateResolution = [[VianEnums dateResolutionStrings] indexOfObject:dateResolutionStr];
        
            self.startDate = (NSDate*)[dict objectForKey:@"startDate"];
            self.endDate = (NSDate*)[dict objectForKey:@"endDate"];
        }
        
        NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *temp = (NSString*)[dict objectForKey:@"start"];
        self.start = [NSDecimalNumber decimalNumberWithString:temp locale:us];
        temp = (NSString*)[dict objectForKey:@"end"];
        self.end = [NSDecimalNumber decimalNumberWithString:temp locale:us];
        
        NSMutableArray *resValues = [NSMutableArray arrayWithCapacity:[[dict objectForKey:@"values"] count]];
        for (NSString *s in (NSArray*)[dict objectForKey:@"values"]) {
            NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:s locale:us];
            [resValues addObject:dn];
        }
        
        self.values = [NSArray arrayWithArray:resValues];
        
        if (isDateAxis) {
            self.dates = [dict objectForKey:@"dates"];
        }
        
        [us release];
    }
    
    return self;
}

-(void)dealloc
{
    [startDate release];
    [endDate release];
    [start release];
    [end release];
    [values release];
    [dates release];
    
    [super dealloc];
}

-(NSDictionary*)dictionaryRepresentation
{
    NSNumber *isDateAxisNum     = [NSNumber numberWithBool:isDateAxis];
    //NSNumber *showGridLinesNum  = [NSNumber numberWithBool:showGridLines];
    //NSNumber *showLabelsNum     = [NSNumber numberWithBool:showLabels];
    
    NSString *dateResolutionStr = @"";
    NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *startStr = @"";
    NSString *endStr = @"";
    
    if (isDateAxis) {
        dateResolutionStr = (NSString*)[[VianEnums dateResolutionStrings] objectAtIndex:dateResolution];
        
        startStr  = [start descriptionWithLocale:us];
        endStr    = [end descriptionWithLocale:us];
    }
    
    NSMutableArray *valuesRes = [NSMutableArray arrayWithCapacity:[values count]];
    for (NSDecimalNumber *dn in values) {
        [valuesRes addObject:[dn descriptionWithLocale:us]];
    }
    
    NSArray *datesRes = [NSArray array];
    if (isDateAxis) {
        datesRes = dates;
    }
    
    [us release];
    
    NSDictionary *res = [NSDictionary dictionaryWithObjectsAndKeys:
                         isDateAxisNum,         @"isDateAxis",
                         //showGridLinesNum,      @"showGridLines",
                         //showLabelsNum,         @"showLabels",
                         dateResolutionStr,     @"dateResolution",
                         startDate,             @"startDate",
                         endDate,               @"endDate",
                         startStr,              @"start",
                         endStr,                @"end",
                         [NSArray arrayWithArray:valuesRes], @"values",
                         datesRes,              @"dates",
                         nil];
    
    return res;    
}

@end

@implementation VianPlot

@synthesize identifier, /*showYGridLines, showYLabels,*/ inMainPlotSpace, plotType, fillType, lineColor, low, high, values, xAxis;

-(id)initWithDictionary:(NSDictionary*)dict
{
    if ( (self = [super init]) ) {
        identifier = (NSString*)[dict objectForKey:@"identifier"];
        
        //showYGridLines = [[dict objectForKey:@"showYGridLines"] boolValue];
        //showYLabels = [[dict objectForKey:@"showYLabels"] boolValue];
        inMainPlotSpace = [[dict objectForKey:@"inMainPlotSpace"] boolValue];
        
        NSString *plotTypeStr = (NSString*)[dict objectForKey:@"plotType"];
        plotType = [[VianEnums plotTypeStrings] indexOfObject:plotTypeStr];
        
        if (plotType == VianPlotTypeScatter) {
            NSString *fillTypeStr = (NSString*)[dict objectForKey:@"fillType"];
            fillType = [[VianEnums fillTypeStrings] indexOfObject:fillTypeStr];
        }
        
        NSString *lineColorStr = (NSString*)[dict objectForKey:@"lineColor"];
        self.lineColor = [CPColor colorWithCGColor:[[UIColor colorWithHexString:lineColorStr] CGColor]];
        
        NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        NSString *temp = (NSString*)[dict objectForKey:@"low"];
        self.low = [NSDecimalNumber decimalNumberWithString:temp locale:us];
        temp = (NSString*)[dict objectForKey:@"high"];
        self.high = [NSDecimalNumber decimalNumberWithString:temp locale:us];
        
        NSMutableArray *resValues = [NSMutableArray arrayWithCapacity:[[dict objectForKey:@"values"] count]];
        switch (plotType) {
            case VianPlotTypeScatter:
            case VianPlotTypeBar:
                for (NSString *s in (NSArray*)[dict objectForKey:@"values"]) {
                    NSDecimalNumber *dn = [NSDecimalNumber decimalNumberWithString:s locale:us];
                    [resValues addObject:dn];
                }
                break;
            case VianPlotTypeTradingRange:
                for (NSDictionary *d in (NSArray*)[dict objectForKey:@"values"]) {
                    [resValues addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSDecimalNumber decimalNumberWithString:[d objectForKey:@"close"] locale:us], @"close",
                                          [NSDecimalNumber decimalNumberWithString:[d objectForKey:@"high"] locale:us], @"high", 
                                          [NSDecimalNumber decimalNumberWithString:[d objectForKey:@"low"] locale:us], @"low", 
                                          [NSDecimalNumber decimalNumberWithString:[d objectForKey:@"open"] locale:us], @"open", 
                                          nil]];
                }
                break;
        }
        
        self.values = [NSArray arrayWithArray:resValues];
             
        self.xAxis = [[[VianXAxis alloc] initWithDictionary:[dict objectForKey:@"xAxis"]] autorelease];
        
        [us release];
    }
    
    return self;
}

-(void)dealloc
{
    [lineColor release];
    [low release];
    [high release];
    [values release];
    [xAxis release];
    
    [super dealloc];
}

-(NSDictionary*)dictionaryRepresentation
{
    //NSNumber *showYGridLinesNum  = [NSNumber numberWithBool:showYGridLines];
    //NSNumber *showYLabelsNum     = [NSNumber numberWithBool:showYLabels];
    NSNumber *inMainPlotSpaceNum = [NSNumber numberWithBool:inMainPlotSpace];
    
    NSString *plotTypeStr = (NSString*)[[VianEnums plotTypeStrings] objectAtIndex:plotType];
    NSString *fillTypeStr = @"";
    if (plotType == VianPlotTypeScatter)
        fillTypeStr = (NSString*)[[VianEnums fillTypeStrings] objectAtIndex:fillType];
    
    NSString *lineColorStr = [[UIColor colorWithCGColor:lineColor.cgColor] hexStringFromColor];
    
    NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *lowStr    = [low descriptionWithLocale:us];
    NSString *highStr   = [high descriptionWithLocale:us];
    
    NSMutableArray *valuesRes = [NSMutableArray arrayWithCapacity:[values count]];
    switch (plotType) {
        case VianPlotTypeScatter:
        case VianPlotTypeBar:
            for (NSDecimalNumber *dn in values) {
                [valuesRes addObject:[dn descriptionWithLocale:us]];
            }
            break;
        case VianPlotTypeTradingRange:
            for (NSDictionary *d in values) {
                [valuesRes addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [[d objectForKey:@"close"] descriptionWithLocale:us], @"close",
                                      [[d objectForKey:@"high"] descriptionWithLocale:us], @"high",
                                      [[d objectForKey:@"low"] descriptionWithLocale:us], @"low",
                                      [[d objectForKey:@"open"] descriptionWithLocale:us], @"open",
                                      nil
                                      ]
                 ];
            }
            break;
    }
    
        
    [us release];
    
    NSDictionary *res = [NSDictionary dictionaryWithObjectsAndKeys:
                         identifier,            @"identifier",
                         //showYGridLinesNum,     @"showYGridLines",
                         //showYLabelsNum,        @"showYLabels",
                         inMainPlotSpaceNum,    @"inMainPlotSpace",
                         plotTypeStr,           @"plotType",
                         fillTypeStr,           @"fillType",
                         lineColorStr,          @"lineColor",
                         lowStr,                @"low",
                         highStr,               @"high",
                         [NSArray arrayWithArray:valuesRes], @"values",
                         [xAxis dictionaryRepresentation], @"xAxis",
                         nil];
    
    return res;    
}

@end

@implementation VianPlotAreaDescription

@synthesize hasSecondaryPlotSpace, secondaryPlotSpaceHeightPercent, mainPlotSpaceLow, mainPlotSpaceHigh, secondaryPlotSpaceLow, secondaryPlotSpaceHigh, xAxisLow, xAxisHigh, lowDate, highDate;

@dynamic plots;

-(id)initWithDictionary:(NSDictionary *)dict
{
    if ( (self = [super init]) ) {
        NSMutableArray *plotsData = [NSMutableArray arrayWithCapacity:[[dict objectForKey:@"plots"] count]];
        for (NSDictionary *d in (NSArray*)[dict objectForKey:@"plots"]) {
            [plotsData addObject:[[[VianPlot alloc] initWithDictionary:d] autorelease]];
        }
        
        self.plots = [NSArray arrayWithArray:plotsData];

        hasSecondaryPlotSpace = [[dict objectForKey:@"hasSecondaryPlotSpace"] boolValue];

        if (hasSecondaryPlotSpace) {
            NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            NSString *temp = (NSString*)[dict objectForKey:@"secondaryPlotSpaceHeightPercent"];
            self.secondaryPlotSpaceHeightPercent = [NSDecimalNumber decimalNumberWithString:temp locale:us];
            [us release];
        }
    }
    
    return self;
}

-(void)dealloc
{
    [plots release];
    
    [secondaryPlotSpaceHeightPercent release];
    
    [mainPlotSpaceLow release];
    [mainPlotSpaceHigh release];
    [secondaryPlotSpaceLow release];
    [secondaryPlotSpaceHigh release];
    
    [xAxisLow release];
    [xAxisHigh release];
    
    [lowDate release];
    [highDate release];
    
    [super dealloc];
}

-(NSDictionary*)dictionaryRepresentation
{
    NSMutableArray *plotsData = [NSMutableArray arrayWithCapacity:[plots count]];
    for (VianPlot *p in plots) {
        [plotsData addObject:[p dictionaryRepresentation]];
    }
    
    NSNumber *hasSecondaryPlotSpaceNum  = [NSNumber numberWithBool:hasSecondaryPlotSpace];
    
    NSString *secondaryPlotSpaceHeightPercentStr = @"";
    if (hasSecondaryPlotSpace) {
        NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        secondaryPlotSpaceHeightPercentStr = [secondaryPlotSpaceHeightPercent descriptionWithLocale:us];
        [us release];
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [NSArray arrayWithArray:plotsData], @"plots",
            hasSecondaryPlotSpaceNum, @"hasSecondaryPlotSpace",
            secondaryPlotSpaceHeightPercentStr, @"secondaryPlotSpaceHeightPercent",
            nil];
}

-(VianPlot*)plotWithIdentifier:(NSString*)identifier
{
    NSAssert((plots != nil) && ([plots count] != 0), @"Plots data is empty");
    for (VianPlot* p in plots) {
        if ([p.identifier isEqualToString:identifier])
            return p;
    }
    
    NSAssert(NO, @"Unknown plot identifier");
    return nil;
}

-(BOOL)hasDateXAxis
{
    for (VianPlot *p in plots) {
        if (p.xAxis.isDateAxis)
            return YES;
    }
    return NO;
}

-(NSArray*)plots
{
    return plots;
}

-(void)setPlots:(NSArray*)newPlots
{
    if (plots != newPlots) {
        [newPlots retain];
        [plots release];
        plots = newPlots;
        
        [mainPlotSpaceLow release];
        [mainPlotSpaceHigh release];
        [secondaryPlotSpaceLow release];
        [secondaryPlotSpaceHigh release];
        [xAxisLow release];
        [xAxisHigh release];
        [lowDate release];
        [highDate release];
        
        mainPlotSpaceLow = [NSDecimalNumber notANumber];
        mainPlotSpaceHigh = [NSDecimalNumber notANumber];
        secondaryPlotSpaceLow = [NSDecimalNumber notANumber];
        secondaryPlotSpaceHigh = [NSDecimalNumber notANumber];
        xAxisLow = [NSDecimalNumber notANumber];
        xAxisHigh = [NSDecimalNumber notANumber];
        
        lowDate = nil;
        highDate = nil;
        
        for (VianPlot* p in plots) {
            if ([xAxisLow isEqual:[NSDecimalNumber notANumber]]) {
                xAxisLow = p.xAxis.start;
                if (p.xAxis.isDateAxis) {
                    lowDate = [(NSDate*)[p.xAxis.dates objectAtIndex:0] retain];
                }

            }
            if ([xAxisHigh isEqual:[NSDecimalNumber notANumber]]) {
                xAxisHigh = p.xAxis.end;
                if (p.xAxis.isDateAxis) {
                    highDate = [(NSDate*)[p.xAxis.dates lastObject] retain];
                }

            }
            
            if ([p.xAxis.start compare:xAxisLow] == NSOrderedAscending) {
                xAxisLow = p.xAxis.start;
                if (p.xAxis.isDateAxis) {
                    [lowDate release];
                    lowDate = [(NSDate*)[p.xAxis.dates objectAtIndex:0] retain];
                }
            }
            
            if ([p.xAxis.end compare:xAxisHigh] == NSOrderedDescending) {
                xAxisHigh = p.xAxis.end;
                if (p.xAxis.isDateAxis) {
                    [highDate release];
                    highDate = [(NSDate*)[p.xAxis.dates lastObject] retain];
                }
            }
                        
            if (p.inMainPlotSpace) {
                if ( [mainPlotSpaceLow isEqual:[NSDecimalNumber notANumber]] ) {
                    mainPlotSpaceLow = p.low;
                }
                if ( [mainPlotSpaceHigh isEqual:[NSDecimalNumber notANumber]] ) {
                    mainPlotSpaceHigh = p.high;
                }
                
                if ([p.low compare:mainPlotSpaceLow] == NSOrderedAscending)
                    mainPlotSpaceLow = p.low;
                if ([p.high compare:mainPlotSpaceHigh] == NSOrderedDescending)
                    mainPlotSpaceHigh = p.high;
            } 
            else {
                if ( [secondaryPlotSpaceLow isEqual:[NSDecimalNumber notANumber]] ) {
                    secondaryPlotSpaceLow = p.low;
                }
                if ( [secondaryPlotSpaceHigh isEqual:[NSDecimalNumber notANumber]] ) {
                    secondaryPlotSpaceHigh = p.high;
                }

                
                if ([p.low compare:secondaryPlotSpaceLow] == NSOrderedAscending)
                    secondaryPlotSpaceLow = p.low;
                if ([p.high compare:secondaryPlotSpaceHigh] == NSOrderedDescending)
                    secondaryPlotSpaceHigh = p.high;
            }
        }
        
        [mainPlotSpaceLow retain];
        [mainPlotSpaceHigh retain];
        [secondaryPlotSpaceLow retain];
        [secondaryPlotSpaceHigh retain];
        [xAxisLow retain];
        [xAxisHigh retain];
    }
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    VianPlot *p = [self plotWithIdentifier:(NSString*)plot.identifier];
    NSAssert([p.values count] == [p.xAxis.values count], @"Plot data inconsistency");
    return [p.values count];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSDecimalNumber *num = [NSDecimalNumber zero];
    
    VianPlot *srcPlot = [self plotWithIdentifier:(NSString*)plot.identifier];
    switch (srcPlot.plotType) {
        case VianPlotTypeScatter:
            if (fieldEnum == CPScatterPlotFieldX) {
                num = [srcPlot.xAxis.values objectAtIndex:index];
            } 
            else if (fieldEnum == CPScatterPlotFieldY) {
                num = [srcPlot.values objectAtIndex:index];
            }
            break;
        case VianPlotTypeBar:
            if (fieldEnum == CPBarPlotFieldBarLocation) {
                num = [srcPlot.xAxis.values objectAtIndex:index];
            }
            else if (fieldEnum == CPBarPlotFieldBarTip) {
                num = [srcPlot.values objectAtIndex:index];
            }
            break;
        case VianPlotTypeTradingRange: {
            NSDictionary *fData = (NSDictionary*)[srcPlot.values objectAtIndex:index];
            
            switch (fieldEnum) {
                case CPTradingRangePlotFieldX:
                    num = [srcPlot.xAxis.values objectAtIndex:index];
                    break;
                case CPTradingRangePlotFieldClose:
                    num = [fData objectForKey:@"close"];
                    break;
                case CPTradingRangePlotFieldHigh:
                    num = [fData objectForKey:@"high"];
                    break;            
                case CPTradingRangePlotFieldLow:
                    num = [fData objectForKey:@"low"];
                    break;
                case CPTradingRangePlotFieldOpen:
                    num = [fData objectForKey:@"open"];
                    break;
            }
            break;
        }
    }
    
    NSAssert(num != nil, @"Data inconsistency detected");
    return num;
}

-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index 
{
    return (id)[NSNull null];
}

#pragma mark -
#pragma mark MultiresDateFormatter fromIndex delegate method
- (NSDate*)dateFromIndex:(NSDecimalNumber *)indexValue
{
    int index;
    VianPlot *plot;
    for (VianPlot *p in plots) {
        if (p.xAxis.isDateAxis) {
            index = [p.xAxis.values indexOfObject:indexValue];
            if (index != NSNotFound) {
                plot = p;
                break;
            }
        }
    }
    
//    NSAssert(plot.xAxis.isDateAxis, @"Invalid call for -dateFromIndex:");
//    NSAssert([plot.xAxis.values count] == [plot.xAxis.dates count], @"X axis dates array inconsistency");
    
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    
    if (index != NSNotFound)
        date = [plot.xAxis.dates objectAtIndex:index];
    
    return date;
}


@end
