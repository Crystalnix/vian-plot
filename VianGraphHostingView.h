//
//  VianGraphHostingView.h
//  AAPLot
//
//  Created by admin on 3/30/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@class VianPlotAreaDescription;

@protocol VianGraphClickHandler
@optional

-(void)handleClick;

@end

@interface VianGraphHostingView : CPGraphHostingView <CPPlotSpaceDelegate, CPScatterPlotDataSource> {
    @private
    VianPlotAreaDescription *model;
    BOOL handleTouch;
    NSUInteger graphIndexForTouch;
    CPXYAxis *selectionAxis;
    CPScatterPlot *scatterPlotWithSymbol;
    NSUInteger selectedPointIndex;
    CGPoint prevTouchPt;
    id clickerDelegate;
}

@property(nonatomic,retain) VianPlotAreaDescription *model;
@property(nonatomic,assign) BOOL handleTouch;
@property(nonatomic,assign) NSUInteger graphIndexForTouch;
@property(nonatomic,assign) id clickerDelegate;

-(void)updateGraphDataFromCurrentModel;
-(void)updateGraphStylesFromCurrentModel;
-(CPXYGraph*)graph;
@end
