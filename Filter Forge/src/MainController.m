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


static int const kDisplayInputImageTag           = 0;
static int const kDisplayOutputImageTag          = 1;
static int const kDisplayInputPlusOutputImageTag = 2;

static int const imageDisplayButtonPositionToImageDisplayMap[] = {MainViewInputImage,MainViewOutputImage,MainViewInputPlusOutputImage};
static int const numImageDisplaySegments = sizeof(imageDisplayButtonPositionToImageDisplayMap)/sizeof(int);

static int const zoomButtonPositionToZoomMap[] = {ZOOM_IN,ZOOM_OUT,ZOOM_FIT};
static int const numZoomButtons = sizeof(zoomButtonPositionToZoomMap)/sizeof(int);

@interface MainController ()

@property (assign) int mDisplayedImage;

@end

@implementation MainController

- (id) init {
    self = [super init];
    if (self) {
        // Create an instance of the chain model
        chain = [[FilterChain alloc]init];
        
        // Register for notifications from the chain model
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelChanged:) name:BESCHAIN_MODEL_CHANGED object:nil];
        
        self.mDisplayedImage = 0; // Select first button by default
        for (int i=0; i < numImageDisplaySegments; i++) {
            if (imageDisplayButtonPositionToImageDisplayMap[i] == MainViewOutputImage) {
                self.mDisplayedImage = i;
            }
        }
    }
    return self;
}

- (void) updateUI {
    
    // Update the displayed image selector
    [self.imageSelectionButtons setSelectedSegment:self.mDisplayedImage];
    

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
    NSInteger selectedSegment = [sender selectedSegment];
    MainViewDisplayedImage displayedImage;

    if (self.mDisplayedImage < numImageDisplaySegments) {
        displayedImage = imageDisplayButtonPositionToImageDisplayMap[selectedSegment];
    }
    else {
        displayedImage = MainViewInputImage;
    }
    [self.experimentalImageView displayImage:displayedImage];
    [self.experimentalImageView needsDisplay];
}

@end
