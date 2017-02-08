//
//  AudioManager.m
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "AudioManager.h"

@implementation AudioManager

+ (AudioManager *)sharedManager //class method
{
    static AudioManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AudioManager alloc] init];
    });
    
    return instance;
}

+ (AVAudioPlayer *)loadFile:(NSString *)filename withType:(NSString *)type // class method
{
    NSURL *url = [[NSBundle mainBundle]URLForResource:filename withExtension:type];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    
    [player prepareToPlay];
    return player;
}

@end
