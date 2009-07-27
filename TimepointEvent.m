//
//  TimepointEvent.m
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TimepointEvent.h"

@implementation TimepointEvent

@synthesize route = m_route, destination = m_destination, distanceToGoal = m_distanceToGoal, goalDeviation = m_goalDeviation, goalTime = m_goalTime, schedTime = m_schedTime;

- (id)initFromDictionary:(NSDictionary*)d
{
	self = [super init];
	if ( self != nil )
	{		
		m_route = [d valueForKey:@"route"];
		m_destination = [d valueForKey:@"destination"];
		NSString* dtgStr = [d valueForKey:@"distanceToGoal"];
		NSString* gdStr = [d valueForKey:@"goalDeviation"];
		NSString* gtStr = [d valueForKey:@"goalTime"];
		NSString* stStr = [d valueForKey:@"schedTime"];
		
		
		if ( m_route == nil || [m_route length] == 0 
			|| m_destination == nil || [m_destination length] == 0 
			|| dtgStr == nil || [dtgStr length] == 0 
			|| gdStr == nil || [gdStr length] == 0
			|| gtStr == nil || [gtStr length] == 0
			|| stStr == nil || [stStr length] == 0
			)
		{
			[self dealloc];
			self = nil;
		}
		else
		{
			m_distanceToGoal = [dtgStr integerValue];
			m_goalDeviation = [gdStr integerValue];
			
			unsigned unitFlags = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
			NSDateComponents* comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];

			[comps setHour:0];
			[comps setMinute:0];
			[comps setSecond:0];
			
			NSDate* midnight = [[NSCalendar currentCalendar] dateFromComponents:comps];
			[comps release];
			
			m_goalTime = [midnight addTimeInterval:[gtStr doubleValue]];
			m_schedTime = [midnight addTimeInterval:[stStr doubleValue]];
		}
	}
	
	return self;
}

- (void)dealloc
{
	[m_route release];
	[m_destination release];
	[m_goalTime release];
	[m_schedTime release];
	[super dealloc];
}

@end
