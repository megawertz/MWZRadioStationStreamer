//
//  MWZPodcastEpisode.m
//  MWZRadioStationStreamer
//
//  Created by  Jason Wertz on 12/19/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZPodcastEpisode.h"

@implementation MWZPodcastEpisode

-(id)initWithTitle:(NSString *)title
              date:(NSString *)date
       description:(NSString *)description
          fileName:(NSString *)fileName {
    
    self = [super init];
    
    if(self) {
        [self setTitle:title];
        [self setDate:date];
        [self setDescription:description];
        [self setFileName:fileName];
    }
    
    return self;
}

-(id)init {
    return [self initWithTitle:nil date:nil description:nil fileName:nil];
}

@end
