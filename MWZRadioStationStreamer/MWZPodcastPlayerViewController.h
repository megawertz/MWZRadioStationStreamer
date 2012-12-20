//
//  MWZPodcastPlayerViewController.h
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWZPodcastEpisode;

@interface MWZPodcastPlayerViewController : UIViewController

@property (nonatomic, strong) MWZPodcastEpisode *episode;

@property (weak, nonatomic) IBOutlet UILabel *epTitle;
@property (weak, nonatomic) IBOutlet UILabel *epDate;
@property (weak, nonatomic) IBOutlet UITextView *epDescription;


@end
