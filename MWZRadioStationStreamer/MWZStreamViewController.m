//
//  MWZFirstViewController.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 9/24/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZStreamViewController.h"

#define INTERFACE_DISAPPEAR_DELAY   5
#define STREAM_URL                  @"http://stream.mc3.edu:8000/stream.m3u"

@interface MWZStreamViewController ()

// Object responsible for playing the stream
@property (nonatomic,strong) AVPlayer *player;

/// Tracks if interface elements are on or off screen
@property BOOL interfaceElementsOnScreen;

/// Method that performs the actual interface animations
-(void)animateInterfaceElementsOnOffScreen;

/// Stops observing player keys and resets player to nil
-(void)resetStreamPlayer;

/// Standard error pop-up for streams
-(void)showStreamError;

/// Get stream metadata
-(void)getMetadata;
@end

@implementation MWZStreamViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.interfaceElementsOnScreen = YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set the interface items to go away after a short delay
    // [self performSelector:@selector(animateInterfaceElementsOnOffScreen) withObject:nil afterDelay:INTERFACE_DISAPPEAR_DELAY];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metadata Access & Processing

// Currently getting this on the main thread for testing.
// TODO: Use loadValuesAsynchronouslyForKeys:completionHandler: in AVMetadataItem
// http://stackoverflow.com/questions/7707513/getting-metadata-from-an-audio-stream
-(void)getMetadata {

    AVPlayerItem *playerItem = [self.player currentItem];
    NSArray *metadataList = [playerItem.asset commonMetadata];
    
    for (AVMetadataItem *metaItem in metadataList) {
        DLog(@"key: %@, value: %@",[metaItem commonKey],[metaItem value]);
    }

}

#pragma mark - Stream Control Methods

-(void)showStreamError {
    
    // TODO: Internationalize this text

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"StreamErrorWindowTitle", @"Title for stream error alert view.")
                                                    message:NSLocalizedString(@"StreamErrorWindowMessage",@"Messeage for stream error alert view.")
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];

}

-(void)showPlayButton {
    NSMutableArray *tbItems = [[self.controlToolbar items] mutableCopy];
    UIBarButtonItem *playButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(toggleStream)];
    [playButton setStyle:UIBarButtonItemStylePlain];
    [tbItems replaceObjectAtIndex:([tbItems count]/2) withObject:playButton];
    [self.controlToolbar setItems:tbItems];
    
}

-(void)showPauseButton {
    NSMutableArray *tbItems = [[self.controlToolbar items] mutableCopy];
    UIBarButtonItem *pauseButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(toggleStream)];
    [pauseButton setStyle:UIBarButtonItemStylePlain];
    [tbItems replaceObjectAtIndex:([tbItems count]/2) withObject:pauseButton];
    [self.controlToolbar setItems:tbItems];
}

-(void)resetStreamPlayer {
    [self.player removeObserver:self forKeyPath:@"rate"];
    [self.player removeObserver:self forKeyPath:@"status"];
    [self setPlayer:nil];
    [self showPlayButton];
}

-(IBAction)userStreamReset {
    if(self.player != nil) {
        [self.player pause];    // just in case
        [self resetStreamPlayer];
        [self toggleStream];    // Probably shouldn't do this
    }
}

- (IBAction)toggleStream {

    // Lazy load the player
    if(_player == nil) {
        AVPlayer *tmp = [AVPlayer playerWithURL:[NSURL URLWithString:STREAM_URL]];
        [self setPlayer:tmp];
        // Register for observations
        [self.player addObserver:self forKeyPath:@"rate" options:0 context:nil];
        [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
        // Just return here, playing is handled by the observer
        // This is so we know we have a valid stream
        return;
    }
    else {
        if([self.player rate]) {
            // We're playing, stop
            // Curious if this sends a notification
            [self.player pause];
        }
        else {
            // Is this still getting notifications?
            [self.player play];
        }
    }
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"rate"]) {
        
        if([self.player rate]) {
            DLog(@"We have a rate, this is playing. Rate: %f",[self.player rate]);
            [self showPauseButton];
        }
        else {
            DLog(@"No rate, not playing.");
            [self showPlayButton];
        }
        
    }
    else if([keyPath isEqualToString:@"status"]) {
        
        // Is it enough to look at just the underlying item's status?
        switch ([self.player.currentItem status]) {
            case AVPlayerStatusReadyToPlay:
                DLog(@"Player's current item is ready to play");
                if([self.player status] == AVPlayerStatusReadyToPlay) {
                    DLog(@"Player and current item are fine. Playing.");
                    [self.player play];
                    [self getMetadata];
                }
                else {
                    DLog(@"Player's currentItem is fine but player failed. Remove observers and set to nil.");
                    [self showStreamError];
                    [self resetStreamPlayer];
                }
                break;
            case AVPlayerStatusFailed:
                DLog(@"Player's Item failed. Remove observers and set to nil.");
                [self showStreamError];
                [self resetStreamPlayer];
                break;
            case AVPlayerStatusUnknown:
                DLog(@"Unknow player's item status");
                [self showStreamError];
                [self resetStreamPlayer];
                break;
            default:
                break;
        }
        
    }
}

#pragma mark - Interface Animation Methods

-(IBAction)toggleInterfaceElements
{
    [self animateInterfaceElementsOnOffScreen];    
}

-(void)animateInterfaceElementsOnOffScreen
{
    // Make sure we don't queue up a bunch of these operations 
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(animateInterfaceElementsOnOffScreen) object:nil];

    // Get frame sizes for animation calculations
    CGRect nowPlayingViewFrame = _nowPlayingView.frame;
    CGRect mpVolumeViewFrame = _mpVolumeView.frame;
    CGRect controlToolbarFrame = _controlToolbar.frame;
    
    // Determine if we are coming or going
    if(self.interfaceElementsOnScreen) {
        nowPlayingViewFrame.origin.y -= nowPlayingViewFrame.size.height;
        
        controlToolbarFrame.origin.y += (controlToolbarFrame.size.height + mpVolumeViewFrame.size.height);
        mpVolumeViewFrame.origin.y += mpVolumeViewFrame.size.height;
        
        [self setInterfaceElementsOnScreen:NO];
    }
    else {
        nowPlayingViewFrame.origin.y += nowPlayingViewFrame.size.height;
        
        controlToolbarFrame.origin.y -= (controlToolbarFrame.size.height + mpVolumeViewFrame.size.height);
        mpVolumeViewFrame.origin.y -= mpVolumeViewFrame.size.height;
        
        [self setInterfaceElementsOnScreen:YES];
        
        // Set the interface items to go away again after a bit
        // [self performSelector:@selector(animateInterfaceElementsOnOffScreen) withObject:nil afterDelay:INTERFACE_DISAPPEAR_DELAY];
    }
    
    // Perform animations
    [UIView animateWithDuration:0.2
                          delay:0.2
                        options: UIViewAnimationCurveEaseInOut
                     animations:^{
                         _nowPlayingView.frame = nowPlayingViewFrame;
                         _controlToolbar.frame = controlToolbarFrame;
                         _mpVolumeView.frame = mpVolumeViewFrame;
                     }
                     completion:^(BOOL finished){
                     }];
}

@end
