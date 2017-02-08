//
//  BouncingViewController.m
//  Magic Maths
//
//  Created by Izzy Ali on 07/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "BouncingViewController.h"
#import "BounceManager.h"
#import "AudioManager.h"

@interface BouncingViewController () {
    
    float p1X;
    float p1Y;
    
    float p2X;
    float p2Y;
    
    float p3X;
    float p3Y;
    
    BOOL collision1X;
    BOOL collision1Y;
    BOOL collision2X;
    BOOL collision2Y;
    BOOL collision3X;
    BOOL collision3Y;
    
    BOOL buffer;
    
    BOOL hold1;
    BOOL hold2;
    BOOL hold3;
    
    BOOL canHold1;
    BOOL canHold2;
    BOOL canHold3;
    
    BOOL isProcessing;
    
    int answer;
    
    int time;
    int count;
    int score;
    int stage;
    int diff;
    int holder;
    
    int chainBonus;
    int chainCount;
    int chainRange;
    
    int correctAnswer;
    int wrongAnswer;
    
    BOOL add12;
    BOOL add13;
    BOOL add21;
    BOOL add23;
    BOOL add31;
    BOOL add32;
    
    BOOL targetOn;
}

//  responsible for the messages sent to view objects of the UIKit framework (in iOS)

@property (nonatomic, weak) IBOutlet UIImageView *ball1;
@property (nonatomic, weak) IBOutlet UIImageView *ball2;
@property (nonatomic, weak) IBOutlet UIImageView *ball3;

/*
 the Ball is broke into 3 parts
 
 1) Boundries of the ball (balll2).
 2) The Label with the value of the ball (label2)
 3) A dummy image ball. (dummy2)
 
 They all have to move together at the same time in the same position, inlduing the text (number value) label. The ball1 is the actual bounds where the collision takes place, the dummy image that you see doesn’t bounce off anything it is the dummy image. 
 If the balls were squares then we wouldn't have to use a dummy. The problem that I found is that UIKit isn't concerned with pixels but the boundries if the image.
 Since they are round but defined in a  square bound, when the two squares (ball2 and ball3 for example) hit each other, they would bounce. As I made it a smaller square inside the dummy image of the ball to make it more realistic.
 
 */

@property (nonatomic, weak) IBOutlet UIImageView *dummy1;
@property (nonatomic, weak) IBOutlet UIImageView *dummy2;
@property (nonatomic, weak) IBOutlet UIImageView *dummy3;

@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UILabel *label3;

@property (nonatomic, weak) NSTimer *gameTimer;

@property (nonatomic, weak) IBOutlet UILabel *sumLabel;

@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *bestLabel;
@property (nonatomic, weak) IBOutlet UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UILabel *chainLabel;

@property (nonatomic, weak) IBOutlet UILabel *reviewScoreLabel;

@property (nonatomic, weak) IBOutlet UIImageView *target;

@property (nonatomic, weak) IBOutlet UIButton *toggleButton;

@property (nonatomic, weak) IBOutlet UIScrollView *pauseScreen;
@property (nonatomic, weak) IBOutlet UIScrollView *reviewScreen;

@end

@implementation BouncingViewController

- (void)viewWillAppear:(BOOL)animated // sets up the intial view
{
    [super viewWillAppear:YES];
    
    // check if their is a best score stored within the keys
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"bounceScore%d%d", stage, diff];
    int best = [prefs integerForKey:key];
    self.bestLabel.text = [NSString stringWithFormat:@"%d", best];
    
    holder = best; // make the holder variable the best score
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseGame2)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:NULL];
    
    BounceManager *manager = [BounceManager sharedManger];
    
    diff = manager.difficulty; //obtain the diffuclty preivously set and the stage selected by the suer 
    [self difficulty:diff];
    
    stage = manager.stage; // stage slection by the user 
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    
    // play audio song, the background music of the app
    if ([prefs boolForKey:@"audio"]) {
        
        AudioManager *audioManager = [AudioManager sharedManager];
        audioManager.audio = [AudioManager loadFile:@"loop" withType:@"mp3"]; 
        audioManager.audio.volume = 0.5;
        audioManager.audio.numberOfLoops = -1;
        [audioManager.audio play];
    }
    else {
        [self.toggleButton setImage:[UIImage imageNamed:@"soundOff.png"] forState:normal]; //  if not then the sound button has been pressed and thus the sound off image will be shown
    }
    
// refers to whether the 4 level (bonus) has been unlocked, same as the fromat in WeightGame
    NSString *key = [NSString stringWithFormat:@"bounce%d%d", stage, diff];
    if (![prefs boolForKey:key] && stage != 4) {
        [prefs setBool:YES forKey:key];
        [prefs synchronize];
    }
    
    [self setPoints:stage]; // collision dection is ready to be implemeneted

    [self prepareLevel]; // call the level preperation
    [self startGame]; // call the startGame method
}

- (void)prepareLevel // sets up the intial level
{
    [self createLabels1]; // calls the Create the labels for ball1
    [self createLabels2]; // label for ball2
    [self createLabels3]; // label for ball3
    
    switch (stage) { // helps decied the level and questions of the relevant stage
        case 1:
            [self setEquationOne]; // level 1 use these set of eqautions (plus and minus)
            break;
        case 2:
            [self setEquationTwo]; // use these equations for level 2 (operator balls)
            break;
        case 3:
            [self setEquationThree]; // the multuiply equations for level 3
            break;
        case 4:
            [self setEquationFour]; // the mix of equations 1/3 for the bonus level
            break;
    }
    // set booleans values to true at the start of the level, so the balls are able to merge/add together
    add12 = YES;
    add13 = YES;
    add21 = YES;
    add23 = YES;
    add31 = YES;
    add32 = YES;
    
    // entry points for the balls coordinates
    [self enter1]; //ball1 (top left)
    [self enter2]; //ball2 (top right)
    [self enter3]; //ball3 (bottom left)
    
    self.timerLabel.textColor = [UIColor whiteColor]; // colour of the timer
}

- (void)startGame //start the game, start timer, tell the balls to move etc
{
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.005f
                                                      target:self
                                                    selector:@selector(moveBalls:)// move the balls around the screen is notified
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning // to do with memeory being to low, warning sent to the ipad
{
    [super didReceiveMemoryWarning];
}

- (void)difficulty:(int)value // set the scores of the level depending on the diffuclty set previously
{
    if (value == 0) {
        wrongAnswer = 1; // take off 1 point for a wrong answer
        chainBonus = 10;
        chainRange = 3;
        time = 99;
    }
    else if (value == 1) {
        wrongAnswer = 3;
        chainBonus = 20; // how many extra points you get for getting the correct amount of answers in a row.
        chainRange = 4;
        time = 90;
    }
    else {
        wrongAnswer = 5;
        chainBonus = 30;
        chainRange = 5; // the number of correct answers you need to get in a row to activate chainBonus
        time = 80;
    }
    correctAnswer = 10; // the user always get 10 points for a correct answer regardless of the difficulty
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d", time];
}

- (void)countDown // Count down timer, same as the method used in WeightViewController
{
    time--;
    self.timerLabel.text = [NSString stringWithFormat:@"%d", time];
    
    if (time == 10) { // play alarm effect when timer reaches 10
        self.timerLabel.textColor = [UIColor redColor]; // red colour text
        self.timerLabel.font = [self.timerLabel.font fontWithSize:50]; // larger font 
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) {
            AudioManager *audioManager = [AudioManager sharedManager];
            audioManager.effect4 = [AudioManager loadFile:@"Alarm" withType:@"mp3"];
            audioManager.effect4.numberOfLoops = 1;
            [audioManager.effect4 play];
        }
    }
    
    if (time <= 0) { // game has finished
        [self.gameTimer invalidate];
        self.gameTimer = nil;
        
        //stores the score 
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"bounceScore%d%d", stage, diff];
        int temp = [prefs integerForKey:key]; // store in temp
        
        if (score > temp) { // checks wther score is greater then temp
            [prefs setInteger:score forKey:key]; //then set it if it is
            [prefs synchronize];
        }
        
        //stops all sound effects when timer has reached 0
        AudioManager *audioManager = [AudioManager sharedManager];
        [audioManager.effect1 stop];
        [audioManager.effect2 stop];
        [audioManager.effect3 stop];
        [audioManager.effect4 stop];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [self timesUp]; // call the method that checks whether the time is up
    }
}

- (void)timesUp // when the timer has finished couting down. The score is checked to tell if its high score or not 
{
    if (score > holder) {
        self.reviewScoreLabel.text = [NSString stringWithFormat:@"NEW HIGH\nSCORE!\n%d", score]; // High score if the current score is higher then the holder (previous best score)
    }
    else {
        self.reviewScoreLabel.text = [NSString stringWithFormat:@"GREAT SCORE\n%d\nYou can do even better!", score]; // if not, its just a normal score (not high)
    }
    self.reviewScreen.hidden = NO; // show the special review score (meaning the one without the sound on/off button)
}

- (void)enter1 // intial coordinates given to the balls entry point
{
    self.ball1.center = CGPointMake(30.0f, 100.0f); // top left ball
    self.dummy1.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
    self.label1.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
    self.ball1.alpha = 1.0f; // move speed/ duration
    self.dummy1.alpha = 1.0f;
    self.label1.alpha = 1.0f;
    
    targetOn = YES; // refers to the equation catching area, where the user drags the ball to check if its right answer or not, this is set to YES to enable it
    canHold1 = YES; // able to hold the ball 1
}

- (void)enter2 // top right ball entry point
{
    self.ball2.center = CGPointMake(1014.0f, 100.0f); // the exact coordiantes of the intial starting point of ball 2
    self.dummy2.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
    self.label2.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
    self.ball2.alpha = 1.0f;
    self.dummy2.alpha = 1.0f;
    self.label2.alpha = 1.0f;
    
    targetOn = YES; // target area of the equation is on
    canHold2 = YES; // able to hold on to ball 2
}

- (void)enter3 // bottom left ball entry point
{
    self.ball3.center = CGPointMake(100.0f, 758.0f);
    self.dummy3.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
    self.label3.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
    self.ball3.alpha = 1.0f;
    self.dummy3.alpha = 1.0f;
    self.label3.alpha = 1.0f;
    
    targetOn = YES; // target area of equation is on
    canHold3 = YES; // able to hold ball 3
}

// Setting up the balls for the adding, boolean value all set to YES so that the action can occur

- (void)set12
{
    add12 = YES; // deals with the adding of ball 1 and 2
}

- (void)set13
{
    add13 = YES; // deals with the adding of ball 1 and 3
}

- (void)set21
{
    add21 = YES; // deals with the adding of ball 2 and 1
}

- (void)set23
{
    add23 = YES; // deals with the adding of ball 2 and 3
}

- (void)set31
{
    add31 = YES; // 
}

- (void)set32
{
    add32 = YES;
}

- (void)merge12 //merging the 1 and 2 balls animation
{
    [UIView animateWithDuration:0.25f
                     animations:^ {
                         self.ball2.alpha = 0.0f;
                         self.dummy2.alpha = 0.0f;
                         self.label2.alpha = 0.0f;
                         self.ball2.center = CGPointMake(self.ball1.center.x, self.ball1.center.y); 
                         self.dummy2.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
                         self.label2.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
                     }
                     completion:^(BOOL finished) { 
                         self.ball2.center = CGPointMake(0.0f, 0.0f);
                         self.dummy2.center = CGPointMake(0.0f, 0.0f);
                         self.label2.center = CGPointMake(0.0f, 0.0f);
                         [self performSelector:@selector(enter2) withObject:nil afterDelay:1.0f]; // entry point for the new ball
                         [self performSelector:@selector(set12) withObject:nil afterDelay:1.0f]; // the animtion after the merging and method call up that is repsonsible for the boolean value is set to YES, meaning the values can bee added
                     }];
}

- (void)merge13 //merging 1 and 3 balls animations
{
    [UIView animateWithDuration:0.25f
                     animations:^ {
                         self.ball3.alpha = 0.0f;
                         self.dummy3.alpha = 0.0f;
                         self.label3.alpha = 0.0f;
                         self.ball3.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
                         self.dummy3.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
                         self.label3.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
                     }
                     completion:^(BOOL finished) {
                         self.ball3.center = CGPointMake(0.0f, 0.0f);
                         self.dummy3.center = CGPointMake(0.0f, 0.0f);
                         self.label3.center = CGPointMake(0.0f, 0.0f);
                         [self performSelector:@selector(enter3) withObject:nil afterDelay:1.0f];
                         [self performSelector:@selector(set13) withObject:nil afterDelay:1.0f];
                     }];
}

- (void)merge21 //merging the 2 and 1 balls animations
{
    [UIView animateWithDuration:0.25f
                     animations:^ {
                         self.ball1.alpha = 0.0f;
                         self.dummy1.alpha = 0.0f;
                         self.label1.alpha = 0.0f;
                         self.ball1.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
                         self.dummy1.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
                         self.label1.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
                     }
                     completion:^(BOOL finished) {
                         self.ball1.center = CGPointMake(0.0f, 0.0f);
                         self.dummy1.center = CGPointMake(0.0f, 0.0f);
                         self.label1.center = CGPointMake(0.0f, 0.0f);
                         [self performSelector:@selector(enter1) withObject:nil afterDelay:1.0f];
                         [self performSelector:@selector(set21) withObject:nil afterDelay:1.0f];
                     }];
}

- (void)merge23 //merging the 2 and 3 balls animations
{
    [UIView animateWithDuration:0.25f
                     animations:^ {
                         self.ball3.alpha = 0.0f;
                         self.dummy3.alpha = 0.0f;
                         self.label3.alpha = 0.0f;
                         self.ball3.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
                         self.dummy3.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
                         self.label3.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
                     }
                     completion:^(BOOL finished) {
                         self.ball3.center = CGPointMake(0.0f, 0.0f);
                         self.dummy3.center = CGPointMake(0.0f, 0.0f);
                         self.label3.center = CGPointMake(0.0f, 0.0f);
                         [self performSelector:@selector(enter3) withObject:nil afterDelay:1.0f];
                         [self performSelector:@selector(set23) withObject:nil afterDelay:1.0f];
                     }];
}

- (void)merge31 // merging the 3 and 1 ball animation 
{
    [UIView animateWithDuration:0.25f
                     animations:^ {
                         self.ball1.alpha = 0.0f;
                         self.dummy1.alpha = 0.0f;
                         self.label1.alpha = 0.0f;
                         self.ball1.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
                         self.dummy1.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
                         self.label1.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
                     }
                     completion:^(BOOL finished) {
                         self.ball1.center = CGPointMake(0.0f, 0.0f);
                         self.dummy1.center = CGPointMake(0.0f, 0.0f);
                         self.label1.center = CGPointMake(0.0f, 0.0f);
                        [self performSelector:@selector(enter1) withObject:nil afterDelay:1.0f];
                         [self performSelector:@selector(set31) withObject:nil afterDelay:1.0f];
                     }];
}

- (void)merge32 // merging the 3 and 2 ball animation
{
    [UIView animateWithDuration:0.25f
                     animations:^ {
                         self.ball2.alpha = 0.0f;
                         self.dummy2.alpha = 0.0f;
                         self.label2.alpha = 0.0f;
                         self.ball2.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
                         self.dummy2.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
                         self.label2.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
                     }
                     completion:^(BOOL finished) {
                         self.ball2.center = CGPointMake(0.0f, 0.0f);
                         self.dummy2.center = CGPointMake(0.0f, 0.0f);
                         self.label2.center = CGPointMake(0.0f, 0.0f);
                         [self performSelector:@selector(enter2) withObject:nil afterDelay:1.0f];
                         [self performSelector:@selector(set32) withObject:nil afterDelay:1.0f];
                     }];
}

- (void)moveBalls:(NSTimer *)timer // method for the movement of the balls, thier collision and merging mechanics
{
    count++;
    if (count >= 200) {
        count = 0;
        [self countDown];
    }
    
    if (CGRectIntersectsRect(self.ball1.frame, self.ball2.frame)) { // if the frame of the ball 1 (the square box) and the frame of the ball 2 intersect (or touch) then this wil occur
        
        if (hold1) { // if ball 1 is being held then do this
            if (add12) { // if the boolean value is YES, add the 1 and 2 ball
                add12 = NO; // but set the ball back to NO for additon again
                
                // used for stage 2 with the operator balls, so that the operator switch round so if a (+) ball and a (-) ball merge, then it becomes (-)
                if ([self.label1.text isEqualToString:@"x"] || [self.label1.text isEqualToString:@"\u00F7"] ||
                    [self.label1.text isEqualToString:@"-"] || [self.label1.text isEqualToString:@"+"] ||
                    [self.label2.text isEqualToString:@"x"] || [self.label2.text isEqualToString:@"\u00F7"] ||
                    [self.label2.text isEqualToString:@"-"] || [self.label2.text isEqualToString:@"+"]) {
                    
                    self.label1.text = self.label3.text; // then the label1 text is equal to the label3
                }
                else { // if its just normal text value, the addition of the two balls occur
                    int total = [self.label1.text intValue] + [self.label2.text intValue]; //adding the label 1 value with the label 2 value and storing it on to the total varible
                    self.label1.text = [NSString stringWithFormat:@"%d", total]; // Assigns the total variable value to the label 1 text field, so in effect you see the two ball values add togetther (merge) to create one ball with the sum of the two previous balls
                }
                
                [self merge12]; // Calls the merge animation, so you see ball 1 and ball 2 merge together and create a new ball1
            }
        }
        else if (hold2) { // if ball 2 is being held, the additon of 2 and 1 method is set out below.
            if (add21) {
                add21 = NO; 
                
                // opeartor level
                if ([self.label1.text isEqualToString:@"x"] || [self.label1.text isEqualToString:@"\u00F7"] ||
                    [self.label1.text isEqualToString:@"-"] || [self.label1.text isEqualToString:@"+"] ||
                    [self.label2.text isEqualToString:@"x"] || [self.label2.text isEqualToString:@"\u00F7"] ||
                    [self.label2.text isEqualToString:@"-"] || [self.label2.text isEqualToString:@"+"]) {
                    
                    self.label2.text = self.label1.text;
                }
                else {
                    int total = [self.label2.text intValue] + [self.label1.text intValue]; //the addtion of the  2 and 1 ball and assing ithe label 2 ball
                    self.label2.text = [NSString stringWithFormat:@"%d", total];
                }
                
                [self merge21]; // animation of the merging of the 2 and 1 balls
            }
        }
        else { // if none of these are in use then collsion of the balls will occurr.  The bouncing off effect
            [self change1X]; // calls up the method for the change in direction of the balls, each method is responsible for certain angle. change1x = ball1 and change2x = ball2 Movement direction
            [self change1Y]; // refers to the actual collison of the balls, the ball1 image frame is used as the boundry
            [self change2X];
            [self change2Y];
        }
    }
    
    if (CGRectIntersectsRect(self.ball1.frame, self.ball3.frame)) { // intersection of the ball 1 and ball 3 
        
        if (hold1) { //if ball 1 is being held, peform the following methods
            if (add13) {
                add13 = NO;
                
                // opeartor level
                if ([self.label1.text isEqualToString:@"x"] || [self.label1.text isEqualToString:@"\u00F7"] ||
                    [self.label1.text isEqualToString:@"-"] || [self.label1.text isEqualToString:@"+"] ||
                    [self.label3.text isEqualToString:@"x"] || [self.label3.text isEqualToString:@"\u00F7"] ||
                    [self.label3.text isEqualToString:@"-"] || [self.label3.text isEqualToString:@"+"]) {
                    
                    self.label1.text = self.label3.text;
                }
                else {
                    int total = [self.label1.text intValue] + [self.label3.text intValue]; //add the label in ball 1 with the label value in 3 and assign it to the label 1
                    self.label1.text = [NSString stringWithFormat:@"%d", total];
                }
                
                [self merge13]; // animation for this merging 1 and 3
            }
        }
        else if (hold3) { // if ball 3 is being held
            if (add31) {
                add31 = NO;
                
                if ([self.label1.text isEqualToString:@"x"] || [self.label1.text isEqualToString:@"\u00F7"] ||
                    [self.label1.text isEqualToString:@"-"] || [self.label1.text isEqualToString:@"+"] ||
                    [self.label3.text isEqualToString:@"x"] || [self.label3.text isEqualToString:@"\u00F7"] ||
                    [self.label3.text isEqualToString:@"-"] || [self.label3.text isEqualToString:@"+"]) {
                    
                    self.label3.text = self.label1.text;
                }
                else {
                    int total = [self.label3.text intValue] + [self.label1.text intValue];
                    self.label3.text = [NSString stringWithFormat:@"%d", total];
                }
                
                [self merge31]; // animation of the merging of 3 and 1
            }
        }
        else { // refers to the change in direction given to the ball
            [self change1X];
            [self change1Y];
            [self change3X]; //call the relevant change in direction of the specific ball, in this case change3x = ball3 movement
            [self change3Y];
        }
    }
    
    if (CGRectIntersectsRect(self.ball2.frame, self.ball3.frame)) { // intersection of ball 2 and ball 3
        
        if (hold2) {
            if (add23) {
                add23 = NO;
                
                // operator level
                if ([self.label2.text isEqualToString:@"x"] || [self.label2.text isEqualToString:@"\u00F7"] ||
                    [self.label2.text isEqualToString:@"-"] || [self.label2.text isEqualToString:@"+"] ||
                    [self.label3.text isEqualToString:@"x"] || [self.label3.text isEqualToString:@"\u00F7"] ||
                    [self.label3.text isEqualToString:@"-"] || [self.label3.text isEqualToString:@"+"]) {
                    
                    self.label2.text = self.label3.text;
                }
                else {
                    int total = [self.label2.text intValue] + [self.label3.text intValue]; // the additon of the label 2 and label 3 and showing output in label 2
                    self.label2.text = [NSString stringWithFormat:@"%d", total];
                }
                
                [self merge23]; // merging animation for ball 2 and 3
            }
        }
        else if (hold3) {
            if (add32) {
                add32 = NO;
                
                // operator level
                if ([self.label2.text isEqualToString:@"x"] || [self.label2.text isEqualToString:@"\u00F7"] ||
                    [self.label2.text isEqualToString:@"-"] || [self.label2.text isEqualToString:@"+"] ||
                    [self.label3.text isEqualToString:@"x"] || [self.label3.text isEqualToString:@"\u00F7"] ||
                    [self.label3.text isEqualToString:@"-"] || [self.label3.text isEqualToString:@"+"]) {
                    
                    self.label3.text = self.label2.text;
                }
                else {
                    int total = [self.label3.text intValue] + [self.label2.text intValue];// the additon of the label 3 and label 2 and showing output in label 3
                    self.label3.text = [NSString stringWithFormat:@"%d", total];
                }
                
                [self merge32]; // merging animation of ball3 and ball2
            }
        }
        else { // coliison of the 2 balls is handle here, its direction and angel specific to each ball
            [self change2X];
            [self change2Y];
            [self change3X];
            [self change3Y];
        }
    }
    
    //Boundry settings of the screen for the balls
    
    if (!hold1 && canHold1) { //if no one is holding ball1 and canhold1 (meaning the ball can be held) is true, the do this this
        //this helps with boundry sscreen setting for the balls
        if (self.ball1.center.x <= 0) { // refers to the edge of the screen if the ball hits the edge of screen then it changes its direction, (left)
            self.ball1.center = CGPointMake(10, self.ball1.center.y);
            [self change1X]; //change direction method check in the x range for ball1, change also changes the value of the text label
        }
        else if (self.ball1.center.x >= 1024) { // edge of the screen, (right)
            self.ball1.center = CGPointMake(1014, self.ball1.center.y);
            [self change1X];
        }
        else if (self.ball1.center.y <= 0) { //top of the screen
            self.ball1.center = CGPointMake(self.ball1.center.x, 10);
            [self change1Y];// change in direction method of the y range
        }
        else if (self.ball1.center.y >= 768) { // bottom of the screen
            self.ball1.center = CGPointMake(self.ball1.center.x, 758);
            [self change1Y];
        }
        
        self.ball1.center = CGPointMake(self.ball1.center.x + p1X, self.ball1.center.y + p1Y); // tells the ball to move in an actual direction, x and y which is set in the method collsion1x/ collision1y 
        self.dummy1.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
        self.label1.center = CGPointMake(self.ball1.center.x, self.ball1.center.y);
        
    }
    
  
    
    if (!hold2 && canHold2) { // //if no one is holding ball2 and canhold2 (meaning the ball can be held) is true, the do this this
        if (self.ball2.center.x <= 0) { // left
            self.ball2.center = CGPointMake(10, self.ball2.center.y);
            [self change2X];
        }
        else if (self.ball2.center.x >= 1024) { // right
            self.ball2.center = CGPointMake(1014, self.ball2.center.y);
            [self change2X];
        }
        else if (self.ball2.center.y <= 0) { //top
            self.ball2.center = CGPointMake(self.ball2.center.x, 10);
            [self change2Y];
        }
        else if (self.ball2.center.y >= 768) { // bottom
            self.ball2.center = CGPointMake(self.ball2.center.x, 758);
            [self change2Y];
        }
        self.ball2.center = CGPointMake(self.ball2.center.x + p2X, self.ball2.center.y + p2Y); // Movement of the ball
        self.dummy2.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
        self.label2.center = CGPointMake(self.ball2.center.x, self.ball2.center.y);
    }
    
    //
    
    if (!hold3 && canHold3) { // //if no one is holding ball3 and canhold3 (meaning the ball can be held) is true, the do this this
        if (self.ball3.center.x <= 0) { // left
            self.ball3.center = CGPointMake(10, self.ball3.center.y);
            [self change3X];
        }
        else if (self.ball3.center.x >= 1024) { // right
            self.ball3.center = CGPointMake(1014, self.ball3.center.y);
            [self change3X];
        }
        else if (self.ball3.center.y <= 0) { // top
            self.ball3.center = CGPointMake(self.ball3.center.x, 10);
            [self change3Y];
        }
        else if (self.ball3.center.y >= 768) { // bottom
            self.ball3.center = CGPointMake(self.ball3.center.x, 758);
            [self change3Y];
        }
        self.ball3.center = CGPointMake(self.ball3.center.x + p3X, self.ball3.center.y + p3Y);
        self.dummy3.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
        self.label3.center = CGPointMake(self.ball3.center.x, self.ball3.center.y);
    }
}

- (void)change1X // method for the change in direction movement, what the ball movment acutal does when collsion with another ball has occured or boundry
// its so that the ball goes in the opposite direction 
{
    if (collision1X) { // if YES (recall reinstateCollide method)
        
        /* p1X and p1Y are set to either 1 or -1. 1 makes the ball move down/right and -1 does the opposite. */
        if (p1X == 1) { // so if its equal to p1X then make the ball move in the opposite direction
            p1X = -1;
        }
        else {
            p1X = 1;
        }

        [self createLabels1]; // calling up the method that creates the label (number value) of ball1
        
        collision1X = NO; 
        [self performSelector:@selector(reinstateCollide:) withObject:@1 afterDelay:0.2f]; // make sure the balls are ready to colide again, basically set the collision1X = YES, boolean value
    }
}
//Label1 = ball1 = top left = dummy1

- (void)createLabels1 // create the actual number which is inside ball1
{
    if (stage != 2) { // make sure it is not the stage 2 level (operator ball)
        self.label1.text = [NSString stringWithFormat:@"%d", arc4random() % 10 + 1]; // this is passed on to label1 with the randomely selected number
    }
    else { // if it is stage 2 then make sure the label is in operator form 
        
        int operator = arc4random() % 4;
        switch (operator) {
            case 0:
                self.label1.text = @"x";
                break;
            case 1:
                self.label1.text = @"\u00F7";// divide symbol
                break;
            case 2:
                self.label1.text = @"-";
                break;
            case 3:
                self.label1.text = @"+";
                break;
        }
    }
}

- (void)change1Y // Change the up/down direction of ball1
{
    if (collision1Y) {
         /* p1X and p1Y are set to either 1 or -1. 1 makes the ball move down/right and -1 does the opposite. */
        if (p1Y == 1) {
            p1Y = -1;
        }
        else {
            p1Y = 1;
        }
    
        [self createLabels1]; // create the actual number which is inside ball1, that when hits the sides of the screen changes
        
        collision1Y = NO;
        [self performSelector:@selector(reinstateCollide:) withObject:@2 afterDelay:0.2f]; // make sure that the balls are ready and able to collide again by invoking reinstateCollide (which does this)
    }
}

- (void)change2X // change the ball2 direction, left/ right driection
{
    if (collision2X) {
        
        if (p2X == 1) { // the amount that the direction is should change, in this case the opposite direction when it equal a certain value
            p2X = -1;
        }
        else {
            p2X = 1;
        }
        
        [self createLabels2]; // create the random number inside ball2 when the ball its the sides of the screen
        
        collision2X = NO;
        [self performSelector:@selector(reinstateCollide:) withObject:@3 afterDelay:0.2f]; // collision ready again
    }
}

- (void)createLabels2 // create the label inside ball2 when it hits the sides of the screen
{
    if (stage != 2) { // if its not level/ stage 2
        self.label2.text = [NSString stringWithFormat:@"%d", arc4random() % 10 + 1]; // random number betweeen 1 - 10
    }
    else {
        // it is level 2, opeartaor balls only
        int operator = arc4random() % 4; // random number between 0 - 3
        switch (operator) {
            case 0:
                self.label2.text = @"x";
                break;
            case 1:
                self.label2.text = @"\u00F7"; // divide symbol
                break;
            case 2:
                self.label2.text = @"-";
                break;
            case 3:
                self.label2.text = @"+";
                break;
        }
    }
}

- (void)change2Y
{
    if (collision2Y) { // change in driection up/ down for ball2
        
        if (p2Y == 1) { // the amount that it will change by if its equal to 1 (p2Y)
            p2Y = -1; // oppsoite direction
        }
        else {
            p2Y = 1;
        }
        
        [self createLabels2]; // create the label for ball2
  
        collision2Y = NO;
        [self performSelector:@selector(reinstateCollide:) withObject:@4 afterDelay:0.2f]; // re instate the collide
    }
}

- (void)change3X // change in direction in left/ right for ball3
{
    if (collision3X) {
        
        if (p3X == 1) {
            p3X = -1; // opposite direction
        }
        else {
            p3X = 1;
        }
        
        [self createLabels3]; // create the label for ball3

        collision3X = NO;
        [self performSelector:@selector(reinstateCollide:) withObject:@5 afterDelay:0.2f]; // restart the collsion method.
    }
}

- (void)createLabels3 // creates the label 3 for ball3
{
    if (stage != 2) { // if its not level 2
        self.label3.text = [NSString stringWithFormat:@"%d", arc4random() % 10 + 1]; // number values between 1-10 and show it the label3 text
    }
    else {
        // if its stage 2
        int operator = arc4random() % 4;
        switch (operator) {
            case 0:
                self.label3.text = @"x";
                break;
            case 1:
                self.label3.text = @"\u00F7"; // divide symbol
                break;
            case 2:
                self.label3.text = @"-";
                break;
            case 3:
                self.label3.text = @"+";
                break;
        }
    }
}

- (void)change3Y
{ // change in direction up/down for ball 3
    if (collision3Y) {
        
        if (p3Y == 1) { // if it equal to this value
            p3Y = -1; // oppsoite driection
        }
        else {
            p3Y = 1;
        }

        [self createLabels3]; // creat the label value for ball3

        collision3Y = NO;
        [self performSelector:@selector(reinstateCollide:) withObject:@6 afterDelay:0.2f]; // restart the collsion method again, essentailly setting the boolean vlaue of collision3Y = Yes
    }
}

- (void)reinstateCollide:(NSNumber *)number //make sure the collsion is reset and ready to use again if the ball collides
{
    int ball = [number intValue];
    
    switch (ball) { // set the boolean values to be TRUE, in effect reset the condtions so that they can be used again for the collsions
        case 1:
            collision1X = YES;
            break;
        case 2:
            collision1Y = YES;
            break;
        case 3:
            collision2X = YES;
            break;
        case 4:
            collision2Y = YES;
            break;
        case 5:
            collision3X = YES;
            break;
        case 6:
            collision3Y = YES;
            break;
    }
}

- (void)setEquationOne // first stage, plus and minus, the numbers were kept low intentionally
{
    int random = arc4random() % 5 + 1; // ranodmely select the equation style question, so that the suer gets a good mix of questions
    
    if (random == 1) { // if its equal to 1
        int part1 = arc4random() % 10 + 1;
        answer = arc4random() % 9 + 1;// the answer variable is used to check whether the answer is correct, as well as the storage of the actual answer
        int total = part1 + answer; // each stage of the calculation, is stored into a specific vairble
        int part2 = arc4random() % total + 1; // now use the previous variables, to create a second part of the equation
        int part3 = total - part2; //then 
        self.sumLabel.text = [NSString stringWithFormat:@"%d + (  ) = %d + %d", part1, part2, part3]; // the ( ) is where the answer ball will be place by the user and where the user sees the eqaution.
    }
    else if (random == 2) {
        int part1 = arc4random() % 20 + 7;
        int part2 = arc4random() % 10 + 2;
        int part3 = arc4random() % 6 + 1;
        answer = (part1 + part2) - part3;
        self.sumLabel.text = [NSString stringWithFormat:@"%d + %d = %d + (  )", part1, part2, part3];
    }
    else if (random == 3) {
        int part1 = arc4random() % 15 + 3;
        answer = arc4random() % 10 + 1;
        int part2 = part1 + answer;
        self.sumLabel.text = [NSString stringWithFormat:@"%d + (  ) = %d", part1, part2];
    }
    else if (random == 4) {
        int part1 = arc4random() % 20 + 13;
        int part2 = arc4random() % 10 + 3;
        int part3 = arc4random() % 10 + 3;
        answer = (part1 - part2) + part3;
        self.sumLabel.text = [NSString stringWithFormat:@"%d - %d =  (  ) - %d", part1, part2, part3];
    }
    else if (random == 5) {
        int part2 = arc4random() % 12 + 5;
        int part3 = arc4random() % 16 + 5;
        answer = arc4random() % 20 + 10 + part3;
        int part1 = answer > (part2 + part3) ? answer - (part2 + part3) : (part2 + part3) - answer;
        self.sumLabel.text = [NSString stringWithFormat:@"(  ) - %d = %d + %d", part1, part2, part3];
    }
}

- (void)setEquationTwo // operator missing style equations aka stage 2
{
    int random = arc4random() % 4 + 1; // randomise the choice of the type and equation style
    
    if (random == 1) {
        int part1 = arc4random() % 15 + 2;
        int part2 = arc4random() % 15 + 2;
        int part3 = part1 * part2; //multipliacation style
        self.sumLabel.text = [NSString stringWithFormat:@"%d (  ) %d = %d", part1, part2, part3];
    }
    else if (random == 2) {
        int part3 = arc4random() % 5 + 1;
        int part4 = arc4random() % 5 + 2;
        int part2 = part3 * 2;
        int part1 = part3 * part4 * part2; //multiplication stle
        self.sumLabel.text = [NSString stringWithFormat:@"%d (  ) %d = %d x %d", part1, part2, part3, part4];
    }
    else if (random == 3) {
        int part1 = arc4random() % 40 + 22;
        int part2 = arc4random() % 20 + 1;
        int part3 = part1 - part2; //minus style 
        self.sumLabel.text = [NSString stringWithFormat:@"%d (  ) %d = %d", part1, part2, part3];
    }
    else if (random == 4) {
        int part1 = arc4random() % 30 + 6;
        int part2 = arc4random() % 20 + 6;
        int total = part1 + part2;
        int part3 = arc4random() % total + 4;
        int part4 = total > part3 ? total - part3 : part3 - total; // division calculation style
        self.sumLabel.text = [NSString stringWithFormat:@"%d + %d = %d (  ) %d", part1, part2, part3, part4];
    }
    answer = random; // this will be used in the checkAnswer method, so that we ensure it is the correct answer
}

- (void)setEquationThree //multiple style questions
{
    int random = arc4random() % 3 + 1; // randomly select 3 style of questions
    
    if (random == 1) {
        answer = arc4random() % 5 + 2;
        int part3 = arc4random() % 5 + 2;
        int part1 = answer * 2;
        int part2 = part3 * 2;
        answer = answer * 4;
        self.sumLabel.text = [NSString stringWithFormat:@"%d x %d = (  ) x %d", part1, part2, part3];
    }
    else if (random == 2) {
        int part1 = arc4random() % 8 + 2;
        int part2 = arc4random() % 5 + 2;
        answer = part1 * part2;
        self.sumLabel.text = [NSString stringWithFormat:@"%d x %d = (  )", part1, part2];
    }
    else if (random == 3) {
        int part1 = arc4random() % 7 + 2;
        answer = arc4random() % 6 + 2;
        int part2 = part1 * answer;
        self.sumLabel.text = [NSString stringWithFormat:@"%d x (  ) = %d", part1, part2];
    }
}

- (void)setEquationFour //Bonus level, combination of level 1 and 3
{
    switch (arc4random() % 2) { // the equation styles questions are randomely selected between the the two types
        case 0:
            [self setEquationOne]; // plus/ minus questions
            break;
        case 1:
            [self setEquationThree]; // multiply
            break;
    }
}

- (void)setPoints:(int)ball // collesion paths for the balls, the route they actual take when collidng with one another
{
    collision1X = YES;
    collision1Y = YES;
    collision2X = YES;
    collision2Y = YES;
    collision3X = YES;
    collision3Y = YES;
    
    p1X = 1;
    p1Y = 1;
    
    p2X = -1;
    p2Y = 1;
    
    p3X = -1;
    p3Y = -1;
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event //intial touch event, so when the user first touches the dummy image(ball picture)
{    
    UITouch *touch = [[event allTouches] anyObject];
 
    if ([touch view] == self.dummy1 && !hold2 && !hold3) { // dummy1 image (the actual image of the tennis ball) is being held and nothing else, hold2/ hold3 can not be held
        hold1 = YES; // setting the boolean Values to YES, meaning the dummy1 can be held and no other
        canHold1 = YES; // again used for future, meaing the ability to hold dummy1 image one
        CGFloat horizontalDistance = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x; // intial coordinates taken and used to find it
        CGFloat verticalDistance   = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        self.dummy1.center = CGPointMake(self.dummy1.center.x + horizontalDistance, self.dummy1.center.y + verticalDistance - 50); // -50 actually moves the ball upwards
        self.ball1.center = CGPointMake(self.dummy1.center.x, self.dummy1.center.y);
        self.label1.center = CGPointMake(self.dummy1.center.x, self.dummy1.center.y);
    }
    else if ([touch view] == self.dummy2  && !hold1  && !hold3) { // dummy2 image (the actual image of the tennis ball) is being held and nothing else
        hold2 = YES;
        canHold2 = YES;
        CGFloat horizontalDistance = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        CGFloat verticalDistance   = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        self.dummy2.center = CGPointMake(self.dummy2.center.x + horizontalDistance, self.dummy2.center.y + verticalDistance - 50);
        self.ball2.center = CGPointMake(self.dummy2.center.x, self.dummy2.center.y);
        self.label2.center = CGPointMake(self.dummy2.center.x, self.dummy2.center.y);
    }
    else if ([touch view] == self.dummy3 && !hold1 && !hold2) { // dummy3 image (the actual image of the tennis ball) is being held and nothing else
        hold3 = YES;
        canHold3 = YES;
        CGFloat horizontalDistance = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        CGFloat verticalDistance   = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        self.dummy3.center = CGPointMake(self.dummy3.center.x + horizontalDistance, self.dummy3.center.y + verticalDistance - 50);
        self.ball3.center = CGPointMake(self.dummy3.center.x, self.dummy3.center.y);
        self.label3.center = CGPointMake(self.dummy3.center.x, self.dummy3.center.y);
    }
    else {
        [super touchesCancelled:touches withEvent:event]; // cancels the touch, the ball contiues its drectional movement
    }
    [self checkcollision]; // calls the method responsible with the check if a collsion has occured with the target equation area
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event // the dummmy (the actual ball image) that is made moved follwing the user finger, so this tracks what the user finger is doing on the screen
{
	UITouch *touch = [[event allTouches] anyObject];
    
    if ([touch view] == self.dummy1 && canHold1 && !hold2 && !hold3) { // dummy1 image is being held (canhold1 = YES) and no other other, thus allowing the user to make the ball follow its finger, only the one ball though
        hold1 = YES; // 
        self.view.multipleTouchEnabled = NO; // no touches from the other balls, just the one
        CGFloat horizontalDistance = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        CGFloat verticalDistance   = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        self.dummy1.center = CGPointMake(self.dummy1.center.x + horizontalDistance, self.dummy1.center.y + verticalDistance); // makes the ball follow the user finder via adjusting the actual coordinates and passessing onto the view screen
        self.ball1.center = CGPointMake(self.dummy1.center.x, self.dummy1.center.y);
        self.label1.center = CGPointMake(self.dummy1.center.x, self.dummy1.center.y);
    }
    else if ([touch view] == self.dummy2 && canHold2 && !hold1 && !hold3) { // dummy2 image is being held (canhold2 = YES) and no other other, allows the tracking of the user finger
        hold2 = YES;
        CGFloat horizontalDistance = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x;
        CGFloat verticalDistance   = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        self.dummy2.center = CGPointMake(self.dummy2.center.x + horizontalDistance, self.dummy2.center.y + verticalDistance);
        self.ball2.center = CGPointMake(self.dummy2.center.x, self.dummy2.center.y);
        self.label2.center = CGPointMake(self.dummy2.center.x, self.dummy2.center.y);
    }
    else if ([touch view] == self.dummy3 && canHold3 && !hold1 && !hold2) { // dummy1 image is being held (canhold1 = YES) and no other other, allows the tracking of the fingers movmeent
        hold3 = YES;
        CGFloat horizontalDistance = [touch locationInView:self.view].x - [touch previousLocationInView:self.view].x; // pased on the corrdinates so that they can be used for movemnt on the view screen
        CGFloat verticalDistance   = [touch locationInView:self.view].y - [touch previousLocationInView:self.view].y;
        self.dummy3.center = CGPointMake(self.dummy3.center.x + horizontalDistance, self.dummy3.center.y + verticalDistance);
        self.ball3.center = CGPointMake(self.dummy3.center.x, self.dummy3.center.y);
        self.label3.center = CGPointMake(self.dummy3.center.x, self.dummy3.center.y);
    }
    [self checkcollision]; // calls the method responsible with the check if a collsion has occured with the target equation area
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event // when the balls have been released
{
    hold1 = NO;
    hold2 = NO;
    hold3 = NO;
}

- (void)checkcollision // the ball1 (square) is actually what is used to drag to the equation to check if its right, the "hold" refers to whether the ball is being held by the user. The ball 1 frame is the actual area that is detected by the targetOn (which is the equation area) This checks if the ball has been move thed 
{
    if (CGRectIntersectsRect(self.ball1.frame, self.target.frame) && targetOn && hold1) { // when the ball1 and target area intersect
        
        targetOn = NO;
        canHold1 = NO;
        hold1 = NO;
        
        [UIView animateWithDuration:0.25f // animation of the ball going into the eqation section
                         animations:^ {
                             self.ball1.alpha = 0.0f;
                             self.dummy1.alpha = 0.0f;
                             self.label1.alpha = 0.0f;
                             self.ball1.center = CGPointMake(512.0f, -30.0f); // where the equation or target area is located in the screen (equation area)
                             self.dummy1.center = CGPointMake(512.0f, -30.0f);
                             self.label1.center = CGPointMake(512.0f, -30.0f);
                         }
                         completion:^(BOOL finished) { // the compeleted animation, it takes into account of the value of the ball, so when the user places the ball1 inside this eqaution area. that ball is checked to see if it correct
                             
                             if ([self.label1.text isEqualToString:@"x"]) self.label1.text = @"1"; // matches up the relevant expression for level2 (operators) within the label1 to see if its correct
                             if ([self.label1.text isEqualToString:@"\u00F7"]) self.label1.text = @"2";
                             if ([self.label1.text isEqualToString:@"-"]) self.label1.text = @"3";
                             if ([self.label1.text isEqualToString:@"+"]) self.label1.text = @"4";
                             
                             [self checkAnswer:[self.label1.text intValue]]; // the anwser for ball1 is checked whether it is correct
                             
                             if (stage == 2) { // level 2
                                 int operator = arc4random() % 4;
                                 switch (operator) {
                                     case 0:
                                         self.label1.text = @"x";
                                         break;
                                     case 1:
                                         self.label1.text = @"\u00F7"; // divide symbol
                                         break;
                                     case 2:
                                         self.label1.text = @"-";
                                         break;
                                     case 3:
                                         self.label1.text = @"+";
                                         break;
                                 }
                             }
                             
                             [self performSelector:@selector(enter1) withObject:nil afterDelay:1.0f]; // bring in another ball1 from its entry point
                         }];
    }
    else if (CGRectIntersectsRect(self.ball2.frame, self.target.frame) && targetOn && hold2) { // when ball2 and target area is located (equation area)
        
        targetOn = NO;
        canHold2 = NO;
        hold2 = NO;
        
        [UIView animateWithDuration:0.25f
                         animations:^ {
                             self.ball2.alpha = 0.0f;
                             self.dummy2.alpha = 0.0f;
                             self.label2.alpha = 0.0f;
                             self.ball2.center = CGPointMake(512.0f, -30.0f); // target area corridnates, where its located on the screen
                             self.dummy2.center = CGPointMake(512.0f, -30.0f);
                             self.label2.center = CGPointMake(512.0f, -30.0f);
                         }
                         completion:^(BOOL finished) {
                             
                             // the completed animation and whether the score/ opeartor inside the label2 is correct
                             if ([self.label2.text isEqualToString:@"x"]) self.label2.text = @"1";
                             if ([self.label2.text isEqualToString:@"\u00F7"]) self.label2.text = @"2";
                             if ([self.label2.text isEqualToString:@"-"]) self.label2.text = @"3";
                             if ([self.label2.text isEqualToString:@"+"]) self.label2.text = @"4";
                             
                             [self checkAnswer:[self.label2.text intValue]]; // checks whether the answer for ball2 is correct
                             
                             if (stage == 2) {
                                 int operator = arc4random() % 4;
                                 switch (operator) {
                                     case 0:
                                         self.label2.text = @"x";
                                         break;
                                     case 1:
                                         self.label2.text = @"\u00F7";
                                         break;
                                     case 2:
                                         self.label2.text = @"-";
                                         break;
                                     case 3:
                                         self.label2.text = @"+";
                                         break;
                                 }
                             }
                             
                             [self performSelector:@selector(enter2) withObject:nil afterDelay:1.0f];  // bring in another ball2 from its entry point
                         }];
    }
    else if (CGRectIntersectsRect(self.ball3.frame, self.target.frame) && targetOn && hold3) { // when ball3 and target area is located (equation area)
        
        targetOn = NO;
        canHold3 = NO;
        hold3 = NO;
        
        [UIView animateWithDuration:0.25f
                         animations:^ {
                             self.ball3.alpha = 0.0f;
                             self.dummy3.alpha = 0.0f;
                             self.label3.alpha = 0.0f;
                             self.ball3.center = CGPointMake(512.0f, -30.0f); //the coordiantes of where the equaiton/ target area is located
                             self.dummy3.center = CGPointMake(512.0f, -30.0f);
                             self.label3.center = CGPointMake(512.0f, -30.0f);
                         }
                         completion:^(BOOL finished) {
                             // completed aniamtion for ball3, and whether the score/ opeartor inside the label3 is correct 
                             if ([self.label3.text isEqualToString:@"x"]) self.label3.text = @"1"; // matches the operator balls with its label 3 expression and pass it on to the label3
                             if ([self.label3.text isEqualToString:@"\u00F7"]) self.label3.text = @"2";
                             if ([self.label3.text isEqualToString:@"-"]) self.label3.text = @"3";
                             if ([self.label3.text isEqualToString:@"+"]) self.label3.text = @"4";
                             
                             [self checkAnswer:[self.label3.text intValue]]; // checks the answer for ball3 is correct by calling the relevant method
                             
                             if (stage == 2) { // level 2 
                                 int operator = arc4random() % 4;
                                 switch (operator) {
                                     case 0:
                                         self.label3.text = @"x";
                                         break;
                                     case 1:
                                         self.label3.text = @"\u00F7";
                                         break;
                                     case 2:
                                         self.label3.text = @"-";
                                         break;
                                     case 3:
                                         self.label3.text = @"+";
                                         break;
                                 }
                             }
                             
                             [self performSelector:@selector(enter3) withObject:nil afterDelay:1.0f]; // bring in another ball3 from its entry point, as the last one has been 'consumed'
                         }];
    }
}

- (void)checkAnswer:(int)attempt // method used to check whether the answer is correct
{
    AudioManager *audioManager = [AudioManager sharedManager];
    
    if (attempt == answer) { // if the user attempt is the correct answer
        
        score += correctAnswer; // add 10 to the score, if the answer is correct
        chainCount++; // add one to the chainCount (for the chain bonus)
        
        if (chainCount == chainRange) {
            chainCount = 0; // resset the chain account
            score += chainBonus; // add the chain bonus 
            [self chainAnime]; // chain aniamtion
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) { //plays the correct sound effect audio
                audioManager.effect1 = [AudioManager loadFile:@"correct" withType:@"mp3"];
                [audioManager.effect1 play];
            }
        }
        else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) {
                audioManager.effect3 = [AudioManager loadFile:@"chain" withType:@"mp3"]; // chain sound played, if chain bonus is activation
                [audioManager.effect3 play];
            }
        }
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", score]; // score is updated
        
        // storage and retirvial of the score with the use of keys
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"bounceScore%d%d", stage, diff]; 
        int temp = [prefs integerForKey:key];
        
        if (score > temp) {
            self.bestLabel.text = [NSString stringWithFormat:@"%d", score];
        }
    }
    else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) { //plays the incorrrect sound effect
            audioManager.effect2 = [AudioManager loadFile:@"incorrect" withType:@"mp3"];
            [audioManager.effect2 play];
        }
        
        score -= wrongAnswer;// take off wrong amount off the score, -1/-3/-5 for the respective diffciulty
        chainCount = 0; // reset the chain of the count to 0, so the user has to build them up
        
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];
    }
    
    switch (stage) { // selection of the equation questions for the specific stages
        case 1:
            [self setEquationOne]; // level 1
            break;
        case 2:
            [self setEquationTwo]; // level 2
            break;
        case 3:
            [self setEquationThree]; // level 3
            break;
        case 4:
            [self setEquationFour]; // bonus level
            break;
    }
}

- (void)chainAnime // Same as the one used in the WeightViewController, the chain label animation
{
    self.chainLabel.text = [NSString stringWithFormat:@"+ %d", chainBonus]; // the chainbonus for the level/difficulty is shown along with the plus symbol.
    self.chainLabel.center = CGPointMake(900.0f, 520.0f); //intial starting point of animation
    self.chainLabel.alpha = 1.0f;
    
    [UIView animateWithDuration:1.25f // moves upwards to the set coordinate
                     animations:^ {
                         self.chainLabel.alpha = 0.0f;
                         self.chainLabel.center = CGPointMake(900.0f, 100.0f); // endpoint of the animation
                     }
                     completion:nil];
}

#pragma mark - IBActions

- (IBAction)pausePressed:(UIButton *)sender // pauses the game
{
    AudioManager *audioManager = [AudioManager sharedManager];
    
    if (sender.tag == 1) { //when the user input is detected for the pause menu option
        [self pauseGame2]; // the pause method is called
    }
    else {
        self.pauseScreen.hidden = YES; // hides the pause screen// when the play button is hit
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:0.005f target:self selector:@selector(moveBalls:) userInfo:nil repeats:YES]; // move the bals after the play button has been pressed
        
        if (time <= 10) { // timer is less then 10 play the alarm audio
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            if ([prefs boolForKey:@"audio"]) {
                audioManager.effect4 = [AudioManager loadFile:@"Alarm" withType:@"mp3"];
                [audioManager.effect4 play];
            }
        }
    }
}

- (void)pauseGame2 // method for pausesing the game
{
    if ([self.gameTimer isValid]) { // supend the timer
        [self.gameTimer invalidate];
        self.gameTimer = nil;
        
        if (time <= 10) { // when the time reaches this ppoint, it must remember to stop the audio of the alaram
            AudioManager *audioManager = [AudioManager sharedManager];
            [audioManager.effect4 stop];
        }
    }
    
    self.pauseScreen.hidden = NO; //pause screen is shown
}

- (IBAction)toggleSoundPressed:(id)sender // method as to whether the sound button has been pressed or not 
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AudioManager *audioManager = [AudioManager sharedManager];
    
    if ([prefs boolForKey:@"audio"]) { //stops audio if sound icon is pressed
        [prefs setBool:NO forKey:@"audio"];
        
        [audioManager.audio stop];
        
        [self.toggleButton setImage:[UIImage imageNamed:@"soundOff.png"] forState:normal]; //the sound off image is shown
    }
    else {
        [prefs setBool:YES forKey:@"audio"]; // play the audio
        
        audioManager.audio = [AudioManager loadFile:@"loop" withType:@"mp3"];
        audioManager.audio.numberOfLoops = -1;
        [audioManager.audio play];
        
        [self.toggleButton setImage:[UIImage imageNamed:@"soundOn.png"] forState:normal]; // the sound on image is then displayed
    }
    [prefs synchronize];
}

- (IBAction)replayPressed:(id)sender //reset everything regarding the level (but obvioulsy remember the hiigh score if thier is one) and start again
{
    [self difficulty:diff];// dificulty set previously of the level is used again
    chainCount = 0; // chain count reset
    
    score = 0;// score is reset to 0
    self.scoreLabel.text = @"0";
    
    // storage and retrivial of the score with the use of keys
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"bounceScore%d%d", stage, diff];
    holder = [prefs integerForKey:key];
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d", time]; //time 
    self.timerLabel.textColor = [UIColor blackColor];
    self.timerLabel.font = [self.timerLabel.font fontWithSize:37];
    
    self.reviewScreen.hidden = YES; // hide the review screen
    
    [self prepareLevel]; // call the method that sets up the prepare level method, gets the game ready
    [self performSelector:@selector(startGame) withObject:nil afterDelay:0.5f];
}

- (IBAction)homePressed:(id)sender // the (X) button is pressed, goes back the previous menu game screen
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // remove observer
    
    [self.gameTimer invalidate]; // stop and suspend timer
    self.gameTimer = nil;
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; //storage of the score
    NSString *key = [NSString stringWithFormat:@"bounceScore%d%d", stage, diff];
    int temp = [prefs integerForKey:key];
    
    if (score > temp) { // checks whether the score is greater then the temp one, meaning if the score is a best score it is set as such. If this is not done then. Then when the review screen comes up and the bestScore is 65 and the score is 61. The score is shown. Which is wrong
        [prefs setInteger:score forKey:key];
        [prefs synchronize];
    }
    
    // stops audio effects for the game
    AudioManager *audioManager = [AudioManager sharedManager];
    [audioManager.audio stop];
    [audioManager.effect1 stop];
    [audioManager.effect2 stop];
    [audioManager.effect3 stop];
    [audioManager.effect4 stop];
    
    [self dismissViewControllerAnimated:YES completion:nil]; //animate it to the menu screen
}

@end
