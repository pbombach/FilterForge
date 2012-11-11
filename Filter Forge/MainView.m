//
//  BESMainView.m
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//
#import <Quartz/Quartz.h>

#import "MainView.h"

typedef enum {
    ZoomDirectionIn = 0,
    ZoomDirectionOut = 1,
} ZoomDirection;

NSString * const kInputImageKey = @"inputImage";
NSString * const kOutputImageKey = @"outputImage";
NSString * const kCompositeImageKey = @"inputPlusOutputImage";


static CGFloat const defaultZoomInMagnification = .41421356237309; // magnification = 1+m => 1 - sqrt(2)
static CGFloat const defaultZoomOutMagnification = -0.292893218813450; // 1 - 1/sqrt(2)
static CGFloat const ZoomMax = 200.;
static CGFloat const ZoomMin = 1.0;

@interface MainView ()

@property (assign) CGFloat fitToWindowZoom;
@property (assign) CGPoint fitToWindowOffset;
@property (assign) CGFloat currentZoom;
@property (assign) CGPoint currentOffset;

@property (strong) CIContext *context;
@property (strong) CIImage *currentImage;
@property (copy) NSString *displayedImage;

@end


@implementation MainView

@synthesize images = _images;

# pragma mark - Initializer

- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sizeChanged:) name:NSViewFrameDidChangeNotification object:self.superview];
        self.currentZoom = 1.0;
        self.displayedImage = kOutputImageKey;
    }
    
    return self;
}

# pragma mark - Events and Notification Handlers

- (void) sizeChanged:(NSNotification *)sender {
    
    [self contentViewSize];
    CGFloat effectiveZoom = self.currentZoom*self.fitToWindowZoom;
    [self calculateFitToWindowValues];
    self.currentZoom = MAX(1,effectiveZoom/self.fitToWindowZoom);
    [self scaleCurrentImage];
    [self setNeedsDisplay:YES];
}

- (void) magnifyWithEvent:(NSEvent *)event {
    
    CGFloat m = [event magnification];
    [self scaleZoom:m atPoint:event.locationInWindow];
}

# pragma mark - Getters and Setters

- (void) setImages:(NSDictionary *)images {
    
    // Save new image
    _images = images;
    
    // TODO: Make sure that the input and output image are equal in size
    
    // Calculate the fit to zoom
    [self calculateFitToWindowValues];
    
    // Reset the zoom
    self.currentZoom = 1.0;
    
    // Calculate size based on magnifcation level
    [self contentViewSize];
    
    // Scale current window
    [self scaleCurrentImage];
    
    [self scrollToCenter];
    
    // Redisplay
    [self setNeedsDisplay:YES];
}

# pragma mark - Public API

- (void) resetZoom {
    self.currentZoom = 1.0;
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

- (void) displayImage:(NSString *)newImage {
    
    self.displayedImage = newImage;
    [self scaleCurrentImage];
    [self setNeedsDisplay:YES];
    
    
}

# pragma mark - Private Implementation

- (void) zoomInOrOut:(ZoomDirection) zoomDirection {
    
    // Calculate view midpoint
    CGPoint midPoint;
    midPoint.x = self.superview.frame.size.width/2.0;
    midPoint.y = self.superview.frame.size.height/2.0;
    
    // Select magnification
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
    
    // Set scale
    [self scaleZoom:magnification atPoint:midPoint];
}

- (void) scaleZoom:(CGFloat)m atPoint:(CGPoint) point {
    
    // Scale zoom and clip it to maximum value
    self.currentZoom *= 1+m;
    self.currentZoom = MAX(ZoomMin,MIN(ZoomMax, self.currentZoom));
    
    NSPoint currentScrollPoint = self.visibleRect.origin;
    NSPoint newScrollPoint = currentScrollPoint;
    NSPoint drawingOffset = [self drawingOffset];
    
    [self contentViewSize];
    
    [self scaleCurrentImage];
    
    if ( !CGPointEqualToPoint(point, CGPointZero)) {
        m = m+1;
        
        if (self.currentImage.extent.size.height > self.superview.frame.size.height) {
            newScrollPoint.y = (m-1)*point.y + m*(currentScrollPoint.y+drawingOffset.y);
        }
        
        if (self.currentImage.extent.size.width > self.superview.frame.size.width) {
            newScrollPoint.x = (m-1)*point.x + m*(currentScrollPoint.x+drawingOffset.x);
        }
    }
    [self scrollPoint:newScrollPoint];
}

- (void) contentViewSize {
    CGSize size = CGSizeZero;
    CIImage *inputImage = [self imageForKey:kInputImageKey];
    
    if ( inputImage == nil) {
        size = self.superview.frame.size;
    }
    else {
        size.width = MAX(self.currentZoom*self.fitToWindowZoom*inputImage.extent.size.width, self.superview.frame.size.width);
        size.height = MAX(self.currentZoom*self.fitToWindowZoom*inputImage.extent.size.height, self.superview.frame.size.height);
    }
    CGRect frame = self.frame;
    frame.size = size;
    [self setFrame:frame];
}

- (CIImage *) imageForKey:(NSString *) key {
    CIImage *image = nil;
    if ( self.images != nil) {
        image = self.images[key];
    }
    return image;
    
}

- (void) calculateFitToWindowValues {
    CIImage *inputImage = [self imageForKey:kInputImageKey];
    CGFloat wr = self.superview.frame.size.width/inputImage.extent.size.width;
    CGFloat hr =self.superview.frame.size.height/inputImage.extent.size.height;
    self.fitToWindowZoom = MIN(wr,hr);
}

- (void) scaleCurrentImage {
    
    NSAffineTransform *scale = [NSAffineTransform transform];
    [scale scaleBy:self.fitToWindowZoom*self.currentZoom];
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    [filter setValue:scale forKey:kCIInputTransformKey];
    CIImage *image;
    image = [self imageForKey:self.displayedImage];
    if (image != nil ) {
        [filter setValue:image forKey:kCIInputImageKey];
        self.currentImage = [filter valueForKey:kCIOutputImageKey];
    }
}

- (void) scrollToCenter {
    
    CGPoint offset = CGPointZero;
    offset.x = MAX(0,-(self.superview.frame.size.width - self.currentImage.extent.size.width)/2.0);
    offset.y = MAX(0,-(self.superview.frame.size.height - self.currentImage.extent.size.height)/2.0);
    [self scrollPoint:offset];
}

- (NSPoint) drawingOffset {
    NSPoint offset = CGPointZero;
    offset.x = (self.frame.size.width - self.currentImage.extent.size.width)/2.0;
    offset.y = (self.frame.size.height - self.currentImage.extent.size.height)/2.0;
    return offset;
}

- (void) drawRect:(NSRect)dirtyRect {
    
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    if (self.currentImage != nil) {
        if (self.context == nil) {
            self.context = [CIContext contextWithCGContext:context options:nil];
        }
        CGRect dst = dirtyRect;
        CGRect src = dirtyRect;
        CGPoint offset = CGPointZero;
        offset.x = (self.frame.size.width - self.currentImage.extent.size.width)/2.0;
        offset.y = (self.frame.size.height - self.currentImage.extent.size.height)/2.0;
        dst.origin.x += offset.x;
        dst.origin.y += offset.y;
        [self.context drawImage:self.currentImage inRect:dst fromRect:src];
    }
}
@end
