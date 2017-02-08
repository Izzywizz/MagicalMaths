//
//  HelpViewController.m
//  Magic Maths
//
//  Created by Izzy Ali on 10/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@property (nonatomic, weak) IBOutlet UITextView *play;
@property (nonatomic, weak) IBOutlet UITextView *about;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *aboutButton;

/* IBAction and IBOutlet are defined to show variables and methods that are connected and referenced in the Interface Builder.*/

@end

@implementation HelpViewController

- (IBAction)playPressed:(id)sender // if the play button is pressed, the following sequence of actions occur
{
    self.about.hidden = YES; // hide the about screen
    self.play.hidden = NO; // show the play screen with the text about how to play the games
    
    [self.playButton setImage:[UIImage imageNamed:@"playArrowDown.png"] forState:normal]; // shows the red outline arrow, meaning that the menu option has been selected when the user has pressed it
    [self.aboutButton setImage:[UIImage imageNamed:@"playArrow.png"] forState:normal]; // show the normal arrow (unpressed version)
}

- (IBAction)aboutPressed:(id)sender // When the user presses the about arrow, these action occur.
{
    self.play.hidden = YES; //hide the screen
    self.about.hidden = NO; // show the about screen whilst hiding the text of how to play screen.
    
    [self.playButton setImage:[UIImage imageNamed:@"playArrow.png"] forState:normal];
    [self.aboutButton setImage:[UIImage imageNamed:@"playArrowDown.png"] forState:normal];
}

- (IBAction)homePressed:(id)sender // back arrow, go back to the previous screen
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
