//
//  CPFillStripes.h
//  AAPLot
//
//  Created by admin on 4/4/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot-CocoaTouch.h"

@interface CPFill(Stripes)

+(CPFill *)fillWithFirstColor:(CPColor *)_firstColor secondColor:(CPColor *)_secondColor stripeWidth:(NSUInteger)_stripeWidth;

-(id)initWithFirstColor:(CPColor *)_firstColor secondColor:(CPColor *)_secondColor stripeWidth:(NSUInteger)_stripeWidth;

@end
