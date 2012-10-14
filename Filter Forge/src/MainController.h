//
//  RootViewController.h
//  Filter Forge
//
//  Created by Paul Bombach on 9/23/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

#pragma mark - Forward Declarations

@class FilterChain;
@class MainView;

typedef enum {
    ZOOM_IN = 0,
    ZOOM_OUT = 1,
    ZOOM_FIT = 2
} ZOOM_CONTROLS;


@interface MainController : NSObject
{
    // UI Elements
    
  
    
    
    // Model
    __strong FilterChain *chain;
}

// Actions
- (IBAction)zoomButtonClicked:(id)sender;
#pragma mark - Actions
- (IBAction)inputButtonClicked:(id)sender;
- (IBAction)edgeButtonClicked:(id)sender;
- (IBAction)outputButtonClicked:(id)sender;
@property (weak) IBOutlet MainView *experimentalImageView;
@property (weak) IBOutlet NSSegmentedControl *zoomButtons;


#pragma mark - Properties
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSView *contentView;


#pragma mark - Core Logic
- (void) modelChanged:(NSNotification *) sender;

@end
