//
//  BESMainView.h
//  Filter Forge
//
//  Created by Paul Bombach on 10/3/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainViewDataSource.h"

typedef enum _MainViewDisplayedImage {
    MainViewInputImage              = 0,
    MainViewOutputImage             = 1,
    MainViewInputPlusOutputImage    = 2
} MainViewDisplayedImage;

@interface MainView : NSView
{
}

@property (strong, nonatomic) NSDictionary *images;

- (void) resetZoom;
- (void) zoomIn;
- (void) zoomOut;


- (void) displayImage:(MainViewDisplayedImage)newImage;

@end
