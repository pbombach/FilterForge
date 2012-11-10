//
//  MaskToAlpha.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Quartz/Quartz.h>

extern NSString * const kMaskToAlphaScale; //= @"alphaScale";
extern NSString * const kMaskToAlphaOutputValue;// = @"OutputValue";
extern NSString * const kMaskToAlphaName;

@interface MaskToAlpha : CIFilter
{
    CIImage   *inputImage;
    CIImage   *outputImage;
    NSNumber  *alphaScale;
    NSNumber  *outputValue;
}

@end
