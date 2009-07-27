//
//  BGAnnotationView.m
//  BusGnosis
//
//  Created by Michael Rockhold on 7/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "BGAnnotationView.h"
#import "BusInfo.h"
#import <math.h>

static NSString* bGAnnotationViewReuseIdentifier = @"BusGnosticAnnotation";

static UIFont*		s_textFont;
static CGRect		s_textRect;
static CGSize		s_frameSize;

static const double c_diameter = 48;
static UIImage*		s_image;
static CGRect		s_image_rect;

static UIButton*	s_rightCalloutAccessoryView;

@interface MyLeftCalloutAccessoryView : UIView
{
	NSString* m_route;
}

- (id)initWithRoute:(NSString*)r;
- (void)drawRect:(CGRect)rect;
@end

@implementation MyLeftCalloutAccessoryView

- (id)initWithRoute:(NSString*)r
{
	self = [super initWithFrame:s_image_rect];
	if (self != nil)
	{
		//[self setFrame:CGRectMake(0, 0, 48, 20)];
		m_route = [r retain];
		self.opaque = NO;
	}
	return self;
}

- (void)dealloc
{
	[m_route release];
	[super dealloc];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(myContext);
	CGContextScaleCTM(myContext, 1.0, -1.0);
	CGContextTranslateCTM(myContext, 0, -rect.size.height);
	CGContextDrawImage(myContext, rect, s_image.CGImage);
	CGContextRestoreGState(myContext);
	
	[[UIColor blackColor] set];		
	[m_route drawInRect:UIEdgeInsetsInsetRect(rect, UIEdgeInsetsMake(2, 2, 2, 2)) withFont:s_textFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

@end



@implementation BGAnnotationView

+(void)initialize
{
	if (self == [BGAnnotationView class])
	{
		s_textFont =  [UIFont boldSystemFontOfSize:10];
				
		CGSize textSize = [@"888" sizeWithFont:s_textFont];
		s_textRect = CGRectMake(-textSize.width/2, -textSize.width/2, textSize.width, textSize.width);				
		s_textRect.origin.y += 2; // just looks a bit better
						
		s_frameSize = CGSizeMake(c_diameter, c_diameter);

		s_image = [UIImage imageNamed:@"bus_with_dot.png"];
		CGSize image_size = [s_image size];
		
		double image_diameter = sqrt(pow(image_size.height, 2) + pow(image_size.width,2));
		
		double w = c_diameter * image_size.width / image_diameter;
		double h = c_diameter * image_size.height / image_diameter;
		
		s_image_rect = CGRectMake(-w/2, -h/2, w, h);
		
		s_rightCalloutAccessoryView = [[UIButton buttonWithType:UIButtonTypeDetailDisclosure] retain];
	}
}

+ (BGAnnotationView*)reuseExistingView:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{	
	BGAnnotationView* bgv = (BGAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:bGAnnotationViewReuseIdentifier];
	
	return bgv;
}

+ (BGAnnotationView*)newOrUsed:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{
	BGAnnotationView* oldView = [BGAnnotationView reuseExistingView:mv Annotation:ann];
    
	return (oldView != nil) ? oldView : [(BGAnnotationView*)[[BGAnnotationView alloc] initWithMapView:mv Annotation:ann] retain];
}

- (id)initWithMapView:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{
	self = [super initWithAnnotation:ann reuseIdentifier:bGAnnotationViewReuseIdentifier];
	
	if (self != nil)
	{
		[self setFrame:CGRectMake(0, 0, s_frameSize.width, s_frameSize.height)];
		self.opaque = NO;
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
CGFloat RadiansToDegrees(CGFloat radians) {return radians * 180 / M_PI;};

- (void)drawRect:(CGRect)rect
{	
	NSString* tag = [NSString stringWithFormat:@"%@", ((BusInfo*)self.annotation).route];
	double heading = [((BusInfo*)self.annotation).heading doubleValue];
	if ( heading < 0 || heading >= 360 ) heading = 0;

	CGContextRef myContext = UIGraphicsGetCurrentContext();

	CGContextTranslateCTM(myContext, rect.size.width/2, rect.size.height/2);
	CGContextSaveGState(myContext);

	if ( heading >= 180 )
	{
		CGContextScaleCTM(myContext, -1.0, 1.0);
		heading = -heading;
	}
	heading += 90;

	CGContextRotateCTM(myContext, DegreesToRadians(heading));
	CGContextDrawImage(myContext, s_image_rect, s_image.CGImage);
	CGContextRestoreGState(myContext);
	
	[[UIColor blackColor] set];		
	[tag drawInRect:s_textRect withFont:s_textFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{	
	if (  CGRectContainsPoint(UIEdgeInsetsInsetRect(s_textRect, UIEdgeInsetsMake (-2, -2, -2, -2)), point))
		return self;
	else
		return nil;	
}

- (BOOL)canShowCallout
{
	return YES;
}

- (UIView*) leftCalloutAccessoryView
{
	return [[[MyLeftCalloutAccessoryView alloc] initWithRoute:[NSString stringWithFormat:@"%@", ((BusInfo*)self.annotation).route]] autorelease];
}

- (UIView*) rightCalloutAccessoryView
{
	return s_rightCalloutAccessoryView;
}

@end
