//
//  WeightDictionary.m
//  Magic Maths
//
//  Created by Izzy ali on 08/01/2013.
//  Copyright (c) 2013 Izzy Ali. All rights reserved.
//

#import "WeightDictionary.h"

@implementation WeightDictionary

/*
 
So our dictionary would look like this for example:
with the dynamic stage, diffculty
 
 @"weightScore11" : @180,
 @"weightScore12" : @85,
 @"weightScore13" : @170,
 @"weightScore14" : @20

 */

- (id)weightDict:(id)key
{
    NSDictionary *dict = @ {
      
        @"key1" : @1,
        @"key2" : @2,
        @"key3" : @3,
        @"key4" : @4,
        @"key5" : @5,
        @"key6" : @6,
        @"key7" : @7,
        @"key8" : @8,
        @"key9" : @9,
        @"key10" : @10,
        @"key11" : @11,
        @"key12" : @12,
        @"key13" : @13,
        @"key14" : @14,
        @"key15" : @15,
        @"key16" : @16,
        @"key17" : @17,
        @"key18" : @18,
        @"key19" : @19,
        @"key20" : @20,
    };
    
    NSNumber *value = [dict objectForKey:key];
    return value;
}


@end
