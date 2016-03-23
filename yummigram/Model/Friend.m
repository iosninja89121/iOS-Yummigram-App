//
//  Friend.m
//  yummigram
//
//  Created by User on 4/17/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import "Friend.h"

@implementation Friend

@synthesize strName;
@synthesize arrPhoneNumber;
@synthesize arrPhoneLabel;
@synthesize arrEmailAddress;
@synthesize arrEmailLabel;

- (id)init
{
    self = [super init];
    if(self)
    {
        strName = @"";
        arrPhoneNumber  = [[NSMutableArray alloc] init];
        arrPhoneLabel   = [[NSMutableArray alloc] init];
        arrEmailAddress = [[NSMutableArray alloc] init];
        arrEmailLabel   = [[NSMutableArray alloc] init];
    }
    
    return self;
}
@end
