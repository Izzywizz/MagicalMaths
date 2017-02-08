//
//  ViewController.m
//  Magic Maths
//
//  Created by Izzy Ali on 03/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "ViewController.h"
#import "WeightMenuViewController.h"
#import "BounceMenuViewController.h"
#import "HelpViewController.h"

// import relevant files

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

// When the user touches the Weight image, the user is taken to the Weight Menu (WeightMenuViewController)

- (IBAction)weightGamePressed:(id)sender
{
    //Model methods
    WeightMenuViewController *controller = [[WeightMenuViewController alloc] initWithNibName:@"WeightMenuViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; // The animation of how it slides to the next screen
    [self presentViewController:controller animated:YES completion:nil]; // To do with animation, askes whether its completed and that the transition style is specified previously in the modalTransitionStyle property (Flip Horizontal thing)
}

// Similar to the above action, in that when 'touched' brings up the Bouncing Ball game Menu

- (IBAction)bounceGamePressed:(id)sender
{
    BounceMenuViewController *controller = [[BounceMenuViewController alloc] initWithNibName:@"BounceMenuViewController" bundle:nil]; // calls up the relevant, viewcontroller (bounce Menu)
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)helpPressed:(id)sender //Brings up the help menu screen when pressed
{
    HelpViewController *controller = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; // animation of the screen
    [self presentViewController:controller animated:YES completion:nil];
}

@end
