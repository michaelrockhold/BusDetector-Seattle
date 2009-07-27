//
//  MRCoordinateRegion.h
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKGeometry.h>

@interface MRCoordinateRegion : NSObject<NSCoding>
{
	MKCoordinateRegion m_mKCoordinateRegion;
}

- (id)initWithLatitude:(double)latitude Longitude:(double)longitude LatitudeDelta:(double)latitudeDelta LongitudeDelta:(double)longitudeDelta;
- (id)initWithLatitude:(double)latitude Longitude:(double)longitude LatitudinalDistance:(double)latitudinalDistance LongitudinalDistance:(double)longitudinalDistance;

- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)coder;

@property MKCoordinateRegion coordinateRegion;
@end
