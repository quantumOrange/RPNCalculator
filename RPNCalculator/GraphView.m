//
//  GraphView.m
//  Calculator
//
//  Created by David Crooks on 22/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//



#import "GraphView.h"
#import "AxesDrawer.h"


@implementation GraphView
@synthesize dataSource=_dataSource;
@synthesize scale = _scale;
@synthesize axisOrigin =_axisOrigin;
@synthesize axisSize=_axisSize;


#define DEFAULT_SCALE 1.0
#define AXIS_IPHONE 160.0
#define AXIS_IPAD 384.0
#define TOPLEFT_X 0.0
#define TOPLEFT_Y 0.0
#define DEFAULT_POINTS_PER_UNIT 100

- (CGFloat)scale
{
    if (!_scale) 
    {
        return DEFAULT_SCALE; // don't allow zero scale
    } else 
    {
        return _scale;
    }
}
- (CGFloat)axisSize
{
    if(!_axisSize)
    {
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) 
        {
            return AXIS_IPAD;
        }
        else
        {
            return AXIS_IPHONE;
        }
    }
    else 
    {
        return _axisSize;
    }
}

- (void)setScale:(CGFloat)scale
{
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

- (CGPoint) axisOrigin
{
    if(!_axisOrigin.x || !_axisOrigin.y)
    {
        CGPoint defaultOrigin;
        
        defaultOrigin.x=self.axisSize + TOPLEFT_X;
        defaultOrigin.y=self.axisSize + TOPLEFT_Y;
                
        return defaultOrigin;
    }
    else
    {
        return _axisOrigin;
    }
    
}


- (void)setAxisOrigin:(CGPoint)axisOrigin
{
    if (axisOrigin.x != _axisOrigin.x || axisOrigin.y != _axisOrigin.y){
        _axisOrigin = axisOrigin;
        [self setNeedsDisplay]; // any time our origin changes, call for redraw
    }
}

- (void) moveOrigin: (UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) 
    {
        CGPoint translation = [gesture translationInView:self];
        CGPoint newOrigin;
        newOrigin.x = self.axisOrigin.x + translation.x;
        newOrigin.y = self.axisOrigin.y + translation.y;
        [self setAxisOrigin: newOrigin];
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

- (void)tapOrigin: (UITapGestureRecognizer *) gesture
{
    gesture.numberOfTapsRequired = 3;
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint newOrigin =[gesture locationInView:self];
        [self setAxisOrigin: newOrigin];
    }
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    // Drawing code
    //Set scale for axis
 //   CGFloat axisScale=145.0;
    CGRect bounds;
    CGPoint rectOrigin;
    rectOrigin.x=TOPLEFT_X;
    rectOrigin.y=TOPLEFT_Y;
    CGSize rectSize;
    
    rectSize.width=2*self.axisSize;
    rectSize.height=2*self.axisSize;
    
    bounds.origin=rectOrigin;
    bounds.size=rectSize;
    
    
    //self.axisOrigin.x=AXIS + TOPLEFT_X ;
   //self.axisOrigin.y=AXIS + TOPLEFT_Y ;
    //[self setAxisOrigin:rectOrigin];
    CGFloat pointsPerUnit=DEFAULT_POINTS_PER_UNIT*self.scale;
    
    //draw graph axis
    [AxesDrawer drawAxesInRect:bounds originAtPoint:self.axisOrigin scale:pointsPerUnit];
    
    
    
    //Draw graph on axis
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint graphPoint;
       
   
    CGContextBeginPath(context);
    for (int i=0; i<=2*self.axisSize; i++) 
    {
        
        float x = (i-self.axisSize)/pointsPerUnit;
        float y = [self.dataSource functionOfx:self evaluatedAt:x]; //delagate views datasource
        
        graphPoint.x = self.axisOrigin.x + pointsPerUnit*x;
        graphPoint.y = self.axisOrigin.y - pointsPerUnit*y;
        
        if (i==0) 
        {
            CGContextMoveToPoint(context, graphPoint.x, graphPoint.y);
        } 
        else 
        {
            CGContextAddLineToPoint(context, graphPoint.x, graphPoint.y);
        }
        
    }
     
    CGContextStrokePath(context);
}

@end
