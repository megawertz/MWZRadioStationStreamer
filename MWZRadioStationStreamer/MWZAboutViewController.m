//
//  MWZAboutViewController.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 10/10/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "MWZAboutViewController.h"

@interface MWZAboutViewController ()

@end

@implementation MWZAboutViewController

-(BOOL) webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[inRequest URL]];
        return NO;
    }
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// TODO: Internationalize this using template-replace and Localize files.
    NSString *file2Load = [[NSBundle mainBundle] pathForResource:@"About" ofType:@"html"];
    NSURL *file2LoadURL = [NSURL fileURLWithPath:file2Load];
    NSURLRequest *r = [NSURLRequest requestWithURL:file2LoadURL];
    [self.aboutWebView loadRequest:r];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
