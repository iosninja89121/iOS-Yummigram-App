//
//  ProfileViewController.h
//  yummigram
//
//  Created by User on 5/11/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIAttributedLabel.h>

@interface ProfileViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, NIAttributedLabelDelegate>
@property (nonatomic, retain) NSString *strUserObjID;
@end
