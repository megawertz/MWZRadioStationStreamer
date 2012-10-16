//
//  MWZSecondViewController.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 9/24/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZScheduleViewController.h"
#import "UIViewController+ErrorMessage.h"

#define UPDATE_URL              @"http://www.mc3.edu/jwertz"
#define SCHEDULE_FILE_NAME      @"ShowData.plist"

#define SHOW_TITLE              @"Title"
#define SHOW_DESCRIPTION        @"Description"
#define SHOW_START_TIME         @"StartTime"
#define SHOW_END_TIME           @"EndTime"
#define SHOW_DAY_OF_WEEK        @"Day"

#define SCHEDULE_SHOWS_THIS_DAY @"Shows"
#define SCHEDULE_TITLE          @"ScheduleTitle"
#define SCHEDULE_VERSION        @"ScheduleVersion"
#define SCHEDULE_SHOW_DATA      @"ScheduleShowData"

@interface MWZScheduleViewController ()

/// Cached date formatter for use when creating cells.
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

-(void)processDownloadedData:(NSData *)downloadData;

@end

@implementation MWZScheduleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup a dateFormatter to use for this view
    if([self dateFormatter] == nil)
    {
        NSDateFormatter *tmpdf = [[NSDateFormatter alloc] init];
        [tmpdf setTimeStyle:NSDateFormatterShortStyle];
        [tmpdf setDateStyle:NSDateFormatterNoStyle];
        
        [self setDateFormatter:tmpdf];
    }
    
    // Check if there is a show plist in the documents directory
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [documentPaths objectAtIndex:0];
    NSString *dbVisitsPotentialPath = [docPath stringByAppendingPathComponent:SCHEDULE_FILE_NAME];
    
    // If not, put the empty one there
    if(![[NSFileManager defaultManager] fileExistsAtPath:dbVisitsPotentialPath])
    {
        // copy db to documents directory
        // TODO: Make these filename components defines
        NSString *dbBundlePath = [[NSBundle mainBundle] pathForResource:@"showData" ofType:@"plist"];
        BOOL copySuccess = [[NSFileManager defaultManager] copyItemAtPath:dbBundlePath toPath:dbVisitsPotentialPath error:nil];
        
        if(!copySuccess)
        {
            // If we can't copy the db this is a big error
            // How best to respond to this?
            NSLog(@"Visits DB file not copied to documents directory. Error.");
            return;
        }
        
    }
    
    NSString *p = dbVisitsPotentialPath;
    
    NSDictionary *tmpDictionary = [[NSDictionary alloc] initWithContentsOfFile:p];
    [self.scheduleTitle setTitle:[tmpDictionary objectForKey:SCHEDULE_TITLE]];

    [self setShowData:[tmpDictionary objectForKey:SCHEDULE_SHOW_DATA]];
    self.showDataVersionNumber = [[tmpDictionary objectForKey:SCHEDULE_VERSION] intValue];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Schedule Update

-(IBAction)updateSchedule
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",UPDATE_URL,SCHEDULE_FILE_NAME]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    __block MWZScheduleViewController *blockSelf = self;
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               if(error == nil && [httpResponse statusCode] == 200) {
                                   [blockSelf processDownloadedData:data];
                               }
                               else {
                                   // Download error, prompt to try again
                                   [blockSelf errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_ScheduleDownloadError",@"There was an error with the download.")
                                                message:NSLocalizedString(@"ErrorDialogMessage_ScheduleDownloadFailed",@"There was an error. Please try again later.")
                                        andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];
                               }
                           }];
}

-(void)processDownloadedData:(NSData *)downloadData
{
    // Get the plist
    NSPropertyListFormat format;
    NSString *errorDescription = nil;
    NSDictionary *tmp = [NSPropertyListSerialization propertyListFromData:downloadData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
    
    int newVersionNumber = [[tmp objectForKey:@"version"] intValue];
    
    // NSLog(@"Old Version: %d, New Version: %d",showDataVersionNumber,newVersionNumber);
    if(self.showDataVersionNumber < newVersionNumber)
    {
        // NSLog(@"Downloading data");
        // Build the path to save the file
        NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [documentPaths objectAtIndex:0];
        NSString *dbVisitsPotentialPath = [docPath stringByAppendingPathComponent:@"showData.plist"];
        
        // Remove old item
        [[NSFileManager defaultManager] removeItemAtPath:dbVisitsPotentialPath error:nil];
        
        // Save new item
        [tmp writeToFile:dbVisitsPotentialPath atomically:YES];
        
        // Now get the data and update
        NSArray *tmpArray = [tmp objectForKey:SCHEDULE_SHOW_DATA];
        [self setShowData:tmpArray];
        self.scheduleTitle.title = [tmp objectForKey:SCHEDULE_TITLE];
        self.showDataVersionNumber = newVersionNumber;
        [self.tableView reloadData];
    }
    else {
        // Alert the user
        [self errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_ScheduleDownloadUnavailable",@"Nothing New.")
                     message:NSLocalizedString(@"ErrorDialogMessage_ScheduleDownloadNoNewData",@"There was no new schedule available.")
             andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];
    }
}

#pragma mark - Table Delegates

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.showData count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dayOfWeek = [self.showData objectAtIndex:section];
    
    NSArray *showsThatDay = [dayOfWeek objectForKey:SCHEDULE_SHOWS_THIS_DAY];
    return [showsThatDay count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dayOfWeek = [self.showData objectAtIndex:section];
    
    return [dayOfWeek objectForKey:SHOW_DAY_OF_WEEK];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if(cell == nil)
    {
        // Get custom cell from a nib
        // [[NSBundle mainBundle] loadNibNamed:@"ShowCell" owner:self options:NULL];
        // cell = nibCustomCell;
        
        // Template provided cell loading code
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
    }

    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    NSDictionary *dayOfWeek = [self.showData objectAtIndex:section];
    NSArray *showsThatDay = [dayOfWeek objectForKey:SCHEDULE_SHOWS_THIS_DAY];
    NSDictionary *showInfo = [showsThatDay objectAtIndex:row];
    
    cell.textLabel.text = [showInfo objectForKey:SHOW_TITLE];
    cell.detailTextLabel.text = [showInfo objectForKey:SHOW_DESCRIPTION];
    
    
    return cell;
}





@end
