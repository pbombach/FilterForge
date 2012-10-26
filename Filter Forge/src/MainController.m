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
        // Create an instance of the chain model
        chain = [[FilterChain alloc]init];
        
        // Register for notifications from the chain model
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelChanged:) name:BESCHAIN_MODEL_CHANGED object:nil];
        self.mDisplayedImage = MainViewInputImage;
    }
    return self;
}

- (void) updateUI {
    
    // Update the displayed image selector
    int imageSelectionButton;
    MainViewDisplayedImage displayedImage;
    switch (self.mDisplayedImage) {
        case MainViewInputImage:
            imageSelectionButton = 0;
            displayedImage = MainViewInputImage;
            break;
        case MainViewOutputImage:
            imageSelectionButton = 1;
            displayedImage = MainViewOutputImage;
            break;
        case MainViewInputPlusOutputImage:
            displayedImage = MainViewInputPlusOutputImage;
            imageSelectionButton = 2;
            break;
        default:
            break;
    }
    [self.imageSelectionButtons setSelectedSegment:imageSelectionButton];
    
    // Tell the MainView to load the image

    

}
#pragma mark - Actions

- (IBAction)inputButtonClicked:(id)sender {
    
    // Prompt the user for a file dialog
    NSOpenPanel *openPanel = [[NSOpenPanel alloc] init];
    [openPanel runModal];
    
    // Set the file in the chain
    [chain setFileURL:openPanel.URL];

}

- (IBAction)edgeButtonClicked:(id)sender {
 
}

- (IBAction)outputButtonClicked:(id)sender {
}

#pragma mark - Core Logic

- (void)modelChanged:(NSNotification *)sender {
    self.experimentalImageView.images = chain.largeImages;
}

#pragma mark - BESMainViewDataSource

#pragma mark - NIB Stuff

- (void) awakeFromNib {
    [self updateUI];
}

- (IBAction)zoomButtonClicked:(id)sender {
    long clickedSegment = [sender selectedSegment];
    switch (clickedSegment) {
        case ZOOM_IN:
            [self.experimentalImageView zoomIn];
            break;
        case ZOOM_OUT:
            [self.experimentalImageView zoomOut];
            break;
        case ZOOM_FIT:
            [self.experimentalImageView resetZoom];
            break;
        default:
            break;
    }
}

- (IBAction)imageSelectionButtonClicked:(id)sender {
    
    long clickedSegment = [sender selectedSegment];
    self.mDisplayedImage = clickedSegment;
    [self.experimentalImageView displayImage:clickedSegment];
    [self.experimentalImageView needsDisplay];
}

@end
