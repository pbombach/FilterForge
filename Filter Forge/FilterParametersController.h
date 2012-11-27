//
//  FilterParametersController.h
//  Filter Forge
//
//  Created by Paul Bombach on 11/25/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FilterParametersController : NSWindowController

@property (strong) CIFilter *filter;
@property (weak) IBOutlet NSView *contentView;

@end
