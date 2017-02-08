//
//  WeightManager.m
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "WeightManager.h"



@implementation WeightManager

+ (WeightManager *)sharedManger // class method
{
    static WeightManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[WeightManager alloc] init];
    });
    
    return instance;
}

@end
