//
//  MaskToAlpha.m
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "MaskToAlpha.h"


static CIKernel *maskToAlpha = nil;

NSString * const kMaskToAlphaScale = @"alphaScale";
NSString * const kMaskToAlphaOutputValue = @"OutputValue";
NSString * const kMaskToAlphaName = @"PmbMaskToAlpha";


@implementation MaskToAlpha


+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    return filter;
}

+ (void)initialize
{
    [CIFilter registerFilterName:kMaskToAlphaName
                     constructor: (id<CIFilterConstructor>) self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"Mask To Alpha", kCIAttributeFilterDisplayName,
                                   [NSArray arrayWithObjects:
                                    kCICategoryColorAdjustment, kCICategoryVideo,
                                    kCICategoryStillImage,kCICategoryInterlaced,
                                    kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
                                   nil]
     ];
}

- (id)init
{
    if(maskToAlpha == nil)// 1
    {
        NSBundle    *bundle = [NSBundle bundleForClass: [self class]];
        NSString    *code2 = [NSString stringWithContentsOfFile:[bundle pathForResource:@"MaskToAlpha" ofType:@"cikernel"] encoding:NSASCIIStringEncoding error:NULL];
//        NSString    *code = [NSString stringWithContentsOfFile: [bundle
//                                                                 pathForResource: @"MaskToAlpha"
//                                                                 ofType: @"cikernel"]];
        NSArray     *kernels = [CIKernel kernelsWithString: code2];
        maskToAlpha = [kernels objectAtIndex:0] ;
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
    
    NSDictionary *outputValueAttributes =
    @{
        kCIAttributeMin       : @0.0,
        kCIAttributeMax       : @1.0,
        kCIAttributeSliderMin : @0.0,
        kCIAttributeSliderMax : @1.0,
        kCIAttributeDefault   : @0.5,
        kCIAttributeType      : kCIAttributeTypeScalar
    };
    
    return @{kMaskToAlphaOutputValue:outputValueAttributes,kMaskToAlphaScale:alphaScaleAttributes};

}

- (CIImage *)outputImage
{

    NSDictionary * attributes = [self attributes];
    
   // inputImage = [attributes objectForKey:kCIInputImageKey];
    alphaScale = [attributes objectForKey:kMaskToAlphaScale];
    outputValue = [attributes objectForKey:kMaskToAlphaOutputValue];
    float malphaScale = 0.5;
    float moutputValue = 1.0;
    
    CISampler *src = [CISampler samplerWithImage: inputImage];

    CIImage *outImage = [self apply:maskToAlpha,src,[NSNumber numberWithFloat:malphaScale],[NSNumber numberWithFloat:moutputValue],kCIApplyOptionDefinition, [src definition],nil] ;

    return outImage;
}

@end
