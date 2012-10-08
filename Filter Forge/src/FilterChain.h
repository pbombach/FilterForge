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
    NSURL *fileURL;
    CIImage *result;
}

@property (strong) CIImage *inputImage;


- (void) setFileURL:(NSURL *) fileURL;

- (CIImage *) getOutputImage;

@end
