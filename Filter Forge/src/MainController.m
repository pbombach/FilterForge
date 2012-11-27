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
#import "SettingsController.h"
#import "FilterParametersController.h"

static int const kDisplayInputImage           = 0;
static int const kDisplayOutputImage          = 1;
static int const kDisplayInputPlusOutputImage = 2;

static int const kZoomOut = 0;
static int const kZoomIn  = 1;
static int const kZoomFit = 2;

@interface MainController ()

@property (assign) int mDisplayedImage;

@property (strong) SettingsController *settingsController;
@property (strong) FilterParametersController *filterParametersController;
@property (strong) FilterChain *chain;

@end

@implementation MainController

- (id) init {
    
    
    self = [super init];
    if (self) {
        // Create an instance of the chain model
        _chain = [[FilterChain alloc]init];
        
        // Register for notifications from the chain model
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelChanged:) name:BESCHAIN_MODEL_CHANGED object:nil];
        
        self.mDisplayedImage = kDisplayInputPlusOutputImage; // Select first button by default
        
        self.settingsController = nil;
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
    [self.chain setFileURL:openPanel.URL];
    
}

- (IBAction)edgeButtonClicked:(id)sender {
    self.filterParametersController = [[FilterParametersController alloc] init];
    self.filterParametersController.filter = self.chain.userSelectedFilter;
    [self.filterParametersController showWindow:self];
}

- (IBAction)outputButtonClicked:(id)sender {
}

- (IBAction)settingsButtonClicked:(id)sender {
    
   // [NSApp beginSheet:self.settingsWindow modalForWindow:[self.mainView window] modalDelegate:nil didEndSelector:NULL contextInfo:NULL];
    if (self.settingsController == nil) {
        self.settingsController = [[SettingsController alloc]init];
        self.settingsController.mainController = self;
    }
    self.settingsController.filterChain = self.chain;
    
    [self.settingsController showWindow:self];
}

#pragma mark - Core Logic

- (void)modelChanged:(NSNotification *)sender {
    self.mainView.images =  @{kInputImageKey:self.chain.inputImage,kOutputImageKey:self.chain.outputImage,kCompositeImageKey:self.chain.compositeImage};
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

- (void) setFilterOpacity:(float)opacity {
    self.chain.opacity = opacity;
}

- (void) setMaskColor:(NSColor *)maskColor {
    self.chain.maskColor = maskColor;
}

@end
