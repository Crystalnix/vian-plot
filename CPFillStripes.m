//
//  CPFillStripes.m
//  AAPLot
//
//  Created by admin on 4/4/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import "CPFillStripes.h"
#import "_CPFillStripes.h"


@implementation CPFill (Stripes)

-(id)initWithFirstColor:(CPColor *)_firstColor secondColor:(CPColor *)_secondColor stripeWidth:(NSUInteger)_stripeWidth
{
    [self release];
    
    self = [(_CPFillStripes *)[_CPFillStripes alloc] initWithFirstColor:_firstColor secondColor:_secondColor stripeWidth:_stripeWidth];
    
    return self;
}

+(CPFill *)fillWithFirstColor:(CPColor *)_firstColor secondColor:(CPColor *)_secondColor stripeWidth:(NSUInteger)_stripeWidth
{
    return [[(_CPFillStripes *)[_CPFillStripes alloc] initWithFirstColor:_firstColor secondColor:_secondColor stripeWidth:_stripeWidth] autorelease];
}

@end
