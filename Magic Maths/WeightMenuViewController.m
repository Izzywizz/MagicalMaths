//
//  WeightMenuViewController.m
//  Magic Maths
//
//  Created by Izzy Ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

// imports the header files

#import "WeightMenuViewController.h"
#import "WeightManager.h"
#import "WeightViewController.h"
#import "HelpViewController.h"

@interface WeightMenuViewController () {
    
    int diff;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *segment;
@property (nonatomic, weak) IBOutlet UIButton *bonus;

@end

@implementation WeightMenuViewController



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self unlockBonus]; //checks and calls the mthod, that asks whether the bonus level should be unlocked
}

- (void)unlockBonus //unlocks the bonus level, if the user has played the other stages
{
    diff = self.segment.selectedSegmentIndex; //the bonus level is unlocked depending on the difficulty, so if it medium and you played all of them they are unocked. However if the difficulty is easy and you have'nt played all the levels then it wony unlock
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *key;
    
    int unlock = 0;
    
    for (int i = 1; i < 4; i++) {
        key = [NSString stringWithFormat:@"weight%d%d", i, diff];
        if ([prefs boolForKey:key]) {
            unlock++;
        }
    }
    if (unlock == 3) { // unlocks the bonus level if the user has completed the other 3 levels
        self.bonus.enabled = YES; // enables the bonus level button
    }
    else {
        self.bonus.enabled = NO; // disables it
    }
}

- (void)viewDidLoad // called when your view loading is finished loading
{
    [super viewDidLoad];
	
    WeightManager *manager = [WeightManager sharedManger];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int select = [prefs integerForKey:@"weightSegment"]; // storage/ creation of the keys of the difficulty within the slect variable
    self.segment.selectedSegmentIndex = select; 
    manager.difficulty = select;
}

- (IBAction)weightSegmentPressed:(UISegmentedControlSegment *)sender //helps the user select the specfic difficulty of the level, 0 = left (Easy), centre = 1(Medium), right = 2 (hard)
{
    WeightManager *manager = [WeightManager sharedManger];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    int select = self.segment.selectedSegmentIndex; // when the chosen difficulty has been pressed, it is stored in select, the number.
    manager.difficulty = select; // the number reflects the difficulty
    
    [self unlockBonus]; // asks whether the bonus level is unlocked for a specific difficulty or not
    
    [prefs setInteger:select forKey:@"weightSegment"];
    [prefs synchronize];
}

- (IBAction)weightGamePressed:(UIButton *)sender // deals with the selection of the level (stage)
{
    WeightManager *manager = [WeightManager sharedManger];
    manager.stage = sender.tag; // stage selection
    
    WeightViewController *controller = [[WeightViewController alloc] initWithNibName:@"WeightViewController" bundle:nil]; //calls up the relevant viewcontroller when the button is pressed
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //animation
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)helpPressed:(id)sender //Brings up the help menu screen when pressed
{
    HelpViewController *controller = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; // animation of the screen
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)homePressed:(id)sender // the back button (arrow) tells it to go back a screen 
{
    [self dismissViewControllerAnimated:YES completion:nil]; //animate it (the flippy up/ down animiation thing)
}

@end
