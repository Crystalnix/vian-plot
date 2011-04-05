//
//  VianYahooDataPuller.h
//  AAPLot
//
//  Created by admin on 3/31/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlotAreaDescription.h"

@class VianYahooDataPuller;

@protocol VianYahooDataPullerDelegate

@optional

-(void)dataPullerDidFinishFetch:(VianYahooDataPuller *)dp;

@end

@interface VianYahooDataPuller : NSObject {
    @private
    NSString *symbol;
    VianDateResolution dateResolution;
    
    NSArray *financialData;
    
    NSDate *startDate;
    NSDate *endDate;
    
    NSDecimalNumber *closeMin;
    NSDecimalNumber *closeMax;
    NSDecimalNumber *highMin;
    NSDecimalNumber *highMax;
    NSDecimalNumber *lowMin;
    NSDecimalNumber *lowMax;
    NSDecimalNumber *openMin;
    NSDecimalNumber *openMax;
    NSDecimalNumber *volumeMin;
    NSDecimalNumber *volumeMax;
    
    id delegate;
    
    BOOL loadingData;
    NSString *csvString;
    NSMutableData *receivedData;
    NSURLConnection *connection;
}

@property(nonatomic,assign) id delegate;

-(id)initWithTargetSymbol:(NSString *)aSymbol dateResolution:(VianDateResolution)dateRes;
-(VianPlotAreaDescription*)modelForData;
@end
