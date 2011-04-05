//
//  Nice.h
//  AAPLot
//
//  Created by admin on 3/24/11.
//  Copyright 2011 Crystalnix. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const double nice_intervals[];

double nice_ceil(double x);
double nice_floor(double x);
double nice_round(double x);

//NSArray *nice_ticks(double lo, double hi);
//NSArray *nice_ticks(double lo, double hi, NSUInteger ticks);

@interface Nice : NSObject {
    
}

+(NSArray*)niceTicksWithLo:(double)lo hi:(double)hi ticks:(NSUInteger)ticks inside:(BOOL)inside;

@end
