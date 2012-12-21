//
//  MWZPodcastEpisode.h
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWZPodcastEpisode : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *url;

-(id)initWithTitle:(NSString *)title
              date:(NSString *)date
       description:(NSString *)description
               url:(NSString *)url;


-(NSString *)file;

@end
