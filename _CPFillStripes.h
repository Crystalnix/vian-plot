//
//  _CPFillStripes.h
//  CorePlot-CocoaTouch
//
//  Created by admin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CPFill.h"

@class CPGradient;

@interface _CPFillStripes : CPFill <NSCopying, NSCoding> {
    @private
    CPColor *firstColor;
    CPColor *secondColor;
    NSUInteger stripeWidth;
}

/// @name Initialization
/// @{
-(id)initWithFirstColor:(CPColor *)_firstColor secondColor:(CPColor *)_secondColor stripeWidth:(NSUInteger)_stripeWidth;
///	@}

/// @name Drawing
/// @{
-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext;
-(void)fillPathInContext:(CGContextRef)theContext;
///	@}

@end
