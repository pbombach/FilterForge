//
//  AlphaBlend.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Quartz/Quartz.h>

extern NSString * const kAlphaBlendOpacityKey;
extern NSString * const kAlphaBlendInputImageAKey;
extern NSString * const kAlphaBlendInputImageBKey;
extern NSString * const kAlphaBlendName;


@interface AlphaBlend : CIFilter
{
    CIImage *inputImageA;
    CIImage *inputImageB;
    NSNumber  *opacity;
    CIImage   *outputImage;

}

@end
