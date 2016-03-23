//
//  NSOperationQueue+SharedQueue.h
//  yummigram
//
//  Created by User on 5/6/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (SharedQueue)
+ (NSOperationQueue *) pffileOperationQueue;
@end
