//
//  NSOperationQueue+SharedQueue.m
//  yummigram
//
//  Created by User on 5/6/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "NSOperationQueue+SharedQueue.h"

@implementation NSOperationQueue (SharedQueue)

+ (NSOperationQueue *) pffileOperationQueue {
    static NSOperationQueue *pffileQueue = nil;
    if (pffileQueue == nil) {
        pffileQueue = [[NSOperationQueue alloc] init];
        [pffileQueue setName:@"com.rwtutorial.pffilequeue"];
    }
    return pffileQueue;
}

@end
