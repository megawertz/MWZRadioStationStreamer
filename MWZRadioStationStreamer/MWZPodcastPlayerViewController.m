//
//  MWZPodcastPlayerViewController.m
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZPodcastPlayerViewController.h"
#import "MWZPodcastEpisode.h"

#define STREAM_URL  @"http://stream.mc3.edu/podcast/mc3ota/media/"
#define SEEK_AMOUNT 30  // used for rewind and fast forward

@interface MWZPodcastPlayerViewController ()

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic, strong) id timeObserver;

@end

@implementation MWZPodcastPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup the info
    [self.epTitle setText:[self.episode title]];
    [self.epDate setText:[self.episode date]];
    [self.epDescription setText:[self.episode description]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)secondsToTimerFormat:(int)s {
  
    int hours = s / 60 / 60;
    int minutes = (s - hours * 60 * 60) / 60;
    int seconds = s % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
}

- (IBAction)rewind:(id)sender {
    int currentPosition = CMTimeGetSeconds([[self player] currentTime]);
    [[self player] seekToTime:CMTimeMake(currentPosition-SEEK_AMOUNT, 1)];
}

- (IBAction)fastforward:(id)sender {
    int currentPosition = CMTimeGetSeconds([[self player] currentTime]);
    [[self player] seekToTime:CMTimeMake(currentPosition+SEEK_AMOUNT, 1)];
}

- (IBAction)play:(id)sender {
    // Lazy load the player
    if(_player == nil) {
        NSString *fullStreamURL = [NSString stringWithFormat:@"%@",[self.episode url]];
        
        // DLog(@"Full Stream URL: %@",fullStreamURL);
        
        AVPlayer *tmp = [AVPlayer playerWithURL:[NSURL URLWithString:fullStreamURL]];
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
//        if([self.player.currentItem isPlaybackLikelyToKeepUp])
////            [self.spinner stopAnimating];
//        else
////            [self.spinner startAnimating];
        
    }
    
    if([keyPath isEqualToString:@"rate"]) {
        
        if([self.player rate]) {
            DLog(@"We have a rate, this is playing. Rate: %f",[self.player rate]);
            CMTime d = [[self.player currentItem] duration];
            if(d.timescale > 0) {
                [self setEpisodeDuration:CMTimeGetSeconds(d)];
                
                __block MWZPodcastPlayerViewController *blockSelf = self;
                self.timeObserver = [[self player] addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
                    
                    int secondsPlayed = CMTimeGetSeconds(time);
                    [blockSelf.timePlayedLabel setText:[blockSelf secondsToTimerFormat:secondsPlayed]];
                    [blockSelf.timeRemainingLabel setText:[blockSelf secondsToTimerFormat:(blockSelf.episodeDuration - secondsPlayed)]];
                    
                    float progressAmt = (secondsPlayed/(float)blockSelf.episodeDuration);
                    [[blockSelf playerProgressBar] setValue:progressAmt animated:YES];
                    
                }];

            }
            
//            [self showPauseButton];
//            if(![self.player.currentItem isPlaybackLikelyToKeepUp])
//                [self.spinner startAnimating];
        }
        else {
            DLog(@"No rate, not playing.");
//            [self showPlayButton];
//            [self.spinner stopAnimating];
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
//                [self showStreamError];
//                [self resetStreamPlayer];
                break;
            case AVPlayerStatusUnknown:
                DLog(@"Unknow player status");
//                [self showStreamError];
//                [self resetStreamPlayer];
                break;
            default:
                break;
        }
        
    }
}


@end
