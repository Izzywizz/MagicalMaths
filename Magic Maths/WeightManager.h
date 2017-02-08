//
//  WeightManager.h
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 WeightManager is used to store which level and difficulty that has been selected from the menu. Get a correct answer and it knows how many points to award and how quickly the time should run down for each level. Created as an object (weightManager) so that its given "state" can be retrieved or changed at anytime. So I can extned the app, you can expand/change the manager and it doesn't effect the controller at all.
 */

@interface WeightManager : NSObject

@property (nonatomic) int stage;
@property (nonatomic) int difficulty;

+ (WeightManager *)sharedManger;

@end
