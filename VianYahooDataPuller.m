//
//  VianYahooDataPuller.m
//  AAPLot
//
//  Created by admin on 3/31/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import "VianYahooDataPuller.h"
#import "APFinancialData.h"
#import "NSDateFormatterExtensions.h"

@interface VianYahooDataPuller ()

@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, readwrite, retain) NSArray *financialData;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, copy) NSString *csvString;
@property (nonatomic, retain) NSDecimalNumber *closeMin;
@property (nonatomic, retain) NSDecimalNumber *closeMax;
@property (nonatomic, retain) NSDecimalNumber *highMin;
@property (nonatomic, retain) NSDecimalNumber *highMax;
@property (nonatomic, retain) NSDecimalNumber *lowMin;
@property (nonatomic, retain) NSDecimalNumber *lowMax;
@property (nonatomic, retain) NSDecimalNumber *openMin;
@property (nonatomic, retain) NSDecimalNumber *openMax;
@property (nonatomic, retain) NSDecimalNumber *volumeMin;
@property (nonatomic, retain) NSDecimalNumber *volumeMax;

-(void)fetch;
-(NSString *)URL;
-(void)notifyPulledData;
-(void)parseCSVAndPopulate;
@end

@implementation VianYahooDataPuller

@synthesize startDate, endDate, financialData, receivedData, connection, csvString, closeMax, closeMin, highMax, highMin, lowMax, lowMin, openMax, openMin, volumeMax, volumeMin;

-(id)delegate 
{
    return delegate;
}

-(void)setDelegate:(id)aDelegate
{
    if(delegate != aDelegate)
    {
        delegate = aDelegate;
        if([financialData count] > 0)
            [self notifyPulledData]; //loads cached data onto UI
    }
}

-(id)initWithTargetSymbol:(NSString *)aSymbol dateResolution:(VianDateResolution)dateRes
{
    if ( (self = [super init]) ) {
        symbol = [aSymbol copy];
        dateResolution = dateRes;
        
        [self performSelector:@selector(fetch) withObject:nil afterDelay:0.01];
    }
    
    return self;
}

-(void)dealloc
{
    [symbol release];
    [financialData release];
    [csvString release];
    
    [closeMin release];
    [closeMax release];
    [lowMax release];
    [lowMin release];
    [highMax release];
    [highMin release];
    [openMax release];
    [openMin release];
    [volumeMax release];
    [volumeMin release];
    
    [super dealloc];
}

-(NSString *)URL;
{
    NSString *resolutionStr = @"";
    switch (dateResolution) {
        case VianDateResolutionDay:
            resolutionStr = @"1d";
            break;
        case VianDateResolutionWeek:
            resolutionStr = @"7d";
            break;
        case VianDateResolutionMonth:
            resolutionStr = @"1m";
            break;
        case VianDateResolutionThreeMonths:
            resolutionStr = @"3m";
            break;
        case VianDateResolutionSixMonths:
            resolutionStr = @"6m";
            break;
        case VianDateResolutionYear:
            resolutionStr = @"1y";
            break;
        case VianDateResolutionTwoYears:
            resolutionStr = @"2y";
            break;
    }
    
    NSString *url = [NSString stringWithFormat:@"http://chartapi.finance.yahoo.com/instrument/1.0/%@/chartdata;type=quote;range=%@/csv/", symbol, resolutionStr];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return url;
}

-(void)notifyPulledData
{
    if (delegate && [delegate respondsToSelector:@selector(dataPullerDidFinishFetch:)]) {
        [delegate performSelector:@selector(dataPullerDidFinishFetch:) withObject:self];
    }
}

#pragma mark -
#pragma mark Downloading of data

-(BOOL)shouldDownload
{    
    BOOL shouldDownload = YES; 
    return shouldDownload;
}

-(void)fetch
{
    if ( loadingData ) return;
    
    if ([self shouldDownload])
    {                
        loadingData = YES;
        NSString *urlString = [self URL];
        NSLog(@"URL = %@", urlString);
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
        
        // create the connection with the request
        // and start loading the data
        self.connection = [NSURLConnection connectionWithRequest:theRequest delegate:self];
        if (self.connection) {
            self.receivedData = [NSMutableData data];
        } 
		else {
            //TODO: Inform the user that the download could not be started
            loadingData = NO;
        }
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // append the new data to the receivedData
    [self.receivedData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [self.receivedData setLength:0];
}

-(void)cancelDownload
{
    if (loadingData) {
        [self.connection cancel];
        loadingData = NO;
        
        self.receivedData = nil;
        self.connection = nil;
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    loadingData = NO;
    self.receivedData = nil;
    self.connection = nil;
    NSLog(@"err = %@", [error localizedDescription]);
    //TODO:report err
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    loadingData = NO;
	self.connection = nil;    
	
	NSString *csv = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
    self.csvString = csv;
    [csv release];
	
    self.receivedData = nil;
    [self parseCSVAndPopulate];
}

-(void)parseCSVAndPopulate;
{
    NSArray *csvLines = [self.csvString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    NSString *line = nil;
    
    NSLocale *us = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    BOOL useDates = YES;
    NSUInteger i = 0;
    for (;;++i) {
        line = (NSString *)[csvLines objectAtIndex:i];
        NSArray *lineData = [line componentsSeparatedByString:@":"];
        NSString *paramName = (NSString*)[lineData objectAtIndex:0];
        NSArray *values = [(NSString*)[lineData objectAtIndex:1] componentsSeparatedByString:@","];
        if ([paramName isEqualToString:@"Timestamp"]) {
            useDates = NO;
        } 
        else if ([paramName isEqualToString:@"close"]) {
            self.closeMin = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:0] locale:us];
            self.closeMax = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:1] locale:us];
        }
        else if ([paramName isEqualToString:@"high"]) {
            self.highMin = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:0] locale:us];
            self.highMax = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:1] locale:us];
        }
        else if ([paramName isEqualToString:@"low"]) {
            self.lowMin = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:0] locale:us];
            self.lowMax = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:1] locale:us];
        }
        else if ([paramName isEqualToString:@"open"]) {
            self.openMin = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:0] locale:us];
            self.openMax = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:1] locale:us];
        }
        else if ([paramName isEqualToString:@"volume"]) {
            self.volumeMin = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:0] locale:us];
            self.volumeMax = [NSDecimalNumber decimalNumberWithString:[values objectAtIndex:1] locale:us];
            break;
        }
    }
	
    [us release];
    
    i++;
    NSMutableArray *newFinancials = [NSMutableArray arrayWithCapacity:[csvLines count]-i];
    NSDictionary *currentFinancial = nil;
    for (; i < [csvLines count]-1; i++) {
        line = (NSString *)[csvLines objectAtIndex:i];
        currentFinancial = [NSDictionary dictionaryWithCSVLine:line useDates:useDates];
        [newFinancials addObject:currentFinancial];
    }
    self.startDate = [(NSDictionary*)[newFinancials objectAtIndex:0] objectForKey:@"date"];
    self.endDate = [(NSDictionary*)[newFinancials lastObject] objectForKey:@"date"];
    
    [self setFinancialData:[NSArray arrayWithArray:newFinancials]];
    [self notifyPulledData];
}

-(VianPlotAreaDescription*)modelForData
{
    NSAssert([financialData count] > 0, @"No data for model creation");
    
    VianXAxis *xAxis = [[[VianXAxis alloc] init] autorelease];
    xAxis.isDateAxis = YES;
    //xAxis.showGridLines = YES;
    //xAxis.showLabels = YES;
    
    xAxis.dateResolution = dateResolution;
    xAxis.startDate = startDate;
    xAxis.endDate = endDate;
    
    xAxis.start = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:1.0] decimalValue]];
    xAxis.end = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:[financialData count]] decimalValue]];
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[financialData count]];
    for (NSUInteger i = 1; i <= [financialData count]; ++i)
        [values addObject:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:i] decimalValue]]];
    NSMutableArray *dates = [NSMutableArray arrayWithCapacity:[financialData count]];
    NSMutableArray *closePlotValues = [NSMutableArray arrayWithCapacity:[financialData count]];
    NSMutableArray *volumePlotValues = [NSMutableArray arrayWithCapacity:[financialData count]];
    NSMutableArray *ohlcPlotValues = [NSMutableArray arrayWithCapacity:[financialData count]];
    for (NSDictionary *d in financialData) {
        [dates addObject:[d objectForKey:@"date"]]; 
        [closePlotValues addObject:[d objectForKey:@"close"]];
        [volumePlotValues addObject:[d objectForKey:@"volume"]];
        [ohlcPlotValues addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [d objectForKey:@"close"], @"close", 
                                   [d objectForKey:@"high"], @"high", 
                                   [d objectForKey:@"low"], @"low", 
                                   [d objectForKey:@"open"], @"open", 
                                   nil]];
    }
    
    xAxis.values = [NSArray arrayWithArray:values];
    xAxis.dates = [NSArray arrayWithArray:dates];
    
    VianPlot *closePlot = [[[VianPlot alloc] init] autorelease];
    closePlot.identifier = @"Close Plot";
    //closePlot.showYGridLines = YES;
    //closePlot.showYLabels = YES;
    closePlot.inMainPlotSpace = YES;
    closePlot.plotType = VianPlotTypeScatter;
    closePlot.fillType = VianFillTypeStripes;
    closePlot.lineColor = [CPColor whiteColor];
    closePlot.low = closeMin;
    closePlot.high = closeMax;
    closePlot.values = [NSArray arrayWithArray:closePlotValues];
    closePlot.xAxis = xAxis;
    
    VianPlot *volumePlot = [[[VianPlot alloc] init] autorelease];
    volumePlot.identifier = @"Volume Plot";
    //volumePlot.showYGridLines = YES;
    //volumePlot.showYLabels = YES;
    volumePlot.inMainPlotSpace = NO;
    volumePlot.plotType = VianPlotTypeBar;
    volumePlot.fillType = VianFillTypeNone;
    volumePlot.lineColor = [CPColor whiteColor];
    volumePlot.low = volumeMin;
    volumePlot.high = volumeMax;
    volumePlot.values = [NSArray arrayWithArray:volumePlotValues];
    volumePlot.xAxis = xAxis;
    
    VianPlot *ohlcPlot = [[[VianPlot alloc] init] autorelease];
    ohlcPlot.identifier = @"OHLC Plot";
    //ohlcPlot.showYGridLines = YES;
    //ohlcPlot.showYLabels = YES;
    ohlcPlot.inMainPlotSpace = YES;
    ohlcPlot.plotType = VianPlotTypeTradingRange;
    ohlcPlot.fillType = VianFillTypeNone;
    ohlcPlot.lineColor = [CPColor redColor];
    ohlcPlot.low = lowMin;
    ohlcPlot.high = highMax;
    ohlcPlot.values = [NSArray arrayWithArray:ohlcPlotValues];
    ohlcPlot.xAxis = xAxis;
    
    VianPlotAreaDescription *vpad = [[[VianPlotAreaDescription alloc] init] autorelease];
    vpad.plots = [NSArray arrayWithObjects:closePlot, volumePlot, ohlcPlot, nil];
    vpad.hasSecondaryPlotSpace = YES;
    vpad.secondaryPlotSpaceHeightPercent = [NSDecimalNumber decimalNumberWithMantissa:16 exponent:-2 isNegative:NO];
    
    return vpad;
}
@end
