//
//  CustomClearView.m
//  InstaThi
//
//  Created by Swati Pareek on 12/6/12.
//  Copyright (c) 2012 Rocky Pareek. All rights reserved.
//

#import "CustomClearView.h"

@implementation CustomClearView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
