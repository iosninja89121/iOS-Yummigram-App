//
//  NewChatViewController.h
//  yummigram
//
//  Created by User on 5/12/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (nonatomic, strong) NSString *strOtherUserObjId;
@end
