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

@interface MainController : NSObject
{
}

// Actions
- (IBAction)zoomButtonClicked:(id)sender;
- (IBAction)imageSelectionButtonClicked:(id)sender;

#pragma mark - Actions
- (IBAction)inputButtonClicked:(id)sender;
- (IBAction)edgeButtonClicked:(id)sender;
- (IBAction)outputButtonClicked:(id)sender;
- (IBAction)settingsButtonClicked:(id)sender;

#pragma mark - Properties
@property (strong) IBOutlet MainView *mainView;
@property (strong) IBOutlet NSSegmentedControl *zoomButtons;
@property (strong) IBOutlet NSWindow *settingsWindow;
@property (strong) IBOutlet NSSegmentedControl *imageSelectionButtons;

#pragma mark - Core Logic
- (void) modelChanged:(NSNotification *) sender;
- (void) setFilterOpacity:(float) opacity;
- (void) setMaskColor:(NSColor *) color;

@end
