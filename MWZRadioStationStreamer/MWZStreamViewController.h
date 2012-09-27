//
//  MWZFirstViewController.h
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 9/24/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface MWZStreamViewController : UIViewController

/// Outlets to allow the interface elements to animate on/off screen
@property (weak, nonatomic) IBOutlet UIView *nowPlayingView;
@property (weak, nonatomic) IBOutlet UIView *mpVolumeView;
@property (weak, nonatomic) IBOutlet UIToolbar *controlToolbar;

/// Outlet to play/pause button
@property (weak, nonatomic) IBOutlet UIBarButtonItem *toggleStreamButton;

/// Action for user to trigger interface element on/off screen animations
-(IBAction)toggleInterfaceElements;

/// Toggle the stream on and off
-(IBAction)toggleStream;
-(IBAction)userStreamReset;

@end
