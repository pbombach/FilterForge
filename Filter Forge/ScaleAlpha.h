//
//  ScaleAlpha.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Quartz/Quartz.h>

extern NSString * const kScaleAlphaOpacityKey;
//extern NSString * const kScaleAlphaInputImageAKey;
//extern NSString * const kScaleAlphaInputImageBKey;
extern NSString * const kScaleAlphaName;


@interface ScaleAlpha : CIFilter
{
    CIImage *inputImage;
    NSNumber  *opacity;
    CIImage   *outputImage;

}

@end
