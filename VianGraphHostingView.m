//
//  VianGraphHostingView.m
//  AAPLot
//
//  Created by admin on 3/30/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import "VianGraphHostingView.h"
#import "PlotAreaDescription.h"
#import "Nice.h"
#import "MultiresDateFormatter.h"
#import "CPFillStripes.h"


@interface VianGraphHostingView ()

-(NSSet*)getXDateMajorTickLocations;
-(NSSet*)getXMajorTickLocations;
-(NSSet*)getYMajorTickLocations;

@end

@implementation VianGraphHostingView

@synthesize model, handleTouch, graphIndexForTouch, clickerDelegate;

-(void)myCommonInit
{
    CPXYGraph *graph = [[[CPXYGraph alloc] initWithFrame:CGRectZero] autorelease];
	CPTheme *theme = [CPTheme themeNamed:kCPStocksTheme];
	[graph applyTheme:theme];
	graph.frame = self.bounds;
    graph.defaultPlotSpace.delegate = self;
	//graph.paddingRight = 50.0f;
    //graph.paddingLeft = 50.0f;
    graph.plotAreaFrame.masksToBorder = YES;
    //graph.plotAreaFrame.cornerRadius = 0.0f;
    //CPMutableLineStyle *borderLineStyle = [CPMutableLineStyle lineStyle];
    //borderLineStyle.lineColor = [CPColor whiteColor];
    //borderLineStyle.lineWidth = 2.0f;
    //graph.plotAreaFrame.borderLineStyle = borderLineStyle;
	self.hostedGraph = graph;
    
    // Axes
    CPXYAxisSet *xyAxisSet = (id)graph.axisSet;
    CPXYAxis *xAxis = xyAxisSet.xAxis;
    CPMutableLineStyle *lineStyle = [xAxis.axisLineStyle mutableCopy];
    lineStyle.lineWidth = 1.5;
    lineStyle.lineColor = [CPColor colorWithComponentRed: 0.3 green: 0.3 blue: 0.8 alpha: 1.0];
    lineStyle.lineCap = kCGLineCapButt;
    xAxis.axisLineStyle = lineStyle;
    //	[lineStyle release];
    xAxis.labelingPolicy = CPAxisLabelingPolicyLocationsProvided;
    xAxis.minorTicksPerInterval = 0;
    //xAxis.labelingPolicy = CPAxisLabelingPolicyAutomatic;
    //    CPMutableLineStyle *gridLineStyle = [CPMutableLineStyle lineStyle];
    //    gridLineStyle.lineColor = [CPColor grayColor];
    //    gridLineStyle.lineWidth = 2.0f;
    xAxis.majorGridLineStyle = lineStyle;
    [lineStyle release];
    xAxis.majorTickLineStyle = nil;
    
    
    CPXYAxis *yAxis = xyAxisSet.yAxis;
    
    CPMutableLineStyle *lineStyleY = [yAxis.axisLineStyle mutableCopy];
    lineStyleY.lineWidth = 1;
    lineStyleY.lineColor = [CPColor colorWithComponentRed: 0.3 green: 0.3 blue: 0.8 alpha: 1.0];
    lineStyleY.lineCap = kCGLineCapButt;
    
    yAxis.axisLineStyle = nil;
	yAxis.labelingPolicy = CPAxisLabelingPolicyLocationsProvided;
    yAxis.labelAlignment = CPAlignmentTop;
    yAxis.majorGridLineStyle = lineStyleY;
    yAxis.majorTickLineStyle = nil;
    [lineStyleY release];
    
    // Add plot space for horizontal bar charts
    CPXYPlotSpace *secondaryPlotSpace = [[CPXYPlotSpace alloc] init];
	secondaryPlotSpace.identifier = @"Secondary Plot Space";
    [graph addPlotSpace:secondaryPlotSpace];
    [secondaryPlotSpace release];
}

-(id)initWithFrame:(CGRect)frame
{
    if ( (self = [super initWithFrame:frame]) ) {
		[self myCommonInit];
    }
    return self;
}

// On the iPhone, the init method is not called when loading from a XIB
-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self myCommonInit];
}

-(void)dealloc
{
    [model release];
    [super dealloc];
}

-(VianPlotAreaDescription*)model
{
    return model;
}

-(void)setModel:(VianPlotAreaDescription *)newModel
{
    if (model != newModel) {
        [newModel retain];
        [model release];
        model = newModel;
        
        NSAssert([model.plots count] != 0, @"No plots specified");
        CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
        [self updateGraphStylesFromCurrentModel];
        [self updateGraphDataFromCurrentModel];
        // TODO: the following call may be made in both previous calls instead
        [graph reloadData];
    }
}

-(CPXYGraph*)graph
{
    return (CPXYGraph*)self.hostedGraph;
}

-(void)setHandleTouch:(BOOL)isHandleTouch
{
    CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
    
    CPXYPlotSpace *mainPlotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    CPXYPlotSpace *secondaryPlotSpace = (CPXYPlotSpace *)[graph plotSpaceWithIdentifier:@"Secondary Plot Space"];
    
    handleTouch = isHandleTouch;
    mainPlotSpace.allowsUserInteraction = handleTouch;
}

-(void)updateGraphDataFromCurrentModel
{
    CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
    
    CPXYPlotSpace *mainPlotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    CPXYPlotSpace *secondaryPlotSpace = (CPXYPlotSpace *)[graph plotSpaceWithIdentifier:@"Secondary Plot Space"];
    
    CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
    
    NSDecimalNumber *high = model.mainPlotSpaceHigh;
    NSDecimalNumber *low = model.mainPlotSpaceLow;
    NSDecimalNumber *length = [high decimalNumberBySubtracting:low];
    
    const int lowerEmptySpaceHeight = 32;
    const int rightEmptySpaceWidth = 100;
    
    NSDecimalNumber *xRangeLength = [model.xAxisHigh decimalNumberBySubtracting:model.xAxisLow];
    
    NSDecimalNumber *xExtraSpacePercent = [[NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromInt(rightEmptySpaceWidth)] decimalNumberByDividingBy:
                                           [NSDecimalNumber decimalNumberWithDecimal:CPDecimalFromInt(graph.bounds.size.width)]];
    NSDecimalNumber *xExtraSpace = [xRangeLength decimalNumberByMultiplyingBy:xExtraSpacePercent];
    NSDecimalNumber *xRangeLengthFinal = [xRangeLength decimalNumberByAdding:xExtraSpace];
    
    NSDecimalNumber *mainSpaceDisplacementPercent = 
    [
     [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:lowerEmptySpaceHeight] decimalValue]] decimalNumberByDividingBy:
     [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:graph.bounds.size.height] decimalValue]]
     ];
    
    if (!model.hasSecondaryPlotSpace) {
        NSDecimalNumber *lengthDisplacementValue = [length decimalNumberByMultiplyingBy:mainSpaceDisplacementPercent];
        NSDecimalNumber *lowDisplayLocation = [low decimalNumberBySubtracting:lengthDisplacementValue];
        NSDecimalNumber *lengthDisplayLocation = [length decimalNumberByAdding:lengthDisplacementValue];
        
        mainPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:[model.xAxisLow decimalValue] length:[xRangeLengthFinal decimalValue]];
        mainPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:[lowDisplayLocation decimalValue] length:[lengthDisplayLocation decimalValue]];
        axisSet.xAxis.gridLinesRange = [CPPlotRange plotRangeWithLocation:[low decimalValue] length:[length decimalValue]];
        axisSet.xAxis.orthogonalCoordinateDecimal = [model.mainPlotSpaceLow decimalValue];
    }
    else {
        // TODO: implement with secondary plot space
        // *****************************************
        NSDecimalNumber *lengthDisplacementValue = [length decimalNumberByMultiplyingBy:model.secondaryPlotSpaceHeightPercent];
        NSDecimalNumber *lowDisplayLocation = [low decimalNumberBySubtracting:lengthDisplacementValue];
        NSDecimalNumber *lengthDisplayLocation = [length decimalNumberByAdding:lengthDisplacementValue];
        
        axisSet.xAxis.gridLinesRange = [CPPlotRange plotRangeWithLocation:[lowDisplayLocation decimalValue] length:[lengthDisplayLocation decimalValue]];
        axisSet.xAxis.orthogonalCoordinateDecimal = [lowDisplayLocation decimalValue];
        
        NSDecimalNumber *sumMainSpaceDisplacementPercent = [mainSpaceDisplacementPercent decimalNumberByAdding:model.secondaryPlotSpaceHeightPercent];
        
        lengthDisplacementValue = [length decimalNumberByMultiplyingBy:sumMainSpaceDisplacementPercent];
        lowDisplayLocation = [low decimalNumberBySubtracting:lengthDisplacementValue];
        lengthDisplayLocation = [length decimalNumberByAdding:lengthDisplacementValue];
               
        mainPlotSpace.xRange = [CPPlotRange plotRangeWithLocation:[model.xAxisLow decimalValue] length:[xRangeLengthFinal decimalValue]];
        mainPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:[lowDisplayLocation decimalValue] length:[lengthDisplayLocation decimalValue]];
        
        NSDecimalNumber *secondaryLow = model.secondaryPlotSpaceLow;
        NSDecimalNumber *secondaryHigh = model.secondaryPlotSpaceHigh;
        NSDecimalNumber *secondaryLength = [secondaryHigh decimalNumberBySubtracting:secondaryLow];

        NSDecimalNumber *secondaryMultiplier = [[NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:NO] decimalNumberByDividingBy:model.secondaryPlotSpaceHeightPercent];
        NSDecimalNumber *secondaryDisplayLength = [secondaryLength decimalNumberByMultiplyingBy:secondaryMultiplier];
        NSDecimalNumber *secondaryDisplacementValue = [secondaryDisplayLength decimalNumberByMultiplyingBy:mainSpaceDisplacementPercent];
        secondaryDisplayLength = [secondaryDisplayLength decimalNumberByAdding:secondaryDisplacementValue];
        NSDecimalNumber *secondaryDisplayLow = [secondaryLow decimalNumberBySubtracting:secondaryDisplacementValue];
        
        secondaryPlotSpace.xRange = mainPlotSpace.xRange;
        secondaryPlotSpace.yRange = [CPPlotRange plotRangeWithLocation:[secondaryDisplayLow decimalValue] length:[secondaryDisplayLength decimalValue]];
        
    }
    
    // Axes
    if ([model hasDateXAxis]) {
        MultiresDateFormatter *df = [[[MultiresDateFormatter alloc] initWithStartDate:model.lowDate 
                                                                              endDate:model.highDate] autorelease];
        df.indexConverter = model;
        
        axisSet.xAxis.labelFormatter = df;
    }
    
    if ([model hasDateXAxis])
        axisSet.xAxis.majorTickLocations = [self getXDateMajorTickLocations];
    else
        axisSet.xAxis.majorTickLocations = [self getXMajorTickLocations];
        
    axisSet.yAxis.majorTickLocations = [self getYMajorTickLocations];
    axisSet.yAxis.orthogonalCoordinateDecimal = [[model.xAxisLow decimalNumberByAdding:xRangeLengthFinal] decimalValue];
}

-(void)updateGraphStylesFromCurrentModel
{
    CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
    for (CPPlot *cpp in [graph allPlots]) {
        [graph removePlot:cpp];
    }
    
    scatterPlotWithSymbol = nil;
    
    CPXYPlotSpace *mainPlotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
    CPXYPlotSpace *secondaryPlotSpace = (CPXYPlotSpace *)[graph plotSpaceWithIdentifier:@"Secondary Plot Space"];
    
    for (VianPlot *plot in model.plots) {
        switch (plot.plotType) {
            case VianPlotTypeScatter: {
                CPMutableLineStyle *scatterLineStyle = [CPMutableLineStyle lineStyle];
                scatterLineStyle.lineColor = plot.lineColor;
                scatterLineStyle.lineWidth = 2.0f;
                
                CPScatterPlot *scatterPlot = [[[CPScatterPlot alloc] initWithFrame:graph.bounds] autorelease];
                scatterPlot.identifier = plot.identifier;
                scatterPlot.dataLineStyle = scatterLineStyle;
                scatterPlot.dataSource = model;
                
                if (scatterPlotWithSymbol == nil) {
                    scatterPlotWithSymbol = scatterPlot;
                    scatterPlot.dataSource = self;
                    
                    CPMutableTextStyle *ts = [[[CPMutableTextStyle alloc] init] autorelease];
                    ts.fontName = @"Arial";
                    ts.fontSize = 24;
                    ts.color = [CPColor whiteColor];
                    scatterPlot.labelTextStyle = ts;
                    scatterPlot.labelFormatter = [[[NSNumberFormatter alloc] init] autorelease];
                }
                
                if (plot.inMainPlotSpace)
                    [graph addPlot:scatterPlot];
                else
                    [graph addPlot:scatterPlot toPlotSpace:secondaryPlotSpace];
                
                if (plot.fillType == VianFillTypeStripes) {
                    CPColor *firstStripesColor = [CPColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.0];
                    CPColor *secondStripesColor = [CPColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
                    CPFill *areaStripesFill = [CPFill fillWithFirstColor:firstStripesColor secondColor:secondStripesColor stripeWidth:2];
                    scatterPlot.areaFill = areaStripesFill;
                }
                else if (plot.fillType == VianFillTypeGradient) {
                    CPColor *areaColor = [CPColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
                    CPGradient *areaGradient = [CPGradient gradientWithBeginningColor:areaColor endingColor:[CPColor clearColor]];
                    areaGradient.angle = -90.0f;
                    CPFill *areaGradientFill = [CPFill fillWithGradient:areaGradient];
                    scatterPlot.areaFill = areaGradientFill;
                }
                scatterPlot.areaBaseValue = plot.inMainPlotSpace ? [model.mainPlotSpaceLow decimalValue] : 
                [model.secondaryPlotSpaceLow decimalValue];
            }
                break;
                
            case VianPlotTypeBar: {
                CPBarPlot *volumePlot = [CPBarPlot tubularBarPlotWithColor:[CPColor blackColor] horizontalBars:NO];
                volumePlot.dataSource = model;
                
                CPMutableLineStyle *lineStyle = [volumePlot.lineStyle mutableCopy];
                lineStyle.lineColor = plot.lineColor;
                volumePlot.lineStyle = lineStyle;
                [lineStyle release];
                
                volumePlot.fill = nil; 
                volumePlot.barWidth = CPDecimalFromFloat(0.0f);
                volumePlot.identifier = plot.identifier;
                
                if (plot.inMainPlotSpace) {
                    volumePlot.baseValue = [model.mainPlotSpaceLow decimalValue];
                    [graph addPlot:volumePlot];
                } else {
                    volumePlot.baseValue = [model.secondaryPlotSpaceLow decimalValue];
                    [graph addPlot:volumePlot toPlotSpace:secondaryPlotSpace];
                }
            }
                break;
                
            case VianPlotTypeTradingRange: {
                CPMutableLineStyle *tradingRangeLineStyle = [CPMutableLineStyle lineStyle];
                tradingRangeLineStyle.lineColor = plot.lineColor;
                tradingRangeLineStyle.lineWidth = 1.0f;
                CPTradingRangePlot *ohlcPlot = [[[CPTradingRangePlot alloc] initWithFrame:graph.bounds] autorelease];
                ohlcPlot.identifier = plot.identifier;
                ohlcPlot.lineStyle = tradingRangeLineStyle;
                CPMutableTextStyle *whiteTextStyle = [CPMutableTextStyle textStyle];
                whiteTextStyle.color = [CPColor whiteColor];
                whiteTextStyle.fontSize = 8.0;
                ohlcPlot.labelTextStyle = whiteTextStyle;
                ohlcPlot.labelOffset = 5.0;
                ohlcPlot.stickLength = 2.0f;
                ohlcPlot.dataSource = model;
                ohlcPlot.plotStyle = CPTradingRangePlotStyleOHLC;
                if (plot.inMainPlotSpace)
                    [graph addPlot:ohlcPlot];
                else
                    [graph addPlot:ohlcPlot toPlotSpace:secondaryPlotSpace];
            }
                break;
        }
    }
}

//@end

#pragma mark -
#pragma mark Private Methods

//@implementation VianGraphHostingView ()

-(NSSet*)getXDateMajorTickLocations
{
    NSAssert(model != nil, @"Empty model");
    
    BOOL found = NO;
    VianPlot *plot;
    for (plot in model.plots) {
        if (plot.xAxis.isDateAxis) {
            found = YES;
            break;
        }
    }

    NSAssert(plot.xAxis.isDateAxis, @"Not a date axis");

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents;
    
    NSMutableArray *locations = [NSMutableArray arrayWithCapacity:20];
    NSDate *date;
    unsigned unitFlags;
    
    NSTimeInterval delta = [plot.xAxis.endDate timeIntervalSinceDate:plot.xAxis.startDate];
    
    date = [plot.xAxis.dates objectAtIndex:0];
    
    switch (plot.xAxis.dateResolution) {
        case VianDateResolutionDay:
            unitFlags = NSHourCalendarUnit;
            break;
        case VianDateResolutionWeek:
            unitFlags = NSDayCalendarUnit;
            break;
        case VianDateResolutionMonth:
            unitFlags = NSWeekCalendarUnit;
            break;
        case VianDateResolutionThreeMonths:
        case VianDateResolutionSixMonths:
        case VianDateResolutionYear:
        case VianDateResolutionTwoYears:
            unitFlags = NSMonthCalendarUnit;
            break;
    }
    
    dateComponents = [gregorian components:unitFlags fromDate:date];
    NSInteger prevValue;
    switch (plot.xAxis.dateResolution) {
        case VianDateResolutionDay:
            prevValue = [dateComponents hour];
            break;
        case VianDateResolutionWeek:
            prevValue = [dateComponents day];
            break;
        case VianDateResolutionMonth:
            prevValue = [dateComponents week];
            break;
        case VianDateResolutionThreeMonths:
        case VianDateResolutionSixMonths:
        case VianDateResolutionYear:
        case VianDateResolutionTwoYears:
            prevValue = [dateComponents month];
            break;
    }
    
    for (int i = 1; i < [plot.xAxis.dates count]; ++i) {
        date = [plot.xAxis.dates objectAtIndex:i];
        dateComponents = [gregorian components:unitFlags fromDate:date];
        
        NSInteger value;
        switch (plot.xAxis.dateResolution) {
            case VianDateResolutionDay:
                value = [dateComponents hour];
                break;
            case VianDateResolutionWeek:
                value = [dateComponents day];
                break;
            case VianDateResolutionMonth:
                value = [dateComponents week];
                break;
            case VianDateResolutionThreeMonths:
            case VianDateResolutionSixMonths:
            case VianDateResolutionYear:
            case VianDateResolutionTwoYears:
                value = [dateComponents month];
                break;
        }
        
        if (value != prevValue && (plot.xAxis.dateResolution != VianDateResolutionYear || (12 + value - prevValue) % 12 > 1) &&
            (plot.xAxis.dateResolution != VianDateResolutionTwoYears || (12 + value - prevValue) % 12 > 3)) {
            if ([date timeIntervalSinceDate:plot.xAxis.startDate] > delta / 12 &&
                [plot.xAxis.endDate timeIntervalSinceDate:date] > delta / 12)
                [locations addObject:[plot.xAxis.values objectAtIndex:i]];
            prevValue = value;
        }
    }
    
    
    [locations addObject:[plot.xAxis.values lastObject]];
    
    [gregorian release];
    
    return [NSSet setWithArray:locations];
}

-(NSSet*)getXMajorTickLocations
{
    NSArray *ticks = [Nice niceTicksWithLo:[model.xAxisLow doubleValue] hi:[model.xAxisHigh doubleValue] ticks:5 inside:YES];
    
    return [NSSet setWithArray:[ticks arrayByAddingObject:model.xAxisHigh]];
}

-(NSSet*)getYMajorTickLocations
{
    NSRange range;
    
    NSArray *ticks = [Nice niceTicksWithLo:[model.mainPlotSpaceLow doubleValue] hi:[model.mainPlotSpaceHigh doubleValue] ticks:5 inside:YES];
    
    double intLength = [model.mainPlotSpaceHigh doubleValue] - [model.mainPlotSpaceLow doubleValue];
    if ([[[ticks objectAtIndex:0] decimalNumberBySubtracting:model.mainPlotSpaceLow] doubleValue] < intLength / 20) {
        range.location = 1;
        range.length = [ticks count]-1;
        ticks = [ticks subarrayWithRange:range];
    }
    if ([[model.mainPlotSpaceHigh decimalNumberBySubtracting:[ticks lastObject]] doubleValue] < intLength / 20) {
        NSRange range;
        range.location = 0;
        range.length = [ticks count] - 1;
        ticks = [ticks subarrayWithRange:range];
    }
    
    return [NSSet setWithArray:[ticks arrayByAddingObjectsFromArray:
                                [NSArray arrayWithObjects: 
                                 model.mainPlotSpaceLow, model.mainPlotSpaceHigh, nil]]];
}

#pragma mark -
#pragma mark CPPlotSpaceDelegate methods

-(NSUInteger)selectedPointIndex:(NSDecimal)xCoord {
    if (scatterPlotWithSymbol != nil) {
        NSDecimalNumber *xCoordNum = [NSDecimalNumber decimalNumberWithDecimal:xCoord];
        VianPlot *plot = [model plotWithIdentifier:scatterPlotWithSymbol.identifier];
        for (NSDecimalNumber *num in plot.xAxis.values) {
            if ([num compare:xCoordNum] == NSOrderedDescending)
                return [plot.xAxis.values indexOfObject:num];
        }
        return [plot.xAxis.values count] - 1;
    }
        
    return 0;
}

-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point
{
    if (scatterPlotWithSymbol != nil) {
        CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
        
        CPXYPlotSpace *mainPlotSpace = (CPXYPlotSpace *)graph.defaultPlotSpace;
        CPXYPlotSpace *secondaryPlotSpace = (CPXYPlotSpace *)[graph plotSpaceWithIdentifier:@"Secondary Plot Space"];
        
        VianPlot *plot = [model plotWithIdentifier:(NSString*)scatterPlotWithSymbol.identifier];
        
        prevTouchPt = point;
        
        if (space == mainPlotSpace) {
        
            CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
            /*CPXYAxis * */selectionAxis = [[[CPXYAxis alloc] init] autorelease];
            selectionAxis.coordinate = CPCoordinateY;
            
            point.x -= 20;
            
            NSDecimal pt[2];
            [space plotPoint:pt forPlotAreaViewPoint:point];
            
            selectedPointIndex = [self selectedPointIndex:pt[0]];
            
            selectionAxis.orthogonalCoordinateDecimal = 
            [(NSDecimalNumber*)[plot.xAxis.values objectAtIndex:selectedPointIndex] decimalValue];
                        
            CPMutableLineStyle *ls = [axisSet.xAxis.axisLineStyle mutableCopy];
            ls.lineWidth = 3.0;
            ls.lineColor = [CPColor greenColor];
            selectionAxis.axisLineStyle = ls;
            selectionAxis.plotSpace = mainPlotSpace;
            selectionAxis.labelingPolicy = CPAxisLabelingPolicyNone;
            selectionAxis.visibleRange = axisSet.xAxis.gridLinesRange;
            
            axisSet.axes = [axisSet.axes arrayByAddingObject:selectionAxis];
            
            [axisSet relabelAxes];
            [scatterPlotWithSymbol reloadData];
        }
    }
    
    return NO;
}

-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)point
{
    if (scatterPlotWithSymbol != nil) {
        CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
        CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
        VianPlot *plot = [model plotWithIdentifier:(NSString*)scatterPlotWithSymbol.identifier];
        
        if (selectionAxis != nil) {
            point.x -= 20;
            
            NSDecimal pt[2];
            [space plotPoint:pt forPlotAreaViewPoint:point];
            
            selectedPointIndex = [self selectedPointIndex:pt[0]];
            
            selectionAxis.orthogonalCoordinateDecimal = 
                [(NSDecimalNumber*)[plot.xAxis.values objectAtIndex:selectedPointIndex] decimalValue];
            [axisSet relabelAxes];
            [scatterPlotWithSymbol reloadData];
        }
    }
    
    return NO;
}

-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(id)event
{
    if (scatterPlotWithSymbol != nil) {
        CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
        CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
        
        if ([axisSet.axes containsObject:selectionAxis]) {
            NSRange range;
            range.location = 0;
            range.length = 2;
            axisSet.axes = [axisSet.axes subarrayWithRange:range];
            selectionAxis = nil;
            [axisSet relabelAxes];
            [scatterPlotWithSymbol reloadData];
        }
    }
    
    return NO;
}


-(BOOL)plotSpace:(CPPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point
{
    if (clickerDelegate != nil) {
        double len = sqrt(pow(point.x - prevTouchPt.x, 2) + pow(point.y - prevTouchPt.y, 2));
        if (len < 10 && [clickerDelegate respondsToSelector:@selector(handleClick)]) {
            [clickerDelegate handleClick];            
        }
    }
    
    if (scatterPlotWithSymbol != nil) {
        CPXYGraph *graph = (CPXYGraph*)self.hostedGraph;
        CPXYAxisSet *axisSet = (CPXYAxisSet *)graph.axisSet;
        
        if ([axisSet.axes containsObject:selectionAxis]) {
            NSRange range;
            range.location = 0;
            range.length = 2;
            axisSet.axes = [axisSet.axes subarrayWithRange:range];
            selectionAxis = nil;
            [axisSet relabelAxes];
            [scatterPlotWithSymbol reloadData];
        }
    }
    
    return NO;
}

-(NSUInteger)numberOfRecordsForPlot:(CPPlot *)plot {
    return [model numberOfRecordsForPlot:plot];
}

-(NSNumber *)numberForPlot:(CPPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    return [model numberForPlot:plot field:fieldEnum recordIndex:index];
}

-(CPLayer *)dataLabelForPlot:(CPPlot *)plot recordIndex:(NSUInteger)index 
{
    if (scatterPlotWithSymbol == plot) {
        if (index == selectedPointIndex && selectionAxis != nil)
            return nil;
    }
    
    return [model dataLabelForPlot:plot recordIndex:index];
}

-(CPPlotSymbol *)symbolForScatterPlot:(CPScatterPlot *)plot recordIndex:(NSUInteger)index
{
    static CPPlotSymbol *sym = nil;
    if (sym == nil) {
        sym = [[CPPlotSymbol ellipsePlotSymbol] retain];
        CGSize size;
        size.width = 15;
        size.height = 15;
        sym.size = size;
        sym.lineStyle = nil;
        sym.fill = [CPFill fillWithColor:[CPColor greenColor]];
    }
    
    if (scatterPlotWithSymbol == plot) {
        if (index == selectedPointIndex && selectionAxis != nil)
            return sym;
    }
    
    return nil;
}

@end
