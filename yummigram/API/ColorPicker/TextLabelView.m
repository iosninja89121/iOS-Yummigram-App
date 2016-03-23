//
//  TextLabelView.m
//  InstaThi
//
//  Created by Swati Pareek on 12/13/12.
//  Copyright (c) 2012 Rocky Pareek. All rights reserved.
//

#import "TextLabelView.h"

@implementation TextLabelView

@synthesize strFontStyle,strText,fontSize,myFrameRect,maximumLabelSize,actualRect,borderWidth,borderShow,fontColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        

    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    maximumLabelSize = CGSizeMake(600,600);
    expectedLabelSize = [strText sizeWithFont:[UIFont fontWithName:strFontStyle size:fontSize]                     
                            constrainedToSize:maximumLabelSize 
                                lineBreakMode:UILineBreakModeMiddleTruncation];
    
    //    actualRect=CGRectMake((rect.size.width / 2) - (expectedLabelSize.width / 2),
    //                          (rect.size.height / 2) - (expectedLabelSize.height / 2),
    //                          myFrameRect.size.width ,
    //                          myFrameRect.size.height );
    
    
    actualRect= CGRectMake(0,0,
                           rect.size.width,
                           rect.size.height);
    
    [fontColor set];
    
    
    [strText drawInRect:CGRectIntegral(actualRect) withFont:[UIFont fontWithName:strFontStyle size:fontSize] lineBreakMode:UILineBreakModeMiddleTruncation alignment:UITextAlignmentLeft];
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGMutablePathRef squarePath = CGPathCreateMutable();
    CGPathMoveToPoint(squarePath, NULL, self.bounds.origin.x, self.bounds.origin.y);
    CGPathAddLineToPoint(squarePath, NULL,self.bounds.origin.x , CGRectGetHeight(actualRect));
    CGPathAddLineToPoint(squarePath, NULL, CGRectGetWidth(actualRect),CGRectGetHeight(actualRect));
    CGPathAddLineToPoint(squarePath, NULL, CGRectGetWidth(actualRect),self.bounds.origin.y );
    CGContextAddPath(context, squarePath);
    
    CGContextClosePath(context);
    CGFloat yellowColor[4] = {1.0f, 1.0f, 0.0f, 1.0f};
    CGContextSetLineWidth(context, borderWidth);
    CGContextSetStrokeColor(context, yellowColor);
    CGContextSetShadow(context, CGSizeMake(3.0f, 3.0f), borderWidth);
    CGContextStrokePath(context);
    CGContextAddPath(context, squarePath);
}


@end
