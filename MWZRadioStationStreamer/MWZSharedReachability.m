//
//  MWZSharedReachability.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 3/4/13.
//  Copyright (c) 2013 Jason Wertz. All rights reserved.
//

#import "MWZSharedReachability.h"
#import "Reachability.h"

@interface MWZSharedReachability()

// This is general, should check host
@property (strong, nonatomic) Reachability *reachInternet;

-(void)reachabilityChanged:(NSNotification *)note;

@end

@implementation MWZSharedReachability

+(MWZSharedReachability *)sharedReachability {
    static MWZSharedReachability *sharedReachability = nil;
    if(!sharedReachability)
        sharedReachability = [[super allocWithZone:nil] init];
    
    return sharedReachability;
}

+(id)allocWithZone:(NSZone *)zone {
    return [self sharedReachability];
}

-(id)init {
    self = [super init];
    if(self) {
        // Setup the object
        Reachability *tmp = [Reachability reachabilityForInternetConnection];
        [self setReachInternet:tmp];
        
        // Get the default state of the network
        // Without this the initial state is wrong and doesn't get corrected unitl
        //   a notification is sent. Not sure why...but it's late soooooo
        NetworkStatus status = [[self reachInternet] currentReachabilityStatus];
        [self setIsNetworkReachable:(status != NotReachable)];
        
        // Start sending notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        [[self reachInternet] startNotifier];
    }
    
    return self;
}

-(void)dealloc {
    [[self reachInternet] stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reachabilityChanged:(NSNotification *)note
{
    DLog(@"Reachability Changed yo!");
    
    NetworkStatus status = [[self reachInternet] currentReachabilityStatus];
    [[self.class sharedReachability] setIsNetworkReachable:(status != NotReachable)];
}

@end
