//
//  BESChain.m
//  Filter Forge
//
//  Created by Paul Bombach on 9/23/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//


#import <Quartz/Quartz.h>
#import "FilterChain.h"

@implementation FilterChain

NSString *const BESCHAIN_MODEL_CHANGED = @"BESCHAIN_MODEL_CHANGED";

- (void) setFileURL:(NSURL *)_fileURL
{
    // Don't do anything if the file hasn't changed
    if ([fileURL isEqual:_fileURL]) {
        return;
    }
    
    fileURL = _fileURL;
    [self process];
    
    // Notify controller that image is dirty
   
}

//- (void) getImage
-(void) process {

    _inputImage = [CIImage imageWithContentsOfURL:fileURL];


    
    NSLog(@"%@",_inputImage.properties);
    
    CIFilter *filter = [CIFilter filterWithName:@"CIAffineTransform"];
    NSAffineTransform *scaleAndRotate = [NSAffineTransform transform];
    
    NSAffineTransformStruct cgAffineTransform = [self transformForImage:_inputImage];
    [scaleAndRotate setTransformStruct:cgAffineTransform];

    [filter setValue:scaleAndRotate forKey:kCIInputTransformKey];
    [filter setValue:_inputImage forKey:kCIInputImageKey];
   
   


    result = [filter valueForKey:kCIOutputImageKey]; // 4
//    image = result;
    
//      NSLog(@"%f %f %f %f",image.extent.origin.x,image.extent.origin.y,image.extent.size.width,image.extent.size.height);

     [[NSNotificationCenter defaultCenter] postNotificationName:BESCHAIN_MODEL_CHANGED object:self];

}
- (CIImage *) getOutputImage {
    return result;
    
}

#pragma mark - MainViewDataSource


- (NSDictionary *) largeImages {
    return @{kInputImage:result};
}

# pragma mark - Scale Calculations

// Getter for image dpi width value
//
- (float) dpiWidthForImage:(CIImage *) ciImage
{
    NSDictionary *properties = [ciImage properties];

    NSNumber* val = [properties objectForKey:(id)kCGImagePropertyDPIWidth];
    float  f = [val floatValue];
    return (f==0 ? 72 : f); // return default 72 if none specified
}


// Getter for image dpi height value
//
- (float) dpiHeightForImage:(CIImage *) ciImage
{
    NSDictionary *properties = [ciImage properties];
    NSNumber* val = [properties objectForKey:(id)kCGImagePropertyDPIHeight];
    float  f = [val floatValue];
    return (f==0 ? 72 : f); // return default 72 if none specified
}


// Getter for display orientation of the image.
//
- (int) orientationForImage:(CIImage *) ciImage
{
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
//
- (NSAffineTransformStruct) transformForImage:(CIImage *)ciImage
{
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
