//
//  RootViewController.m
//  Filter Forge
//
//  Created by Paul Bombach on 9/23/12.
//  Copyright (c) 2012 Blue Eagle Software. All rights reserved.
//

#import "MainController.h"
#import "FilterChain.h"
#import <QuartzCore/QuartzCore.h>
#import "MainView.h"

@interface MainController ()

@end

@implementation MainController

- (id) init {
    self = [super init];
    if (self) {
        // stuff
        
        // Create an instance of the chain model
        chain = [[FilterChain alloc]init];
        
        // Register for notifications from the chain model
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelChanged:) name:BESCHAIN_MODEL_CHANGED object:nil];
    }
    return self;
}

#pragma mark - Actions

- (IBAction)inputButtonClicked:(id)sender {
    
    // Prompt the user for a file dialog
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel runModal];
    NSLog(@"Files: %@",openPanel.URL);
    
    // Set the file in the chain
    [chain setFileURL:openPanel.URL];

//    CIContext *context = [CIContext contextWithOptions:nil];
    
    //CGContextRef context =
}

- (IBAction)edgeButtonClicked:(id)sender {
    [self.experimentalImageView setZoom:1.0 withPoint:CGPointZero];
}

- (IBAction)outputButtonClicked:(id)sender {
}

#pragma mark - Core Logic

- (void)modelChanged:(NSNotification *)sender {
    NSLog(@"Model changed");
    self.experimentalImageView.images = chain.largeImages;
}

#pragma mark - BESMainViewDataSource

#pragma mark - NIB Stuff

- (void) awakeFromNib {
    self->_experimentalImageView.dataSource = chain;
}

- (IBAction)zoomButtonClicked:(id)sender {
    long clickedSegment = [sender selectedSegment];
    switch (clickedSegment) {
        case ZOOM_IN:
            break;
        case ZOOM_OUT:
            break;
        case ZOOM_FIT:
            [self.experimentalImageView setZoom:1.0 withPoint:CGPointZero];
            break;
        default:
            break;
    }
}

@end
