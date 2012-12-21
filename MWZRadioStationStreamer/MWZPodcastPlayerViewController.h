//
//  MWZPodcastPlayerViewController.h
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class MWZPodcastEpisode;

@interface MWZPodcastPlayerViewController : UIViewController

@property (nonatomic, strong) MWZPodcastEpisode *episode;

@property (weak, nonatomic) IBOutlet UILabel *epTitle;
@property (weak, nonatomic) IBOutlet UILabel *epDate;
@property (weak, nonatomic) IBOutlet UITextView *epDescription;

@property (weak, nonatomic) IBOutlet UIProgressView *progressBar;
@property (weak, nonatomic) IBOutlet UILabel *timePlayedLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *playPauseButton;

@property (weak, nonatomic) IBOutlet UIView *volumeControlView;

- (IBAction)rewind:(id)sender;
- (IBAction)fastforward:(id)sender;
- (IBAction)play:(id)sender;


@end
