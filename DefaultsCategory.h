//
//  DefaultsCategory.h
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MRCoordinateRegion.h"

@interface NSUserDefaults(MRLocationSupport)

- (void)setCoordinateRegion:(MRCoordinateRegion*)mrcr forKey:(NSString*)k;

- (MRCoordinateRegion*)coordinateRegionForKey:(NSString*)k;

@end
