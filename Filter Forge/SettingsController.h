//
//  SettingsController.h
//  Filter Forge
//
//  Created by Paul Bombach on 11/12/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MainController;

@interface SettingsController : NSWindowController
{
}
- (IBAction)opacitySliderMoved:(id)sender;

@property (weak) MainController *mainController;


@end
