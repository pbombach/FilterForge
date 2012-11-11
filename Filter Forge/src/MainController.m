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

static int const kDisplayInputImage           = 0;
static int const kDisplayOutputImage          = 1;
static int const kDisplayInputPlusOutputImage = 2;

static int const kZoomOut = 0;
static int const kZoomIn  = 1;
static int const kZoomFit = 2;

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
        
        self.mDisplayedImage = kDisplayInputPlusOutputImage; // Select first button by default
    }
    return self;
}

- (void) updateUI {
    
    
    // Update the displayed image selector
    [self.imageSelectionButtons setSelectedSegment:self.mDisplayedImage];
    [self imageSelectionButtonClicked:self.imageSelectionButtons];
    
    
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
    self.mainView.images =  @{kInputImageKey:chain.inputImage,kOutputImageKey:chain.outputImage,kCompositeImageKey:chain.compositeImage};
}

#pragma mark - BESMainViewDataSource

#pragma mark - NIB Stuff

- (void) awakeFromNib {
    [self updateUI];
}


- (IBAction)zoomButtonClicked:(id)sender {
    long clickedSegment = [sender selectedSegment];
    
    switch (clickedSegment) {
        case kZoomIn:
            [self.mainView zoomIn];
            break;
        case kZoomOut:
            [self.mainView zoomOut];
            break;
        case kZoomFit:
            [self.mainView resetZoom];
            break;
        default:
            break;
    }
}

-(void) displayImage:(NSInteger) image {
    switch (image) {
        case kDisplayInputImage:
            [self.mainView displayImage:kInputImageKey];
            break;
        case kDisplayOutputImage:
            [self.mainView displayImage:kOutputImageKey];
            break;
        case kDisplayInputPlusOutputImage:
            [self.mainView displayImage:kCompositeImageKey];
            break;
        default:
            [self.mainView displayImage:kInputImageKey];
            break;
    }
    [self.mainView needsDisplay];
}

- (IBAction)imageSelectionButtonClicked:(id)sender {
    NSInteger clickedSegment = [sender selectedSegment];
    [self displayImage:clickedSegment];
}

@end
