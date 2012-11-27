//
//  ThresholdAndMap.m
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "ThresholdAndMap.h"


static CIKernel *thresholdAndMap = nil;

NSString * const kThresholdAndMapScale = @"alphaScale";
NSString * const kThresholdAndMapMapColor = @"mapColor";
NSString * const kThresholdAndMapName = @"ThresholdAndMap";


@implementation ThresholdAndMap


+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    return filter;
}

+ (void)initialize
{
    [CIFilter registerFilterName:kThresholdAndMapName
                     constructor: (id<CIFilterConstructor>) self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"ThresholdAndMap", kCIAttributeFilterDisplayName,
                                   [NSArray arrayWithObjects:
                                    kCICategoryColorAdjustment, kCICategoryVideo,
                                    kCICategoryStillImage,kCICategoryInterlaced,
                                    kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
                                   nil]
     ];
}

- (id)init
{
    if(thresholdAndMap == nil)// 1
    {
        NSBundle    *bundle = [NSBundle bundleForClass: [self class]];
        NSString    *code2 = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ThresholdAndMap" ofType:@"cikernel"] encoding:NSASCIIStringEncoding error:NULL];
        NSArray     *kernels = [CIKernel kernelsWithString: code2];
        thresholdAndMap = [kernels objectAtIndex:0] ;
    }
    return [super init];
}

- (CGRect)regionOf: (int)sampler  destRect: (CGRect)rect  userInfo: (NSNumber *)radius
{
    return CGRectInset(rect, -[radius floatValue], 0);
}

- (NSDictionary *)customAttributes
{
    NSDictionary * alphaScaleAttributes =
    @{
        kCIAttributeMin       : @0.0,
        kCIAttributeMax       : @1.0,
        kCIAttributeSliderMin : @0.0,
        kCIAttributeSliderMax : @1.0,
        kCIAttributeDefault   : @0.5,
        kCIAttributeType      : kCIAttributeTypeScalar
    };
    
    NSDictionary * mapColorAttributes =
    @{
    kCIAttributeDefault : [CIColor colorWithRed:1.0
                                          green:1.0
                                           blue:1.0
                                          alpha:1.0]
    };
    
    return @{kThresholdAndMapMapColor:mapColorAttributes,kThresholdAndMapScale:alphaScaleAttributes};

}

- (CIImage *)outputImage
{

    CISampler *src = [CISampler samplerWithImage: inputImage];

    CIImage *outImage = [self apply:thresholdAndMap,src,self->mapColor,kCIApplyOptionDefinition, [src definition],nil] ;

    return outImage;
}

@end
