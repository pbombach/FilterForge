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

@implementation MainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:NSViewFrameDidChangeNotification object:self.superview];
        mCurrentZoom = 1.0;
    }
    
    return self;
}


- (void)sizeChanged:(NSNotification *)sender {

    [self contentViewSize];
    
    CGFloat effectiveZoom = mCurrentZoom*fitToWindowZoom;
    
    [self calculateFitToWindowValues];
    mCurrentZoom = MAX(1,effectiveZoom/fitToWindowZoom);

    [self scaleCurrentImage];
    
    [self setNeedsDisplay:YES];
}

- (void) setZoom:(CGFloat)m atPoint:(CGPoint) point {
    
    //mCurrentZoom = zoom;
    

    
    mCurrentZoom *= 1+m;
    mCurrentZoom = MAX(1,MIN(200, mCurrentZoom));

    
   // NSLog(@"Magnify: %f",mCurrentZoom);
    


    NSPoint currentScrollPoint = self.visibleRect.origin;
    NSPoint newScrollPoint = currentScrollPoint;
    
    [self contentViewSize];
    
    [self scaleCurrentImage];

    
    if ( !CGPointEqualToPoint(point, CGPointZero)) {
        m = m+1;

        if (mCurrentImage.extent.size.height > self.superview.frame.size.height) {
            newScrollPoint.y = (m-1)*point.y + m*currentScrollPoint.y;
        }
        
        if (mCurrentImage.extent.size.width > self.superview.frame.size.width) {
            newScrollPoint.x = (m-1)*point.x + m*currentScrollPoint.x;
        }

        NSLog(@"Point: %f %f",newScrollPoint.x,newScrollPoint.y);

    }
    [self scrollPoint:newScrollPoint];
   
    
//    [self setNeedsDisplay:YES];

    
}

- (void) magnifyWithEvent:(NSEvent *)event {
    
//    CGFloat zoom = mCurrentZoom*([event magnification]+1);
    CGFloat m = [event magnification];
//
    
    // Only change offset if image exceeds window size
    

    
//    if (mCurrentImage.extent.size.height > self.superview.frame.size.height) {
//        newScrollPoint.y = (m-1)*event.locationInWindow.y +m*currentScrollPoint.y;
//    }
//    
//    if (mCurrentImage.extent.size.width > self.superview.frame.size.width) {
//        newScrollPoint.x = (m-1)*event.locationInWindow.x +m*currentScrollPoint.x;
//    }

//    zoom = MAX(1,MIN(200,zoom));
    [self setZoom:m atPoint:event.locationInWindow];
//    [self setZoom:m atPoint:CGPointZero];
    
//    [self scrollPoint:newScrollPoint];

//    mCurrentZoom *= 1+event.magnification;
//    mCurrentZoom = MAX(1,MIN(200, mCurrentZoom));
//
//
//    [self contentViewSize];
//
//    
//    NSLog(@"Magnify: %f",mCurrentZoom);
//    [self scaleCurrentImage];
//    
//    // Only change offset if image exceeds window size
//    NSPoint currentScrollPoint = self.visibleRect.origin;
//    CGFloat m = 1 + [event magnification];
//
//    NSPoint newScrollPoint = currentScrollPoint;
//
//    if (mCurrentImage.extent.size.height > self.superview.frame.size.height) {
//        newScrollPoint.y = (m-1)*event.locationInWindow.y +m*currentScrollPoint.y;
//    }
//    
//    if (mCurrentImage.extent.size.width > self.superview.frame.size.width) {
//        newScrollPoint.x = (m-1)*event.locationInWindow.x +m*currentScrollPoint.x;
//    }
//    
//    [self scrollPoint:newScrollPoint];
//    [self setNeedsDisplay:YES];
    
}


- (void) contentViewSize {
    CGSize size = CGSizeZero;
    CIImage *inputImage = [self inputImage];
    
    if ( inputImage == nil) {
        size = self.superview.frame.size;
    }
    else {
        size.width = MAX(mCurrentZoom*fitToWindowZoom*inputImage.extent.size.width, self.superview.frame.size.width);
        size.height = MAX(mCurrentZoom*fitToWindowZoom*inputImage.extent.size.height, self.superview.frame.size.height);
    }
    CGRect frame = self.frame;
    frame.size = size;
    [self setFrame:frame];
}

- (CIImage *)inputImage {
    CIImage *inputImage = nil;
    if ( self.images != nil) {
        inputImage = self.images[kInputImage];
    }
    return inputImage;
}

- (void) calculateFitToWindowValues {
    CIImage *inputImage = [self inputImage];
    CGFloat wr = self.superview.frame.size.width/inputImage.extent.size.width;
    CGFloat hr =self.superview.frame.size.height/inputImage.extent.size.height;
    fitToWindowZoom = MIN(wr,hr);


}

- (NSDictionary *) images {
    return mImages;
}

- (void) scaleCurrentImage {
    
    NSAffineTransform *scale = [NSAffineTransform transform];
    [scale scaleBy:fitToWindowZoom*mCurrentZoom];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    
    [filter setValue:scale forKey:kCIInputTransformKey];
    
    CIImage *inputImage = [self inputImage];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    
    mCurrentImage = [filter valueForKey:kCIOutputImageKey];

    
}

- (void) scrollToCenter {
    
    CGPoint offset = CGPointZero;
    offset.x = MAX(0,-(self.superview.frame.size.width - mCurrentImage.extent.size.width)/2.0);
    offset.y = MAX(0,-(self.superview.frame.size.height - mCurrentImage.extent.size.height)/2.0);
    
    [self scrollPoint:offset];

}
- (void) setImages:(NSDictionary *)images {
    
    // Save new image
    mImages = images;
    
    // TODO: Make sure that the input and output image are equal in size
    
    // Calculate the fit to zoom
    [self calculateFitToWindowValues];
    
    // Reset the zoom
    mCurrentZoom = 1.0;
    
    // Calculate size based on magnifcation level
    [self contentViewSize];
    
    // Scale current window
    [self scaleCurrentImage];
    
    [self scrollToCenter];

    // Redisplay
    [self setNeedsDisplay:YES];
}


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
   
    
    if (mCurrentImage != nil) {
        if (mContext == nil) {
            mContext = [CIContext contextWithCGContext:context options:nil];
        }
       

        CGRect dst = dirtyRect;
        CGRect src = dirtyRect;
        CGPoint offset = CGPointZero;
        offset.x = (self.frame.size.width - mCurrentImage.extent.size.width)/2.0;
        offset.y = (self.frame.size.height - mCurrentImage.extent.size.height)/2.0;
       
        dst.origin.x += offset.x;
        dst.origin.y += offset.y;
//        NSLog(@"Offset: %@",NSStringFromPoint((NSPoint) offset));
//        NSLog(@"Frame: %@",NSStringFromRect((NSRect) self.frame));
//        NSLog(@"Image: %@",NSStringFromRect((NSRect) mCurrentImage.extent));
        

        [mContext drawImage:mCurrentImage inRect:dst fromRect:src];
    }
    else {
        
    }
}

@end
