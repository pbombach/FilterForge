//
//  BESChain.m
//  Filter Forge
//
//  Created by Paul Bombach on 9/23/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//


#import <Quartz/Quartz.h>
#import "FilterChain.h"
#import "MaskToAlpha.h"
#import "AlphaBlend.h"

/*
 #pragma mark - Synthesized Properties
 #pragma mark - Initializers and Dealloc
 #pragma mark - Properties
 #pragma mark - Protocols
 #pragma mark - Overridden Methods
 #pragma mark - Instance Methods
 
 */

NSString *const BESCHAIN_MODEL_CHANGED = @"BESCHAIN_MODEL_CHANGED";
NSString * const kInputImageChangedKey = @"InputImageChangedKey";
NSString * const kOutputImageChangedKey = @"InputImageChangedKey";;
NSString * const kCompositeImageChangedKey = @"InputImageChangedKey";;


// Local ivars
@interface FilterChain()

@property (strong) CIFilter *maskToAlpha;
@property (strong) CIFilter *alphaBlend;
@property (strong) CIFilter *userSelectedFilter;
@property (nonatomic, strong) NSURL *fileURL;

@property (assign) bool newInput;
@property (assign) bool refilterInput;
@property (assign) bool reComposite;

@end

@implementation FilterChain


- (id) init {
    self = [super init];
    if (self) {
        self.userSelectedFilter = [CIFilter filterWithName:@"CIEdges"];
        [self.userSelectedFilter setDefaults];
        self.maskToAlpha = nil;
        _opacity = 0.25;
        _maskColor = [NSColor redColor];
        _isMask = YES;
        self.newInput = true;
        self.refilterInput = true;
        self.reComposite = true;
    }
    
    return self;
}

#pragma mark - Public Interface

- (void) setFileURL:(NSURL *) afileURL {
    // Don't do anything if the file hasn't changed
    if ([self.fileURL isEqual:afileURL]) {
        return;
    }
    
    _fileURL = afileURL;
    
    self.newInput = YES;
    self.refilterInput = YES;
    self.reComposite = YES;
    [self process];
    
}

#pragma mark - Private Implementation

// Handle any changes to the model that would require the chain to be recalculated
-(void) process {

    BOOL inputImageChanged = NO;
    BOOL outputImageChanged = NO;
    
    if (self.maskToAlpha == nil) {

        [MaskToAlpha class];
        self.maskToAlpha = [CIFilter filterWithName:kMaskToAlphaName];
        [self.maskToAlpha setDefaults];
    }
    
    if (self.alphaBlend == nil) {
        [AlphaBlend class];
        self.alphaBlend = [CIFilter filterWithName:kAlphaBlendName];
        [self.alphaBlend setDefaults];
    }
    
    if (self.newInput) {
        
        self.inputImage = [CIImage imageWithContentsOfURL:self.fileURL];
        
        CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
        NSAffineTransform *scaleAndRotate = [NSAffineTransform transform];
        
        NSAffineTransformStruct cgAffineTransform = [self transformForImage:_inputImage];
        [scaleAndRotate setTransformStruct:cgAffineTransform];
        
        [filter setValue:scaleAndRotate forKey:kCIInputTransformKey];
        [filter setValue:_inputImage forKey:kCIInputImageKey];
        
        self.inputImage = [filter valueForKey:kCIOutputImageKey]; // 4
        self.newInput = false;
        inputImageChanged = YES;
    }
    
    if (self.refilterInput) {
        [self.userSelectedFilter setValue:_inputImage forKey:kCIInputImageKey];
        self.outputImage = [self.userSelectedFilter valueForKey:kCIOutputImageKey];
        self.refilterInput = false;
        outputImageChanged = YES;
    }
    
    if (self.reComposite) {
    
        CIImage *maskImage;

      
        if (self.isMask) {
            [self.maskToAlpha setValue:_outputImage forKey:kCIInputImageKey];
            [self.maskToAlpha setValue:[NSNumber numberWithFloat:1.0] forKey:kMaskToAlphaScale];
            [self.maskToAlpha setValue:self.maskColor forKey:kMaskToAlphaMapColor];
            maskImage = [self.maskToAlpha valueForKey:kCIOutputImageKey];
        }
        else {
            maskImage = self.outputImage;
        }
        
//        CIFilter *sourceOverFilter = [CIFilter filterWithName:@"CISourceOverCompositing"];
//        [sourceOverFilter setValue:maskImage forKey:kCIInputImageKey];
//        [sourceOverFilter setValue:self.inputImage forKey:kCIInputBackgroundImageKey];
        [self.alphaBlend setValue:maskImage forKey:kAlphaBlendInputImageAKey];
        [self.alphaBlend setValue:self.inputImage forKey:kAlphaBlendInputImageBKey];
        [self.alphaBlend setValue:[NSNumber numberWithFloat:self.opacity] forKey:kAlphaBlendOpacityKey];
        
        self.compositeImage = [self.alphaBlend valueForKey:@"outputImage"];
        self.reComposite = false;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BESCHAIN_MODEL_CHANGED object:self];

}

- (void) setMaskColor:(NSColor *)maskColor {
    _maskColor = maskColor;
    self.reComposite = true;
    [self process];
}
- (NSColor *) maskColor {
    return _maskColor;
}

- (void) setOpacity:(float)opacity {
    _opacity = opacity;
    self.reComposite = true;
    [self process];
}

- (void) setIsMask:(BOOL)isMask {
    _isMask = isMask;
    self.reComposite = true;
    [self process];
}

# pragma mark - Scale Calculations

// Getter for image dpi width value
- (float) dpiWidthForImage:(CIImage *) ciImage {
    NSDictionary *properties = [ciImage properties];

    NSNumber* val = [properties objectForKey:(id)kCGImagePropertyDPIWidth];
    float  f = [val floatValue];
    return (f==0 ? 72 : f); // return default 72 if none specified
}


// Getter for image dpi height value
- (float) dpiHeightForImage:(CIImage *) ciImage {
    NSDictionary *properties = [ciImage properties];
    NSNumber* val = [properties objectForKey:(id)kCGImagePropertyDPIHeight];
    float  f = [val floatValue];
    return (f==0 ? 72 : f); // return default 72 if none specified
}


// Getter for display orientation of the image.
- (int) orientationForImage:(CIImage *) ciImage {
    // If present, the value of the kCGImagePropertyOrientation key is a
    // CFNumberRef with the same value as defined by the TIFF and Exif
    // specifications.  That is:
    //  1 =  row 0 top, col 0 lhs  =  normal
    //  2 =  row 0 top, col 0 rhs  =  flip horizontal
    //  3 =  row 0 bot, col 0 rhs  =  rotate 180
    //  4 =  row 0 bot, col 0 lhs  =  flip vertical
    //  5 =  row 0 lhs, col 0 top  =  rot -90, flip vert
    //  6 =  row 0 rhs, col 0 top  =  rot 90
    //  7 =  row 0 rhs, col 0 bot  =  rot 90, flip vert
    //  8 =  row 0 lhs, col 0 bot  =  rotate -90
    
    NSDictionary *properties = [ciImage properties];
    NSNumber* val = [properties objectForKey:(id)kCGImagePropertyOrientation];
    int orient = [val intValue];
    if (orient<1 || orient>8)
        orient = 1;
    return orient;
}


// Getter for image transform
- (NSAffineTransformStruct) transformForImage:(CIImage *)ciImage {
    float xdpi = [self dpiWidthForImage:ciImage];
    float ydpi = [self dpiHeightForImage:ciImage];
    int orient = [self orientationForImage:ciImage];
    
    float x = (ydpi>xdpi) ? ydpi/xdpi : 1;
    float y = (xdpi>ydpi) ? xdpi/ydpi : 1;
    float w = x * ciImage.extent.size.width;
    float h = y * ciImage.extent.size.height;
    
    NSAffineTransformStruct ctms[8] = {
        { x, 0, 0, y, 0, 0},  //  1 =  row 0 top, col 0 lhs  =  normal
        {-x, 0, 0, y, w, 0},  //  2 =  row 0 top, col 0 rhs  =  flip horizontal
        {-x, 0, 0,-y, w, h},  //  3 =  row 0 bot, col 0 rhs  =  rotate 180
        { x, 0, 0,-y, 0, h},  //  4 =  row 0 bot, col 0 lhs  =  flip vertical
        { 0,-x,-y, 0, h, w},  //  5 =  row 0 lhs, col 0 top  =  rot -90, flip vert
        { 0,-x, y, 0, 0, w},  //  6 =  row 0 rhs, col 0 top  =  rot 90
        { 0, x, y, 0, 0, 0},  //  7 =  row 0 rhs, col 0 bot  =  rot 90, flip vert
        { 0, x,-y, 0, h, 0}   //  8 =  row 0 lhs, col 0 bot  =  rotate -90
    };
    
    return ctms[orient-1];
}

@end