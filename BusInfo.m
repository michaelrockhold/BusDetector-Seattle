//
//  BusInfo.m
//  BusGnosis
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import "BusInfo.h"

NSString* compassHeadings[] = 
{
	@"North",
	@"NNE",
	@"NE",
	@"ENE",
	@"East",
	@"ESE",
	@"SE",
	@"SSE",
	@"South",
	@"SSW",
	@"SW",
	@"WSW",
	@"West",
	@"WNW",
	@"NW",
	@"NNW"
};

@implementation BusInfo

@synthesize fresh = m_fresh;

- (id)initWithDictionary:(NSDictionary*)d
{
	self = [super init];
	if (self != nil)
	{
		m_fresh = YES;
		m_info = [d retain];
		m_location = [[[CLLocation alloc] initWithLatitude:[[d valueForKey:@"latitude"] doubleValue] longitude:[[d valueForKey:@"longitude"] doubleValue]] retain];
	}
	return self;
}

- (void)dealloc
{
	[m_info release];
	[m_location release];
	[super dealloc];
}

- (NSNumber*)route
{
	return [m_info valueForKey:@"routeID"];
}

- (NSNumber*)vehicleID
{
	return [m_info valueForKey:@"vehicleID"];
}

- (NSNumber*)heading
{
	return [m_info valueForKey:@"heading"];
}

- (NSString*)compassHeading
{
	double h = [self.heading doubleValue];
	if (h >= 360 || h < 0) h = 0;
	return compassHeadings[(int)(trunc((h+11.25)/22.5))];
}

- (NSString*)title
{
	return [NSString stringWithFormat:@"Vehicle %@", self.vehicleID];
}

- (NSString*)subtitle
{
	return [NSString stringWithFormat:@"Route %@, heading %@", self.route, self.compassHeading];
}

- (CLLocationCoordinate2D)coordinate
{
	return m_location.coordinate;
}

- (CLLocation*)location
{
	return m_location;
}

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation
{
	return [self.location getDistanceFrom:otherLocation];
}

- (Boolean)isEqualToBusInfo:(BusInfo*)bus
{
	return ( [self.location isEqual:bus.location] 
			&& [self.route isEqual:bus.route]
			&& [self.vehicleID isEqual:bus.vehicleID]
			&& [self.heading isEqual:bus.heading]
			);
}

@end

