//
//  BusInfo.h
//  SOAP_AuthExample
//
//  Created by Michael Rockhold on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MKAnnotation.h>
#import "MapViewController.h"

@interface BusInfo : NSObject<MKAnnotation>
{
	NSDictionary* m_info;
	CLLocation* m_location;
	BOOL m_fresh;
}

- (id)initWithDictionary:(NSDictionary*)d;

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation;

- (Boolean)isEqualToBusInfo:(BusInfo*)bus;

@property (readonly, retain) NSNumber* route;
@property (readonly, retain) NSNumber* vehicleID;
@property (readonly, retain) NSNumber* heading;
@property (readonly, retain) NSString* title;
@property (readonly, retain) NSString* subtitle;
@property (readonly, nonatomic) CLLocationCoordinate2D coordinate;
@property (retain, readonly) CLLocation* location;
@property BOOL fresh;
@end
