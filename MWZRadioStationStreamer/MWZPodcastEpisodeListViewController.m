//
//  MWZPodcastEpisodeListViewController.m
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZPodcastEpisodeListViewController.h"
#import "MWZPodcastEpisode.h"
#import "MWZEpisodeTableViewCell.h"
#import "MWZPodcastPlayerViewController.h"

// Interesting tags
#define ITEM_TAG            @"item"
#define TITLE_TAG           @"title"
#define LINK_TAG            @"link"
#define DESCRIPTION_TAG     @"description"
#define PUBDATE_TAG         @"pubDate"

@interface MWZPodcastEpisodeListViewController ()

@property (nonatomic, strong) NSMutableArray *episodes;
@property (nonatomic, strong) NSSet *tags;
@property (nonatomic, strong) MWZPodcastEpisode *currentEpisode;
@property (nonatomic, strong) NSMutableString *currentString;

-(void)fetchRSSFeed;

@end

@implementation MWZPodcastEpisodeListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.episodes = [NSMutableArray array];
    
    // Tags I'm interested in to add to objects
    self.tags = [NSSet setWithArray:@[TITLE_TAG, LINK_TAG, DESCRIPTION_TAG, PUBDATE_TAG]];
    
    // When the view loads, go get the RSS feed
    // For now just download and process, setup caching later
    [self fetchRSSFeed];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// podcastEpisodeDetailSeque

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"podcastEpisodeDetailSeque"]) {
        MWZPodcastPlayerViewController *destination = [segue destinationViewController];
        destination.episode = [self.episodes objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}

#pragma mark - XML Processing

-(void)fetchRSSFeed {
    // Here we could check for a cached version, can also implement pull to refresh to call this
    NSURL *url = [NSURL URLWithString:self.feedURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    
    
    __weak typeof(self) delegate = self;
    [NSURLConnection sendAsynchronousRequest:request queue:q completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
       
        if ([data length] > 0 && error == nil) {
            [delegate parseXMLData:data];
        }
        else {
            // Bad things, handle errors here.
        }
        
    }];
    
}

-(void)parseXMLData:(NSData *)data {
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    [parser setDelegate:self];
    [parser parse];
}

-(void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName
         attributes:(NSDictionary *)attributeDict {
    
    if([elementName isEqualToString:ITEM_TAG]) {
        // reset the currentEpisode
        self.currentEpisode = [[MWZPodcastEpisode alloc] init];
    }
    else if([self.tags containsObject:elementName]) {
        // It's a tag we're interested in, reset the accumulator
        self.currentString = [NSMutableString string];
    }
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [self.currentString appendString:string];
}

-(void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName {
    
    NSString *trimmedString = [self.currentString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if([elementName isEqualToString:ITEM_TAG]) {
        // Add to the collection
        [self.episodes addObject:self.currentEpisode];
    }
    else if([elementName isEqualToString:TITLE_TAG]) {
        [self.currentEpisode setTitle:trimmedString];
    }
    else if([elementName isEqualToString:LINK_TAG]) {
        [self.currentEpisode setFileName:trimmedString];
    }
    else if([elementName isEqualToString:DESCRIPTION_TAG]) {
        // Get rid of any text in parens at the end of the string
        NSRange subRange = [trimmedString rangeOfString:@"(Run"];
        NSString *d = (subRange.location == NSNotFound) ? trimmedString : [trimmedString substringToIndex:subRange.location];
        [self.currentEpisode setDescription:d];
    }
    else if([elementName isEqualToString:PUBDATE_TAG]) {
        [self.currentEpisode setDate:trimmedString];
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    // refresh the tableview
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.episodes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"episodeCell";
    MWZEpisodeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if(cell == nil) {
        cell = [[MWZEpisodeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    MWZPodcastEpisode *e = [self.episodes objectAtIndex:[indexPath row]];
    
    [cell.epTitle setText:[e title]];
    [cell.epDate setText:[e date]];
    [cell.epDescription setText:[e description]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Get description text
    MWZPodcastEpisode *e = [self.episodes objectAtIndex:[indexPath row]];
    NSString *description = [e description];
    
    // TODO: AHHHHHH, DON'T HARDCODE THIS!!!!
    // And yet, here I am...doing this again ;-)
    // Get a reference to an actual cell object and pull sizes out on viewDidLoad?
    float defaultCellHeight = 78.0 - 21.0;
    
    CGSize maxSize = CGSizeMake(270.0,999.0);
    
    CGSize actualSize = [description sizeWithFont:[UIFont systemFontOfSize:14.0] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    
    // Measure and return the height...get number of lines?
    return defaultCellHeight + actualSize.height;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
