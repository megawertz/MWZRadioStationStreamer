//
//  MWZPodcastPlayerViewController.m
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZPodcastPlayerViewController.h"
#import "MWZPodcastEpisode.h"

@interface MWZPodcastPlayerViewController ()

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

@end
