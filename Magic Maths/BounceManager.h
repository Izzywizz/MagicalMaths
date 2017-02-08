//
//  BounceManager.h
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BounceManager : NSObject
/*
 BounceManger is used to store which level and difficulty that has been selected from the menu. Created as an object (bounceManager) so that its given "state" can be retrieved or changed at anytime. Able to expand/change the manager and it doesn't effect the controller at all.
 */
@property (nonatomic) int stage;
@property (nonatomic) int difficulty;

+ (BounceManager *)sharedManger;

@end
