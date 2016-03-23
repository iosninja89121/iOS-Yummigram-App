//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"

@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, strong) NSString *strCurrent;
@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize delegate;
@synthesize nSelIndex;
@synthesize animationDirection;
@synthesize strCurrent;

- (id)showDropDown:(UIButton *)b data:(NSArray *)arr mode:(NSString *)direction current:(NSString *)strCur{
    btnSender = b;
    animationDirection = direction;
    CGFloat height = 40 * arr.count;
    self.table = (UITableView *)[super init];
    strCurrent = strCur;
    
    if (self) {
        // Initialization code
        CGRect btn = b.superview.frame;
        
        
        self.list = [NSArray arrayWithArray:arr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
        }
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.backgroundColor = [UIColor clearColor];
        table.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_drop_board"]];
        table.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.separatorColor = [UIColor clearColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];

        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y- height, btn.size.width, height);
        } else if([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, height);
        }
        
        table.frame = CGRectMake(0, 0, btn.size.width, height);
        
        [UIView commitAnimations];
        [b.superview.superview addSubview:self];
        [self addSubview:table];
    }
    
    nSelIndex = -1;
    return self;
}

-(void)hideDropDown:(UIButton *)b {
    CGRect btn = b.superview.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    if ([animationDirection isEqualToString:@"up"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
    }else if ([animationDirection isEqualToString:@"down"]) {
        self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
    }
    table.frame = CGRectMake(0, 0, btn.size.width, 0);
    [UIView commitAnimations];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
    }
    
//    cell.backgroundColor = [UIColor colorWithRed:70.0f/255.0f green:163.0f/255.0f blue:182.0f/255.0f alpha:1];
    cell.backgroundColor = [UIColor clearColor];
    
    if([[self.list objectAtIndex:indexPath.row] isEqualToString:strCurrent]){
        cell.textLabel.textColor = [UIColor whiteColor];
    }else{
        cell.textLabel.textColor = [UIColor colorWithRed:178.0f/255.0f green:218.0f/255.0f blue:224.0f/255.0f alpha:1];
    }
    
//    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [self.list objectAtIndex:indexPath.row];
    
    UIImageView * v = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop_button_closed"]];
    cell.selectedBackgroundView = v;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
//    [btnSender setTitle:c.textLabel.text forState:UIControlStateNormal];
//    
//    for (UIView *subview in btnSender.subviews) {
//        if ([subview isKindOfClass:[UIImageView class]]) {
//            [subview removeFromSuperview];
//        }
//    }
//    imgView.image = c.imageView.image;
//    imgView = [[UIImageView alloc] initWithImage:c.imageView.image];
//    imgView.frame = CGRectMake(5, 5, 25, 25);
//    [btnSender addSubview:imgView];
    nSelIndex = indexPath.row;
    [self myDelegate];
}

- (void) myDelegate{
    [self.delegate niDropDownDelegateMethod:self];
}

-(void)dealloc {
//    [super dealloc];
//    [table release];
//    [self release];
}

@end
