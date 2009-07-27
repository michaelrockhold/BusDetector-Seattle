
#ifndef __BUSINFOCOLLECTOR_H__
#define __BUSINFOCOLLECTOR_H__

#import <Foundation/Foundation.h>

@class BusInfo;
@class BusInfoCollector;


@protocol BusInfoCollectorDelegate <NSObject>
- (void)busInfoCollectorWillStartCollectingBuses:(BusInfoCollector*)collector;
- (void)busInfoCollectorAddBus:(BusInfo*)bus;
- (void)busInfoCollectorDidFinishCollectingBuses:(BusInfoCollector*)collector;
@end


@interface BusInfoCollector : NSObject
{
	NSObject<BusInfoCollectorDelegate>* m_delegate;
}

+ (void)initialize;
- (id)initWithBusInfoCollectorDelegate:(NSObject<BusInfoCollectorDelegate>*)bicd;
- (void)collect:(NSObject*)timepointsArrayObject;
- (void)collectAsync:(NSArray*)timepoints;
@end

#endif