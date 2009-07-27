//
//  Timepoint.h
//
//  Created by Michael Rockhold on 5/30/09.
//  Copyright 2009 The Rockhold Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotation.h>
#import "TimepointEvent.h"

@interface Timepoint : NSObject<NSCoding, MKAnnotation>
{
	NSString*	name;
	NSString*	pointID;
	CLLocation* location;
	NSMutableArray* events;
}

- (id)initFromName:(NSString*)n 
		   PointID:(NSString*)p 
		  Location:(CLLocation*)l;

- (NSString*)title;

- (id)initWithCoder:(NSCoder*)decoder;
- (void)encodeWithCoder:(NSCoder*)coder;

- (void)clearEvents;
- (void)addEvent:(TimepointEvent*)e;

- (CLLocationDistance)getDistanceFrom:(CLLocation*)otherLocation;

@property (nonatomic, retain, readonly) NSString* name;
@property (nonatomic, retain, readonly) NSString* pointID;
@property (nonatomic, retain, readonly) CLLocation* location;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain, readonly) NSArray* events;
@property (nonatomic, retain, readonly) NSString* description;

@end
