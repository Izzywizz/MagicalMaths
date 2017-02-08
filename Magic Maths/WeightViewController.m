//
//  WeightViewController.m
//  Magic Maths
//
//  Created by Izzy Ali on 03/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
// .h file is public
// .m file is private

#import "WeightViewController.h"
#import "WeightDictionary.h"
#import "WeightManager.h"
#import "AudioManager.h"


@interface WeightViewController () {
    
    float weight1;
    float weight2;
    float weight3;
    float weight4;

    int type1; // refers to the images. There are 20 (in the range 1-20)
    int type2;
    int type3;
    int type4;
    
    int time; // The time for the game
    int score; // The score for the game
    int correct; // helps with the correct answer
    int stage; // refers to the level
    int diff; // refers to the difficuluty
    int holder; // helps determine the high score
    
    int chainBonus;
    int chainCount;
    int chainRange;
    
    int correctAnswer;
    int wrongAnswer;
    
    // Booloean values
    BOOL isHeavyist; // used to set the lightest and heavest questions
    BOOL isGame; // checks if the game is ready
}
// definning the property for just this interface, assessors methods are created, a setter and a getter

@property (nonatomic, weak) IBOutlet UIButton *button1;
@property (nonatomic, weak) IBOutlet UIButton *button2;
@property (nonatomic, weak) IBOutlet UIButton *button3;
@property (nonatomic, weak) IBOutlet UIButton *button4;

@property (nonatomic, weak) IBOutlet UIButton *box1;
@property (nonatomic, weak) IBOutlet UIButton *box2;
@property (nonatomic, weak) IBOutlet UIButton *box3;
@property (nonatomic, weak) IBOutlet UIButton *box4;

@property (nonatomic, weak) IBOutlet UIButton *toggleButton;

@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;
@property (nonatomic, weak) IBOutlet UILabel *label3;
@property (nonatomic, weak) IBOutlet UILabel *label4;

@property (nonatomic, weak) IBOutlet UILabel *questionLabel;
@property (nonatomic, weak) IBOutlet UILabel *timerLabel;
@property (nonatomic, weak) IBOutlet UILabel *scoreLabel;
@property (nonatomic, weak) IBOutlet UILabel *bestLabel;
@property (nonatomic, weak) IBOutlet UILabel *chainLabel;

@property (nonatomic, weak) IBOutlet UILabel *reviewScoreLabel;

@property (nonatomic, weak) IBOutlet UIImageView *tick; // used for the tick and corss

@property (nonatomic, weak) IBOutlet UIScrollView *pauseScreen;
@property (nonatomic, weak) IBOutlet UIScrollView *reviewScreen;

@property (nonatomic, weak) NSTimer *gameTimer;

@property (nonatomic, strong) WeightDictionary *weightDictionary;

@end

@implementation WeightViewController

- (WeightDictionary *)weightDictionary  
{
    if (!_weightDictionary) _weightDictionary = [[WeightDictionary alloc] init]; // prepare the WeightDictionary object
    return _weightDictionary;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES]; //Telling UIview that an animation is about happen
    [self prepareLevel]; // calling the method that prepares the level
}

- (void)prepareLevel // Gets the level ready, set outs the posistion of images and the relevant weights.
{
    isGame = YES; // Game on
    
    WeightManager *manager = [WeightManager sharedManger];// class method, returns an object which is the instance of the class manager
    stage = manager.stage; // prepares the specific level that was previously chosen by the user in the Weight Menu screen
    
    // NSUserDefaults is a Singleton that caches preferences that you want to keep hold of. Because it is cached you can can retrieve those values in any object. At an indeterminate time or for sure when you use [prefs synchronise];
    // the cached values are saved into a dictionary of key pairs
    // userDefaults inherits from NSDictionary and uses a Plist to save/retrieve key pairs
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"weightScore%d%d", stage, diff]; 
    int best = [prefs integerForKey:key]; //loads up best score
    self.bestLabel.text = [NSString stringWithFormat:@"%d", best]; // refers to the label bestLabel in (in the xib file), so the user sees the best score (if their is one) when the level is loaded 
    
    holder = best; // sets the holder as the best score
    
    // prepers the layout and makes sure the images are their oringial size (0.0, 0.0) before actually showing them to the user
    // as everything is to scale 
    
    self.label1.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.label2.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.label3.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.label4.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.questionLabel.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.timerLabel.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    
    self.button1.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.button2.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.button3.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.button4.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    
    self.box1.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.box2.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.box3.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    self.box4.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
    
    [self setWeights]; // calling the weight set up method, amke sure the weight values are ready
    
    [UIView animateWithDuration:0.75f // timer animation property
                          delay:0.0f
                        options:UIViewAnimationCurveLinear
                     animations:^ {
                         self.timerLabel.transform = CGAffineTransformMakeScale(1.0f, 1.0f); // setting the scale size of timer animation
                     }
                     completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad]; // Makes sure the view is loaded into memeory and the correct labels are here, in this case for the pause menu
    
    // adding an observer for the (pauseGame)**
    // The pause screen is invoked by adding the following code into the viewDidLoad; (so the hardware home button when pressed calls it)
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pauseGame)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:NULL];
    
    // The observer observes when the App is resigned "UIApplicationWillResignActiveNotification" provided by Apple. When the user hits the home key for example, the notification center send a message to out pauseGame method in effect pausing the game.
    
    [self performSelector:@selector(startGame) withObject:nil afterDelay:0.5f];
    
    WeightManager *manager = [WeightManager sharedManger];
    // difficulty set by the user in the previous menu screen
    diff = manager.difficulty;
    [self difficulty:diff];
    // diff = difficulty level
    stage = manager.stage; // stage is the level selected by the user in the previous screen 
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; // used to save settings and properties related to application or user data. So any data saved to will persist throughout the app
    
    if ([prefs boolForKey:@"audio"]) {
        // loops the audio for the music that plays in the background
        
        AudioManager *audioManager = [AudioManager sharedManager];
        audioManager.audio = [AudioManager loadFile:@"loop" withType:@"mp3"];
        audioManager.audio.volume = 0.5;
        audioManager.audio.numberOfLoops = -1;
        [audioManager.audio play];
    }
    else {
        [self.toggleButton setImage:[UIImage imageNamed:@"soundOff.png"] forState:normal]; //if the sound button is pressed off the music
    }
    
    // Used in the unlocking of the bonus level, no need create keys before hand, the game dynamically creates the key names from the games level difficulty and only if they are not equal to level 4 (bonus level)
    NSString *key = [NSString stringWithFormat:@"weight%d%d", stage, diff];
    if (![prefs boolForKey:key] && stage != 4) {
        [prefs setBool:YES forKey:key]; // Very first time they start up and play, they cannot possibly exist, so it creates a key with that name and sets it to YES. The next time, nothing happens, however when all 3 levels have been played, the bonus level is unlocked. 
        [prefs synchronize];
    }
}


- (void)dealloc // Remove itself as an observer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)difficulty:(int)value // Helps set the varying bonus points recieved and the timer assocaited to the difficulty. They change depend on thee dfficulty selcted in the slider
{
    if (value == 0) { //Easy difficulty
        wrongAnswer = 1; // the amount of points taken off the score, when answer is wrong
        chainBonus = 10; // bonus points for the score that is added
        chainRange = 3; // the amount of correct asnwers needed to activate the bonus points
        time = 80; // timer of the clock
    }
    else if (value == 1) { //Medium difficulty
        wrongAnswer = 3;
        chainBonus = 20;
        chainRange = 4;
        time = 70;
    }
    else {
        wrongAnswer = 5; // Hard difficulty
        chainBonus = 30;
        chainRange = 5;
        time = 60;
    }
    correctAnswer = 10; // points added to the score
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d", time];
}

- (void)startGame // Starting the game 
{
    [self scaleOut]; // rcalls up the images/ animations and scales of the images ready to be sued
    self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown:) userInfo:nil repeats:YES]; // Games starts and passed it on to the timer which is in seconds and selects the CountDown method
}

- (void)countDown:(NSTimer *)timer // method for the counting down of the timer
{
    time--; // take one off the time and show it in the timerlabel, so the user sees the timer count down from 60 for example
    self.timerLabel.text = [NSString stringWithFormat:@"%d", time];
    
    if (time == 10) { // When the timer reaches 10, the colour of timer label text goes to red and gets larger
        self.timerLabel.textColor = [UIColor redColor];
        self.timerLabel.font = [self.timerLabel.font fontWithSize:50];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) { // plays the audio after the timer reaches the 10 seconds point
            AudioManager *audioManager = [AudioManager sharedManager];
            audioManager.effect4 = [AudioManager loadFile:@"Alarm" withType:@"mp3"];
            audioManager.effect4.numberOfLoops = 1;
            [audioManager.effect4 play];
        }
    }
    
    if (time <= 0) { // When the timer reaches 0, stop the game, hence the invalidate/ nil
        [self.gameTimer invalidate];
        self.gameTimer = nil;
    
        isGame = NO; // game is not on, stop!
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSString *key = [NSString stringWithFormat:@"weightScore%d%d", stage, diff]; 
        int temp = [prefs integerForKey:key];
        // This is how the a key and a value are being saved within our Weight Dictionary
        // using the stage and diff to dynamically create a key name to save the score and the same again to retrieve it.
        // And you retrieve it from the dictionary just the same way as using NSUserDefaults for future reference
        
        if (score > temp) { // so if the score is greater then the temp then you set it as the new score
            [prefs setInteger:score forKey:key];
            [prefs synchronize];
        }
        
        AudioManager *audioManager = [AudioManager sharedManager]; // stop all the audio effects associated with the game
        [audioManager.effect1 stop];
        [audioManager.effect2 stop];
        [audioManager.effect3 stop];
        [audioManager.effect4 stop];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self]; // remove the observer
        
        [self timesUp]; // Calls the method that checks whether the score is high or not
    }
}

- (void)timesUp // Detmines whether the score was high or not
{
    if (score > holder) { // if the score gained in the level is higher then the currect 'holder' variable (meaning the best score previously) then the higher score is set
        self.reviewScoreLabel.text = [NSString stringWithFormat:@"NEW HIGH\nSCORE!\n%d", score];
    }
    else { // if its not a high score then say this message
        self.reviewScoreLabel.text = [NSString stringWithFormat:@"GREAT SCORE\n%d\nYou can do even better!", score];
    }
    self.reviewScreen.hidden = NO; // Shows the specfic reviewScreen, the one with the replay button and Quit (not the one with the sound button)
}

- (void)scaleIn // animation of the inbetween stage of image load up when the user has been shown the tick or cross.
// Loading up the next set of 4 images, this is the animation for this and image scaling is handle here
{
    self.tick.alpha = 0.0f; // durtation of the animation of the tick / cross
    
    [UIView animateWithDuration:0.4f
                          delay:0.0f
                        options:UIViewAnimationCurveLinear
                     animations:^ {
                         
                         self.label1.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.label2.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.label3.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.label4.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.questionLabel.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         
                         self.button1.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.button2.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.button3.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.button4.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         
                         self.box1.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.box2.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.box3.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                         self.box4.transform = CGAffineTransformMakeScale(0.0f, 0.0f);
                     }
                     completion:^(BOOL finished) {
                         [self setWeights];
                     }];
}

- (void)scaleOut // what intially is shown, the images with the scale and size including animaition properties
{
    if (isGame) { // if the boolean value is true then do this.
        [self.button1 setUserInteractionEnabled:YES];
        [self.button2 setUserInteractionEnabled:YES];
        [self.button3 setUserInteractionEnabled:YES];
        [self.button4 setUserInteractionEnabled:YES];
        
        [UIView animateWithDuration:0.4f
                              delay:0.0f
                            options:UIViewAnimationCurveLinear
                         animations:^ {

                             self.label1.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.label2.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.label3.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.label4.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.questionLabel.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             
                             self.button1.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.button2.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.button3.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.button4.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             
                             self.box1.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.box2.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.box3.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                             self.box4.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                         }
                         completion:nil];
    }
}

- (void)setWeights // creatting the weights for the images
{
    NSString *file;
    NSString *key;
    float value;
    int random = 0;
    
    WeightManager *manager = [WeightManager sharedManger];
    
    // calls the specific stage that the user has selected and manages the different weights of the different stage, so that they stay in range for each of the stages.
    
    if (manager.stage == 1) {
        random = arc4random() % 10 + 2; // means to get a random value from 2 to 10 and set this value to the variable random
    }
    else if (manager.stage == 2) {
        random = arc4random() % 200 + 1; // Get a random value from 1 to 200 
    }
    else if (manager.stage == 3) {
        random = arc4random() % 20000 + 1; // Get a random value from 1 to 2000 and so on
    }
    else {
        random = arc4random() % 20000000 + 1; 
    }
    
    type1 = arc4random() % 20 + 1;
    // randomly choose a image and set it to type1, Weight image files have numbers (1-20) this is then assigned to type 1
    
    file = [NSString stringWithFormat:@"weight%d", type1];
    [self.button1 setImage:[UIImage imageNamed:file] forState:UIControlStateNormal]; //the image is then assigned to the button1 (top left)
    
    key = [NSString stringWithFormat:@"key%d", type1]; //sets the weight number for the type1 image, by retirving the key asssociated with it. So for example Weight12 image means that the 12 key is set to the 'key'
    
    value = [[self.weightDictionary weightDict:key] floatValue]; // this is the value of weight of picture, for example 12
    
    if (stage == 3) { // level 3
        value /= 10; // So if the stage is 3 then you divide the values for the weights by 10, so that the level will produce the required values needed for the level. Meaning the range of 0.1g - 40Kg.
    }
    else if (stage == 4) { // level 4 (bonus level)
        value /= 1000; // This will make sure the range will be 0.001g - 400Kg
    }
    
    value *= random; // helps the numbers be random but within scale with one another, we multiply the value by the random varible, remember that random variable is set earlier on. So 12 * Random (the number is dependent on the stage)
    
    if (stage == 4) { // This is used for the bonus level
        
        BOOL bool4 = arc4random() % 2; // As for this stage I wanted to randomise Kg and g values, so the user has to really think about which to choose. helps randomise this
        
        if (bool4) {
            if (value < 1) { //This makes sure that the values shown are in the correct format ie decimal place
                self.label1.text = [NSString stringWithFormat:@"%0.3fg", value]; //the value of the weight is shown within label1 of view xib
            }
            else {
                self.label1.text = [NSString stringWithFormat:@"%0.0fg", value]; //helps with the format of the decimal point
            }
        }
        else {
            value /= 1000; // divide the value by 1000
            self.label1.text = [NSString stringWithFormat:@"%0.3fKg", value]; // helps with the Kilograms quesitions, to 3 decimal places
        }
    }
    else {
        if (value < 1000) {
            if (stage == 3) { // used in stage 3, helps the users reconise weight that have one decimal place 
                self.label1.text = [NSString stringWithFormat:@"%0.1fg", value]; // 1 decimal place 
            }
            else {
                self.label1.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label1.text = [NSString stringWithFormat:@"%0.1fkg", value];
        }
    }
    

    for (;;) {
        type2 = arc4random() % 20 + 1; // Select another random image from 1-20 artwork available
        if (type2 != type1) { //make sure the type1 image is not the same as the type2 image
            break;
        }
    }
    
    // Follows the same format as above but type2 image , contains image and key values for the use of random weight value
    file = [NSString stringWithFormat:@"weight%d", type2];
    [self.button2 setImage:[UIImage imageNamed:file] forState:UIControlStateNormal]; // type2 image assinged to button2 (yop right)
    
    key = [NSString stringWithFormat:@"key%d", type2];
    value = [[self.weightDictionary weightDict:key] floatValue];
    
    if (stage == 3) { 
        value /= 10;
    }
    else if (stage == 4) {
        value /= 1000; 
    }
    
    value *= random;
    
    if (stage == 4) {
        
        BOOL bool4 = arc4random() % 2;
        
        if (bool4) {
            if (value < 1) {
                self.label2.text = [NSString stringWithFormat:@"%0.3fg", value];
            }
            else {
                self.label2.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label2.text = [NSString stringWithFormat:@"%0.3fKg", value];
        }
    }
    else {
        if (value < 1000) {
            if (stage == 3) {
                self.label2.text = [NSString stringWithFormat:@"%0.1fg", value];
            }
            else {
                self.label2.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label2.text = [NSString stringWithFormat:@"%0.1fkg", value];
        }
    }
    
    // type3 image and weights for the later stages
    
    for (;;) {
        type3 = arc4random() % 20 + 1;
        if (type3 != type1 && type3 != type2) { //makes sure that the type3 image is not the same as type1 and type2
            break;
        }
    }
    
    file = [NSString stringWithFormat:@"weight%d", type3];
    [self.button3 setImage:[UIImage imageNamed:file] forState:UIControlStateNormal]; //type3 image is assigned to button3 (bottom left)
    
    key = [NSString stringWithFormat:@"key%d", type3];
    value = [[self.weightDictionary weightDict:key] floatValue];
    
    if (stage == 3) {
        value /= 10;
    }
    else if (stage == 4) {
        value /= 1000;
    }
    
    value *= random;
    
    if (stage == 4) {
        
        BOOL bool4 = arc4random() % 2;
        
        if (bool4) {
            if (value < 1) {
                self.label3.text = [NSString stringWithFormat:@"%0.3fg", value];
            }
            else {
                self.label3.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label3.text = [NSString stringWithFormat:@"%0.3fKg", value];
        }
    }
    else {
        if (value < 1000) {
            if (stage == 3) {
                self.label3.text = [NSString stringWithFormat:@"%0.1fg", value];
            }
            else {
                self.label3.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label3.text = [NSString stringWithFormat:@"%0.1fkg", value];
        }
    }
    
    // type4 image and weights for the later stages
    for (;;) {
        type4 = arc4random() % 20 + 1;
        if (type4 != type1 && type4 != type2 && type4 != type3) { //makes sure that the type3 image  is not the same as type1, type 2 and type3
            break;
        }
    }
    file = [NSString stringWithFormat:@"weight%d", type4];
    [self.button4 setImage:[UIImage imageNamed:file] forState:UIControlStateNormal];//type4 image is assigned to button4 (bottom right)
    
    key = [NSString stringWithFormat:@"key%d", type4];
    value = [[self.weightDictionary weightDict:key] floatValue];
    
    if (stage == 3) {
        value /= 10;
    }
    else if (stage == 4) {
        value /= 1000;
    }
    
    value *= random;
    
    if (stage == 4) {
        
        BOOL bool4 = arc4random() % 2;
        
        if (bool4) {
            if (value < 1) {
                self.label4.text = [NSString stringWithFormat:@"%0.3fg", value];
            }
            else {
                self.label4.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label4.text = [NSString stringWithFormat:@"%0.3fKg", value];
        }
    }
    else {
        if (value < 1000) {
            if (stage == 3) {
                self.label4.text = [NSString stringWithFormat:@"%0.1fg", value];
            }
            else {
                self.label4.text = [NSString stringWithFormat:@"%0.0fg", value];
            }
        }
        else {
            value /= 1000;
            self.label4.text = [NSString stringWithFormat:@"%0.1fkg", value];
        }
    }

    
    isHeavyist = arc4random() % 2; // chooses between the two questions, LIGHTEST or HEAVIEST, this is choosesn at random. So that the user doesnt know what type of question is comming. Helps stop pre defined expectations. Make the game more interesting
    
    if (isHeavyist) { // if its a heaviest do this
        self.questionLabel.text = @"What's the HEAVIEST weight?"; // set the question label with the question
        [self setHighest]; // calld the method that deals whether the correct heaviest image has been selected
    }
    else { // if not do this
        self.questionLabel.text = @"What's the LIGHTEST weight?"; // lightest question
        [self setLowest]; // called the method that deals whether the correct lightest image has been selected
    }
    
    [self performSelector:@selector(scaleOut) withObject:nil afterDelay:0.0f]; // calls scaleout method, so the images are set up ready to be animated to be used again
}

// effect 1 correct answer sound
// effect 2 incorrect answer sound
// effect 3 chain bonus song
// effect 4 alarm song

#pragma mark - Answer

- (IBAction)answerPressed:(UIButton *)sender //This method is for the user input and to check whether the image the user has chosen is the correct image
{
    [self.button1 setUserInteractionEnabled:NO]; // refers to the diffent image buttons, button1 (top left) type1 image
    [self.button2 setUserInteractionEnabled:NO]; // top right button (type2 image)
    [self.button3 setUserInteractionEnabled:NO]; // bottom left (type3 image)
    [self.button4 setUserInteractionEnabled:NO]; // botton right (type4 image)
    
    AudioManager *audioManager = [AudioManager sharedManager]; // audio effects need to be used so it all
    
    if (sender.tag == correct) { // sender.tag checks the correct variable with the button pressed and if it correct (which is done below in setHighest or setLightest) by seeing if it is correct, so if button2 (type2 image) is pressed and it is the heaviest weight, then correct = 2. Then the score updates
        
        score += correctAnswer; // the correct answer (which equal to 10 points) is then added to the score.
        chainCount++; // add one to chainCount, so its keeping track of the number of correct answers the user has given
        
        if (chainCount == chainRange) { // So when the user gets 3/4/5 correct answers in a row and its compared with ChainRange, then the Chain animation is played and change count is reset
            chainCount = 0; // reset the chainCount
            score += chainBonus; // Amount set by the ChainBonus is then added on to the score, dependent on teh fficulty the amunt added on.
            [self chainAnime]; // plays the chain animation
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) { // Tells the app to play the correct sound effect if the user selects the right answer
                audioManager.effect1 = [AudioManager loadFile:@"correct" withType:@"mp3"];
                [audioManager.effect1 play];
            }
        }
        else {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) { // the chain sound effect if the user gets 3/4/5 answers right in the row
                audioManager.effect3 = [AudioManager loadFile:@"chain" withType:@"mp3"];
                [audioManager.effect3 play];
            }
        }
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", score]; //the score label is updated with the score during the game.
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; // storage of the score within the dictionary
        NSString *key = [NSString stringWithFormat:@"weightScore%d%d", stage, diff];
        int temp = [prefs integerForKey:key];
        
        if (score > temp) { // checks whether the score is greater then the score gained in the game
            self.bestLabel.text = [NSString stringWithFormat:@"%d", score]; // if the score is a best score, then its updated and shown here within the game
        }
        [self right:sender.tag]; // correct answer, the green right (tick) animation
    }
    else { // if the user selected the wrong image this is done
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"audio"]) { //incorrect sound effect played when the user gets a question wrong
            audioManager.effect2 = [AudioManager loadFile:@"incorrect" withType:@"mp3"];
            [audioManager.effect2 play];
        }
        
        score -= wrongAnswer; // takes points off the user for an incorrect asnwer
        chainCount = 0; // reset the chainCount so the user has build up correct answers again to activate the chain bonus
        
        self.scoreLabel.text = [NSString stringWithFormat:@"%d", score];// score label is updataed, so user sees the score visually
        [self wrong:sender.tag]; // wrong cross aniamtion is called
    }
    [self performSelector:@selector(scaleIn) withObject:nil afterDelay:1.3f]; // bring the next set of images with the use of the scaleIn method
}

- (void)chainAnime // animation of the chain
{
    self.chainLabel.text = [NSString stringWithFormat:@"+ %d", chainBonus]; // When the user activates the chain, the + goes from the bottom of the screen to the top as well as the ChainBonus number value (dependent on the level) usually 10
    self.chainLabel.center = CGPointMake(900.0f, 520.0f); // specific coordinates where its located and will first occur
    self.chainLabel.alpha = 1.0f;
    
    [UIView animateWithDuration:1.25f
                     animations:^ {
                         self.chainLabel.alpha = 0.0f;
                         self.chainLabel.center = CGPointMake(900.0f, 100.0f); //animation telling it to move upwards and stop at that specific point
                     }
                     completion:nil];
}

- (void)setHighest // finds which image is the heaviest and sets it to a variable for future use.
{
    if (type1 > type2 && type1 > type3 && type1 > type4) { // Refers to the images weight, This means that when the button1 (or type1 image) is pressed, this is then checked to see if it is the heaviest weight if it is.  the variable 'correct' is set to = 1
        correct = 1; // this variable will then be used - (IBAction)answerPressed:(UIButton *)sender

    }
    else if (type2 > type3 && type2 > type4) { // if type1 is not the heaviest, then type2 image weight is then checked to see if it is heaviest
        correct = 2;
    }
    else if (type3 > type4) { // if type3 (button3) is greater then the type4 image, type3 image is the heaviest weight
        correct = 3;
    }
    else { //type 4 image is therefore the heaviest
        correct = 4;
    }
}

- (void)setLowest // is the opposite, find the image with lightest weight 
{
    if (type1 < type2 && type1 < type3 && type1 < type4) { // refers to lightest weight, bascially the reverse of the method above. So if type1 image is the lightest it
        correct = 1; // sets correct to equal to 1, 
    }
    else if (type2 < type3 && type2 < type4) { //type2 (button2) is the lightest 
        correct = 2;
    }
    else if (type3 < type4) { //type3 image is the lightest
        correct = 3;
    }
    else { // therefore type4 image must be the lightest
        correct = 4;
    }
}

- (void)right:(int)num //tick animation
{
    UIButton *button = (UIButton *)[self.view viewWithTag:num];
    
    if ([button isKindOfClass:[UIButton class]]) {
        
        [UIView animateWithDuration:0.25f
                         animations:^ {
                             button.transform = CGAffineTransformMakeScale(1.1f, 1.1f); // intially make the image(type1 etc) bigger and reduce its size again, so reinforce that the user has got the answer right.
                         }
                         completion:^(BOOL finished) {
                             
                             self.tick.center = CGPointMake(button.center.x + 95.0f, button.center.y - 95.0f); // refers to the coordinates of where the animation of the tick will take place, (top right corner of the image)
                             self.tick.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tick" ofType:@"png"]]; // tick image
                             self.tick.alpha = 1.0f;
                             
                             [UIView animateWithDuration:0.25f
                                                   delay:0.2f
                                                 options:UIViewAnimationCurveLinear
                                              animations:^ {
                                                  button.transform = CGAffineTransformMakeScale(1.0f, 1.0f); //refers to scale again going back to the correct size.
                                              }
                                              completion:nil];
                         }];
    }
}

- (void)wrong:(int)num // cross animation
{
    UIButton *button = (UIButton *)[self.view viewWithTag:num];
    
    if ([button isKindOfClass:[UIButton class]]) {
        
        [UIView animateWithDuration:0.1f
                         animations:^ {
                             button.center = CGPointMake(button.center.x + 10, button.center.y); // make the image shake from left to right but keep it at the same y coordinate, it goes right first
                         }
                         completion:^(BOOL finished) {
                             
                             self.tick.center = CGPointMake(button.center.x + 85.0f, button.center.y - 95.0f); // coordinates of the cross image
                             self.tick.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cross" ofType:@"png"]]; // uses the cross image lcoated in the artowkr folder
                             self.tick.alpha = 1.0f;
                             
                             [UIView animateWithDuration:0.1f
                                              animations:^ {
                                                  button.center = CGPointMake(button.center.x - 10, button.center.y); // shake the image left and same y coordinate centred
                                              }
                                              completion:^(BOOL finished) { // animate the changes, when the image that is wrong is pressed, it will shake right and left a few times quickly, done with the use of loops
                                                  
                                                  static int count;
                                                  count++;
                                                  
                                                  if (count < 3) {
                                                      [self wrong:num];
                                                  }
                                                  else {
                                                      count = 0;
                                                  }
                                              }];
                         }];
    }
}

#pragma mark - IBActions

- (IBAction)pausePressed:(UIButton *)sender //the pause button is pressed
{
    AudioManager *audioManager = [AudioManager sharedManager]; 
    
    if (sender.tag == 1) {
        [self pauseGame]; // Calls the pauseGame method, that suspend the games progress, timer etc. The music however still plays
    }
    else { // when the pause button is not pressed then it resumes normal oepration, timer/ alrm sound
        self.pauseScreen.hidden = YES; // pause screen hides
        self.gameTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(countDown:) userInfo:nil repeats:YES]; // start the timer with it couting down
        
        if (time <= 10) { // when the timer reaches less then an equal to 10 seconds, the alarm sound will start to play and remind user the only have 10 seconds left
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            
            if ([prefs boolForKey:@"audio"]) {
                audioManager.effect4 = [AudioManager loadFile:@"Alarm" withType:@"mp3"]; // find the audio file Alarm.mp3
                [audioManager.effect4 play]; // play the alarm music
            }
        }
    }
}

- (void)pauseGame // the method used when game is paused, tells timer to stop, and also the sound effect for the alarm
{
    if ([self.gameTimer isValid]) {
        [self.gameTimer invalidate];
        self.gameTimer = nil;
        
        if (time <= 10) {  // stop alarm effects, if game is paused
            AudioManager *audioManager = [AudioManager sharedManager]; 
            [audioManager.effect4 stop];
      

        }
    }
    
    self.pauseScreen.hidden = NO; //shows the pause menu box meanu and fade the background
}

- (IBAction)toggleSoundPressed:(id)sender // refers to the button in xib file, the view. Meaning the sound button image in the pause menu screen if this has been presssed the following happens.
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    AudioManager *audioManager = [AudioManager sharedManager];
    
    if ([prefs boolForKey:@"audio"]) { // offs the sound for the app if the button is pressed
        [prefs setBool:NO forKey:@"audio"]; // boolean set to NO
        
        [audioManager.audio stop]; // stops the music when pressed
        
        [self.toggleButton setImage:[UIImage imageNamed:@"soundOff.png"] forState:normal]; // shows the music off image when the button is pressed
    }
    else {
        [prefs setBool:YES forKey:@"audio"]; // plays the music again when pressed , boolean value is set to YES
        
        audioManager.audio = [AudioManager loadFile:@"loop" withType:@"mp3"];
        audioManager.audio.numberOfLoops = -1;
        [audioManager.audio play]; // plays music and loops it
        
        [self.toggleButton setImage:[UIImage imageNamed:@"soundOn.png"] forState:normal]; // shows the music on image when the button is pressed again
    }
    [prefs synchronize];
}

- (IBAction)replayPressed:(id)sender // if the replay button in the view (xib) is pressed, the user then restarts the game from the begginning
{
    [self difficulty:diff];
    chainCount = 0; //chain account set to zero
    
    score = 0; // reset to zero
    self.scoreLabel.text = @"0";
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"weightScore%d%d", stage, diff];
    holder = [prefs integerForKey:key];
    
    self.timerLabel.text = [NSString stringWithFormat:@"%d", time]; // font colour size etc is reset back to normal
    self.timerLabel.textColor = [UIColor blackColor];
    self.timerLabel.font = [self.timerLabel.font fontWithSize:37];
    
    self.reviewScreen.hidden = YES; // Hides the review screen
    
    [self prepareLevel]; // call up the method that prepares the level again
    [self performSelector:@selector(startGame) withObject:nil afterDelay:0.5f]; // starts the game back up again from the beginning
}

- (IBAction)homePressed:(id)sender // if the home button is pressed in the view (xib), the X image (the quit button basicaly).  then the user is taken back to previous Weight menu screen
{
   [[NSNotificationCenter defaultCenter] removeObserver:self]; //remove observer as its no longer needed
    
    [self.gameTimer invalidate]; // stops and removes the timer
    self.gameTimer = nil;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults]; //storage of the score
    NSString *key = [NSString stringWithFormat:@"weightScore%d%d", stage, diff]; 
    int temp = [prefs integerForKey:key];
    
    if (score > temp) { // checks whether this temp score is greater then the score and the score is then set accordingly
        [prefs setInteger:score forKey:key];
        [prefs synchronize];
    }
    
    AudioManager *audioManager = [AudioManager sharedManager]; // Stops the music and effects when home button is pressed
    [audioManager.audio stop];
    [audioManager.effect1 stop];
    [audioManager.effect2 stop];
    [audioManager.effect3 stop];
    [audioManager.effect4 stop];
    
    [self dismissViewControllerAnimated:YES completion:nil]; // animate it to go to the next screen
}

@end
