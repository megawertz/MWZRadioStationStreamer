//
//  MWZPodcastEpisodeListViewController.h
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWZPodcastEpisodeListViewController : UITableViewController <NSXMLParserDelegate>

@property (nonatomic,strong) NSString *feedURL;

-(void)parseXMLData:(NSData *)data;

@end
