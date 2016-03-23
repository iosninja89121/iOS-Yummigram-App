//
//  TextLabelView.h
//  InstaThi
//
//  Created by Swati Pareek on 12/13/12.
//  Copyright (c) 2012 Rocky Pareek. All rights reserved.
//

#import "CustomClearView.h"
#import <QuartzCore/QuartzCore.h>

@interface TextLabelView : CustomClearView{

    NSString *strFontStyle,*strText;
    float fontSize,borderWidth;
    CGSize maximumLabelSize; 
    CGSize expectedLabelSize;
    CGRect actualRect,myFrameRect;
    UIColor *fontColor;
    BOOL borderShow;
}

@property(nonatomic,strong)    NSString *strFontStyle,*strText;
@property(nonatomic,assign)    float fontSize,borderWidth;
@property(nonatomic,assign)    CGRect actualRect,myFrameRect;
@property(nonatomic,assign)    CGSize maximumLabelSize; 
@property(nonatomic,assign)    BOOL borderShow;
@property(nonatomic,strong)    UIColor *fontColor;

@end
