//
//  UIViewController+ErrorMessage.h
//  MWZRadioStationStreamer
//
//  Created by Jason Wertz on 10/10/12.
//  Copyright (c) 2012 Jason Wertz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ErrorMessage)

-(void)errorWithTitle:(NSString *)title message:(NSString *)message andCancelButton:(NSString *)cancelButton;

@end
