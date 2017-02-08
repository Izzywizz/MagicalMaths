//
//  AppDelegate.m
//  Magic Maths
//
//  Created by Izzy Ali on 03/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

    // Telling the delegate that the app is almost ready to be launched
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // THe self.window.rootViewController will resize the ViewController according to status bar height
    // acts as a sort of root controller 
    
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    NSDictionary *dict = @ {
        @"audio" : @YES
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:dict];
    
    return YES;
}

@end
