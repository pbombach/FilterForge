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
    // Model
    __strong FilterChain *chain;
}

// Actions
- (IBAction)zoomButtonClicked:(id)sender;
- (IBAction)imageSelectionButtonClicked:(id)sender;

#pragma mark - Actions
- (IBAction)inputButtonClicked:(id)sender;
- (IBAction)edgeButtonClicked:(id)sender;
- (IBAction)outputButtonClicked:(id)sender;

@property (weak) IBOutlet MainView *mainView;
@property (weak) IBOutlet NSSegmentedControl *zoomButtons;


#pragma mark - Properties
@property (weak) IBOutlet NSSegmentedControl *imageSelectionButtons;

#pragma mark - Core Logic
- (void) modelChanged:(NSNotification *) sender;

@end
