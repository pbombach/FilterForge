//
//  ThresholdAndMap.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Quartz/Quartz.h>

extern NSString * const kThresholdAndMapScale; //= @"alphaScale";
extern NSString * const kThresholdAndMapOutputValue;// = @"OutputValue";
extern NSString * const kThresholdAndMapMapColor;
extern NSString * const kThresholdAndMapName;

@interface ThresholdAndMap : CIFilter
{
    CIImage   *inputImage;
    CIImage   *outputImage;
    NSNumber  *alphaScale;
    NSColor   *mapColor;
}

@end
