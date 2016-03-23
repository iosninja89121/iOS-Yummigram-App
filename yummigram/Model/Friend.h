//
//  Friend.h
//  yummigram
//
//  Created by User on 4/17/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Friend : NSObject

@property (strong, nonatomic) NSString *strName;
@property (strong, nonatomic) NSMutableArray *arrPhoneNumber;
@property (strong, nonatomic) NSMutableArray *arrPhoneLabel;
@property (strong, nonatomic) NSMutableArray *arrEmailAddress;
@property (strong, nonatomic) NSMutableArray *arrEmailLabel;
@end
