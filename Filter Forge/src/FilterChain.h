//
//  BESChain.h
//  Filter Forge
//
//  Created by Paul Bombach on 9/23/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const BESCHAIN_MODEL_CHANGED;// = @"BESCHAIN_MODEL_CHANGED_NOTIFICAITON";
extern NSString * const kInputImageChangedKey;
extern NSString * const kOutputImageChangedKey;
extern NSString * const kCompositeImageChangedKey;

@interface FilterChain : NSObject
{
    float _opacity;
    NSColor *_maskColor;
}


@property (strong) CIImage *inputImage;
@property (strong) CIImage *outputImage;
@property (strong) CIImage *compositeImage;

@property (assign,nonatomic) float opacity;
@property (strong) NSColor * maskColor;
@property (assign,nonatomic) BOOL isMask;
@property (strong) CIFilter *userSelectedFilter;

- (void) setFileURL:(NSURL *) fileURL;
- (void) setFilterChanged;

@end
