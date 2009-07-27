//
//  MRCoordinateRegion.m
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/24/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MRCoordinateRegion.h"


@implementation MRCoordinateRegion

@synthesize coordinateRegion = m_mKCoordinateRegion;

- (id)initWithLatitude:(double)latitude Longitude:(double)longitude LatitudeDelta:(double)latitudeDelta LongitudeDelta:(double)longitudeDelta
{
	self = [super init];
	if ( self != nil )
	{
		CLLocationCoordinate2D coord;
		coord.latitude = latitude;
		coord.longitude = longitude;
		m_mKCoordinateRegion = MKCoordinateRegionMake(coord, MKCoordinateSpanMake(latitudeDelta, longitudeDelta));
	}
	return self;
}


- (id)initWithLatitude:(double)latitude Longitude:(double)longitude LatitudinalDistance:(double)latitudinalDistance LongitudinalDistance:(double)longitudinalDistance
{
	self = [super init];
	if ( self != nil )
	{
		CLLocationCoordinate2D coord;
		coord.latitude = latitude;
		coord.longitude = longitude;
		m_mKCoordinateRegion = MKCoordinateRegionMakeWithDistance(coord, latitudinalDistance, longitudinalDistance);
	}
	return self;
}


- (id)initWithCoder:(NSCoder*)coder
{
	double latitude = [coder decodeDoubleForKey:@"latitude"];
	double longitude = [coder decodeDoubleForKey:@"longitude"];
	double latitudeDelta = [coder decodeDoubleForKey:@"latitudeDelta"];
	double longitudeDelta = [coder decodeDoubleForKey:@"longitudeDelta"];

    return [self initWithLatitude:latitude Longitude:longitude LatitudeDelta:latitudeDelta LongitudeDelta:longitudeDelta];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeDouble:m_mKCoordinateRegion.center.latitude forKey:@"latitude"];
    [coder encodeDouble:m_mKCoordinateRegion.center.longitude forKey:@"longitude"];
    [coder encodeDouble:m_mKCoordinateRegion.span.latitudeDelta forKey:@"latitudeDelta"];
    [coder encodeDouble:m_mKCoordinateRegion.span.longitudeDelta forKey:@"longitudeDelta"];
}

@end
