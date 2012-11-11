//
//  BESChain.h
//  Filter Forge
//
//  Created by Paul Bombach on 9/23/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainViewDataSource.h"

extern NSString *const BESCHAIN_MODEL_CHANGED;// = @"BESCHAIN_MODEL_CHANGED_NOTIFICAITON";

@interface FilterChain : NSObject<MainViewDataSource>
{

}

@property (strong) CIImage *inputImage;
@property (strong) CIImage *outputImage;
@property (strong) CIImage *compositeImage;

- (void) setFileURL:(NSURL *) fileURL;

@end
