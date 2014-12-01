//
//  ViewController.h
//  Pebblue
//
//  Created by myktra on 7/7/14.
//  Copyright (c) 2014 Michael Trachtman. All rights reserved.
//

@import UIKit;
#import <PebbleKit/PebbleKit.h>

@interface ViewController : UIViewController <PBPebbleCentralDelegate> {
    PBWatch *_targetWatch;
    CFTimeInterval currentTime;
}

@end