//
//  OpenGL41View.h
//  Maze Generator
//
//  Created by Jason James on 4/16/20.
//  Copyright © 2020 Jason James. All rights reserved.
//

#define GL_SILENCE_DEPRECATION

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenGL41View : NSOpenGLView
{
    IBOutlet NSPopUpButton * algorithmPopUpButton;
    IBOutlet NSTextField * heightTextField;
    IBOutlet NSTextField * widthTextField;
    IBOutlet NSStepper * heightStepper;
    IBOutlet NSStepper * widthStepper;
    IBOutlet NSPopUpButton * viewPopUpButton;
    IBOutlet NSSwitch * axesSwitch;
    IBOutlet NSButton * generateButton;

    IBOutlet NSTextField * timeLabel;
    IBOutlet NSTextField * messageLabel;

    NSTimer * timer;
    NSTimer * enemyTimer;
    NSTimer * spinCameraTimer;
}

- (IBAction)updateAlgorithm:(id)sender;
- (IBAction)updateHeight:(id)sender;
- (IBAction)updateWidth:(id)sender;
- (IBAction)updateView:(id)sender;
- (IBAction)updateAxes:(id)sender;
- (IBAction)generate:(id)sender;

@end

NS_ASSUME_NONNULL_END
