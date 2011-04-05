//
//  _CPFillStripes.m
//  CorePlot-CocoaTouch
//
//  Created by admin on 3/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "_CPFillStripes.h"
#import "_CPFillGradient.h"
#import "CPColor.h"

#include <math.h>

@interface _CPFillStripes(private)
-(void)drawStripesInRect:(CGRect)rect inContext:(CGContextRef)ctx;
@end

@implementation _CPFillStripes

#pragma mark -
#pragma mark init/dealloc

-(id)initWithFirstColor:(CPColor *)_firstColor secondColor:(CPColor *)_secondColor stripeWidth:(NSUInteger)_stripeWidth;
{
    if ( (self = [super init]) ) {
		firstColor = [_firstColor retain];
        secondColor = [_secondColor retain];
        stripeWidth = _stripeWidth;
	}
	return self;
}

-(void)dealloc
{
    [firstColor release];
	[secondColor release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing

-(void)drawStripesInRect:(CGRect)rect inContext:(CGContextRef)ctx
{
    
    //CGContextSetFillColorWithColor(ctx, firstColor.cgColor);
    //CGContextFillRect(ctx, rect);
    
    int nStripes = (int)ceil(rect.size.height / (2 * stripeWidth));
    CGFloat yCoordIncrement = rect.size.height / nStripes;
    
    const CGFloat* firstColorComps = CGColorGetComponents(firstColor.cgColor);
    const CGFloat* secondColorComps = CGColorGetComponents(secondColor.cgColor);
    CGFloat colorIncrement[4];
    CGFloat fillColor[4];
    
    colorIncrement[0] = (secondColorComps[0] - firstColorComps[0]) / nStripes;
    colorIncrement[1] = (secondColorComps[1] - firstColorComps[1]) / nStripes;
    colorIncrement[2] = (secondColorComps[2] - firstColorComps[2]) / nStripes;
    colorIncrement[3] = (secondColorComps[3] - firstColorComps[3]) / nStripes;
    
    memcpy(fillColor, firstColorComps, sizeof(CGFloat) * 4);
    
    CGFloat stripeY = rect.origin.y;
    for (int i = 0; i < nStripes; stripeY += yCoordIncrement, ++i) {
        CGRect stripeRect = CGRectMake(rect.origin.x, stripeY, rect.size.width, stripeWidth);
        
        CGContextSetFillColorWithColor(ctx, [CPColor colorWithComponentRed:fillColor[0] green:fillColor[1] blue:fillColor[2] alpha:fillColor[3]].cgColor);
        CGContextFillRect(ctx, stripeRect);
        
        fillColor[0] = fillColor[0] + colorIncrement[0];
        fillColor[1] = fillColor[1] + colorIncrement[1];
        fillColor[2] = fillColor[2] + colorIncrement[2];
        fillColor[3] = fillColor[3] + colorIncrement[3];
    }
}

-(void)fillRect:(CGRect)theRect inContext:(CGContextRef)theContext
{
    CGContextSaveGState(theContext);
	
    CGContextClipToRect(theContext, *(CGRect *)&theRect);
	
	// draw here
    [self drawStripesInRect:theRect inContext:theContext];
	
    CGContextRestoreGState(theContext);
}

-(void)fillPathInContext:(CGContextRef)theContext
{
    if ( !CGContextIsPathEmpty(theContext) ) {
		CGContextSaveGState(theContext);
		
		CGRect boxBounds = CGContextGetPathBoundingBox(theContext);
		CGContextClip(theContext);
		
        // draw here
        [self drawStripesInRect:boxBounds inContext:theContext];
        
		CGContextRestoreGState(theContext);
	}
}

#pragma mark -
#pragma mark NSCopying methods

-(id)copyWithZone:(NSZone *)zone
{
	_CPFillStripes *copy = [[[self class] allocWithZone:zone] init];
	copy->firstColor = [self->firstColor copyWithZone:zone];
    copy->secondColor = [self->secondColor copyWithZone:zone];
    copy->stripeWidth = self->stripeWidth;
    
	return copy;
}

#pragma mark -
#pragma mark NSCoding methods

-(Class)classForCoder
{
	return [CPFill class];
}

-(void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:firstColor forKey:@"firstColor"];
    [coder encodeObject:secondColor forKey:@"secondColor"];
    [coder encodeObject:[NSNumber numberWithUnsignedInteger:stripeWidth] forKey:@"stripeWidth"];
}

-(id)initWithCoder:(NSCoder *)coder
{
	if ( (self = [super init]) ) {
		firstColor = [[coder decodeObjectForKey:@"firstColor"] retain];
        secondColor = [[coder decodeObjectForKey:@"secondColor"] retain];
        stripeWidth = [[coder decodeObjectForKey:@"stripeWidth"] unsignedIntegerValue];
	}
	return self;
}


@end
