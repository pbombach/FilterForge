//
//  BESMainView.m
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//
#import <Quartz/Quartz.h>

#import "MainView.h"
#import "MainViewDataSource.h"

typedef enum {
    ZoomDirectionIn = 0,
    ZoomDirectionOut = 1,
} ZoomDirection;

static CGFloat defaultZoomInMagnification = .41421356237309; // magnification = 1+m => 1 - sqrt(2)
static CGFloat defaultZoomOutMagnification = -0.292893218813450; // 1 - 1/sqrt(2)

@interface MainView ()

@property (assign) CGFloat fitToWindowZoom;
@property (assign) CGPoint fitToWindowOffset;
@property (assign) CGFloat mCurrentZoom;
@property (assign) CGPoint mCurrentOffset;
@property (strong) NSDictionary *mImages;
@property (strong) CIContext *mContext;
@property (strong) CIImage *mCurrentImage;
@property (assign)MainViewDisplayedImage displayedImage;

@end

@implementation MainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:NSViewFrameDidChangeNotification object:self.superview];
        self.mCurrentZoom = 1.0;
        self.displayedImage = MainViewOutputImage;
    }
    
    return self;
}


- (void)sizeChanged:(NSNotification *)sender {

    [self contentViewSize];
    
    CGFloat effectiveZoom = self.mCurrentZoom*self.fitToWindowZoom;
    
    [self calculateFitToWindowValues];
    self.mCurrentZoom = MAX(1,effectiveZoom/self.fitToWindowZoom);

    [self scaleCurrentImage];
    
    [self setNeedsDisplay:YES];
}

- (void) scaleZoom:(CGFloat)m atPoint:(CGPoint) point {

    self.mCurrentZoom *= 1+m;
    self.mCurrentZoom = MAX(1,MIN(200, self.mCurrentZoom));

    NSPoint currentScrollPoint = self.visibleRect.origin;
    NSPoint newScrollPoint = currentScrollPoint;
    NSPoint drawingOffset = [self drawingOffset];
    
    [self contentViewSize];
    
    [self scaleCurrentImage];

    if ( !CGPointEqualToPoint(point, CGPointZero)) {
        m = m+1;

        if (self.mCurrentImage.extent.size.height > self.superview.frame.size.height) {
            newScrollPoint.y = (m-1)*point.y + m*(currentScrollPoint.y+drawingOffset.y);
        }
        
        if (self.mCurrentImage.extent.size.width > self.superview.frame.size.width) {
            newScrollPoint.x = (m-1)*point.x + m*(currentScrollPoint.x+drawingOffset.x);
        }
    }

    [self scrollPoint:newScrollPoint];
}

- (void) resetZoom {
    self.mCurrentZoom = 1.0;
    [self scrollPoint:CGPointZero];
    [self contentViewSize];
    [self scaleCurrentImage];
}

- (void) zoomIn {
    [self zoomInOrOut:ZoomDirectionIn];
}

- (void) zoomOut {
    [self zoomInOrOut:ZoomDirectionOut];
}

- (void) zoomInOrOut:(ZoomDirection) zoomDirection {
    
    // Calculate view midpoint
    CGPoint midPoint;
    midPoint.x = self.superview.frame.size.width/2.0;
    midPoint.y = self.superview.frame.size.height/2.0;
    CGFloat magnification;
    switch (zoomDirection) {
        case ZoomDirectionIn:
            magnification = defaultZoomInMagnification;
            break;
        case ZoomDirectionOut:
            magnification = defaultZoomOutMagnification;
            break;
        default:
            magnification = 1.0; // No zoom
            break;
    }
    [self scaleZoom:magnification atPoint:midPoint];

}

- (void) magnifyWithEvent:(NSEvent *)event {

    CGFloat m = [event magnification];
    [self scaleZoom:m atPoint:event.locationInWindow];
}


- (void) contentViewSize {
    CGSize size = CGSizeZero;
    CIImage *inputImage = [self inputImage];
    
    if ( inputImage == nil) {
        size = self.superview.frame.size;
    }
    else {
        size.width = MAX(self.mCurrentZoom*self.fitToWindowZoom*inputImage.extent.size.width, self.superview.frame.size.width);
        size.height = MAX(self.mCurrentZoom*self.fitToWindowZoom*inputImage.extent.size.height, self.superview.frame.size.height);
    }
    CGRect frame = self.frame;
    frame.size = size;
    [self setFrame:frame];
}

- (CIImage *) imageForKey:(NSString *) key {
    CIImage *image = nil;
    if ( self.mImages != nil) {
        image = self.mImages[key];
    }
    return image;

}
- (CIImage *)inputImage {
    return [self imageForKey:kInputImage];
}


- (void) calculateFitToWindowValues {
    CIImage *inputImage = [self inputImage];
    CGFloat wr = self.superview.frame.size.width/inputImage.extent.size.width;
    CGFloat hr =self.superview.frame.size.height/inputImage.extent.size.height;
    self.fitToWindowZoom = MIN(wr,hr);


}

- (void) scaleCurrentImage {
    
    NSAffineTransform *scale = [NSAffineTransform transform];
    [scale scaleBy:self.fitToWindowZoom*self.mCurrentZoom];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    
    [filter setValue:scale forKey:kCIInputTransformKey];
    
    CIImage *image;
    
    switch (self.displayedImage) {
        case MainViewInputImage:
            image = [self imageForKey:kInputImage];
            break;
        case MainViewOutputImage:
            image = [self imageForKey:kOutputImage];
            break;
        default:
            break;
    }
    [filter setValue:image forKey:kCIInputImageKey];
    
    
    self.mCurrentImage = [filter valueForKey:kCIOutputImageKey];

    
}

- (void) scrollToCenter {
    
    CGPoint offset = CGPointZero;
    offset.x = MAX(0,-(self.superview.frame.size.width - self.mCurrentImage.extent.size.width)/2.0);
    offset.y = MAX(0,-(self.superview.frame.size.height - self.mCurrentImage.extent.size.height)/2.0);
    
    [self scrollPoint:offset];
}



- (void) setImages:(NSDictionary *)images {
    
    // Save new image
    _mImages = images;
    
    // TODO: Make sure that the input and output image are equal in size
    
    // Calculate the fit to zoom
    [self calculateFitToWindowValues];
    
    // Reset the zoom
    self.mCurrentZoom = 1.0;
    
    // Calculate size based on magnifcation level
    [self contentViewSize];
    
    // Scale current window
    [self scaleCurrentImage];
    
    [self scrollToCenter];

    // Redisplay
    [self setNeedsDisplay:YES];
}


- (NSPoint) drawingOffset {
    NSPoint offset = CGPointZero;
    offset.x = (self.frame.size.width - self.mCurrentImage.extent.size.width)/2.0;
    offset.y = (self.frame.size.height - self.mCurrentImage.extent.size.height)/2.0;
    return offset;
}

- (void)drawRect:(NSRect)dirtyRect {
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
   
    
    if (self.mCurrentImage != nil) {
        if (self.mContext == nil) {
            self.mContext = [CIContext contextWithCGContext:context options:nil];
        }
       

        CGRect dst = dirtyRect;
        CGRect src = dirtyRect;
        CGPoint offset = CGPointZero;
        offset.x = (self.frame.size.width - self.mCurrentImage.extent.size.width)/2.0;
        offset.y = (self.frame.size.height - self.mCurrentImage.extent.size.height)/2.0;
       
        dst.origin.x += offset.x;
        dst.origin.y += offset.y;

        [self.mContext drawImage:self.mCurrentImage inRect:dst fromRect:src];
    }
    else {
        
    }
}

- (void) displayImage:(MainViewDisplayedImage)newImage {
    self.displayedImage = newImage;
    [self scaleCurrentImage];
    [self setNeedsDisplay:YES];
}


#pragma mark - Defunct Code

- (void) drawCenterPointWithContext:(CGContextRef) currentContext {
    [[NSColor whiteColor] set];
    /* Get the current graphics context */
    CGPoint superViewMidPoint = CGPointMake(self.superview.frame.size.width/2.,self.superview.frame.size.height/2);
    CGPoint midPoint = [self convertPoint:superViewMidPoint fromView:self.superview];
    midPoint.x += self.visibleRect.origin.x;
    midPoint.y += self.visibleRect.origin.y;

    NSLog(@"\n\n");
    NSLog(@"Parent frame: %@",NSStringFromRect(self.superview.frame));
    NSLog(@"My Frame: %@",NSStringFromRect(self.frame));
    NSLog(@"My Bounds: %@",NSStringFromRect(self.bounds));


//    NSLog(@"draw dirtyRect: %@",NSStringFromRect(dirtyRect));
    NSLog(@"frameMidPoint: %@",NSStringFromPoint((NSPoint) midPoint));
    NSLog(@"superViewMidPoint: %@",NSStringFromPoint((NSPoint) superViewMidPoint));
    NSLog(@"draw visibleRec: %@",NSStringFromRect(self.visibleRect));
//    NSPoint currentScrollPoint = self.visibleRect.origin;
    CGPoint x1 = midPoint;
    x1.x -= 25;
    CGPoint x2 = midPoint;
    x2.x += 25;

    /* Set the width for the line */
    CGContextSetLineWidth(currentContext,1.0f);
    /* Start the line at this point */
    CGContextMoveToPoint(currentContext,x1.x,x1.y);
    /* And end it at this point */

    CGContextAddLineToPoint(currentContext,x2.x,x2.y);
    x1 = midPoint;
    x1.y -= 25;
    x2 = midPoint;
    x2.y += 25;
    CGContextMoveToPoint(currentContext,x1.x,x1.y);
    /* And end it at this point */

    CGContextAddLineToPoint(currentContext,x2.x,x2.y);


    /* Use the context's current color to draw the line */
    CGContextStrokePath(currentContext);

}


@end
