//
//  MWZSecondViewController.h
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 9/24/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWZScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *showData;
@property (strong, nonatomic) UIView *updatingView;

@property int showDataVersionNumber;

@property (weak, nonatomic) IBOutlet UINavigationItem *scheduleTitle;

-(IBAction)updateSchedule;

@end
