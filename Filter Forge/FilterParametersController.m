//
//  FilterParametersController.m
//  Filter Forge
//
//  Created by Paul Bombach on 11/25/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Quartz/Quartz.h>

#import "FilterParametersController.h"

@interface FilterParametersController ()

@end

@implementation FilterParametersController

- (id) init {
    self = [super initWithWindowNibName:@"FilterParametersView"];
//    self = [super init];
    if (self != nil) {
        
        
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    

    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    NSDictionary *uiConfiguration = @{IKUISizeFlavor:IKUISizeRegular,kCIUIParameterSet:kCIUISetDevelopment};

    NSArray *excludedKeys = @[kCIInputImageKey];

    IKFilterUIView *filterView = [self.filter viewForUIConfiguration:uiConfiguration excludedKeys:excludedKeys];
    [filterView setAutoresizingMask:NSViewMaxXMargin|NSViewMinXMargin|NSViewWidthSizable];
    [filterView setAutoresizesSubviews:NO];
    NSString *h = [filterView performSelector:@selector(_subtreeDescription)];
    NSLog(@"%@",h);


    NSRect filterViewRect = filterView.frame;
  
  
    NSRect windowRect = filterViewRect;
    windowRect.origin.x = filterViewRect.size.width;
    windowRect.origin.y = filterViewRect.size.height;
    windowRect.size.width += 30.;
    windowRect.size.height += 20;

    self.window.contentView = filterView;
    [self.window setFrame:windowRect display:YES];

}



@end
