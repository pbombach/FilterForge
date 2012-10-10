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
        mCurrentZoom = 1.0;
    }
    
    return self;
}


- (void)sizeChanged:(NSNotification *)sender {
    [self contentViewSize];
    
    [self calculateFitToWindowValues];
    [self scaleCurrentImage];
}


- (void) contentViewSize {
    CGSize size = CGSizeZero;
    if ( mCurrentImage == nil) {
        size = self.superview.frame.size;
    }
    else {
        size.width = MAX(mCurrentZoom*mCurrentImage.extent.size.width, self.superview.frame.size.width);
        size.height = MAX(mCurrentZoom*mCurrentImage.extent.size.height, self.superview.frame.size.height);
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
//    NSLog(@"%f %f",wr,hr);
    fitToWindowZoom = MIN(wr,hr);
    
//    fitToWindowZoom = MIN(self.frame.size.width/inputImage.extent.size.width, self.frame.size.height/inputImage.extent.size.height);

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

    
}

- (void) setImages:(NSDictionary *)images {
    
    // Save new image
    mImages = images;
    
    // TODO: Make sure that the input and output image are equal in size
    
    // Calculate the fit to zoom
    [self calculateFitToWindowValues];
    
    // Scale current window
    [self scaleCurrentImage];
    
//    CGRect frame = self.frame;
//    frame.size = mCurrentImage.extent.size;
//    frame.origin = fitToWindowOffset;
//    CGRect parentFrame = [self superview].frame;
//    [self setFrame:frame];
    
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
        offset.x = MAX(0,(self.frame.size.width - mCurrentImage.extent.size.width)/2.0);
        offset.y = MAX(0,(self.frame.size.height - mCurrentImage.extent.size.height)/2.0);
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
