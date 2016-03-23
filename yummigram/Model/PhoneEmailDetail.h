//
//  PhoneEmailDetail.h
//  yummigram
//
//  Created by User on 4/18/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PhoneEmailDetail : NSObject
@property (strong, nonatomic) NSString *strLabel;
@property (strong, nonatomic) NSString *strValue;
@property (nonatomic) PhoneEmailMode category;
@end
