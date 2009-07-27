//
//  TimepointEvent.h
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimepointEvent : NSObject
{
	NSString* m_route;
	NSString* m_destination;
	NSInteger m_distanceToGoal;
	NSInteger m_goalDeviation;
	NSDate* m_goalTime;
	NSDate* m_schedTime;
}

- (id)initFromDictionary:(NSDictionary*)d;
- (void)dealloc;

@property (retain, readonly) NSString* route;
@property (retain, readonly) NSString* destination;
@property (readonly) NSInteger distanceToGoal;
@property (readonly) NSInteger goalDeviation;
@property (readonly, retain) NSDate* goalTime;
@property (readonly, retain) NSDate* schedTime;
@end
