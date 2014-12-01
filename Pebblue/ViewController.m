//
//  ViewController.m
//  Pebblue
//
//  Created by myktra on 7/7/14.
//  Copyright (c) 2014 Michael Trachtman. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    
    currentTime = CACurrentMediaTime();

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // We'd like to get called when Pebbles connect and disconnect, so become the delegate of PBPebbleCentral:
    [[PBPebbleCentral defaultCentral] setDelegate:self];
    
    // Initialize with the last connected watch:
    [self setTargetWatch:[[PBPebbleCentral defaultCentral] lastConnectedWatch]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setTargetWatch:(PBWatch*)watch {
    _targetWatch = watch;
    
    // NOTE:
    // For demonstration purposes, we start communicating with the watch immediately upon connection,
    // because we are calling -appMessagesGetIsSupported: here, which implicitely opens the communication session.
    // Real world apps should communicate only if the user is actively using the app, because there
    // is one communication session that is shared between all 3rd party iOS apps.
    
    // Test if the Pebble's firmware supports AppMessages / Weather:
    [watch appMessagesGetIsSupported:^(PBWatch *watch, BOOL isAppMessagesSupported) {

        if (isAppMessagesSupported) {
            // Configure our communications channel to target the weather app:
            // See demos/feature_app_messages/weather.c in the native watch app SDK for the same definition on the watch's end:
            // 2f2b03e9-78c6-4309-8124-fe3b7024a7c3
            uuid_t myAppUUIDbytes;
            NSUUID *myAppUUID = [[NSUUID alloc] initWithUUIDString:@"2f2b03e9-78c6-4309-8124-fe3b7024a7c3"];
            [myAppUUID getUUIDBytes:myAppUUIDbytes];
            
            // okay, we're connected
            [[PBPebbleCentral defaultCentral] setAppUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
            NSLog(@"[%@] connected with AppMessages", [watch name]);
            
            // set up message listener
            [_targetWatch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
                
                CFTimeInterval elapsedTime = CACurrentMediaTime() - currentTime;
                currentTime = CACurrentMediaTime();
                NSLog(@"[%@] %f received message %@", [watch name], elapsedTime, update);
                return YES;
                
            } withUUID:[NSData dataWithBytes:myAppUUIDbytes length:16]];
            
        } else {
            
            NSString *message = [NSString stringWithFormat:@"Blegh... %@ does NOT support AppMessages :'(", [watch name]];
            [[[UIAlertView alloc] initWithTitle:@"Connected..." message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        }
    }];
}

/*
 *  PBPebbleCentral delegate methods
 */

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidConnect:(PBWatch*)watch isNew:(BOOL)isNew {
    
    NSLog(@"[%@] didconnect", [watch name]);
    [self setTargetWatch:watch];
    
}

- (void)pebbleCentral:(PBPebbleCentral*)central watchDidDisconnect:(PBWatch*)watch {
    
    NSLog(@"[%@] diddisconnect", [watch name]);
    
    if (_targetWatch == watch || [watch isEqual:_targetWatch]) {
        [self setTargetWatch:nil];
    }
    
}

@end
