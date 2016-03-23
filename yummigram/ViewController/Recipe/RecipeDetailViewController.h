//
//  RecipeDetailViewController.h
//  yummigram
//
//  Created by User on 4/2/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIAttributedLabel.h>

@interface RecipeDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, NIAttributedLabelDelegate>
@property (strong) WallImage *wallImage;
@end
