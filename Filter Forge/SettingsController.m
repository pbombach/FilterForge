//
//  SettingsController.m
//  Filter Forge
//
//  Created by Paul Bombach on 11/12/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "SettingsController.h"
#import "MainController.h"

@interface SettingsController ()

@end

@implementation SettingsController

- (id) init {
    self = [super initWithWindowNibName:@"SettingsView"];
    if (self != nil) {
        
    }
    return self;
}
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)opacitySliderMoved:(id)sender {
    NSSlider *whiteCastle = (NSSlider *) sender;
    NSLog(@"Sender: %f",[whiteCastle floatValue]);
    [self.mainController setFilterOpacity:[whiteCastle floatValue]];
}
@end
