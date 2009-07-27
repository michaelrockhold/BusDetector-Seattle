//
//  LocationInfo.m
//  LocateMe
//
//  Created by Michael Rockhold on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MKPlacemark.h>
#import <CoreLocation/CLLocation.h>
#import "LocationInfo.h"
#import "Timepoint.h"
#import "BusInfo.h"
#import "MapViewController.h"

NSInteger TimepointSortByDistanceFromHome(id tp1, id tp2, void* currentLocation)
{
	
	CLLocationDistance dist1 = [tp1 getDistanceFrom:currentLocation];
	CLLocationDistance dist2 = [tp2 getDistanceFrom:currentLocation];
	
	return (dist1 > dist2) ? 1 : (dist1 < dist2) ? -1 : 0;
}


@implementation LocationInfo

@synthesize timepoints = m_timepoints, buses = m_buses, mapViewController = m_mapViewController, currentLocation = m_currentLocation;

- (id)init
{
	self = [super init];
	if ( self != nil )
	{
		m_mapViewController = nil;
		m_currentLocation = nil;
		m_timepoints = [[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"timepoints" ofType:@"dat"]] retain];
		m_buses = [[NSMutableDictionary dictionaryWithCapacity:400] retain];
	
		[self updateBusInfo];
		NSTimer* aTimer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(updateBusInfo) userInfo:nil repeats:YES];
		[aTimer retain];
	}
	return self;
}

- (void)dealloc
{
	[m_timepoints release];
	[m_buses release];
	[m_mapViewController release];
	[super dealloc];
}


#if 0
- (void)setCurrentLocation:(CLLocation*)location
{	
	[currentLocation release];
	currentLocation = [location retain];

	// Ask the map service for address info for this new location
    MKReverseGeocoder* rg = [[[MKReverseGeocoder alloc] initWithCoordinate:location.coordinate] retain];
    rg.delegate = self;
    [rg start];	
}
#endif	

#pragma mark Methods relating to collecting timepoint and bus location information
- (void)updateBusInfo
{
	[[[[BusInfoCollector alloc] initWithBusInfoCollectorDelegate:self] retain] collectAsync:m_timepoints]; 	
}

- (void)busInfoCollectorWillStartCollectingBuses:(BusInfoCollector*)collector
{
	for (BusInfo* bi in [m_buses allValues])
	{
		bi.fresh = NO;
	}
}

- (void)busInfoCollectorAddBus:(BusInfo*)bus
{
	@synchronized(m_buses)
	{
		Boolean busMoved = NO;
		BusInfo* previousBi = [m_buses objectForKey:bus.vehicleID];
		if ( previousBi == nil )
		{
			busMoved = YES;
		}
		else
		{
			previousBi.fresh = YES;
			busMoved = ! [previousBi isEqualToBusInfo:bus];
			
			if ( busMoved )
				[m_mapViewController busRemoved:previousBi];
		}
		if ( busMoved )
		{
			bus.fresh = YES;
			[m_buses setObject:bus forKey:bus.vehicleID];
			[m_mapViewController busAdded:bus];
		}
	}
}

- (void)busInfoCollectorDidFinishCollectingBuses:(BusInfoCollector*)collector
{
	[collector release];
	for (BusInfo* bi in [m_buses allValues])
	{
		if ( bi.fresh == NO )
		{
			[m_mapViewController busRemoved:bi];
			[m_buses removeObjectForKey:bi.vehicleID];
		}
	}
}


#pragma mark ---- reverseGeocoder methods ----

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error
{
    [geocoder release];
}

- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)placemark
{
    NSMutableString* address = [[[NSMutableString alloc] init] autorelease];
    
    [address appendFormat:@"%@, %@, %@", placemark.subThoroughfare, placemark.thoroughfare, placemark.locality];
	//[self newLocationUpdate:address];
    [geocoder release];
}

@end
