//
//  BGTimepointAnnotationView.h
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MKMapView.h>
#import <MapKit/MKAnnotationView.h>


@interface BGTimepointAnnotationView : MKAnnotationView
{

}

+ (BGTimepointAnnotationView*)reuseExistingView:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann;

+ (BGTimepointAnnotationView*)newOrUsed:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann;

- (id)initWithAnnotation:(id <MKAnnotation>)ann;

- (void)drawRect:(CGRect)rect;

@end
