//
//  AudioManager.h
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioManager : NSObject

/*
 AudioManager is used in the playback of the audio effects. Created as an object so that its given "state" can be retrieved or changed at anytime. */

// effect 1 correct answer sound
// effect 2 incorrect answer sound
// effect 3 chain bonus song
// effect 4 alarm song

@property (nonatomic, strong) AVAudioPlayer *audio;
@property (nonatomic, strong) AVAudioPlayer *effect1;
@property (nonatomic, strong) AVAudioPlayer *effect2;
@property (nonatomic, strong) AVAudioPlayer *effect3;
@property (nonatomic, strong) AVAudioPlayer *effect4;

+ (AudioManager *)sharedManager; // class method
+ (AVAudioPlayer *)loadFile:(NSString *)filename withType:(NSString *)type;

//Load the filename with type (mp3) etc

@end
