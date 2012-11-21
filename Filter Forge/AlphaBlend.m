//
//  AlphaBlend.m
//  Filter Forge
//
//  Created by Paul Bombach on 10/27/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "AlphaBlend.h"


static CIKernel *alphaBlendKernel = nil;

NSString * const kAlphaBlendOpacityKey = @"opacity";
NSString * const kAlphaBlendInputImageAKey = @"inputImageA";
NSString * const kAlphaBlendInputImageBKey = @"inputImageB";
NSString * const kAlphaBlendName = @"AlphaBlend";


@implementation AlphaBlend


+ (CIFilter *)filterWithName: (NSString *)name
{
    CIFilter  *filter;
    filter = [[self alloc] init];
    return filter;
}

+ (void)initialize
{
    [CIFilter registerFilterName:kAlphaBlendName
                     constructor: (id<CIFilterConstructor>) self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"AlphaBlend", kCIAttributeFilterDisplayName,
                                   [NSArray arrayWithObjects:
                                    kCICategoryColorAdjustment, kCICategoryVideo,
                                    kCICategoryStillImage,kCICategoryInterlaced,
                                    kCICategoryNonSquarePixels,nil], kCIAttributeFilterCategories,
                                   nil]
     ];
}

- (id)init
{
    if(alphaBlendKernel == nil)// 1
    {
        NSBundle    *bundle = [NSBundle bundleForClass: [self class]];
        NSString    *code2 = [NSString stringWithContentsOfFile:[bundle pathForResource:@"MaskToAlpha" ofType:@"cikernel"] encoding:NSASCIIStringEncoding error:NULL];
        NSArray     *kernels = [CIKernel kernelsWithString: code2];
        alphaBlendKernel = [kernels objectAtIndex:1] ;
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
    
    return @{kAlphaBlendOpacityKey:opacityAttrib};

}

- (CIImage *)outputImage
{

    CISampler *srcA = [CISampler samplerWithImage: inputImageA];
    CISampler *srcB =[CISampler samplerWithImage: inputImageB];

    CIImage *outImage = [self apply:alphaBlendKernel,srcA,srcB,opacity,kCIApplyOptionDefinition, [srcA definition],nil] ;

    return outImage;
}

@end
