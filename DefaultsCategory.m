//
//  DefaultsCategory.m
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DefaultsCategory.h"


@implementation NSUserDefaults(MRLocationSupport)

- (void)setCoordinateRegion:(MRCoordinateRegion*)mrcr forKey:(NSString*)k
{
    NSData* theData=[NSKeyedArchiver archivedDataWithRootObject:mrcr];
    [self setObject:theData forKey:k];
}

- (MRCoordinateRegion*)coordinateRegionForKey:(NSString*)k
{
    MRCoordinateRegion* rgn=nil;
    NSData* theData = [self dataForKey:k];
    if (theData != nil)
        rgn = (MRCoordinateRegion*)[NSKeyedUnarchiver unarchiveObjectWithData:theData];
    return rgn;
}

@end