//
//  TagViewController.h
//  yummigram
//
//  Created by User on 6/15/15.
//  Copyright (c) 2015 Philip. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NIAttributedLabel.h>

@interface TagViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,NIAttributedLabelDelegate>
@property (nonatomic, strong) NSString *strTag;
@end
