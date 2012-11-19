//
//  SettingsController.m
//  Filter Forge
//
//  Created by Paul Bombach on 11/12/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "SettingsController.h"
#import "MainController.h"
#import "FilterChain.h"

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
    
    [self updateInterface];
}

- (void) setColorUIIsEnabled:(BOOL) enabled {
    self.mapColorLabel.enabled = enabled;
    self.mapColorSelector.enabled = enabled;
    
}

- (void) updateInterface {
    [self.mapColorSelector setColor:self.filterChain.maskColor];
    self.opacitySlider.floatValue = self.filterChain.opacity;
    
}

- (IBAction)opacitySliderMoved:(id)sender {
    NSSlider *slider = (NSSlider *) sender;
    self.filterChain.opacity = [slider floatValue];
}

- (IBAction)filterCheckBoxToggled:(id)sender {
    if ( [((NSObject *)sender) isKindOfClass:[NSButton class]] ) {
        NSInteger state = [(NSButton *)sender state];
        [self setColorUIIsEnabled:(state == NSOnState)];
    }
    else {
        NSLog(@"%s:%d Expected sender to be NSButton, but found %@",__FILE__,__LINE__,
              [[sender class] description]);
    }
}

- (IBAction)colorChanged:(id)sender {
    NSColor *maskColor = [self.mapColorSelector color];
    self.filterChain.maskColor = maskColor;
}

@end
