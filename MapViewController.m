/*
 
 File: MapViewController.m
 Abstract: Controller class for the "main" view (visible at app start).
 
 */

// Shorthand for getting localized strings, used in formats below for readability
#define LocStr(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

#import <Foundation/Foundation.h>

#import "MapViewController.h"
#import "Timepoint.h"
#import "BGAnnotationView.h"
#import "BGTimepointAnnotationView.h"
#import "LocationInfo.h"
#import "BusInfo.h"
#import "DefaultsCategory.h"
#import "BusDetector_SeattleAppDelegate.h"

#pragma mark Controller

@implementation MapViewController

@synthesize mapView = m_mapView;

- (LocationInfo*)locationInfo
{
	return ((BusDetector_SeattleAppDelegate*)([UIApplication sharedApplication].delegate)).locationInfo;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc
{
    [m_locationManager release];
	[super dealloc];
}

- (IBAction)newFavorite:(id)sender
{
}

- (IBAction)gotoCurrentLocation:(id)sender
{
	m_mapView.centerCoordinate = self.locationInfo.currentLocation.coordinate;
}

// Called when the view is loading for the first time only
// If you want to do something every time the view appears, use viewWillAppear or viewDidAppear
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	m_locationManager = [[[CLLocationManager alloc] init] retain];
    m_locationManager.delegate = self; // Tells the location manager to send updates to this object
    	
	MRCoordinateRegion* whereWasI = nil;
	
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	whereWasI = [defaults coordinateRegionForKey:@"mapview"];
	[defaults release];
	
	if (whereWasI == nil)
	{
		whereWasI = [[MRCoordinateRegion alloc] initWithLatitude:47.606056 Longitude:-122.332695 LatitudinalDistance:300.0 LongitudinalDistance:300.0];
	}
	[m_mapView setRegion:whereWasI.coordinateRegion animated:TRUE];
	[whereWasI release];
	
	if ( ! m_locationManager.locationServicesEnabled )
    {
        //[self addTextToLog:NSLocalizedString(@"NoLocationServices", @"User disabled location services")];
    }
    else
    {
        [m_locationManager startUpdatingLocation];
    }
	
	self.locationInfo.mapViewController = self;
	//[m_mapView addAnnotations:self.locationInfo.timepoints];
	
	if (self.locationInfo.currentLocation != nil)
	{
		m_gotoCurrentLocationButtonItem.enabled = YES;
	}
}

-(void)newError:(NSString *)text
{
}

#pragma mark ---- LocationInfoDelegate methods

- (void)busAdded:(BusInfo*)bus
{
    [m_mapView addAnnotation:bus];
}

- (void)busRemoved:(BusInfo*)bus
{
    [m_mapView removeAnnotation:bus];
}

#pragma mark ---- CLLocationManager methods

// Called when the location is updated
- (void)locationManager:(CLLocationManager*)manager
	didUpdateToLocation:(CLLocation*)newLocation
		   fromLocation:(CLLocation*)oldLocation
{
    [manager stopUpdatingLocation];
	self.locationInfo.currentLocation = newLocation;
}

// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager*)manager
	   didFailWithError:(NSError*)error
{
	NSMutableString* errorString = [[[NSMutableString alloc] init] autorelease];
    
	if ([error domain] == kCLErrorDomain)
    {
		// We handle CoreLocation-related errors here
        
		switch ([error code])
        {
                // This error code is usually returned whenever user taps "Don't Allow" in response to
                // being told your app wants to access the current location. Once this happens, you cannot
                // attempt to get the location again until the app has quit and relaunched.
                //
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
                //
			case kCLErrorDenied:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationDenied", nil)];
				break;
                
                // This error code is usually returned whenever the device has no data or WiFi connectivity,
                // or when the location cannot be determined for some other reason.
                //
                // CoreLocation will keep trying, so you can keep waiting, or prompt the user.
                //
			case kCLErrorLocationUnknown:
				[errorString appendFormat:@"%@\n", NSLocalizedString(@"LocationUnknown", nil)];
				break;
                
                // We shouldn't ever get an unknown error code, but just in case...
                //
			default:
				[errorString appendFormat:@"%@ %d\n", NSLocalizedString(@"GenericLocationError", nil), [error code]];
				break;
		}
	}
    else
    {
		// We handle all non-CoreLocation errors here
		// (we depend on localizedDescription for localization)
		[errorString appendFormat:@"Error domain: \"%@\"  Error code: %d\n", [error domain], [error code]];
		[errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
	}
    
	// Display the update
	[self newError:errorString];
}

#pragma mark MKMapViewDelegate methods

- (MKAnnotationView *)mapView:(MKMapView *)mv viewForAnnotation:(id <MKAnnotation>)ann
{
	Class k = [ann class];
	if (k == [BusInfo class])
		return [BGAnnotationView newOrUsed:mv Annotation:ann];
	else if (k == [Timepoint class])
		return [BGTimepointAnnotationView newOrUsed:mv Annotation:ann];
	else if (k == [MKUserLocation class])
		return nil;
	else
	{
		NSLog(@"MapViewController encountered annotation of class %s\n", class_getName(k));
		return nil;
	}
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	NSLog(@"callout control tapped\n");
}
@end
