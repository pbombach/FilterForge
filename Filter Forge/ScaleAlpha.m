//
//  ScaleAlpha.m
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "ScaleAlpha.h"


static CIKernel *ScaleAlphaKernel = nil;

NSString * const kScaleAlphaOpacityKey = @"opacity";
NSString * const kScaleAlphaInputImageAKey = @"inputImageA";
NSString * const kScaleAlphaInputImageBKey = @"inputImageB";
NSString * const kScaleAlphaName = @"ScaleAlpha";


@implementation ScaleAlpha


+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    return filter;
}

+ (void)initialize
{
    [CIFilter registerFilterName:kScaleAlphaName
                     constructor: (id<CIFilterConstructor>) self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"ScaleAlpha", kCIAttributeFilterDisplayName,
                                   [NSArray arrayWithObjects:
                                    kCICategoryColorAdjustment, kCICategoryVideo,
                                    kCICategoryStillImage,kCICategoryInterlaced,
                                    kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
                                   nil]
     ];
}

- (id)init
{
    if(ScaleAlphaKernel == nil)// 1
    {
        NSBundle    *bundle = [NSBundle bundleForClass: [self class]];
        NSString    *code2 = [NSString stringWithContentsOfFile:[bundle pathForResource:@"ScaleAlpha" ofType:@"cikernel"] encoding:NSASCIIStringEncoding error:NULL];
        NSArray     *kernels = [CIKernel kernelsWithString: code2];
        ScaleAlphaKernel = [kernels objectAtIndex:0] ;
    }
    return [super init];
}

- (CGRect)regionOf: (int)sampler  destRect: (CGRect)rect  userInfo: (NSNumber *)radius
{
    return CGRectInset(rect, -[radius floatValue], 0);
}

- (NSDictionary *)customAttributes
{
    NSDictionary * opacityAttrib =
    @{
        kCIAttributeMin       : @0.0,
        kCIAttributeMax       : @1.0,
        kCIAttributeSliderMin : @0.0,
        kCIAttributeSliderMax : @1.0,
        kCIAttributeDefault   : @0.5,
        kCIAttributeType      : kCIAttributeTypeScalar
    };
    
    return @{kScaleAlphaOpacityKey:opacityAttrib};

}

- (CIImage *)outputImage
{

    CISampler *srcA = [CISampler samplerWithImage: inputImage];
    //    CISampler *srcB =[CISampler samplerWithImage: inputImageB];

//    CIImage *outImage = [self apply:ScaleAlphaKernel,srcA,opacity,kCIApplyOptionDefinition, [srcA definition],nil] ;
    NSDictionary *optionsDictionary = @{kCIApplyOptionDefinition:[srcA definition]};
    CIImage *outImage = [self apply:ScaleAlphaKernel arguments:@[srcA,opacity] options:optionsDictionary];

    return outImage;
}

@end
