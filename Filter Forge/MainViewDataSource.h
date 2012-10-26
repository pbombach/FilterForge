//
//  BESMainViewDataSource.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString * const kInputImage = @"inputImage";
static NSString * const kOutputImage = @"outputImage";

@protocol MainViewDataSource <NSObject>

- (NSDictionary *) largeImages;

@end
