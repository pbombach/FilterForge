//
//  BESMainViewDataSource.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kInputImageKey;
extern NSString * const kOutputImageKey;
extern NSString * const kCompositeImageKey;

@protocol MainViewDataSource <NSObject>

- (NSDictionary *) largeImages;

@end