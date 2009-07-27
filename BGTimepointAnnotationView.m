//
//  BGTimepointAnnotationView.m
//  BusDetector-Seattle
//
//  Created by Michael Rockhold on 7/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import "BGTimepointAnnotationView.h"
#import "Timepoint.h"

static NSString* bGTimepointAnnotationViewReuseIdentifier = @"BGTimepointAnnotation";

static CGMutablePathRef s_ellipsePath;
static UIFont*		s_textFont;
static CGRect		s_textRect;
static CGSize		s_frameSize;

@implementation BGTimepointAnnotationView

+(void)initialize
{
	if (self == [BGTimepointAnnotationView class])
	{
		s_textFont =  [UIFont boldSystemFontOfSize:10];
		
		CGSize textSize = [@"8888" sizeWithFont:s_textFont];
		s_textRect = CGRectMake(-textSize.width/2, -textSize.height/2, textSize.width, textSize.height);
		float wmore = textSize.width * 0.05;
		float hmore = textSize.height * 0.05;
		CGRect ellipseRect = UIEdgeInsetsInsetRect(s_textRect, UIEdgeInsetsMake (-hmore, -wmore, -hmore, -wmore));
		s_frameSize = CGSizeMake(ellipseRect.size.width, ellipseRect.size.height);
		
		s_ellipsePath = CGPathCreateMutable();
		CGPathAddEllipseInRect(s_ellipsePath, nil, ellipseRect);
	}
}

+ (BGTimepointAnnotationView*)reuseExistingView:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{	
	BGTimepointAnnotationView* bgv = (BGTimepointAnnotationView*)[mv dequeueReusableAnnotationViewWithIdentifier:bGTimepointAnnotationViewReuseIdentifier];
	
	return bgv;
}

+ (BGTimepointAnnotationView*)newOrUsed:(MKMapView *)mv Annotation:(id <MKAnnotation>)ann
{
	BGTimepointAnnotationView* oldView = [BGTimepointAnnotationView reuseExistingView:mv Annotation:ann];
    
	return (oldView != nil) ? oldView : [(BGTimepointAnnotationView*)[[BGTimepointAnnotationView alloc] initWithAnnotation:ann] retain];
}

- (id)initWithAnnotation:(id <MKAnnotation>)ann
{
	self = [super initWithAnnotation:ann reuseIdentifier:bGTimepointAnnotationViewReuseIdentifier];
	
	if (self != nil)
	{
		[self setFrame:CGRectMake(0, 0, s_frameSize.width, s_frameSize.height)];
		self.opaque = NO;
	}
	
	return self;
}

- (void)drawRect:(CGRect)rect
{
	NSString* tag = [NSString stringWithFormat:@"%@", ((Timepoint*)self.annotation).pointID];
	
	CGContextRef myContext = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(myContext, s_frameSize.width/2, s_frameSize.height/2);
	
	CGContextSaveGState(myContext);
	
	if ( self.canShowCallout )
		[[UIColor greenColor] set];
	else
		[[UIColor yellowColor] set];
		
	CGContextAddPath(myContext, s_ellipsePath);
	CGContextDrawPath(myContext, kCGPathFillStroke);
	
	CGContextRestoreGState(myContext);
	
	[[UIColor whiteColor] set];		
	[tag drawInRect:s_textRect withFont:s_textFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

@end
