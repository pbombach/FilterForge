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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:NSViewFrameDidChangeNotification object:self];
        mCurrentZoom = 2.0;
    }
    
    return self;
}


- (void)sizeChanged:(NSNotification *)sender {
//    [self calculateFitToWindowValues];
//    [self scaleCurrentImage];
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
    
    fitToWindowZoom = MIN(self.frame.size.width/inputImage.extent.size.width, self.frame.size.height/inputImage.extent.size.height);

    fitToWindowOffset.x = -(fitToWindowZoom*inputImage.extent.size.width - self.frame.size.width)/2.0;
    fitToWindowOffset.y = -(fitToWindowZoom*inputImage.extent.size.height - self.frame.size.height)/2.0;

}

- (NSDictionary *) images {
    return mImages;
}

- (void) scaleCurrentImage {
    
    NSAffineTransform *scale = [NSAffineTransform transform];
    [scale scaleBy:fitToWindowZoom];
    
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    
    [filter setValue:scale forKey:kCIInputTransformKey];
    
    CIImage *inputImage = [self inputImage];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    
    
    mCurrentImage = [filter valueForKey:kCIOutputImageKey];
    
    // Offsets
    mCurrentOffset.x = (fitToWindowZoom*inputImage.extent.size.width - self.frame.size.width);
    mCurrentOffset.y = (fitToWindowZoom*inputImage.extent.size.height - self.frame.size.height);
    mCurrentOffset.x = 0.0;
//    mCurrentOffset.y = 0.0;


    
}

- (void) setImages:(NSDictionary *)images {
    
    // Save new image
    mImages = images;
    
    // TODO: Make sure that the input and output image are equal in size
    
    // Calculate the fit to zoom
    [self calculateFitToWindowValues];
    
    // Scale current window
    [self scaleCurrentImage];
    
    CGRect frame = self.frame;
    frame.size = mCurrentImage.extent.size;
    frame.origin = fitToWindowOffset;
    CGRect parentFrame = [self superview].frame;
    [self setFrame:frame];
    
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
       

//        CGRect destRect = dirtyRect;
//        CGRect src = dirtyRect;
//        src.origin.x += mCurrentOffset.x;
//        src.origin.y += mCurrentOffset.y;
//        destRect.origin.x -= fitToWindowOffset.x;
//        destRect.origin.y -= fitToWindowOffset.y;
        [mContext drawImage:mCurrentImage inRect:dirtyRect fromRect:dirtyRect];
    }
    else {
        
    }
}

@end
