//
//  BESMainView.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewDataSource.h"



@interface MainView : NSView
{
    CGFloat fitToWindowZoom;
    CGPoint fitToWindowOffset;
    NSDictionary *mImages;
    CIContext *mContext;
    CIImage *mCurrentImage;
    CGFloat mCurrentZoom;
    CGPoint mCurrentOffset;
}

//- (void) modelChanged;

- (CIImage *) inputImage;
- (void) setImages:(NSDictionary *) images;
- (NSDictionary *) images;
- (void) scrollToCenter;

@property (weak) id <MainViewDataSource> dataSource;

@end
