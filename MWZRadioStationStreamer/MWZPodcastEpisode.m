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
               url:(NSString *)url {
    
    self = [super init];
    
    if(self) {
        [self setTitle:title];
        [self setDate:date];
        [self setDescription:description];
        [self setUrl:url];
    }
    
    return self;
}

-(id)init {
    return [self initWithTitle:nil date:nil description:nil url:nil];
}

-(NSString *)file {
    // Get just the mp3 filename if needed
    NSURL *tmpUrl = [NSURL URLWithString:[self url]];
    
    // relativePath may be more proper here, this might include fragments and queries
    return [[tmpUrl lastPathComponent] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end
