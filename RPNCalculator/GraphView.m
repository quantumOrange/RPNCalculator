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
@synthesize drawLines=_drawPixels;

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
        [[NSUserDefaults standardUserDefaults] setFloat:newOrigin.x forKey:@"originX"];
        [[NSUserDefaults standardUserDefaults] setFloat:newOrigin.y forKey:@"originY"];
        [gesture setTranslation:CGPointZero inView:self];
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        [[NSUserDefaults standardUserDefaults] setFloat:self.scale forKey:@"scale"];
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}




- (void)tapOrigin: (UITapGestureRecognizer *) gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) || (gesture.state == UIGestureRecognizerStateEnded))
    {
        CGPoint newOrigin =[gesture locationInView:self];
        [self setAxisOrigin: newOrigin];
        [[NSUserDefaults standardUserDefaults] setFloat:newOrigin.x forKey:@"originX"];
        [[NSUserDefaults standardUserDefaults] setFloat:newOrigin.y forKey:@"originY"];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.scale=[[NSUserDefaults standardUserDefaults] floatForKey:@"scale"];
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
    //[AxesDrawer drawAxesInRect:bounds originAtPoint:self.axisOrigin scale:pointsPerUnit];
    
    
    
    //Draw graph on axis
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGPoint graphPoint;
    
    if(self.drawLines)
    {
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
    else
    {
        int pixelPerPoint =self.contentScaleFactor;
        //pixelPerPoint =1;
        static const size_t kComponentsPerPixel = 4;
        static const size_t kBitsPerComponent = sizeof(unsigned char) * 8;
        
        NSInteger imageHeight =2*self.axisSize*pixelPerPoint;
        NSInteger imageWidth = 2*self.axisSize*pixelPerPoint;
        CGContextSaveGState(context); 
        
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        
        size_t bufferLength = imageWidth * imageHeight * kComponentsPerPixel;
        
        unsigned char *buffer = malloc(bufferLength);
        
        
        for (NSInteger i = 0; i < bufferLength; ++i)
        {
            buffer[i] = 255;
        }

        
        for (int imageX=0; imageX<imageWidth ; imageX++) 
        {
            float xValue = (imageX-self.axisOrigin.x)/pointsPerUnit;
            float yValue = [self.dataSource functionOfx:self evaluatedAt:xValue]; //delagate views datasource
            int imageY= imageHeight- self.axisOrigin.y + pointsPerUnit*yValue;
            int pointXY= (imageX + imageY*imageWidth)*kComponentsPerPixel;
            if (imageY<imageHeight) 
            {   
                buffer[pointXY ] = 0;
                buffer[pointXY +1] = 0;
                buffer[pointXY +2] = 0;
               // buffer[pointXY +3] would set the alpha value;
            }
        }
        
                
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);;
        
        CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, kBitsPerComponent, kBitsPerComponent * kComponentsPerPixel, kComponentsPerPixel * imageWidth, rgb, kCGBitmapByteOrderDefault | kCGImageAlphaLast, provider, NULL, TRUE, kCGRenderingIntentDefault);
        
        CGContextDrawImage(context, CGRectMake(0, 0, imageHeight, imageWidth), imageRef);
        
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(rgb);     
        
        CGContextRestoreGState(context);
        
        
        /*
        static const size_t kComponentsPerPixel = 4;
        static const size_t kBitsPerComponent = sizeof(unsigned char) * 8;
        
        NSInteger imageHeight =2*self.axisSize;
        NSInteger imageWidth = 2*self.axisSize;
        CGContextSaveGState(context); 
        
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        
        size_t bufferLength = imageWidth * imageHeight * kComponentsPerPixel;
        
        unsigned char *buffer = malloc(bufferLength);
        
        
        for (NSInteger i = 0; i < bufferLength; ++i)
        {
            buffer[i] = 255;
        }
        
        int index=0;
        
        for (int i=0; i<imageWidth ; i++) 
        {
            float x = (i-self.axisSize)/pointsPerUnit;
            float y = [self.dataSource functionOfx:self evaluatedAt:x]; //delagate views datasource
            //int gpX = self.axisOrigin.x + pointsPerUnit*x;
            int gpY= self.axisOrigin.y - pointsPerUnit*y;
            int pointXY=index+gpY;
            if(gpY<imageHeight)
            {
                buffer[pointXY ] = 0;
                buffer[pointXY +1] = 0;
                buffer[pointXY +2] = 0;
                buffer[pointXY +3] = 0;
            }
            
            index += imageHeight*kComponentsPerPixel;
        }
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, bufferLength, NULL);;
        
        CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, kBitsPerComponent, kBitsPerComponent * kComponentsPerPixel, kComponentsPerPixel * imageWidth, rgb, kCGBitmapByteOrderDefault | kCGImageAlphaLast, provider, NULL, false, kCGRenderingIntentDefault);
        
        CGContextDrawImage(context, CGRectMake(0, 0, imageHeight, imageWidth), imageRef);
        
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(rgb);     
        
        CGContextRestoreGState(context);
         */
    }
    [AxesDrawer drawAxesInRect:bounds originAtPoint:self.axisOrigin scale:pointsPerUnit];
}

@end
