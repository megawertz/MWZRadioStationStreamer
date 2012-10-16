//
//  MWZFirstViewController.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 9/24/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZStreamViewController.h"
#import "UIViewController+ErrorMessage.h"

#define INTERFACE_DISAPPEAR_DELAY   5
#define STREAM_URL                  @"http://stream.mc3.edu:8000/stream.m3u"
#define STATION_PHONE_NUMBER        @"215-619-7366"
#define STATION_EMAIL               @"jwertz@mc3.edu"
#define STATION_TWITTER_ACCOUNT     @"@montcoradio"
#define STATION_TWITTER_HASHTAG     @"#request"

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

/// Make a phone request
-(void)phoneRequest;

/// Make email request
-(void)emailRequest;

/// Make twitter request
-(void)tweetRequest;

@end

@implementation MWZStreamViewController

#pragma mark - View Life Cycle

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup the activity indicator in the navbar manually
    UIActivityIndicatorView *tmpAIV = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:tmpAIV];
    [self setSpinner:tmpAIV];
    [self.navItem setRightBarButtonItem:button];

    [self.nowPlayingView setHidden:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Everytime this appears it is putting the controls back on screen
    // Make sure we set that here.
    self.interfaceElementsOnScreen = YES;
    
    // Start getting remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    // Set the interface items to go away after a short delay
    // [self performSelector:@selector(animateInterfaceElementsOnOffScreen) withObject:nil afterDelay:INTERFACE_DISAPPEAR_DELAY];
}

-(void)viewDidDisappear:(BOOL)animated {
    
    // TODO: If we are playing, don't deregister from getting thesen notifications
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIActionSheet Methods

-(IBAction)contactStation {

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:
                            NSLocalizedString(@"RequestMenuTitle",@"Make a Request!")
                                                       delegate:self
                                              cancelButtonTitle:
                            NSLocalizedString(@"RequestMenuButton_Cancel",@"Cancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            NSLocalizedString(@"RequestMenuButton_Twitter",@"Active word for Twitter service...i.e. Tweet"),
                            NSLocalizedString(@"RequestMenuButton_Email",@"Email"), nil];
    
    // Don't show the call button to devices that can't make calls
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
        [sheet addButtonWithTitle:NSLocalizedString(@"RequestMenuButton_Call",@"Call")];
   
    [sheet showFromTabBar:self.tabBarController.tabBar];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self tweetRequest];
            break;
        case 1:
            [self emailRequest];
            break;
        case 2:
            // No phone button if the device can't make calls
            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
                [self phoneRequest];
            break;
        default:
            break;
    }
}

-(void)emailRequest
{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setToRecipients:[NSArray arrayWithObject:STATION_EMAIL]];
        [controller setSubject:NSLocalizedString(@"RequestEmailSubject", @"Subject of DJ Request Emails")];
        [controller setMessageBody:@"" isHTML:NO];
        
        [self presentViewController:controller animated:YES completion:nil];
        
    }
    else
    {
        [self errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_Standard",@"Error.")
                     message:NSLocalizedString(@"ErrorDialogMessage_EmailUnavialable",@"Device cannot send email.")
             andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	if (result == MFMailComposeResultSent) {
        DLog(@"Mail sent.");
    }
    else {
        DLog(@"Error sending email.");
    }
    
	[self dismissViewControllerAnimated:YES completion:nil];
}

-(void)phoneRequest
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",STATION_PHONE_NUMBER]];
    if([[UIApplication sharedApplication] canOpenURL:url])
        [[UIApplication sharedApplication] openURL:url];
    else {
        //error
        DLog(@"Error, device cannot make phone calls.");
        [self errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_Standard",@"Error.")
                     message:NSLocalizedString(@"ErrorDialogMessage_PhoneUnavialable",@"Device cannot make phone calls.")
             andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];
    }
}

-(void)tweetRequest
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController *twitterViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *tweetFrameworkString = [NSString stringWithFormat:@"%@ %@ ",STATION_TWITTER_ACCOUNT, STATION_TWITTER_HASHTAG];
        [twitterViewController setInitialText:tweetFrameworkString];
        // Tweet sheet should dismiss itself? Seems to.
        [self presentViewController:twitterViewController animated:YES completion:nil];
    }
    else {
        //error
        DLog(@"Error, device cannot tweet.");
        [self errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_Standard",@"Error.")
                     message:NSLocalizedString(@"ErrorDialogMessage_TwitterUnavialable",@"Device cannot make phone calls.")
             andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];

    }
}


#pragma mark - Metadata Access & Processing

// Currently getting this on the main thread for testing.
// TODO: Use loadValuesAsynchronouslyForKeys:completionHandler: in AVMetadataItem
// http://stackoverflow.com/questions/7707513/getting-metadata-from-an-audio-stream

-(void)getMetadata {

    AVPlayerItem *playerItem = [self.player currentItem];
    NSArray *metadataList = [playerItem.asset commonMetadata];
    
    
    if([metadataList count] > 0) {
        // TODO: Animate this in. Don't just let it appear.
        [self.nowPlayingView setHidden:NO];
        // If there's no metadata remove the now playing banner from the view
        [self.nowPlayingLabel setText:@"Metadata Here"];
        
    }
    
    // Debug of metadata to see what I'm getting.
    for (AVMetadataItem *metaItem in metadataList) {
        
        DLog(@"key: %@, value: %@",[metaItem commonKey],[metaItem value]);
    }

}

#pragma mark - Stream Control Methods

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    DLog(@"Remote Event Received!");
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self toggleStream];
                break;
            default:
                break;
        }
    }
}


-(void)showStreamError {
    
    [self errorWithTitle:NSLocalizedString(@"StreamErrorWindowTitle", @"Title for stream error alert view.")
                 message:NSLocalizedString(@"StreamErrorWindowMessage", @"Message for stream error alert view.")
         andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];

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
        [self.player.currentItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:0 context:nil];
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
    if(object == [self.player currentItem])
    {
        DLog(@"KVO message from the currentItem");
        if([self.player.currentItem isPlaybackLikelyToKeepUp])
            [self.spinner stopAnimating];
        else
            [self.spinner startAnimating];

    }
    
    if([keyPath isEqualToString:@"rate"]) {
        
        if([self.player rate]) {
            DLog(@"We have a rate, this is playing. Rate: %f",[self.player rate]);
            [self showPauseButton];
            if(![self.player.currentItem isPlaybackLikelyToKeepUp])
                [self.spinner startAnimating];
        }
        else {
            DLog(@"No rate, not playing.");
            [self showPlayButton];
            [self.spinner stopAnimating];
        }
        
    }
    else if([keyPath isEqualToString:@"status"]) {
        
        // TODO: Do I need to look at the underlying item's status?
        // Tried this and it caused problems.
        switch ([self.player status]) {
            case AVPlayerStatusReadyToPlay:
                DLog(@"Player is ready to play");
                [self.player play];
                // Schedule meta-data here.
                break;
            case AVPlayerStatusFailed:
                DLog(@"Player failed. Remove observers and set to nil.");
                [self showStreamError];
                [self resetStreamPlayer];
                break;
            case AVPlayerStatusUnknown:
                DLog(@"Unknow player status");
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
