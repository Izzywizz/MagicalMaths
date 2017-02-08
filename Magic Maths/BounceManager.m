//
//  BounceManager.m
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "BounceManager.h"

@implementation BounceManager

+ (BounceManager *)sharedManger // class method
{
    static BounceManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BounceManager alloc] init];
    });
    
    return instance;
}

@end
