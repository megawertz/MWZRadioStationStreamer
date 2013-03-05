//
//  MWZSharedReachability.h
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 3/4/13.
//  Copyright (c) 2013 Jason Wertz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWZSharedReachability : NSObject

@property BOOL isNetworkReachable;

+(MWZSharedReachability *)sharedReachability;


@end
