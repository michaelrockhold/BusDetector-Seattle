//
//  LocationInfo.h
//  LocateMe
//
//  Created by Michael Rockhold on 6/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#ifndef __LOCATIONINFO_H__
#define __LOCATIONINFO_H__

#import <MapKit/MKReverseGeocoder.h>
#import "BusInfoCollector.h"

@class MapViewController;

@interface LocationInfo : NSObject<MKReverseGeocoderDelegate, BusInfoCollectorDelegate>
{
	MapViewController*		m_mapViewController;
	NSArray*				m_timepoints;
	NSMutableDictionary*	m_buses;
	CLLocation*				m_currentLocation;
}

- (void)updateBusInfo;

//MKReverseGeocoderDelegate methods
- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFindPlacemark:(MKPlacemark*)placemark;
- (void)reverseGeocoder:(MKReverseGeocoder*)geocoder didFailWithError:(NSError*)error;

// BusCollectorDelegate methods
- (void)busInfoCollectorWillStartCollectingBuses:(BusInfoCollector*)collector;
- (void)busInfoCollectorAddBus:(BusInfo*)bus;
- (void)busInfoCollectorDidFinishCollectingBuses:(BusInfoCollector*)collector;

@property (nonatomic, retain) NSMutableDictionary* buses;
@property (nonatomic, retain) NSArray* timepoints;
@property (nonatomic, retain) CLLocation* currentLocation;
@property (nonatomic, retain) MapViewController* mapViewController;
@end
#endif
