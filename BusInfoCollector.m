
#import "BusInfoCollector.h"
#import "BusInfo.h"
#import "Timepoint.h"
#import <SoapFunction.h>
#import <XPathQuery.h>

@interface GetTimepointEventsFunction : SoapFunction {}
- (id)init;
@end

@implementation GetTimepointEventsFunction
- (id)init
{
	return [super initWithUrl:@"http://ws.its.washington.edu/Mybus/Mybus.asmx"
					   Method:@"getEventEstimatesI"
					Namespace:@"http://dotnet.ws.its.washington.edu"
				   SoapAction:@"http://dotnet.ws.its.washington.edu/getEventEstimatesI"
				   ParamOrder:[NSArray arrayWithObject:@"timepoint"]
				ResponseQuery:@"//ns1:getEventEstimatesIResponse/ns1:getEventEstimatesIResult/ns1:EventEstimate"
			   ResponsePrefix:@"ns1"
			ResponseNamespace:@"http://dotnet.ws.its.washington.edu"];
}

#if 0
- (NSArray*)Invoke:(NSDictionary*)params error:(NSError**)error
{
	NSArray* intermediateResult = [super Invoke:params error:error];
	
	NSMutableArray* events = [NSMutableArray array];
	for ( XPathNode* node in intermediateResult )
	{
		TimepointEvent* event = [[TimepointEvent alloc] initFromDictionary:[XPathNode nodeArrayToDictionary:node.children]];
		if (event != nil) [events addObject:event];		
	}
	return events;
}
#endif
@end


@interface CurrentBusesOnRouteFunction : SoapFunction {}
- (id)init;
@end

@implementation CurrentBusesOnRouteFunction
- (id)init
{
	return [super initWithUrl:@"http://ws.its.washington.edu:9090/transit/avl/services/AvlService"
					 Method:@"getLatestByRoute"
				  Namespace:@"http://avl.transit.ws.its.washington.edu"
				 SoapAction:@"getLatestByRoute"
				 ParamOrder:[NSArray arrayWithObjects:@"in0", @"in1", nil]									
			  ResponseQuery:@"//multiRef"
			 ResponsePrefix:nil
		  ResponseNamespace:nil];
}

#if 0
- (NSArray*)Invoke:(NSDictionary*)params error:(NSError**)error
{
	NSArray* intermediateResult = [super Invoke:params error:error];
	
	NSMutableArray* buses = [NSMutableArray array];
	for ( XPathNode* node in intermediateResult )
	{
		NSDictionary* di = [XPathNode nodeArrayToDictionary:node.children];
		if ( [[di valueForKey:@"latitude"] doubleValue] > 1.0 )
		{
			BusInfo* bus = [[BusInfo alloc] initWithDictionary:di];
			if ( bus != nil ) [buses addObject:bus];
		}
	}
	
	return buses;
}
#endif
@end

GetTimepointEventsFunction* s_getTimepointsEventsFn = nil;
CurrentBusesOnRouteFunction* s_currentBusesOnRouteFn = nil;

@interface BusInfoNodeHandler : NSObject<XPathNodeHandler>
{
	NSObject<BusInfoCollectorDelegate>* m_delegate;
}

-(id)initWithBusInfoCollectorDelegate:(NSObject<BusInfoCollectorDelegate>*)bicd;
-(void)dealloc;
-(void)handleNode:(XPathNode*)node;
@end

@implementation BusInfoNodeHandler

- (id)initWithBusInfoCollectorDelegate:(NSObject<BusInfoCollectorDelegate>*)bicd
{
	self = [super init];
	if ( self != nil )
	{
		m_delegate = [bicd retain];
	}
	
	return self;
}

-(void)dealloc
{
	[m_delegate release];
	[super dealloc];
}

-(void)handleNode:(XPathNode*)node
{
	NSDictionary* di = [XPathNode nodeArrayToDictionary:node.children];
	if ( [[di valueForKey:@"latitude"] doubleValue] < 1.0 )
		return;
	
	BusInfo* bi = [[BusInfo alloc] initWithDictionary:di];
	if ( bi == nil )
		return;
	
	[m_delegate performSelectorOnMainThread:@selector(busInfoCollectorAddBus:) withObject:bi waitUntilDone:YES];
}

@end

@interface TimepointEventXPathNodeHandler : NSObject<XPathNodeHandler>
{
	NSObject<BusInfoCollectorDelegate>* m_delegate;
	Timepoint* m_timepoint;
	NSMutableDictionary* m_uniqueRoutes;
	NSObject<XPathNodeHandler>* m_busInfoNodeHandler;
}

-(id)initWithBusInfoCollectorDelegate:(NSObject<BusInfoCollectorDelegate>*)bicd Timepoint:(Timepoint*)tp KnownRoutes:(NSMutableDictionary*)knownroutes BusInfoNodeHandler:(NSObject<XPathNodeHandler>*)busInfoNodeHandler;
-(void)dealloc;
-(void)handleNode:(XPathNode*)node;
@end

@implementation TimepointEventXPathNodeHandler

-(id)initWithBusInfoCollectorDelegate:(NSObject<BusInfoCollectorDelegate>*)bicd Timepoint:(Timepoint*)tp KnownRoutes:(NSMutableDictionary*)knownroutes BusInfoNodeHandler:(NSObject<XPathNodeHandler>*)busInfoNodeHandler
{
	self = [super init];
	if ( self != nil )
	{
		m_delegate = [bicd retain];
		m_timepoint = [tp retain];
		m_uniqueRoutes = [knownroutes retain];
		m_busInfoNodeHandler = [busInfoNodeHandler retain];
		
		[m_timepoint clearEvents];
	}
	
	return self;
}

-(void)dealloc
{
	[m_delegate release];
	[m_timepoint release];
	[m_uniqueRoutes release];
	[m_busInfoNodeHandler release];
	[super dealloc];
}

-(void)handleNode:(XPathNode*)node
{
	TimepointEvent* tpe = [[TimepointEvent alloc] initFromDictionary:[XPathNode nodeArrayToDictionary:node.children]];
	if (tpe == nil) return;
	
	[m_timepoint addEvent:tpe];
	
	if ( [[m_uniqueRoutes objectForKey:tpe.route] intValue] == 0 )
	{
		[m_uniqueRoutes setObject:[NSNumber numberWithInt:1] forKey:tpe.route];
		
		NSError* error = [s_currentBusesOnRouteFn Invoke:[NSDictionary dictionaryWithObjectsAndKeys:@"http://transit.metrokc.gov", @"in0", [NSNumber numberWithInt:[tpe.route intValue]], @"in1", nil] XPathNodeHandler:m_busInfoNodeHandler];
		if ( error != nil )
		{
			// TODO: do something reasonable with error. Throw exception?
			NSLog(@"error in BusInfoCollector collect::%@ while collecting bus info for route %@ at %@\n", error, tpe.route, m_timepoint.description);
		}
	}
}

@end



@implementation BusInfoCollector

+ (void)initialize
{
	s_getTimepointsEventsFn = [[[GetTimepointEventsFunction alloc] init] retain];
	s_currentBusesOnRouteFn = [[[CurrentBusesOnRouteFunction alloc] init] retain];
}

- (id)initWithBusInfoCollectorDelegate:(NSObject<BusInfoCollectorDelegate>*)bicd
{
	self = [super init];
	if ( self != nil )
	{
		m_delegate = [bicd retain];
	}
	return self;
}
- (void)dealloc
{
	[m_delegate release];
	[super dealloc];
}

- (void)collectAsync:(NSArray*)timepoints
{
	[NSThread detachNewThreadSelector:@selector(collect:) toTarget:self withObject:timepoints];
}


- (void)collect:(NSObject*)timepointsObject
{
	NSArray* timepoints = (NSArray*)timepointsObject;
	NSAutoreleasePool* pool1 = [[NSAutoreleasePool alloc] init]; // autorelease pool for secondary thread
	
	[m_delegate performSelectorOnMainThread:@selector(busInfoCollectorWillStartCollectingBuses:) withObject:self waitUntilDone:YES];
	
	NSMutableDictionary* uniqueRoutes = [NSMutableDictionary dictionaryWithCapacity:10];
	BusInfoNodeHandler* binh = [[[BusInfoNodeHandler alloc] initWithBusInfoCollectorDelegate:m_delegate] autorelease];
	
	for (Timepoint* timepoint in timepoints)
	{
		TimepointEventXPathNodeHandler* tpexpnh = [[TimepointEventXPathNodeHandler alloc] initWithBusInfoCollectorDelegate:m_delegate Timepoint:timepoint KnownRoutes:uniqueRoutes BusInfoNodeHandler:binh];
		
		NSError* error = [s_getTimepointsEventsFn Invoke:[NSDictionary dictionaryWithObject:timepoint.pointID forKey:@"timepoint"] XPathNodeHandler:tpexpnh];
		if ( error != nil )
		{
			NSLog(@"TIMEPOINT BAD %@\n", timepoint.description);
		}
		else
		{
			NSLog(@"TIMEPOINT OK %@\n", timepoint.description);

		}
		[tpexpnh release];
	}
	
	[m_delegate performSelectorOnMainThread:@selector(busInfoCollectorWillStartCollectingBuses:) withObject:self waitUntilDone:YES];
	[pool1 release];
}

@end
