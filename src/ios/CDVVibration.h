//
//  CDVVibration.h
//  Vibration-Obj-c
//
//  Created by MacBook on 17.08.2021.
//

#import <UIKit/UIKit.h>
#import <CoreHaptics/CoreHaptics.h>
#import <Cordova/CDVPlugin.h>

@interface CDVVibration : CDVPlugin


- (void)vibrate: (id)ms;
- (void)stop;

@end
