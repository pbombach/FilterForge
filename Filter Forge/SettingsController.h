//
//  SettingsController.h
//  Filter Forge
//
//  Created by Paul Bombach on 11/12/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainController;
@class FilterChain;

@interface SettingsController : NSWindowController
{
}
- (IBAction)opacitySliderMoved:(id)sender;
- (IBAction)filterCheckBoxToggled:(id)sender;
- (IBAction)colorChanged:(id)sender;

@property (weak) IBOutlet NSTextField *mapColorLabel;
@property (weak) IBOutlet NSColorWell *mapColorSelector;
@property (weak) IBOutlet NSSlider *opacitySlider;

@property (weak) FilterChain *filterChain;

@property (weak) MainController *mainController;

@end
