/*
 MapViewController.h
 Controller class for the map view, as you may have guessed.
 
 Copyright 2009, The Rockhold Company. All rights reserved.
 */

#import <MapKit/MKMapView.h>

@class BusInfo;
@class LocationInfo;

@interface MapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate>
{    
	CLLocationManager*  m_locationManager;
	MKMapView*			m_mapView;
	IBOutlet UIBarButtonItem*	m_gotoCurrentLocationButtonItem;
}

- (void)busAdded:(BusInfo*)bus;
- (void)busRemoved:(BusInfo*)bus;

- (IBAction)newFavorite:(id)sender;
- (IBAction)gotoCurrentLocation:(id)sender;

//CLLocationManagerDelegate methods
- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation;

- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error;

//MKMapViewDelegate
- (MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id <MKAnnotation>)annotation;
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control;

//misc
- (void)newError:(NSString*)text;

@property (nonatomic, retain) IBOutlet MKMapView* mapView;
@property (nonatomic, readonly) LocationInfo* locationInfo;

@end
