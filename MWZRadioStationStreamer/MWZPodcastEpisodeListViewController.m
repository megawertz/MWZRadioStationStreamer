//
//  MWZPodcastEpisodeListViewController.m
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZPodcastEpisodeListViewController.h"
#import "MWZPodcastEpisode.h"

// Defines the outer tag for which I want to collect items
#define TRIGGER_TAG     @"title"

@interface MWZPodcastEpisodeListViewController ()

@property (nonatomic, strong) NSMutableArray *episodes;
@property (nonatomic, strong) NSSet *tags;
@property (nonatomic, strong) MWZPodcastEpisode *currentEpisode;
@property (nonatomic, strong) NSString *currentString;

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
    self.tags = [NSSet setWithArray:@[@"title",@"link",@"description",@"pubDate"]];
    
    // When the view loads, go get the RSS feed
    // For now just download and process, setup caching later
    [self fetchRSSFeed];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    
    if([elementName isEqualToString:TRIGGER_TAG]) {
        // reset the currentEpisode
        self.currentEpisode = [[MWZPodcastEpisode alloc] init];
    }
    
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
}

-(void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName {
    
    
    if([elementName isEqualToString:TRIGGER_TAG]) {
        // Add to the collection
        [self.episodes addObject:self.currentEpisode];
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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
