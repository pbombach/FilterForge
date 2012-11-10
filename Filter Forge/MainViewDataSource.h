//
//  BESMainViewDataSource.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kInputImage;
extern NSString * const kOutputImage;
extern NSString * const kInputPlusOutputImage;

@protocol MainViewDataSource <NSObject>

- (NSDictionary *) largeImages;

@end
