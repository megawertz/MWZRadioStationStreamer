//
//  MWZSecondViewController.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 9/24/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZScheduleViewController.h"
#import "UIViewController+ErrorMessage.h"

// TODO: Get a permenant home for the schedule plist file
#define UPDATE_URL              @"https://dl.dropbox.com/u/274743/"
#define SCHEDULE_FILE_NAME      @"showData.plist"

#define UPDATE_KEY              @"LastUpdateTime"
#define UPDATE_INTERVAL         60 * 5 // 5 minutes

#define SHOW_TITLE              @"Title"
#define SHOW_DESCRIPTION        @"Description"
#define SHOW_START_TIME         @"StartTime"
#define SHOW_END_TIME           @"EndTime"
#define SHOW_DAY_OF_WEEK        @"Day"

#define SCHEDULE_SHOWS_THIS_DAY @"Shows"
#define SCHEDULE_TITLE          @"ScheduleTitle"
#define SCHEDULE_VERSION        @"ScheduleVersion"
#define SCHEDULE_SHOW_DATA      @"ScheduleShowData"

#define SCHEDULE_CELL_TITLE         100
#define SCHEDULE_CELL_TIME          110
#define SCHEDULE_CELL_DESCRIPTION   120

@interface MWZScheduleViewController ()

/// Cached date formatter for use when creating cells.
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

-(void)saveUpdateTime;
-(BOOL)performUpdateBasedOnTime;
-(void)noNewDataAvailableAlert;
-(void)processDownloadedData:(NSData *)downloadData;
-(NSString *)getFormattedTimeWithStartDate:(NSDate *)start andEndDate:(NSDate *)end;

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
            DLog(@"Schedule file not copied to documents directory. Error.");
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

-(NSString *)getFormattedTimeWithStartDate:(NSDate *)start andEndDate:(NSDate *)end {
    NSString *startTime = [self.dateFormatter stringFromDate:start];
    NSString *endTime = [self.dateFormatter stringFromDate:end];
    
    return [NSString stringWithFormat:@"%@ to %@",startTime, endTime];
}

-(IBAction)updateSchedule
{
    
    // Break the code in this if statement out into a separate method.
    if([self performUpdateBasedOnTime])
    {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",UPDATE_URL,SCHEDULE_FILE_NAME]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        // Lazy load this view
        if([self updatingView] == nil) {
            UIView *indicatorView = [[UIView alloc] initWithFrame:[self.view frame]];
            
            [indicatorView setBackgroundColor:[UIColor blackColor]];
            [indicatorView setAlpha:.5];
            
            UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [activityIndicator setCenter:[indicatorView center]];
            [indicatorView addSubview:activityIndicator];
            [activityIndicator startAnimating];
            [self setUpdatingView:indicatorView];
            
        }
        
        [[self view] addSubview:[self updatingView]];
        
        
        __block MWZScheduleViewController *blockSelf = self;
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                                   
                                   [[blockSelf updatingView] removeFromSuperview];
                                   
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                   if(error == nil && [httpResponse statusCode] == 200) {
                                       [blockSelf processDownloadedData:data];
                                       [blockSelf saveUpdateTime];
                                   }
                                   else {
                                       // Download error, prompt to try again
                                       [blockSelf errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_ScheduleDownloadError",@"There was an error with the download.")
                                                    message:NSLocalizedString(@"ErrorDialogMessage_ScheduleDownloadFailed",@"There was an error. Please try again later.")
                                            andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];
                                   }
                               }];
    }
    else {
        [self noNewDataAvailableAlert];
    }
}

-(void)saveUpdateTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:UPDATE_KEY];
}

-(BOOL)performUpdateBasedOnTime {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastUpdate = [defaults objectForKey:UPDATE_KEY];
    
    if(lastUpdate == nil)
        return YES;
    
    DLog(@"Last Update Time: %@",lastUpdate);
    
    return ([lastUpdate timeIntervalSinceNow] > UPDATE_INTERVAL);
    
}

-(void)processDownloadedData:(NSData *)downloadData
{
    // Get the plist
    NSPropertyListFormat format;
    NSString *errorDescription = nil;
    NSDictionary *tmp = [NSPropertyListSerialization propertyListFromData:downloadData mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&errorDescription];
    
    int newVersionNumber = [[tmp objectForKey:SCHEDULE_VERSION] intValue];
    
    if(self.showDataVersionNumber < newVersionNumber)
    {
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
        [self noNewDataAvailableAlert];
    }
}

-(void)noNewDataAvailableAlert {
    // Alert the user
    [self errorWithTitle:NSLocalizedString(@"ErrorDialogTitle_ScheduleDownloadUnavailable",@"Nothing New.")
                 message:NSLocalizedString(@"ErrorDialogMessage_ScheduleDownloadNoNewData",@"There was no new schedule available.")
         andCancelButton:NSLocalizedString(@"ErrorDialogCancelButton_Standard",@"Dismiss.")];
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
    NSArray *showsThatDay = [dayOfWeek objectForKey:SCHEDULE_SHOWS_THIS_DAY];
    
    if([showsThatDay count] == 0)
        return nil;
    else
        return [dayOfWeek objectForKey:SHOW_DAY_OF_WEEK];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    // Get description text
    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    NSDictionary *dayOfWeek = [self.showData objectAtIndex:section];
    NSArray *showsThatDay = [dayOfWeek objectForKey:SCHEDULE_SHOWS_THIS_DAY];
    NSDictionary *showInfo = [showsThatDay objectAtIndex:row];

    NSString *description = [showInfo objectForKey:SHOW_DESCRIPTION];
    
    // TODO: AHHHHHH, DON'T HARDCODE THIS!!!!
    // Get a reference to an actual cell object and pull sizes out on viewDidLoad?
    float defaultCellHeight = 80.0 - 21.0;
    
    CGSize maxSize = CGSizeMake(280.0,999.0);

    CGSize actualSize = [description sizeWithFont:[UIFont systemFontOfSize:16.0] constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    
    // Measure and return the height...get number of lines?
    return defaultCellHeight + actualSize.height;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ScheduleCell";
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSUInteger section = [indexPath section];
	NSUInteger row = [indexPath row];
    
    NSDictionary *dayOfWeek = [self.showData objectAtIndex:section];
    NSArray *showsThatDay = [dayOfWeek objectForKey:SCHEDULE_SHOWS_THIS_DAY];
    NSDictionary *showInfo = [showsThatDay objectAtIndex:row];
    
    UILabel *showTitle = (UILabel *) [cell viewWithTag:SCHEDULE_CELL_TITLE];
    showTitle.text = [showInfo objectForKey:SHOW_TITLE];
    
    UILabel *showTime = (UILabel *) [cell viewWithTag:SCHEDULE_CELL_TIME];
    showTime.text = [self getFormattedTimeWithStartDate:[showInfo objectForKey:SHOW_START_TIME] andEndDate:[showInfo objectForKey:SHOW_END_TIME]];
    
    UILabel *showDescription = (UILabel *) [cell viewWithTag:SCHEDULE_CELL_DESCRIPTION];
    showDescription.text = [showInfo objectForKey:SHOW_DESCRIPTION];
    
    return cell;
}





@end
