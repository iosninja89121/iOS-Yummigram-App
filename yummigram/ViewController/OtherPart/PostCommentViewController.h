//
//  PostCommentViewController.h
//  yummigram
//
//  Created by User on 5/10/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIAttributedLabel.h>

@interface PostCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, NIAttributedLabelDelegate>
@property (strong) WallImage *wallImage;



@end
