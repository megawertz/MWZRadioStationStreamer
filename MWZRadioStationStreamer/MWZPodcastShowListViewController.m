//
//  MWZPodcastViewController.m
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZPodcastShowListViewController.h"
#import "MWZPodcastEpisodeListViewController.h"

@interface MWZPodcastShowListViewController ()

@property (nonatomic, strong) NSArray *feedURLs;

@end

@implementation MWZPodcastShowListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Just setup rss feeds here onload, not going to be a big list
    // If it grows then we can get fancy
    NSArray *tmp = @[@"http://stream.mc3.edu/podcast/mc3ota/feed.xml"];
    [self setFeedURLs:tmp];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"podcastEpisodesSeque"]) {
        MWZPodcastEpisodeListViewController *destination = [segue destinationViewController];
        destination.feedURL = [self.feedURLs objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     // <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
