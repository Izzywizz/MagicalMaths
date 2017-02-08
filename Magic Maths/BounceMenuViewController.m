//
//  BounceMenuViewController.m
//  Magic Maths
//
//  Created by Izzy Ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "BounceMenuViewController.h"
#import "BounceManager.h"
#import "BouncingViewController.h"
#import "HelpViewController.h"

@interface BounceMenuViewController () {
    
    int diff;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment; // refers to the segement control (Easy/ Medium/ Hard)
@property (nonatomic, weak) IBOutlet UIButton *bonus; 

@end

@implementation BounceMenuViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self unlockBonus];
}

- (void)unlockBonus // method for the bonus level
{
    diff = self.segment.selectedSegmentIndex;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *key;
    
    int unlock = 0;
    
    // check to see if all the levels have been complted and whtehr it should the bonus level
    for (int i = 1; i < 4; i++) {
        key = [NSString stringWithFormat:@"bounce%d%d", i, diff]; // dependent on difficulty as well
        if ([prefs boolForKey:key]) {
            unlock++;
        }
    }
    if (unlock == 3) { // if this conditon is true then
        self.bonus.enabled = YES; // enable the bonus level
    }
    else {
        self.bonus.enabled = NO; // otherwise disable the level
    }
}

- (void)viewDidLoad // // called when your view loading is finished loading
{
    [super viewDidLoad];
	
    BounceManager *manager = [BounceManager sharedManger];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int select = [prefs integerForKey:@"bounceSegment"]; // storage/ creation of the keys for difficulty
    self.segment.selectedSegmentIndex = select;
    manager.difficulty = select;
}

- (IBAction)bounceSegmentPressed:(UISegmentedControlSegment *)sender // difficulty selection,  0 = left (Easy), centre = 1(Medium), right = 2 (hard)
{
    BounceManager *manager = [BounceManager sharedManger];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int select = self.segment.selectedSegmentIndex;
    manager.difficulty = select;
    
    [self unlockBonus]; // checks whether the bonus level has been unlocked.
    
    [prefs setInteger:select forKey:@"bounceSegment"]; // keys stored/created for future use
    [prefs synchronize];
}

- (IBAction)bounceGamePressed:(UIButton *)sender // takes in the user touch input for the level for the game
{
    BounceManager *manager = [BounceManager sharedManger]; // calls up the method responsible for object creation in the the respective manager file (BounceManager), so that we can use the pointer manager
    manager.stage = sender.tag; 
    
    BouncingViewController *controller = [[BouncingViewController alloc] initWithNibName:@"BouncingViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; // animation style
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)helpPressed:(id)sender // brings up the help menu, via passing it to the respective view controller
{
    HelpViewController *controller = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil]; // brings up the (help menu)
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; // animation of the screen
    [self presentViewController:controller animated:YES completion:nil]; 
}

- (IBAction)homePressed:(id)sender // back button takes the user back to the previous screen
{
    [self dismissViewControllerAnimated:YES completion:nil]; // animation style
}

@end
