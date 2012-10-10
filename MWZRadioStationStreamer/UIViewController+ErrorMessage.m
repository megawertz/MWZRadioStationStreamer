//
//  UIViewController+ErrorMessage.m
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 10/10/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import "UIViewController+ErrorMessage.h"

@implementation UIViewController (ErrorMessage)

-(void)errorWithTitle:(NSString *)title message:(NSString *)message andCancelButton:(NSString *)cancelButton {

    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: title
                                                        message: message
                                                       delegate: self
                                              cancelButtonTitle: cancelButton
                                              otherButtonTitles: nil];
    [someError show];

}

@end
